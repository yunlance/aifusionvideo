"use client";

import { useEffect, useRef, useState } from "react";
import { Eye, EyeOff, ExternalLink, Loader2, PlugZap } from "lucide-react";
import { AnimatePresence, motion } from "framer-motion";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { toastApiError } from "@/lib/api/toast-api-error";
import {
  apiConfigApi,
  PLATFORM_OPTIONS,
  PLATFORM_LABELS,
  type ApiConfig,
  type ApiConfigSaveReq,
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
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { ProviderVendorIcon } from "@/components/dashboard/model-vendor-icon";
import { getPlatformFields } from "../../_shared";
import { getProtocolOptionsForModelType } from "./model-config-support";
import { comfyUiWorkflowApi } from "@/lib/api/comfyui-workflow";

export interface ApiConfigDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  editingConfig: ApiConfig | null;
  onSaved: () => void;
}

export const PROXY_TYPE_OPTIONS = [
  { value: "none", label: "不使用代理", description: "直连模型服务" },
  { value: "socks5", label: "SOCKS5", description: "常见本地代理，如 127.0.0.1:7890" },
  { value: "http", label: "HTTP", description: "HTTP/HTTPS 出站代理" },
] as const;

export const UNSET_PROTOCOL_VALUE = "__unset_protocol__";

