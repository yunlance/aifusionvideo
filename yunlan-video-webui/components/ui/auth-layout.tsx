"use client";

import React, { useState, useEffect, useSyncExternalStore } from "react";
import { createPortal } from "react-dom";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";
import { Sparkles, Zap, ImagePlus, Film, BookOpen, Cpu, CreditCard } from "lucide-react";
import { cn } from "@/lib/utils";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";

interface AuthLayoutProps {
  className?: string;
  children: React.ReactNode;
  // 成功状态由外部控制
  showSuccess?: boolean;
  // 成功后显示的内容
  successTitle?: string;
  successSubtitle?: string;
  // 扩散过渡动画完成后的回调
  onTransitionComplete?: () => void;
}

/** 信息卡片内容（参考图风格：独立浮层 + 圆角 + 图标前缀） */
const FEATURE_CARDS: { icon: React.ComponentType<{ className?: string }>; title: string; tone: "blue" | "amber" | "emerald" | "violet" | "indigo" }[] = [
  { icon: ImagePlus, title: "AI 生图", tone: "violet" },
  { icon: Film, title: "AI 生视频", tone: "blue" },
  { icon: BookOpen, title: "剧本创作", tone: "emerald" },
  { icon: Sparkles, title: "分镜生成", tone: "amber" },
];

/**
 * 认证页面共享布局（参考 memefast.top 风格）
 * - 左栏（lg+）：大字渐变标语 + 副标题 + 简短说明 + 点状地球轨道装饰 + 能力标签胶囊
 * - 右栏：融入背景的层次感毛玻璃表单卡片（柔和投影 + 顶部高光），移动端自动堆叠
 */
