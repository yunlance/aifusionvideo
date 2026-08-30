"use client";

import { useEffect, useMemo, useState } from "react";
import { Loader2, Search, Settings, ShieldCheck, Trash2, Users } from "lucide-react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useAuthStore } from "@/lib/store/auth-store";
import { userApi } from "@/lib/api/user";
import { toastApiError } from "@/lib/api/toast-api-error";
import { userModelConfigsApi, apiConfigApi, aiModelApi, type ApiConfig, type AiModel } from "@/lib/api/ai-model";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import type { UserRespVO } from "@/lib/api/types";
import { containerVariants, itemVariants, settingsTypography } from "../_shared";

function formatDateTime(value?: string | null): string {
  if (!value) return "--";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("zh-CN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
}

export default function SettingsUsersPage() {
  const currentUser = useAuthStore((state) => state.user);
  const isAdmin = currentUser?.roles?.includes("admin") ?? false;
  const [keyword, setKeyword] = useState("");
  const normalizedKeyword = keyword.trim();
  const [loadedKeyword, setLoadedKeyword] = useState<string | null>(null);
  const [users, setUsers] = useState<UserRespVO[]>([]);
  const [total, setTotal] = useState(0);
  const loading = isAdmin && loadedKeyword !== normalizedKeyword;

  useEffect(() => {
    if (!isAdmin) return;

    let cancelled = false;

    userApi.page({
      pageNo: 1,
      pageSize: 100,
      username: normalizedKeyword || undefined,
    })
      .then((result) => {
        if (cancelled) return;
        setUsers(result.list);
        setTotal(result.total);
      })
      .catch((err) => {
        if (!cancelled) {
          console.error("加载用户列表失败:", err);
          toastApiError(err, "加载用户列表失败");
          setUsers([]);
          setTotal(0);
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoadedKeyword(normalizedKeyword);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [isAdmin, normalizedKeyword]);

  const adminCount = useMemo(
    () => users.filter((user) => user.roles.includes("admin")).length,
    [users]
  );

  // ========== 用户模型设置管理（查看/删除用户私有渠道与模型） ==========
  const [configsUser, setConfigsUser] = useState<UserRespVO | null>(null);
  const [userConfigs, setUserConfigs] = useState<{ apiConfigs: ApiConfig[]; models: AiModel[] } | null>(null);
  const [configsLoading, setConfigsLoading] = useState(false);

  const openUserConfigs = async (user: UserRespVO) => {
    setConfigsUser(user);
    setConfigsLoading(true);
    setUserConfigs(null);
    try {
      const data = await userModelConfigsApi.get(user.id);
      setUserConfigs(data);
    } catch (err) {
      toastApiError(err, "加载用户配置失败");
    } finally {
      setConfigsLoading(false);
    }
  };

  const deleteUserApiConfig = async (id: number) => {
    try {
      await apiConfigApi.delete(id);
      setUserConfigs((prev) => (prev ? { ...prev, apiConfigs: prev.apiConfigs.filter((c) => c.id !== id) } : prev));
    } catch (err) {
      toastApiError(err, "删除渠道失败");
    }
  };

  const deleteUserModel = async (id: number) => {
    try {
      await aiModelApi.delete(id);
      setUserConfigs((prev) => (prev ? { ...prev, models: prev.models.filter((m) => m.id !== id) } : prev));
    } catch (err) {
      toastApiError(err, "删除模型失败");
    }
  };

  if (!isAdmin) {
    return (
      <motion.div
        className="w-full"
        variants={containerVariants}
        initial={false}
        animate="visible"
      >
        <motion.div variants={itemVariants} className="rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-6">
          <h1 className={settingsTypography.pageTitle}>用户列表</h1>
          <p className={settingsTypography.pageDescription}>
            只有管理员可以查看全部用户。普通用户仅可在个人设置中维护自己的资料。
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
      <motion.div variants={itemVariants} className="mb-8 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className={settingsTypography.pageTitle}>用户列表</h1>
          <p className={settingsTypography.pageDescription}>
            查看、搜索和管理系统中的全部用户。
          </p>
        </div>

        <div className="relative w-full md:w-[280px]">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground/60" />
          <input
            type="text"
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            placeholder="按用户名搜索"
            className="w-full rounded-xl border border-border/30 bg-card/40 py-2.5 pl-10 pr-4 text-sm outline-none transition-colors focus:border-primary/40"
          />
        </div>
      </motion.div>

      <motion.div variants={itemVariants} className="grid gap-4 md:grid-cols-3">
        <div className="rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-5">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Users className="h-4 w-4 text-cyan-500" />
            用户总数
          </div>
          <p className="mt-3 text-3xl font-semibold tracking-tight">{total}</p>
        </div>

        <div className="rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-5">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <ShieldCheck className="h-4 w-4 text-emerald-500" />
            管理员
          </div>
          <p className="mt-3 text-3xl font-semibold tracking-tight">{adminCount}</p>
        </div>

        <div className="rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-5">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Users className="h-4 w-4 text-blue-500" />
            普通成员
          </div>
          <p className="mt-3 text-3xl font-semibold tracking-tight">{Math.max(total - adminCount, 0)}</p>
        </div>
      </motion.div>

      <motion.div variants={itemVariants} className="mt-6 rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 text-muted-foreground">
            <Loader2 className="h-5 w-5 animate-spin" />
          </div>
        ) : users.length === 0 ? (
          <div className="py-16 text-center text-sm text-muted-foreground">
            暂无匹配的用户
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead className="bg-muted/20 text-muted-foreground">
                <tr>
                  <th className="px-5 py-3 text-left font-medium">用户名</th>
                  <th className="px-5 py-3 text-left font-medium">昵称</th>
                  <th className="px-5 py-3 text-left font-medium">角色</th>
                  <th className="px-5 py-3 text-left font-medium">状态</th>
                  <th className="px-5 py-3 text-left font-medium">注册时间</th>
                  <th className="px-5 py-3 text-left font-medium">操作</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => {
                  const isUserAdmin = user.roles.includes("admin");
                  return (
                    <tr key={user.id} className="border-t border-border/20">
                      <td className="px-5 py-4 font-medium">{user.username}</td>
                      <td className="px-5 py-4 text-muted-foreground">{user.nickname || "--"}</td>
                      <td className="px-5 py-4">
                        <span
                          className={cn(
                            "inline-flex rounded-full px-2.5 py-1 text-xs font-medium border",
                            isUserAdmin
                              ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-600"
                              : "border-border/30 bg-muted/20 text-foreground/80"
                          )}
                        >
                          {isUserAdmin ? "管理员" : "成员"}
                        </span>
                      </td>
                      <td className="px-5 py-4">
                        <span
                          className={cn(
                            "inline-flex rounded-full px-2.5 py-1 text-xs font-medium border",
                            user.status === 1
                              ? "border-blue-500/30 bg-blue-500/10 text-blue-600"
                              : "border-rose-500/30 bg-rose-500/10 text-rose-600"
                          )}
                        >
                          {user.status === 1 ? "启用" : "禁用"}
                        </span>
                      </td>
                      <td className="px-5 py-4 text-muted-foreground">{formatDateTime(user.createTime)}</td>
                      <td className="px-5 py-4">
                        <button
                          type="button"
                          onClick={() => openUserConfigs(user)}
                          className="inline-flex items-center gap-1.5 rounded-lg border border-border/30 px-3 py-1.5 text-xs font-medium text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors"
                        >
                          <Settings className="h-3.5 w-3.5" />
                          模型设置
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </motion.div>

      {/* 用户模型设置管理弹窗 */}
      <Dialog open={!!configsUser} onOpenChange={(open) => { if (!open) setConfigsUser(null); }}>
        <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{configsUser?.username} 的渠道与模型</DialogTitle>
          </DialogHeader>
          <div className="space-y-6">
            <div>
              <h4 className="text-sm font-semibold mb-2">API 渠道（{userConfigs?.apiConfigs.length ?? 0}）</h4>
              {configsLoading ? (
                <div className="flex justify-center py-6 text-muted-foreground">
                  <Loader2 className="h-5 w-5 animate-spin" />
                </div>
              ) : (userConfigs?.apiConfigs.length ?? 0) === 0 ? (
                <p className="text-xs text-muted-foreground py-3">该用户暂无私有渠道</p>
              ) : (
                <div className="space-y-2">
                  {userConfigs?.apiConfigs.map((cfg) => (
                    <div key={cfg.id} className="flex items-center justify-between rounded-lg border border-border/20 bg-muted/10 px-4 py-2.5">
                      <div>
                        <div className="text-sm font-medium">{cfg.name}</div>
                        <div className="text-xs text-muted-foreground">
                          {cfg.platform} · Key: {cfg.apiKey ? `${cfg.apiKey.slice(0, 6)}****` : "未设置"} · {cfg.status === 1 ? "启用" : "禁用"}
                        </div>
                      </div>
                      <button type="button" onClick={() => deleteUserApiConfig(cfg.id)} className="text-muted-foreground hover:text-rose-500 transition-colors" title="删除渠道">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
            <div>
              <h4 className="text-sm font-semibold mb-2">模型（{userConfigs?.models.length ?? 0}）</h4>
              {configsLoading ? (
                <div className="flex justify-center py-6 text-muted-foreground">
                  <Loader2 className="h-5 w-5 animate-spin" />
                </div>
              ) : (userConfigs?.models.length ?? 0) === 0 ? (
                <p className="text-xs text-muted-foreground py-3">该用户暂无私有模型</p>
              ) : (
                <div className="space-y-2">
                  {userConfigs?.models.map((model) => (
                    <div key={model.id} className="flex items-center justify-between rounded-lg border border-border/20 bg-muted/10 px-4 py-2.5">
                      <div>
                        <div className="text-sm font-medium">{model.name}</div>
                        <div className="text-xs text-muted-foreground">
                          {model.code} · 类型 {model.modelType} · {model.status === 1 ? "启用" : "禁用"}
                        </div>
                      </div>
                      <button type="button" onClick={() => deleteUserModel(model.id)} className="text-muted-foreground hover:text-rose-500 transition-colors" title="删除模型">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </motion.div>
  );
}
