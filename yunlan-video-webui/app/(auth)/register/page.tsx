"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { AuthLayout } from "@/components/ui/auth-layout";
import { useAuthStore } from "@/lib/store/auth-store";
import { getInitStatus } from "@/lib/api/system-init";
import { getApiErrorMessage } from "@/lib/api/api-error";
import { register as registerApi, sendEmailCode } from "@/lib/api/auth";

export default function RegisterPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [nickname, setNickname] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [initReady, setInitReady] = useState(false);
  const [allowRegister, setAllowRegister] = useState(false);
  const [emailRegisterEnabled, setEmailRegisterEnabled] = useState(false);
  const [email, setEmail] = useState("");
  const [verifyCode, setVerifyCode] = useState("");
  const [countdown, setCountdown] = useState(0);
  const [sendingCode, setSendingCode] = useState(false);

  useEffect(() => {
    getInitStatus()
      .then((status) => {
        if (!status.initialized) {
          router.replace("/setup");
          return;
        }
        setAllowRegister(status.allowRegister);
        setEmailRegisterEnabled(!!status.emailRegisterEnabled);
        setInitReady(true);
      })
      .catch((error) => {
        setError(getApiErrorMessage(error));
        setInitReady(true);
      });
  }, [router]);

  useEffect(() => {
    if (countdown <= 0) return;
    const timer = setTimeout(() => setCountdown((prev) => prev - 1), 1000);
    return () => clearTimeout(timer);
  }, [countdown]);

  const validate = (): string | null => {
    if (emailRegisterEnabled) {
      if (!email.trim()) return "请输入邮箱地址";
      if (!/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email.trim())) return "邮箱格式不正确";
      if (!verifyCode.trim()) return "请输入邮箱验证码";
    } else {
      if (!username.trim()) return "请输入用户名";
      if (username.trim().length < 3) return "用户名至少 3 个字符";
    }
    if (!password) return "请输入密码";
    if (password.length < 6) return "密码至少 6 位";
    if (password !== confirmPassword) return "两次输入的密码不一致";
    return null;
  };

  const isFormValid =
    (emailRegisterEnabled
      ? email.trim().length >= 5 && email.includes("@") && verifyCode.trim().length >= 4
      : username.trim().length >= 3) &&
    password.length >= 6 &&
    password === confirmPassword;

  const handleSendCode = async () => {
    if (!email.trim()) {
      setError("请输入邮箱地址");
      return;
    }
    if (!/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email.trim())) {
      setError("邮箱格式不正确");
      return;
    }
    setSendingCode(true);
    setError("");
    try {
      await sendEmailCode(email.trim());
      setCountdown(60);
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("验证码发送失败，请稍后重试");
      }
    } finally {
      setSendingCode(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    setError("");
    setLoading(true);

    try {
      const resp = await registerApi(
        emailRegisterEnabled
          ? {
              email: email.trim(),
              verifyCode: verifyCode.trim(),
              password,
              confirmPassword,
              nickname: nickname.trim() || undefined,
            }
          : {
              username: username.trim(),
              password,
              confirmPassword,
              nickname: nickname.trim() || undefined,
            }
      );

      useAuthStore.setState({
        token: resp.accessToken,
        refreshToken: resp.refreshToken,
        user: {
          id: resp.userId,
          username: resp.username,
          nickname: resp.nickname,
          avatar: null,
          email: null,
          phone: null,
          status: 1,
          createTime: "",
          roles: ["user"],
        },
      });

      document.cookie = `auth-token=${resp.accessToken}; path=/; max-age=${7 * 24 * 60 * 60}; SameSite=Lax`;
      setShowSuccess(true);
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("注册失败，请稍后重试");
      }
    } finally {
      setLoading(false);
    }
  };

  if (!initReady) {
    return <div className="min-h-screen bg-background" />;
  }

  if (!allowRegister) {
    return (
      <AuthLayout>
        <div className="space-y-4">
          <h1 className="text-[2rem] font-bold leading-[1.1] tracking-tight text-foreground">
            当前未开放注册
          </h1>
          <p className="text-base text-muted-foreground font-light leading-relaxed">
            需要管理员先完成初始化，并在系统设置中开启允许注册。
          </p>
          {error ? <p className="text-sm text-red-400/90">{error}</p> : null}
          <Link
            href="/login"
            className="inline-flex items-center justify-center rounded-full bg-primary px-5 py-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            返回登录
          </Link>
        </div>
      </AuthLayout>
    );
  }

  return (
    <AuthLayout
      showSuccess={showSuccess}
      successTitle="注册成功"
      successSubtitle="正在进入控制面板"
      onTransitionComplete={() => router.replace("/dashboard")}
    >
      <div className="space-y-2">
        <h1 className="text-[2rem] font-bold leading-[1.1] tracking-tight text-foreground">
          创建账号
        </h1>
        <p className="text-base text-muted-foreground font-light">
          {emailRegisterEnabled ? "使用邮箱和验证码创建账号" : "使用用户名和密码创建账号"}
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-3">
        {emailRegisterEnabled ? (
          <>
            <input
              type="email"
              placeholder="邮箱地址（将作为登录账号）"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                setError("");
              }}
              className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
              required
              autoComplete="email"
              disabled={loading}
            />
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="邮箱验证码"
                value={verifyCode}
                onChange={(e) => {
                  setVerifyCode(e.target.value);
                  setError("");
                }}
                className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
                required
                autoComplete="off"
                disabled={loading}
                maxLength={6}
              />
              <button
                type="button"
                onClick={handleSendCode}
                disabled={sendingCode || countdown > 0 || loading}
                className={cn(
                  "shrink-0 rounded-full border px-4 text-sm transition-colors",
                  countdown > 0 || sendingCode
                    ? "border-border/30 text-muted-foreground/60 cursor-not-allowed"
                    : "border-primary/40 text-primary hover:bg-primary/10 cursor-pointer"
                )}
              >
                {countdown > 0 ? `${countdown}s 后重发` : sendingCode ? "发送中..." : "获取验证码"}
              </button>
            </div>
          </>
        ) : (
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
            minLength={3}
          />
        )}

        <input
          type="text"
          placeholder="昵称（选填）"
          value={nickname}
          onChange={(e) => setNickname(e.target.value)}
          className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
          autoComplete="nickname"
          disabled={loading}
        />

        <input
          type="password"
          placeholder="密码（至少6位）"
          value={password}
          onChange={(e) => {
            setPassword(e.target.value);
            setError("");
          }}
          className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
          required
          autoComplete="new-password"
          minLength={6}
          disabled={loading}
        />

        <input
          type="password"
          placeholder="确认密码"
          value={confirmPassword}
          onChange={(e) => {
            setConfirmPassword(e.target.value);
            setError("");
          }}
          className="w-full backdrop-blur-[1px] text-foreground border border-border/30 rounded-full py-3 px-5 focus:outline-none focus:border-primary/50 bg-transparent placeholder:text-muted-foreground/60 transition-colors"
          required
          autoComplete="new-password"
          minLength={6}
          disabled={loading}
        />

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

        <motion.button
          type="submit"
          disabled={loading || !isFormValid}
          className={cn(
            "w-full rounded-full font-medium py-3 transition-all duration-300",
            loading || !isFormValid
              ? "bg-muted text-muted-foreground/60 border border-border/30 cursor-not-allowed"
              : "bg-primary text-primary-foreground hover:bg-primary/90 cursor-pointer"
          )}
          whileHover={!loading && isFormValid ? { scale: 1.02 } : undefined}
          whileTap={!loading && isFormValid ? { scale: 0.98 } : undefined}
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
              注册中...
            </span>
          ) : (
            "注册并开始使用"
          )}
        </motion.button>
      </form>

      <p className="text-sm text-muted-foreground pt-2">
        已有账号？{" "}
        <Link href="/login" className="text-foreground underline decoration-foreground/30 underline-offset-4 hover:decoration-foreground/80 transition-colors">
          去登录
        </Link>
      </p>

    </AuthLayout>
  );
}
