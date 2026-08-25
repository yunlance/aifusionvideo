"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useSearchParams, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { AuthLayout } from "@/components/ui/auth-layout";
import { useAuthStore } from "@/lib/store/auth-store";

import { getInitStatus } from "@/lib/api/system-init";
import { getApiErrorMessage } from "@/lib/api/api-error";

function LoginContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const redirectUrl = searchParams.get("redirect") || "/dashboard";
  const login = useAuthStore((s) => s.login);

  const isDev = process.env.NODE_ENV === "development";
  const [username, setUsername] = useState(isDev ? "admin" : "");
  const [password, setPassword] = useState(isDev ? "123456" : "");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [initReady, setInitReady] = useState(false);
  const [allowRegister, setAllowRegister] = useState(false);

  // 检查系统初始化状态，未完成前不渲染登录表单
  useEffect(() => {
    getInitStatus()
      .then((status) => {
        if (!status.initialized) {
          router.replace("/setup");
        } else {
          setAllowRegister(status.allowRegister);
          setInitReady(true);
        }
      })
      .catch((error) => {
        // 后端不可用时仍显示登录页
        setError(getApiErrorMessage(error));
        setInitReady(true);
      });
  }, [router]);

  // 初始化检查完成前显示跟随主题的背景，避免登录表单闪现
  if (!initReady) {
    return <div className="min-h-screen bg-background" />;
  }

  // 登录提交
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username || !password) return;

    setError("");
    setLoading(true);

    try {
      await login(username, password);

      // 设置 cookie 供 proxy 使用
      const store = JSON.parse(localStorage.getItem("auth-storage") || "{}");
      const token = store?.state?.token;
      if (token) {
        document.cookie = `auth-token=${token}; path=/; max-age=${7 * 24 * 60 * 60}; SameSite=Lax`;
      }

      // 触发成功动画，跳转由 onTransitionComplete 回调驱动
      setShowSuccess(true);
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("登录失败，请稍后重试");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout
      showSuccess={showSuccess}
      successTitle="登录成功"
      successSubtitle="正在进入控制面板"
      onTransitionComplete={() => router.replace(redirectUrl)}
    >
      {/* 标题 */}
      <div className="space-y-2">
        <h1 className="text-[2rem] font-bold leading-[1.1] tracking-tight text-foreground">
          欢迎回来
        </h1>
        <p className="text-base text-muted-foreground font-light">登录到你的账户</p>
      </div>

      {/* 登录表单 */}
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="relative">
          <input
            type="text"
            placeholder="用户名"
            value={username}
            onChange={(e) => {
              setUsername(e.target.value);
              setError("");
            }}
            className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
            required
            autoComplete="username"
            disabled={loading}
          />
        </div>

        <div className="relative">
          <input
            type="password"
            placeholder="密码"
            value={password}
            onChange={(e) => {
              setPassword(e.target.value);
              setError("");
            }}
            className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
            required
            autoComplete="current-password"
            minLength={6}
            disabled={loading}
          />
        </div>

        {/* 错误提示 */}
        <AnimatePresence>
          {error && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              transition={{ duration: 0.2 }}
              className="overflow-hidden"
            >
              <p className="text-red-400/90 text-sm py-1">{error}</p>
            </motion.div>
          )}
        </AnimatePresence>

        {/* 登录按钮 */}
        <motion.button
          type="submit"
          disabled={loading || !username || !password}
          className={cn(
            "w-full rounded-full font-medium py-3 transition-all duration-300",
            loading || !username || !password
              ? "bg-muted text-muted-foreground/60 border border-border/30 cursor-not-allowed"
              : "bg-primary text-primary-foreground hover:bg-primary/90 cursor-pointer"
          )}
          whileHover={
            !loading && username && password ? { scale: 1.02 } : undefined
          }
          whileTap={
            !loading && username && password ? { scale: 0.98 } : undefined
          }
          transition={{ duration: 0.2 }}
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                  fill="none"
                />
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                />
              </svg>
              登录中...
            </span>
          ) : (
            "登录"
          )}
        </motion.button>
      </form>

      <div className="flex items-center justify-between text-sm text-muted-foreground pt-2">
        {allowRegister ? (
          <p>
            还没有账号？{" "}
            <Link href="/register" className="text-foreground underline decoration-foreground/30 underline-offset-4 hover:decoration-foreground/80 transition-colors">
              立即注册
            </Link>
          </p>
        ) : <div />}
        <Link href="/forgot-password" className="text-muted-foreground/70 hover:text-foreground transition-colors">
          忘记密码？
        </Link>
      </div>

      {/* 底部信息 */}
      <p className="text-xs text-muted-foreground/60 pt-8">
        云揽镜 · AI视频创作平台
      </p>
    </AuthLayout>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-background" />}>
      <LoginContent />
    </Suspense>
  );
}
