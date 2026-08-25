"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { Check, Loader2, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { toastApiError } from "@/lib/api/toast-api-error";
import {
  aiModelApi,
  apiConfigApi,
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
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ModelVendorIcon } from "@/components/dashboard/model-vendor-icon";
import { formatSemanticLabel, MODEL_PROTOCOL_LABELS } from "./model-config-support";

export interface FetchRemoteModelsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  apiConfig: ApiConfig | null;
  onImported: () => void;
}

export function FetchRemoteModelsDialog({
  open,
  onOpenChange,
  apiConfig,
  onImported,
}: FetchRemoteModelsDialogProps) {
  const [loading, setLoading] = useState(false);
  const [models, setModels] = useState<RemoteModel[]>([]);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [keyword, setKeyword] = useState("");
  const [importing, setImporting] = useState(false);

  const load = useCallback(() => {
    if (!apiConfig) return;
    setLoading(true);
    apiConfigApi
      .remoteModels(apiConfig.id)
      .then(data => setModels(data))
      .catch(err => {
        console.error("拉取远程模型失败:", err);
        toastApiError(err, "拉取远程模型失败");
      })
      .finally(() => setLoading(false));
  }, [apiConfig]);

  useEffect(() => {
    if (open) {
      setModels([]);
      setSelected(new Set());
      setKeyword("");
      setImporting(false);
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

  const allVisibleSelected = filtered.length > 0 && filtered.every(model => selected.has(model.id));

  const toggleAll = () => {
    setSelected(prev => {
      const next = new Set(prev);
      if (allVisibleSelected) {
        filtered.forEach(model => next.delete(model.id));
      } else {
        filtered.forEach(model => next.add(model.id));
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
      const targets = models.filter(model => selected.has(model.id));
      let imported = 0;
      let failed = 0;
      for (const model of targets) {
        try {
          await aiModelApi.create({
            name: model.displayName || model.id,
            code: model.id,
            capabilityPresetCode: model.capabilityPresetCode || undefined,
            modelProtocol: model.modelProtocol || undefined,
            modelType: model.modelType || 1,
            maxConcurrency: model.modelType === 3 ? 1 : 5,
            defaultModel: false,
            supportVision: false,
            multimodalInputTypes: [],
            multimodalInputTransports: {},
            supportReasoning: false,
            reasoningEffortLevels: [],
            contextWindow: 0,
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
    } finally {
      setImporting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-2xl max-h-[calc(100vh-2rem)] flex flex-col overflow-hidden">
        <DialogHeader className="shrink-0">
          <DialogTitle>拉取远程模型</DialogTitle>
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
          <Button
            variant="ghost"
            size="sm"
            onClick={toggleAll}
            disabled={filtered.length === 0 || loading}
          >
            {allVisibleSelected ? "取消全选" : "全选"}
          </Button>
        </div>

        <div className="mt-3 min-h-0 flex-1 overflow-y-auto rounded-xl border border-border/40">
          {loading ? (
            <div className="flex items-center justify-center gap-2 py-10 text-xs text-muted-foreground">
              <Loader2 className="h-4 w-4 animate-spin" />
              正在从网关拉取模型…
            </div>
          ) : models.length === 0 ? (
            <div className="py-10 text-center text-xs text-muted-foreground">
              未获取到可用模型
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-10 text-center text-xs text-muted-foreground">
              没有匹配「{keyword}」的模型
            </div>
          ) : (
            <div className="divide-y divide-border/30">
              {filtered.map(model => {
                const checked = selected.has(model.id);
                const isNewApi = (model.providerPlatform || "").toLowerCase().includes("newapi")
                  || (model.providerPlatform || "").includes("云揽川");
                return (
                  <button
                    key={model.id}
                    type="button"
                    onClick={() => toggle(model.id)}
                    className="flex w-full items-start gap-3 px-3 py-2.5 text-left transition-colors hover:bg-white/5"
                  >
                    <span
                      className={cn(
                        "mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded border transition-colors",
                        checked
                          ? "border-primary bg-primary text-white"
                          : "border-border/60 bg-muted/20"
                      )}
                    >
                      {checked && <Check className="h-3 w-3" />}
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
                        <span className="text-sm font-medium break-words">
                          {model.displayName || model.id}
                        </span>
                        <span className="font-mono text-[10px] text-muted-foreground break-all">
                          {model.id}
                        </span>
                      </span>
                      <span className="mt-1 flex items-center gap-1.5 flex-wrap">
                        {model.modelType ? (
                          <span className="rounded bg-violet-500/10 px-1 py-0.5 text-[10px] text-violet-600">
                            {MODEL_TYPE_LABELS[model.modelType] || `类型 ${model.modelType}`}
                          </span>
                        ) : null}
                        {model.modelProtocol ? (
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
                          <span className="text-[10px] text-muted-foreground/50">
                            自动推断
                          </span>
                        ) : null}
                      </span>
                    </span>
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
