"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { Check, Loader2, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { toastApiError } from "@/lib/api/toast-api-error";
import { getModelDisplayParts } from "@/lib/model-display";
import {
  aiModelApi,
  apiConfigApi,
  MODEL_TYPE_OPTIONS,
  MODEL_TYPE_LABELS,
  type ApiConfig,
  type RemoteModel,
} from "@/lib/api/ai-model";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectGroup,
  SelectItem,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ModelVendorIcon } from "@/components/dashboard/model-vendor-icon";
import {
  formatSemanticLabel,
  MODEL_PROTOCOL_LABELS,
} from "./model-config-support";

export interface FetchRemoteModelsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  apiConfig: ApiConfig | null;
  /** 已添加到该 API 配置下的模型 code 集合，用于标记「已添加」并禁止重复导入 */
  existingModelCodes?: Set<string>;
  onImported: () => void;
}

export function FetchRemoteModelsDialog({
  open,
  onOpenChange,
  apiConfig,
  existingModelCodes,
  onImported,
}: FetchRemoteModelsDialogProps) {
  const [loading, setLoading] = useState(false);
  const [models, setModels] = useState<RemoteModel[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [keyword, setKeyword] = useState("");
  const [importing, setImporting] = useState(false);
  const [defaultModelType, setDefaultModelType] = useState<string>("1");

  const existingCodes = existingModelCodes ?? new Set<string>();

  // 是否存在无法自动识别类型的模型，需要用户手动指定默认类型
  const hasUnknownModelTypes = models.some(model => model.modelType == null);

  const load = useCallback(() => {
    if (!apiConfig) return;
    setLoading(true);
    setError(null);
    apiConfigApi
      .remoteModels(apiConfig.id)
      .then(data => setModels(data))
      .catch(err => {
        console.error("拉取远程模型失败:", err);
        setError(err instanceof Error ? err.message : "获取模型列表失败");
      })
      .finally(() => setLoading(false));
  }, [apiConfig]);

  useEffect(() => {
    if (open) {
      setModels([]);
      setSelected(new Set());
      setKeyword("");
      setError(null);
      setImporting(false);
      setDefaultModelType("1");
      load();
    }
  }, [open, load]);

  const filtered = useMemo(() => {
    const kw = keyword.trim().toLowerCase();
    if (!kw) return models;
    return models.filter(model =>
      model.id.toLowerCase().includes(kw)
      || (model.displayName || "").toLowerCase().includes(kw)
      || (model.ownedBy || "").toLowerCase().includes(kw)
    );
  }, [models, keyword]);

  const selectable = filtered.filter(model => !existingCodes.has(model.id));
  const allVisibleSelected = selectable.length > 0 && selectable.every(model => selected.has(model.id));

  const toggleAll = () => {
    setSelected(prev => {
      const next = new Set(prev);
      if (allVisibleSelected) {
        selectable.forEach(model => next.delete(model.id));
      } else {
        selectable.forEach(model => next.add(model.id));
      }
      return next;
    });
  };

  const toggle = (id: string) => {
    setSelected(prev => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const handleImport = async () => {
    if (!apiConfig || selected.size === 0) return;
    setImporting(true);
    try {
      // 匹配内置能力预设，自动补全描述、多模态、推理、上下文等能力
      const presets = await aiModelApi.presets();
      const targets = models.filter(model => selected.has(model.id));
      let imported = 0;
      let failed = 0;
      for (const model of targets) {
        const preset = model.capabilityPresetCode
          ? presets.find(item => item.code === model.capabilityPresetCode)
          : undefined;
        try {
          await aiModelApi.create({
            name: model.displayName || model.id,
            code: model.id,
            capabilityPresetCode: model.capabilityPresetCode || undefined,
            modelProtocol: model.modelProtocol || preset?.modelProtocol || undefined,
            modelType: model.modelType ?? Number(defaultModelType),
            description: preset?.description,
            supportVision: preset?.multimodalInputTypes?.includes("image") ?? false,
            multimodalInputTypes: preset?.multimodalInputTypes ?? [],
            multimodalInputTransports: preset?.multimodalInputTransports ?? {},
            supportReasoning: preset?.supportReasoning ?? false,
            reasoningEffortLevels: preset?.reasoningEffortLevels ?? [],
            contextWindow: preset?.contextWindow,
            apiConfigId: apiConfig.id,
          });
          imported += 1;
        } catch (err) {
          console.error(`导入模型失败: ${model.id}`, err);
          failed += 1;
        }
      }
      if (imported > 0) {
        toast.success(`已导入 ${imported} 个模型${failed > 0 ? `，${failed} 个失败` : ""}`);
        onImported();
        onOpenChange(false);
      } else {
        toast.error("导入失败", { description: "模型可能已存在，或后端返回错误" });
      }
    } catch (err) {
      toastApiError(err, "获取模型能力预设失败");
    } finally {
      setImporting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl max-h-[calc(100vh-2rem)] flex flex-col overflow-hidden">
        <DialogHeader className="shrink-0">
          <DialogTitle>获取可用模型</DialogTitle>
          <DialogDescription>
            {apiConfig ? `从「${apiConfig.name}」网关获取可用模型，勾选后批量导入。` : "正在准备…"}
          </DialogDescription>
        </DialogHeader>

        <div className="flex items-center gap-2 shrink-0">
          <div className="relative flex-1">
            <Search className="absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={keyword}
              onChange={e => setKeyword(e.target.value)}
              placeholder="搜索模型 ID / 名称 / 提供方"
              className="pl-8 text-sm"
            />
          </div>
          <Button variant="outline" size="sm" onClick={load} disabled={loading || !apiConfig}>
            <RefreshCw className={cn("h-3.5 w-3.5", loading && "animate-spin")} />
            刷新
          </Button>
        </div>

        {hasUnknownModelTypes && (
          <div className="flex items-center gap-2 shrink-0 pt-2">
            <span className="text-xs text-muted-foreground">默认模型类型</span>
            <Select value={defaultModelType} onValueChange={v => setDefaultModelType(String(v))}>
              <SelectTrigger className="w-[148px] text-xs h-8">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  {MODEL_TYPE_OPTIONS.map(opt => (
                    <SelectItem key={opt.value} value={String(opt.value)} className="text-xs">
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectGroup>
              </SelectContent>
            </Select>
            <span className="text-[10px] text-muted-foreground">仅未识别类型的模型使用此默认类型</span>
          </div>
        )}

        {!loading && !error && models.length > 0 && (
          <div className="flex items-center justify-between shrink-0 pt-2">
            <button
              type="button"
              onClick={toggleAll}
              disabled={selectable.length === 0}
              className="text-xs text-muted-foreground hover:text-foreground transition-colors disabled:cursor-not-allowed disabled:opacity-40"
            >
              {allVisibleSelected ? "取消全选" : "全选可添加"}
            </button>
            <span className="text-[10px] text-muted-foreground">
              共 {filtered.length} 个模型，已选 {selected.size} 个
            </span>
          </div>
        )}

        <div className="mt-3 min-h-0 flex-1 overflow-y-auto rounded-xl border border-border/40">
          {loading ? (
            <div className="flex items-center justify-center gap-2 py-10 text-xs text-muted-foreground">
              <Loader2 className="h-4 w-4 animate-spin" />
              正在从网关拉取模型…
            </div>
          ) : error ? (
            <div className="py-8 text-center space-y-3">
              <p className="text-sm text-destructive">{error}</p>
              <Button variant="outline" size="sm" onClick={load}>重试</Button>
            </div>
          ) : models.length === 0 ? (
            <div className="py-10 text-center text-xs text-muted-foreground">未获取到可用模型</div>
          ) : filtered.length === 0 ? (
            <div className="py-10 text-center text-xs text-muted-foreground">没有匹配「{keyword}」的模型</div>
          ) : (
            <div className="divide-y divide-border/30">
              {filtered.map(model => {
                const checked = selected.has(model.id);
                const alreadyExists = existingCodes.has(model.id);
                const isNewApi = (model.providerPlatform || "").toLowerCase().includes("newapi")
                  || (model.providerPlatform || "").includes("云揽川");
                const modelDisplay = getModelDisplayParts({
                  name: model.displayName,
                  code: model.id,
                });

                return (
                  <button
                    key={model.id}
                    type="button"
                    onClick={() => !alreadyExists && toggle(model.id)}
                    disabled={alreadyExists}
                    className={cn(
                      "flex w-full items-start gap-3 px-3 py-2.5 text-left transition-colors hover:bg-white/5",
                      alreadyExists && "cursor-not-allowed opacity-50"
                    )}
                  >
                    <span
                      className={cn(
                        "mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded border transition-colors",
                        alreadyExists
                          ? "border-border/60 bg-muted"
                          : checked
                            ? "border-primary bg-primary text-white"
                            : "border-border/60 bg-muted/20"
                      )}
                    >
                      {checked && !alreadyExists && <Check className="h-3 w-3" />}
                    </span>
                    <span className="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-muted/60">
                      <ModelVendorIcon
                        source={{
                          name: model.displayName,
                          code: model.id,
                          platform: model.providerPlatform,
                          capabilityPresetCode: model.capabilityPresetCode,
                        }}
                        className="size-4"
                      />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="flex items-center gap-2 flex-wrap">
                        <span className="text-sm font-medium break-words">{modelDisplay.name}</span>
                        {modelDisplay.code && (
                          <span className="font-mono text-[10px] text-muted-foreground break-all">
                            {modelDisplay.code}
                          </span>
                        )}
                      </span>
                      <span className="mt-1 flex items-center gap-1.5 flex-wrap">
                        {model.modelType != null ? (
                          <span className="rounded bg-violet-500/10 px-1 py-0.5 text-[10px] text-violet-600">
                            {MODEL_TYPE_LABELS[model.modelType] || `类型 ${model.modelType}`}
                          </span>
                        ) : null}
                        {model.modelProtocol && model.modelProtocol !== "generic" ? (
                          <span className="rounded bg-sky-500/10 px-1 py-0.5 text-[10px] text-sky-500">
                            {formatSemanticLabel(model.modelProtocol, MODEL_PROTOCOL_LABELS)}
                          </span>
                        ) : null}
                        {model.capabilityPresetCode ? (
                          <span className="rounded bg-amber-500/10 px-1 py-0.5 text-[10px] text-amber-600">
                            能力：{model.capabilityPresetCode}
                          </span>
                        ) : null}
                        {model.ownedBy ? (
                          <span className="rounded bg-muted/50 px-1 py-0.5 text-[10px] text-muted-foreground">
                            {model.ownedBy}
                          </span>
                        ) : null}
                        {isNewApi ? (
                          <span className="rounded bg-emerald-500/10 px-1 py-0.5 text-[10px] text-emerald-500">
                            云揽川
                          </span>
                        ) : null}
                        {model.inferredMetadata ? (
                          <span className="text-[10px] text-muted-foreground/50">自动推断</span>
                        ) : null}
                      </span>
                    </span>
                    {alreadyExists && (
                      <span className="shrink-0 rounded bg-muted px-1.5 py-0.5 text-[10px] text-muted-foreground">
                        已添加
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          )}
        </div>

        <DialogFooter className="shrink-0">
          <DialogClose render={<Button variant="outline" size="sm" />}>取消</DialogClose>
          <Button
            size="sm"
            onClick={handleImport}
            disabled={importing || loading || selected.size === 0}
          >
            {importing && <Loader2 className="h-3.5 w-3.5 animate-spin mr-1.5" />}
            导入 {selected.size > 0 ? `已选 ${selected.size} 个` : ""}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