export const AuthLayout = ({
  className,
  children,
  showSuccess = false,
  successTitle = "操作成功",
  successSubtitle = "正在跳转...",
  onTransitionComplete,
}: AuthLayoutProps) => {
  const [initialCanvasHidden, setInitialCanvasHidden] = useState(false);
  const [mounted, setMounted] = useState(false);
  // 直接监听 <html> 上的 dark 类，与 AnimatedThemeToggler 的 DOM 切换方式保持一致
  const [isDark, setIsDark] = useState(true);
  const isClient = useSyncExternalStore(
    () => () => {},
    () => true,
    () => false
  );

  useEffect(() => {
    setMounted(true);
    if (typeof document === "undefined") return;
    const sync = () => setIsDark(document.documentElement.classList.contains("dark"));
    sync();
    const observer = new MutationObserver(sync);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
    return () => observer.disconnect();
  }, []);

  // 外部通过 showSuccess prop 控制，这里延迟隐藏初始 Canvas，形成转场叠加
  useEffect(() => {
    if (!showSuccess) return;
    const timer = setTimeout(() => setInitialCanvasHidden(true), 50);
    return () => clearTimeout(timer);
  }, [showSuccess]);

  return (
    <div
      className={cn(
        "relative flex w-full min-h-screen overflow-hidden",
        // 背景随主题：浅色淡蓝紫渐变（贴近参考图），深色深蓝黑渐变
        isDark
          ? "bg-[radial-gradient(ellipse_at_top_left,#0f172a_0%,#0b1120_55%,#070b18_100%)]"
          : "bg-[radial-gradient(ellipse_at_top_left,#f0f5ff_0%,#f8faff_50%,#eef2ff_100%)]",
        className
      )}
    >
      {/* 背景装饰光斑 */}
      <div
        className={cn(
          "pointer-events-none absolute -top-32 -left-32 size-[28rem] rounded-full blur-3xl",
          isDark ? "bg-indigo-600/15" : "bg-indigo-200/50"
        )}
      />
      <div
        className={cn(
          "pointer-events-none absolute top-1/3 -right-40 size-[32rem] rounded-full blur-3xl",
          isDark ? "bg-purple-600/12" : "bg-purple-200/40"
        )}
      />

      {/* ============ 左栏：品牌叙事区（lg+ 显示） ============ */}
      <div className="relative hidden lg:flex lg:w-[55%] flex-col justify-between p-12 xl:p-16 overflow-hidden">
        {/* 顶部品牌 Logo */}
        <div className="relative z-10 flex items-center gap-3">
          <Image
            src="/logo.png"
            alt="云揽镜"
            width={480}
            height={96}
            priority
            className="h-10 w-auto"
          />
          <div className="flex items-center text-[1.6rem] font-semibold tracking-[0.02em]">
            <span className="text-transparent bg-[linear-gradient(96deg,#7adcf2_0%,#2EC7D5_38%,#2488C8_100%)] bg-clip-text">
              云揽
            </span>
            <span className="text-transparent bg-[linear-gradient(96deg,#FCB659_0%,#FF9F68_34%,#E65979_100%)] bg-clip-text">
              镜
            </span>
          </div>
        </div>

        {/* 中部/下部：参考图风格——中央渐变层叠装饰 + 信息独立卡片环绕分布 */}
        <div className="relative z-10 flex-1 flex items-center justify-center min-h-0">
          {/* 中央渐变层叠装饰（呼吸浮动动画） */}
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
            className="relative h-56 w-56 xl:h-64 xl:w-64"
          >
            {/* 外层光晕（缓慢脉动放大） */}
            <motion.div
              animate={{ scale: [1, 1.06, 1], opacity: [0.8, 1, 0.8] }}
              transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              className={cn(
                "pointer-events-none absolute inset-0 rounded-[2rem] blur-xl",
                isDark
                  ? "bg-gradient-to-br from-indigo-500/45 to-purple-500/35"
                  : "bg-gradient-to-br from-indigo-300/70 to-purple-300/55"
              )}
            />
            <motion.div
              animate={{ y: [0, 4, 0] }}
              transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
              className={cn(
                "pointer-events-none absolute inset-4 rounded-[1.6rem] blur-md",
                isDark
                  ? "bg-gradient-to-br from-indigo-400/55 to-purple-400/40"
                  : "bg-gradient-to-br from-indigo-200/80 to-purple-200/65"
              )}
            />
            <div
              className={cn(
                "pointer-events-none absolute inset-8 rounded-[1.2rem]",
                isDark
                  ? "bg-gradient-to-br from-indigo-300/40 to-purple-300/30 border border-white/10"
                  : "bg-gradient-to-br from-indigo-100/90 to-purple-100/75 border border-white/70 shadow-inner"
              )}
            />
          </motion.div>

          {/* 环绕卡片：参考图风格——独立浮层、玻璃质感、图标前缀 */}
          {/* 左中：主信息卡（基于 Agent + 说明） */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.2, ease: "easeOut" }}
            whileHover={{ y: -4, transition: { duration: 0.2 } }}
            className={cn(
              "group absolute left-0 top-1/2 -translate-y-1/2 max-w-[18rem] rounded-2xl p-4 backdrop-blur-xl border shadow-lg",
              "transition-colors duration-200",
              isDark
                ? "border-white/12 bg-white/8 shadow-indigo-950/40 hover:border-indigo-400/40 hover:shadow-indigo-900/50"
                : "border-white/70 bg-white/75 shadow-indigo-200/60 hover:border-indigo-300/70 hover:shadow-indigo-300/50"
            )}
          >
            <div className="flex items-center gap-2.5">
              <span
                className={cn(
                  "grid size-8 shrink-0 place-items-center rounded-xl transition-transform duration-200 group-hover:scale-110",
                  isDark ? "bg-indigo-500/20 text-indigo-300" : "bg-indigo-500/15 text-indigo-600"
                )}
              >
                <Cpu className="h-4 w-4" />
              </span>
              <div className="min-w-0">
                <p className={cn("text-sm font-semibold leading-tight", isDark ? "text-slate-100" : "text-slate-700")}>
                  基于 Agent 的智能视频创作平台
                </p>
                <p className={cn("text-xs leading-relaxed mt-0.5", isDark ? "text-slate-400" : "text-slate-500")}>
                  从剧本到成片，让 AI 完成每一帧
                </p>
              </div>
            </div>
          </motion.div>

          {/* 右上 / 右中 / 右下：能力小卡（4 个环绕右侧） */}
          {FEATURE_CARDS.map((card, i) => {
            const Icon = card.icon;
            // 右侧四个位置（垂直均匀分布）
            const positions = [
              "top-[8%] right-0",
              "top-1/3 right-2",
              "bottom-1/3 right-2",
              "bottom-[8%] right-0",
            ];
            const toneStyles = {
              blue: isDark ? "bg-blue-500/20 text-blue-300" : "bg-blue-500/15 text-blue-600",
              amber: isDark ? "bg-amber-500/20 text-amber-300" : "bg-amber-500/15 text-amber-600",
              emerald: isDark ? "bg-emerald-500/20 text-emerald-300" : "bg-emerald-500/15 text-emerald-600",
              violet: isDark ? "bg-violet-500/20 text-violet-300" : "bg-violet-500/15 text-violet-600",
              indigo: isDark ? "bg-indigo-500/20 text-indigo-300" : "bg-indigo-500/15 text-indigo-600",
            } as const;
            return (
              <motion.div
                key={card.title}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.45, delay: 0.3 + i * 0.12, ease: "easeOut" }}
                whileHover={{ scale: 1.05, y: -3, transition: { duration: 0.2 } }}
                className={cn(
                  "absolute rounded-full pl-2 pr-4 py-2 backdrop-blur-xl border shadow-md flex items-center gap-2",
                  "transition-colors duration-200",
                  positions[i],
                  isDark
                    ? "border-white/12 bg-white/8 hover:border-white/30"
                    : "border-white/70 bg-white/80 hover:border-indigo-300/70 hover:shadow-lg"
                )}
              >
                <span
                  className={cn(
                    "grid size-7 place-items-center rounded-full transition-transform duration-200",
                    toneStyles[card.tone]
                  )}
                >
                  <Icon className="h-3.5 w-3.5" />
                </span>
                <span className={cn("text-sm font-medium whitespace-nowrap", isDark ? "text-slate-100" : "text-slate-700")}>
                  {card.title}
                </span>
              </motion.div>
            );
          })}

          {/* 左下：胶囊型计费卡片（参考图"按量付费"风格） */}
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.45, delay: 0.8, ease: "easeOut" }}
            whileHover={{ scale: 1.05, y: -3, transition: { duration: 0.2 } }}
            className={cn(
              "absolute bottom-4 left-4 rounded-full pl-2 pr-4 py-2 backdrop-blur-xl border shadow-md flex items-center gap-2",
              "transition-colors duration-200",
              isDark
                ? "border-white/12 bg-white/8 hover:border-white/30"
                : "border-white/70 bg-white/80 hover:border-violet-300/70 hover:shadow-lg"
            )}
          >
            <span
              className={cn(
                "grid size-7 place-items-center rounded-full transition-transform duration-200",
                isDark ? "bg-violet-500/20 text-violet-300" : "bg-violet-500/15 text-violet-600"
              )}
            >
              <CreditCard className="h-3.5 w-3.5" />
            </span>
            <span className={cn("text-sm font-medium whitespace-nowrap", isDark ? "text-slate-100" : "text-slate-700")}>
              按量付费
            </span>
          </motion.div>
        </div>

        {/* 底部版本 */}
        <p className={cn("relative z-10 text-xs", isDark ? "text-slate-600" : "text-slate-400")}>
          云揽镜 · AI 视频创作平台
        </p>
      </div>

      {/* ============ 右栏：表单区域（移动端堆叠为单列） ============ */}
      <div className="relative flex flex-1 flex-col items-center justify-center px-5 py-10 min-h-screen lg:min-h-0">
        {/* 移动端品牌标识（桌面端左栏已展示，此处仅移动端显示） */}
        <div className="flex lg:hidden items-center gap-3 mb-6 self-start">
          <Image
            src="/logo.png"
            alt="云揽镜"
            width={480}
            height={96}
            priority
            className="h-9 w-auto"
          />
          <div className="flex items-center text-[1.4rem] font-semibold tracking-[0.02em]">
            <span className="text-transparent bg-[linear-gradient(96deg,#7adcf2_0%,#2EC7D5_38%,#2488C8_100%)] bg-clip-text">
              云揽
            </span>
            <span className="text-transparent bg-[linear-gradient(96deg,#FCB659_0%,#FF9F68_34%,#E65979_100%)] bg-clip-text">
              镜
            </span>
          </div>
        </div>

        {/* 右上角主题切换 */}
        <div className="absolute top-5 right-5 z-20">
          <AnimatedThemeToggler className="text-foreground/70 hover:text-foreground hover:bg-foreground/8" />
        </div>

        {/* 层次感毛玻璃表单卡片：柔和投影 + 顶部高光 + 大圆角 */}
        <motion.div
          initial={{ opacity: 0, y: 24, scale: 0.98 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ duration: 0.45, ease: "easeOut" }}
          className={cn(
            "relative w-full max-w-md overflow-hidden rounded-2xl p-6 sm:p-9",
            "backdrop-blur-xl border shadow-2xl",
            isDark
              ? "border-white/10 bg-white/5 shadow-indigo-950/50"
              : "border-white/70 bg-white/70 shadow-indigo-200/70"
          )}
        >
          {/* 顶部高光 */}
          <div
            className={cn(
              "absolute inset-x-0 top-0 h-px",
              isDark
                ? "bg-linear-to-r from-transparent via-white/30 to-transparent"
                : "bg-linear-to-r from-transparent via-white/90 to-transparent"
            )}
          />
          {/* 角落柔光 */}
          <div
            className={cn(
              "pointer-events-none absolute -top-14 -right-14 size-36 rounded-full blur-3xl",
              isDark ? "bg-indigo-500/15" : "bg-indigo-200/50"
            )}
          />
          <div
            className={cn(
              "pointer-events-none absolute -bottom-16 -left-16 size-40 rounded-full blur-3xl",
              isDark ? "bg-purple-500/10" : "bg-purple-200/40"
            )}
          />

          <div className="relative">
            <AnimatePresence mode="wait">
              {!showSuccess ? (
                <motion.div
                  key="form-content"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.4, ease: "easeOut" }}
                  className="space-y-6 text-center"
                >
                  {children}
                </motion.div>
              ) : (
                // 成功状态 - 只显示文字，打勾圆形通过 portal 传送到 body
                <motion.div
                  key="success"
                  initial={{ opacity: 0, y: 50 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, ease: "easeOut" }}
                  className="space-y-6 text-center"
                >
                  <div className="space-y-1">
                    <h1 className={cn(
                      "text-[2.5rem] font-bold leading-[1.1] tracking-tight",
                      isDark ? "text-white" : "text-foreground"
                    )}>
                      {successTitle}
                    </h1>
                    <p className={cn(
                      "text-[1.25rem] font-light",
                      isDark ? "text-white/50" : "text-muted-foreground"
                    )}>
                      {successSubtitle}
                    </p>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </motion.div>
      </div>

      {/* 打勾 + 扩散圆形 - 通过 createPortal 传送到 body，脱离层叠上下文 */}
      {showSuccess &&
        isClient &&
        createPortal(
          <div
            style={{
              position: "fixed",
              inset: 0,
              zIndex: 9999,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              pointerEvents: "none",
            }}
          >
            <motion.div
              style={{
                position: "absolute",
                top: "calc(50% - 1rem)",
                left: "50%",
                translateX: "-50%",
              }}
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.6 }}
            >
              <motion.div
                className="w-16 h-16 rounded-full bg-white flex items-center justify-center"
                initial={{ scale: 1 }}
                animate={{ scale: 60 }}
                transition={{
                  duration: 0.6,
                  delay: 1.5,
                  ease: [0.55, 0, 1, 0.45],
                }}
                onAnimationComplete={() => onTransitionComplete?.()}
              >
                <motion.svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-8 w-8 text-black"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  initial={{ opacity: 1 }}
                  animate={{ opacity: 0 }}
                  transition={{ duration: 0.3, delay: 1.3 }}
                >
                  <path
                    fillRule="evenodd"
                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                    clipRule="evenodd"
                  />
                </motion.svg>
              </motion.div>
            </motion.div>
          </div>,
          document.body
        )}
    </div>
  );
};