export function ApiConfigDialog({ open, onOpenChange, editingConfig, onSaved }: ApiConfigDialogProps) {
  const [saving, setSaving] = useState(false);
  const [testingConnection, setTestingConnection] = useState(false);
  const [form, setForm] = useState<ApiConfigSaveReq>({ name: "" });
  const [showSecrets, setShowSecrets] = useState<Record<string, boolean>>({});
  // 切换到 ComfyUI 前的表单快照，用于切回普通平台时还原协议/地址/代理等字段
  const previousFormRef = useRef<ApiConfigSaveReq | null>(null);

  useEffect(() => {
    if (open) {
      if (editingConfig) {
        setForm({
          id: editingConfig.id,
          name: editingConfig.name,
          platform: editingConfig.platform === "deepseek" ? "openai_compatible" : editingConfig.platform || "",
          textProtocol: editingConfig.textProtocol === "deepseek" ? "openai_compatible" : editingConfig.textProtocol || "",
          imageProtocol: editingConfig.imageProtocol || "",
          videoProtocol: editingConfig.videoProtocol || "",
          apiUrl: editingConfig.apiUrl || "",
          autoAppendV1Path: editingConfig.autoAppendV1Path ?? true,
          proxyType: editingConfig.proxyType || "none",
          proxyHost: editingConfig.proxyHost || "",
          proxyPort: editingConfig.proxyPort ?? undefined,
          proxyUsername: editingConfig.proxyUsername || "",
          proxyPassword: editingConfig.proxyPassword || "",
          // 编辑时不回显明文 Key，保存时留空表示不修改
          apiKey: "",
          appId: editingConfig.appId || "",
          appSecret: editingConfig.appSecret || "",
          status: editingConfig.status,
          remark: editingConfig.remark || "",
        });
      } else {
        // 新建默认：接入类型 云揽川；文本/图片/视频默认协议均为 云揽川 通用协议
        setForm({ name: "", platform: "newapi", textProtocol: "openai_compatible", imageProtocol: "newapi", videoProtocol: "newapi", apiUrl: "", autoAppendV1Path: true, proxyType: "none", proxyHost: "", proxyPort: undefined, proxyUsername: "", proxyPassword: "", apiKey: "", appId: "", appSecret: "", status: 1 });
      }
      setShowSecrets({});
      setTestingConnection(false);
      previousFormRef.current = null;
    }
  }, [open, editingConfig]);

  const updateField = <K extends keyof ApiConfigSaveReq>(key: K, value: ApiConfigSaveReq[K]) => {
    setForm(prev => ({ ...prev, [key]: value }));
  };

  const handleSave = async () => {
    if (!form.name.trim()) return;
    setSaving(true);
    try {
      const proxyEnabled = form.proxyType && form.proxyType !== "none";
      const payload: ApiConfigSaveReq = {
        ...form,
        proxyType: proxyEnabled ? form.proxyType : "none",
        proxyHost: proxyEnabled ? form.proxyHost?.trim() : "",
        proxyPort: proxyEnabled ? form.proxyPort : undefined,
        proxyUsername: proxyEnabled ? form.proxyUsername?.trim() : "",
        proxyPassword: proxyEnabled && form.proxyUsername?.trim() ? form.proxyPassword : "",
      };
      if (editingConfig) {
        await apiConfigApi.update(payload);
      } else {
        await apiConfigApi.create(payload);
      }
      onSaved();
      onOpenChange(false);
    } catch (err) {
      console.error("保存 API 配置失败:", err);
      toastApiError(err, "保存 API 配置失败");
    } finally {
      setSaving(false);
    }
  };

  const handleTestConnection = async () => {
    if (!editingConfig) return;
    setTestingConnection(true);
    try {
      const result = await comfyUiWorkflowApi.testConnection(editingConfig.id);
      toast.success("ComfyUI 连接成功", {
        description: `版本 ${result.version || "未知"}，Jobs API ${result.jobsApiSupported ? "可用" : "不可用"}`,
      });
    } catch (err) {
      console.error("检测 ComfyUI 连接失败:", err);
      toastApiError(err, "检测 ComfyUI 连接失败");
    } finally {
      setTestingConnection(false);
    }
  };

  const fields = getPlatformFields(form.platform || "");
  const proxyEnabled = form.proxyType && form.proxyType !== "none";
  const proxyInvalid = Boolean(proxyEnabled && (
    !form.proxyHost?.trim() || !form.proxyPort || form.proxyPort < 1 || form.proxyPort > 65535
    || (!!form.proxyPassword && !form.proxyUsername?.trim())
  ));
  const comfyUiInvalid = form.platform === "comfyui" && !form.apiUrl?.trim();

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl max-h-[calc(100vh-2rem)] flex flex-col overflow-hidden">
        <DialogHeader className="shrink-0">
          <DialogTitle>{editingConfig ? "编辑 API 配置" : "新建 API 配置"}</DialogTitle>
          <DialogDescription>配置连接与鉴权，并为文本、图片、视频分别设置默认请求协议；模型可按需覆盖。</DialogDescription>
        </DialogHeader>

        <div className="space-y-4 overflow-y-auto min-h-0 px-1 -mx-1">
          {/* 配置名称 */}
          <div className="space-y-1.5">
            <Label className="text-xs text-muted-foreground">配置名称</Label>
            <Input
              placeholder="例如：云揽川 网关 / 本地 ComfyUI"
              value={form.name}
              onChange={e => updateField("name", e.target.value)}
              className="text-sm"
            />
          </div>

          {/* 接入与鉴权类型 */}
          <div className="space-y-1.5">
            <Label className="text-xs text-muted-foreground">接入与鉴权类型</Label>
            <Select
              value={form.platform || "openai_compatible"}
              onValueChange={v => {
                const platform = String(v);
                if (platform === form.platform) return;
                setForm(prev => {
                  if (platform === "comfyui") {
                    // 切到 ComfyUI：先保存切换前的表单，再套用 ComfyUI 专属默认
                    previousFormRef.current = prev;
                    return {
                      ...prev,
                      platform,
                      textProtocol: "",
                      imageProtocol: "comfyui",
                      videoProtocol: "comfyui",
                      apiUrl: "http://localhost:8188",
                      autoAppendV1Path: false,
                    };
                  }
                  // 从 ComfyUI 切回普通平台：还原切换前的协议/地址/代理等字段
                  const snapshot = previousFormRef.current;
                  previousFormRef.current = null;
                  if (snapshot) {
                    return { ...snapshot, platform };
                  }
                  // 无快照（原配置就是 ComfyUI）：套用 云揽川 通用协议默认
                  return {
                    ...prev,
                    platform,
                    textProtocol: "openai_compatible",
                    imageProtocol: "newapi",
                    videoProtocol: "newapi",
                    apiUrl: "",
                    autoAppendV1Path: true,
                  };
                });
              }}
              items={PLATFORM_OPTIONS.map(o => ({ value: o.value, label: o.label }))}
            >
              <SelectTrigger className="w-full text-sm">
                <SelectValue placeholder="选择接入类型" />
              </SelectTrigger>
              <SelectContent className="text-sm">
                <SelectGroup>
                  {PLATFORM_OPTIONS.map(opt => (
                    <SelectItem key={opt.value} value={opt.value} className="text-sm">
                      <ProviderVendorIcon
                        provider={opt.value}
                        className="size-4 self-center"
                      />
                      <div className="min-w-0">
                        <div>{opt.label}</div>
                        <div className="text-[10px] text-muted-foreground">{opt.description}</div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectGroup>
              </SelectContent>
            </Select>
            <p className="text-[10px] leading-4 text-muted-foreground">
              决定认证字段、地址规则和远程模型发现方式；具体接口格式由下方各能力协议决定。
            </p>
          </div>

          {/* 第三方接入引导：选择需要外部账号的平台时，提示前往注册 / 购买 */}
          <AnimatePresence initial={false}>
            {form.platform && form.platform !== "comfyui" && (
              <motion.div
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -6 }}
                transition={{ duration: 0.22, ease: [0.25, 0.46, 0.45, 0.94] }}
              >
                <div className="rounded-2xl border border-primary/30 bg-gradient-to-br from-primary/10 via-primary/[0.04] to-transparent p-3.5">
                  <div className="flex items-start gap-3">
                    <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
                      <ExternalLink className="h-4 w-4" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-medium leading-snug">
                        还没有 {PLATFORM_LABELS[form.platform] || "该平台"} 的 API 密钥？
                      </p>
                      <p className="mt-1 text-[11px] leading-4 text-muted-foreground">
                        前往服务官网注册账号并购买额度，获取 API Key 后粘贴到下方对应字段即可开始创作。
                      </p>
                      <a
                        href="https://gate.xinchyun.com"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="mt-2.5 inline-flex h-8 items-center gap-1.5 rounded-lg bg-primary px-3 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
                      >
                        前往注册 / 购买
                        <ExternalLink className="h-3.5 w-3.5" />
                      </a>
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* 能力默认协议（平台已收敛为 云揽川 / ComfyUI，不再提供常用提供商快捷填充） */}
          <div className="rounded-2xl border border-border/40 bg-muted/15 p-3 space-y-3">
            <div>
              <p className="text-xs font-medium">能力默认协议</p>
              <p className="mt-0.5 text-[10px] leading-4 text-muted-foreground">
                同一站点可以按能力使用不同请求格式。例如 Agnes：文本使用 OpenAI 兼容协议，图片和视频使用 Agnes 协议。
              </p>
            </div>
            <div className="grid gap-3 sm:grid-cols-3">
              {([
                { key: "textProtocol", label: "文本默认", modelType: 1 },
                { key: "imageProtocol", label: "图片默认", modelType: 2 },
                { key: "videoProtocol", label: "视频默认", modelType: 3 },
              ] as const).map(item => {
                const options = getProtocolOptionsForModelType(item.modelType);
                return (
                  <div key={item.key} className="space-y-1.5">
                    <Label className="text-[11px] text-muted-foreground">{item.label}</Label>
                    <Select
                      value={form[item.key] || UNSET_PROTOCOL_VALUE}
                      onValueChange={value => updateField(item.key, value === UNSET_PROTOCOL_VALUE ? "" : String(value))}
                      disabled={form.platform === "comfyui"}
                      items={[
                        { value: UNSET_PROTOCOL_VALUE, label: "未配置" },
                        ...options.map(option => ({ value: option.value, label: option.label })),
                      ]}
                    >
                      <SelectTrigger className="w-full text-xs">
                        <SelectValue placeholder="未配置" />
                      </SelectTrigger>
                      <SelectContent className="text-xs">
                        <SelectGroup>
                          <SelectItem value={UNSET_PROTOCOL_VALUE} className="text-xs">未配置</SelectItem>
                          {options.map(option => (
                            <SelectItem key={option.value} value={option.value} className="text-xs">
                              {option.label}
                            </SelectItem>
                          ))}
                        </SelectGroup>
                      </SelectContent>
                    </Select>
                  </div>
                );
              })}
            </div>
          </div>

          {fields.map(field => (
            <div key={field.key} className="space-y-1.5">
              <Label className="text-xs text-muted-foreground">
                {field.label}
                {field.required && !editingConfig && <span className="text-destructive ml-0.5">*</span>}
              </Label>
              <div className="relative">
                {field.multiline ? (
                  <Textarea
                    placeholder={field.placeholder}
                    value={(form as unknown as Record<string, string>)[field.key] || ""}
                    onChange={e => updateField(field.key as keyof ApiConfigSaveReq, e.target.value)}
                    spellCheck={false}
                    className="min-h-28 max-h-60 overflow-auto resize-none font-mono text-xs leading-relaxed break-all whitespace-pre-wrap"
                  />
                ) : (
                  <Input
                    type={field.type === "password" && !showSecrets[field.key] ? "password" : "text"}
                    placeholder={
                      field.key === "apiKey" && editingConfig
                        ? "已保存，留空则不修改"
                        : field.placeholder
                    }
                    value={(form as unknown as Record<string, string>)[field.key] || ""}
                    onChange={e => updateField(field.key as keyof ApiConfigSaveReq, e.target.value)}
                    className="text-sm pr-9"
                  />
                )}
                {field.type === "password" && (
                  <button
                    type="button"
                    onClick={() => setShowSecrets(prev => ({ ...prev, [field.key]: !prev[field.key] }))}
                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {showSecrets[field.key] ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                  </button>
                )}
              </div>
              {field.helperText && (
                <p className="text-[10px] text-muted-foreground/70">{field.helperText}</p>
              )}
            </div>
          ))}

          {form.platform === "openai_compatible" && (
            <div className="rounded-lg border border-border/40 bg-muted/20 px-3 py-2.5">
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => updateField("autoAppendV1Path", !form.autoAppendV1Path)}
                  className={cn(
                    "relative w-9 h-5 rounded-full transition-colors duration-200",
                    form.autoAppendV1Path ? "bg-primary" : "bg-muted-foreground/30"
                  )}
                >
                  <span
                    className={cn(
                      "absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform duration-200",
                      form.autoAppendV1Path && "translate-x-4"
                    )}
                  />
                </button>
                <div className="min-w-0">
                  <Label
                    className="text-xs text-muted-foreground cursor-pointer"
                    onClick={() => updateField("autoAppendV1Path", !form.autoAppendV1Path)}
                  >
                    自动补充 /v1 路径
                  </Label>
                  <p className="text-[10px] text-muted-foreground/70 mt-1">
                    开启后系统会在服务根地址后补充 /v1，再根据模型协议拼接 images、videos、chat 等接口。
                  </p>
                </div>
              </div>
            </div>
          )}

          <div className="rounded-lg border border-border/40 bg-muted/20 px-3 py-2.5 space-y-3">
            <div className="space-y-1.5">
              <Label className="text-xs text-muted-foreground">出站代理</Label>
              <Select
                value={form.proxyType || "none"}
                onValueChange={v => {
                  updateField("proxyType", v as string);
                  if (v === "none") {
                    updateField("proxyHost", "");
                    updateField("proxyPort", undefined);
                    updateField("proxyUsername", "");
                    updateField("proxyPassword", "");
                  }
                }}
                items={PROXY_TYPE_OPTIONS.map(o => ({ value: o.value, label: o.label }))}
              >
                <SelectTrigger className="w-full text-sm">
                  <SelectValue placeholder="选择代理类型" />
                </SelectTrigger>
                <SelectContent className="text-sm">
                  <SelectGroup>
                    {PROXY_TYPE_OPTIONS.map(opt => (
                      <SelectItem key={opt.value} value={opt.value} className="text-sm">
                        <div>
                          <div>{opt.label}</div>
                          <div className="text-[10px] text-muted-foreground">{opt.description}</div>
                        </div>
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
              <p className="text-[10px] text-muted-foreground/70">
                仅影响后端访问当前 API 配置绑定的模型服务，适合 Vertex AI、OpenAI、Anthropic 等国外服务。支持可选代理账号密码。
              </p>
            </div>

            {form.proxyType && form.proxyType !== "none" && (
              <div className="space-y-3">
                <div className="grid grid-cols-[1fr_110px] gap-2">
                  <div className="space-y-1.5">
                    <Label className="text-xs text-muted-foreground">代理主机</Label>
                    <Input
                      placeholder="127.0.0.1"
                      value={form.proxyHost || ""}
                      onChange={e => updateField("proxyHost", e.target.value)}
                      className="text-sm font-mono"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <Label className="text-xs text-muted-foreground">端口</Label>
                    <Input
                      type="number"
                      min={1}
                      max={65535}
                      placeholder="7890"
                      value={form.proxyPort ?? ""}
                      onChange={e => updateField("proxyPort", e.target.value ? Number(e.target.value) : undefined)}
                      className="text-sm font-mono"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div className="space-y-1.5">
                    <Label className="text-xs text-muted-foreground">代理用户名</Label>
                    <Input
                      placeholder="可选"
                      value={form.proxyUsername || ""}
                      onChange={e => updateField("proxyUsername", e.target.value)}
                      className="text-sm"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <Label className="text-xs text-muted-foreground">代理密码</Label>
                    <div className="relative">
                      <Input
                        type={showSecrets.proxyPassword ? "text" : "password"}
                        placeholder="可选"
                        value={form.proxyPassword || ""}
                        onChange={e => updateField("proxyPassword", e.target.value)}
                        className="text-sm pr-9"
                      />
                      <button
                        type="button"
                        onClick={() => setShowSecrets(prev => ({ ...prev, proxyPassword: !prev.proxyPassword }))}
                        className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                      >
                        {showSecrets.proxyPassword ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* 备注 */}
          <div className="space-y-1.5">
            <Label className="text-xs text-muted-foreground">备注</Label>
            <Input
              placeholder="可选备注信息"
              value={form.remark || ""}
              onChange={e => updateField("remark", e.target.value)}
              className="text-sm"
            />
          </div>
        </div>

        <DialogFooter className="shrink-0">
          {editingConfig?.platform === "comfyui" && (
            <Button
              variant="outline"
              size="sm"
              onClick={handleTestConnection}
              disabled={testingConnection || saving}
            >
              {testingConnection ? <Loader2 className="animate-spin" /> : <PlugZap />}
              测试连接
            </Button>
          )}
          <DialogClose render={<Button variant="outline" size="sm" />}>
            取消
          </DialogClose>
          <Button size="sm" onClick={handleSave} disabled={saving || !form.name.trim() || proxyInvalid || comfyUiInvalid}>
            {saving && <Loader2 className="h-3.5 w-3.5 animate-spin mr-1.5" />}
            {editingConfig ? "保存" : "创建"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
