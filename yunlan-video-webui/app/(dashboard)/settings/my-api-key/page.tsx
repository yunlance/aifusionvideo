"use client";

import { useCallback, useEffect, useState } from "react";
import { motion } from "framer-motion";
import { Key, Loader2, Trash2, Eye, EyeOff, Cloud, ExternalLink } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { toastApiError } from "@/lib/api/toast-api-error";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { containerVariants, itemVariants, settingsTypography } from "../_shared";
import { myApiKeyApi, type UserApiKey, type MyApiKeySaveReq } from "@/lib/api/user-api-key";
import { PLATFORM_OPTIONS } from "@/lib/api/ai-model";
import { getInitStatus } from "@/lib/api/system-init";

interface PlatformFormState {
  apiKey: string;
}

const EMPTY_FORM: PlatformFormState = { apiKey: "" };

export default function MyApiKeyPage() {
  const [keys, setKeys] = useState<UserApiKey[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [deleting, setDeleting] = useState<number | null>(null);
  const [forms, setForms] = useState<Record<string, PlatformFormState>>({});
  const [showSecret, setShowSecret] = useState<Record<string, boolean>>({});
  const [modelUseGlobal, setModelUseGlobal] = useState(false);

  useEffect(() => {
    let cancelled = false;
    getInitStatus()
      .then((status) => {
        if (!cancelled) setModelUseGlobal(status.modelUseGlobal);
      })
      .catch(() => {
        // 读取失败时按私有模式处理
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const load = useCallback(async () => {
    try {
      setLoading(true);
      const data = await myApiKeyApi.list();
      setKeys(data);
    } catch (err) {
      toastApiError(err, "加载密钥失败");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const existingByPlatform = (platform: string) => keys.find((k) => k.platform === platform);

  const setForm = (platform: string, patch: Partial<PlatformFormState>) => {
    setForms((prev) => ({
      ...prev,
      [platform]: { ...(prev[platform] ?? EMPTY_FORM), ...patch },
    }));
  };

  const handleSave = async (platform: string) => {
    const form = forms[platform] ?? EMPTY_FORM;
    if (!form.apiKey.trim()) {
      toast.error("请填写 API 密钥");
      return;
    }
    setSaving(platform);
    try {
      const req: MyApiKeySaveReq = {
        platform,
        apiKey: form.apiKey.trim(),
      };
      await myApiKeyApi.save(req);
      toast.success("密钥已保存");
      setForm(platform, EMPTY_FORM);
      await load();
    } catch (err) {
      toastApiError(err, "保存密钥失败");
    } finally {
      setSaving(null);
    }
  };

  const handleDelete = async (id: number) => {
    setDeleting(id);
    try {
      await myApiKeyApi.delete(id);
      toast.success("密钥已删除");
      await load();
    } catch (err) {
      toastApiError(err, "删除密钥失败");
    } finally {
      setDeleting(null);
    }
  };

  // 全局模式下，所有用户统一使用平台密钥，无需个人配置
  if (modelUseGlobal) {
    return (
      <motion.div
        className="w-full"
        variants={containerVariants}
        initial={false}
        animate="visible"
      >
        <motion.div
          variants={itemVariants}
          className="rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-6"
        >
          <h1 className={settingsTypography.pageTitle}>我的密钥</h1>
          <p className={settingsTypography.pageDescription}>
            当前系统为全局模式，所有用户统一使用平台配置的密钥，无需（也不能）配置个人密钥。
          </p>
        </motion.div>
      </motion.div>
    );
  }

  return (
    <motion.div
      className="w-full"
      variants={containerVariants}
      initial={false}
      animate="visible"
    >
      {/* 页面标题 */}
      <motion.div variants={itemVariants} className="mb-8">
        <h1 className={settingsTypography.pageTitle}>我的密钥</h1>
        <p className={settingsTypography.pageDescription}>
          配置你自己的 API 密钥。密钥与平台渠道物理隔离，仅用于你自己的生成请求，其他用户无法看到或使用。
        </p>
      </motion.div>

      {/* 配置说明 + 注册引导 */}
      <motion.div variants={itemVariants} className="mb-6 space-y-3">
        <div className="rounded-2xl border border-border/30 bg-card/50 backdrop-blur-sm p-4">
          <p className="text-xs leading-5 text-muted-foreground">
            决定认证字段、地址规则和远程模型发现方式；具体接口格式由下方各能力协议决定。
          </p>
        </div>
        <div className="rounded-2xl border border-primary/30 bg-gradient-to-br from-primary/10 via-primary/[0.04] to-transparent p-3.5">
          <div className="flex items-start gap-3">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
              <ExternalLink className="h-4 w-4" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium leading-snug">还没有 云揽川 的 API 密钥？</p>
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

      {PLATFORM_OPTIONS.filter((opt) => opt.value !== "comfyui").map((opt) => {
        const existing = existingByPlatform(opt.value);
        const form = forms[opt.value] ?? EMPTY_FORM;
        const show = showSecret[opt.value] ?? false;

        return (
          <motion.div key={opt.value} variants={itemVariants} className="mb-6">
            <div className="rounded-xl border border-border/30 overflow-hidden bg-card/50 backdrop-blur-sm">
              {/* 卡片头部 */}
              <div className="flex items-center gap-3 px-6 py-4 border-b border-border/20">
                <div className="h-9 w-9 rounded-lg bg-violet-500/10 flex items-center justify-center shrink-0">
                  <Cloud className="h-4.5 w-4.5 text-violet-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className={settingsTypography.sectionTitle}>{opt.label}</h3>
                  <p className="text-xs text-muted-foreground">{opt.description}</p>
                </div>
                {existing ? (
                  <span className="px-2 py-0.5 rounded-full bg-green-500/10 text-[10px] text-green-500 font-medium">
                    已配置
                  </span>
                ) : (
                  <span className="px-2 py-0.5 rounded-full bg-muted/50 text-[10px] text-muted-foreground font-medium">
                    未配置
                  </span>
                )}
              </div>

              {/* 表单 */}
              <div className="px-6 py-5">
                <div className="space-y-3 max-w-md">
                  <div className="space-y-1.5">
                    <Label className="text-xs text-muted-foreground">
                      API 密钥 {existing ? "" : <span className="text-destructive">*</span>}
                    </Label>
                    <div className="relative">
                      <Input
                        type={show ? "text" : "password"}
                        placeholder={existing ? "输入新密钥以更新（已保存密钥不会回显）" : "sk-..."}
                        value={form.apiKey}
                        onChange={(e) => setForm(opt.value, { apiKey: e.target.value })}
                        className="text-sm pr-9"
                      />
                      <button
                        type="button"
                        onClick={() =>
                          setShowSecret((p) => ({ ...p, [opt.value]: !(p[opt.value] ?? false) }))
                        }
                        className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                      >
                        {show ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                      </button>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 pt-2">
                    <Button
                      size="sm"
                      onClick={() => handleSave(opt.value)}
                      disabled={saving === opt.value}
                    >
                      {saving === opt.value && <Loader2 className="h-3.5 w-3.5 animate-spin mr-1.5" />}
                      {existing ? "更新密钥" : "保存密钥"}
                    </Button>
                    {existing && (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleDelete(existing.id)}
                        disabled={deleting === existing.id}
                      >
                        {deleting === existing.id ? (
                          <Loader2 className="h-3.5 w-3.5 animate-spin mr-1.5" />
                        ) : (
                          <Trash2 className="h-3.5 w-3.5 mr-1.5" />
                        )}
                        删除
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        );
      })}

      {!loading && keys.length === 0 && (
        <motion.div
          variants={itemVariants}
          className="flex items-center gap-2 rounded-xl border border-dashed border-border/30 px-6 py-8 text-sm text-muted-foreground"
        >
          <Key className="h-4 w-4 text-muted-foreground/50" />
          尚未配置任何密钥，请在上方对应平台填写并保存。
        </motion.div>
      )}
    </motion.div>
  );
}
