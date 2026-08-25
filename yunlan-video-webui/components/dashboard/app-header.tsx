"use client";

import { useEffect, useRef, useCallback } from "react";
import { useRouter, usePathname } from "next/navigation";
import { Bell, Github, LogOut, Settings, Menu, X } from "lucide-react";
import { TopBar } from "@/components/ui/glow-menu";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { UserAvatarDropdown } from "@/components/ui/menu";
import { NotificationPanel } from "@/components/dashboard/notification-panel";
import { ClientErrorBoundary } from "@/components/client-error-boundary";
import { useAuthStore } from "@/lib/store/auth-store";
import { usePipelineStore } from "@/lib/store/pipeline-store";
import { cn } from "@/lib/utils";

/**
 * 顶部栏组件。
 * 横向导航菜单已迁移至左侧边栏，此处仅保留：
 * Logo + 品牌、主题切换、任务通知、GitHub 链接、用户头像与移动端抽屉入口。
 */
export function AppHeader({
  onMenuToggle,
  mobileMenuOpen,
}: {
  /** 移动端触发侧边抽屉开关 */
  onMenuToggle?: () => void;
  /** 移动端抽屉是否打开（用于切换汉堡/关闭图标） */
  mobileMenuOpen?: boolean;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const user = useAuthStore((s) => s.user);
  const logout = useAuthStore((s) => s.logout);
  const restoreRunningPipelines = usePipelineStore(
    (s) => s.restoreRunningPipelines
  );
  const resumePipelineConnections = usePipelineStore(
    (s) => s.resumePipelineConnections
  );
  const bellRef = useRef<HTMLButtonElement>(null);

  // Pipeline 通知
  const {
    tasks,
    notificationOpen,
    setNotificationOpen,
    panelExpanded,
    setPanelExpanded,
  } = usePipelineStore();
  const runningCount = tasks.filter((t) => t.status === "running").length;
  const hasAnyTasks = tasks.length > 0;

  // 页面加载时只恢复 running Pipeline 列表；SSE 由面板选中态管理。
  useEffect(() => {
    restoreRunningPipelines();
  }, [restoreRunningPipelines]);

  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        resumePipelineConnections();
      }
    };
    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => document.removeEventListener("visibilitychange", handleVisibilityChange);
  }, [resumePipelineConnections]);

  // 处理退出登录（layout 会在退出动画完成后自动跳转到登录页）
  const handleLogout = async () => {
    // 等待下拉菜单关闭动画（~200ms）
    await new Promise((resolve) => setTimeout(resolve, 200));
    document.cookie = "auth-token=; path=/; max-age=0";
    await logout();
  };

  const handleNotificationPanelError = useCallback(() => {
    setPanelExpanded(false);
    setNotificationOpen(false);
  }, [setNotificationOpen, setPanelExpanded]);

  // 用户头像下拉菜单项
  const userMenuItems = [
    {
      label: "个人设置",
      icon: <Settings className="h-full w-full" />,
      onClick: () => router.push("/settings/profile"),
    },
  ];

  const userLogoutItem = {
    label: "退出登录",
    icon: <LogOut className="h-full w-full" />,
    onClick: handleLogout,
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-50 px-3 pt-3">
      <TopBar
        className="w-full"
        leftContent={
          <div
            className="flex items-center cursor-pointer shrink-0"
            onClick={() => router.push("/dashboard")}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/logo.png"
              alt="云揽镜"
              className="h-8 w-auto ml-2 rounded-lg"
            />
            <span className="ml-2 text-lg font-bold text-foreground">云揽镜</span>
          </div>
        }
        mobileControls={
          <button
            onClick={onMenuToggle}
            className={cn(
              "p-2 rounded-xl transition-all duration-200",
              "text-muted-foreground hover:text-foreground",
              mobileMenuOpen
                ? "bg-foreground/10 text-foreground"
                : "hover:bg-foreground/5"
            )}
            aria-label={mobileMenuOpen ? "关闭菜单" : "打开菜单"}
          >
            {mobileMenuOpen ? (
              <X className="h-5 w-5" />
            ) : (
              <Menu className="h-5 w-5" />
            )}
          </button>
        }
        rightContent={
          <div className="flex items-center gap-2 justify-end">
            {/* 主题切换按钮 */}
            <AnimatedThemeToggler className="rounded-xl text-violet-500 hover:text-violet-600 hover:bg-violet-500/10 dark:text-violet-300 dark:hover:text-violet-200 dark:hover:bg-violet-400/10 transition-colors" />

            {/* 通知按钮 */}
            <button
              ref={bellRef}
              onClick={() => {
                if (panelExpanded) {
                  setPanelExpanded(false);
                  setNotificationOpen(false);
                } else {
                  setPanelExpanded(true);
                }
              }}
              className={cn(
                "relative p-2 rounded-xl transition-colors",
                "text-amber-500 hover:text-amber-600 hover:bg-amber-500/10 dark:text-amber-300 dark:hover:text-amber-200 dark:hover:bg-amber-400/10",
                panelExpanded
                  ? "bg-amber-500/15 text-amber-600 dark:bg-amber-400/15 dark:text-amber-200"
                  : ""
              )}
            >
              <Bell className="h-5 w-5" />
              {(runningCount > 0 || hasAnyTasks) && (
                <>
                  {/* 扩散光圈：仅运行中时显示 */}
                  {runningCount > 0 && (
                    <span className="absolute top-1 right-1 h-4 w-4 rounded-full bg-blue-500/40 animate-ping" />
                  )}
                  {/* 静态数字徽标 */}
                  <span
                    className={cn(
                      "absolute top-1 right-1 flex items-center justify-center rounded-full ring-2 ring-background/60",
                      runningCount > 0
                        ? "h-4 w-4 bg-blue-500 text-[9px] text-white font-bold"
                        : "h-2 w-2 bg-muted-foreground/40"
                    )}
                  >
                    {runningCount > 0 ? runningCount : null}
                  </span>
                </>
              )}
            </button>

            {/* 通知面板 */}
            <ClientErrorBoundary
              key={`notification-panel-${notificationOpen}-${panelExpanded}`}
              context="AI 任务中心加载失败"
              onError={handleNotificationPanelError}
            >
              <NotificationPanel anchorRef={bellRef} />
            </ClientErrorBoundary>

            <a
              href="https://github.com/yunlance/aifusionvideo"
              target="_blank"
              rel="noreferrer"
              className={cn(
                "p-2 rounded-xl transition-colors",
                "text-sky-500 hover:text-sky-600 hover:bg-sky-500/10 dark:text-sky-300 dark:hover:text-sky-200 dark:hover:bg-sky-400/10"
              )}
              aria-label="打开 GitHub 仓库"
              title="GitHub"
            >
              <Github className="h-5 w-5" />
            </a>

            {/* 用户头像下拉菜单 */}
            <UserAvatarDropdown
              user={{
                name: user?.nickname || user?.username || "用户",
                email: user?.email || user?.username,
                avatarUrl: user?.avatar,
              }}
              menuItems={userMenuItems}
              logoutItem={userLogoutItem}
            />
          </div>
        }
      />
    </header>
  );
}
