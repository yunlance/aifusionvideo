"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import {
  LayoutDashboard,
  BarChart3,
  FolderKanban,
  BookOpen,
  Film,
  Images,
  Users,
  Settings,
  ArrowLeft,
  Bot,
  HardDrive,
  ImagePlus,
  Video,
  ChevronDown,
  PanelLeftClose,
  PanelLeftOpen,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { projectApi, type Project } from "@/lib/api/project";
import { toastApiError } from "@/lib/api/toast-api-error";
import { useAuthStore } from "@/lib/store/auth-store";
import { primaryNavItems } from "@/lib/nav";

// ========== 各模块的二级菜单配置 ==========

interface SidebarItem {
  key: string;
  label: string;
  icon: LucideIcon;
  href: string;
  iconColor: string;
}

interface NavSection {
  key: string;
  label: string;
  href: string;
  icon: LucideIcon;
  iconColor: string;
  children: SidebarItem[];
}

const dashboardItems: SidebarItem[] = [
  { key: "overview", label: "总览", icon: LayoutDashboard, href: "/dashboard", iconColor: "text-blue-400" },
  { key: "analytics", label: "数据分析", icon: BarChart3, href: "/dashboard/analytics", iconColor: "text-purple-400" },
];

const projectListItems: SidebarItem[] = [
  { key: "list", label: "项目列表", icon: FolderKanban, href: "/projects", iconColor: "text-purple-400" },
];

const projectDetailItems: SidebarItem[] = [
  { key: "", label: "概览", icon: LayoutDashboard, href: "", iconColor: "text-blue-400" },
  { key: "scripts", label: "剧本", icon: BookOpen, href: "/scripts", iconColor: "text-purple-400" },
  { key: "storyboards", label: "分镜", icon: Film, href: "/storyboards", iconColor: "text-cyan-400" },
  { key: "assets", label: "素材", icon: Images, href: "/assets", iconColor: "text-orange-400" },
  // { key: "members", label: "成员", icon: Users, href: "/members", iconColor: "text-green-400" },
  { key: "settings", label: "设置", icon: Settings, href: "/settings", iconColor: "text-rose-400" },
];

const assetItems: SidebarItem[] = [
  { key: "list", label: "全部素材", icon: Images, href: "/assets", iconColor: "text-orange-400" },
];

const generationItems: SidebarItem[] = [
  { key: "image", label: "生图", icon: ImagePlus, href: "/generate/image", iconColor: "text-fuchsia-400" },
  { key: "video", label: "生视频", icon: Video, href: "/generate/video", iconColor: "text-cyan-400" },
];

interface SidebarNavProps {
  /** 导航后回调，移动端抽屉用于关闭面板 */
  onNavigate?: () => void;
  /** 当前项目，未传入时组件会按路由自行加载 */
  project?: Project | null;
  /** 桌面端是否以图标栏形态收起 */
  collapsed?: boolean;
  /** 切换桌面端侧栏收起状态 */
  onCollapsedChange?: (collapsed: boolean) => void;
}

// ========== 侧边栏组件 ==========

export function SidebarNav({
  onNavigate,
  project: projectProp,
  collapsed = false,
  onCollapsedChange,
}: SidebarNavProps) {
  const router = useRouter();
  const pathname = usePathname();
  const currentUser = useAuthStore((state) => state.user);
  const isAdmin = currentUser?.roles?.includes("admin") ?? false;

  const projectMatch = pathname.match(/^\/projects\/(\d+)/);
  const projectId = projectMatch ? Number(projectMatch[1]) : null;
  const [projectLocalState, setProjectLocalState] = useState<{
    id: number;
    project: Project;
  } | null>(null);

  const settingsItems: SidebarItem[] = isAdmin
    ? [
      { key: "general", label: "通用设置", icon: Settings, href: "/settings/general", iconColor: "text-green-400" },
      { key: "users", label: "用户列表", icon: Users, href: "/settings/users", iconColor: "text-cyan-400" },
      { key: "profile", label: "个人设置", icon: Users, href: "/settings/profile", iconColor: "text-blue-400" },
      { key: "ai-models", label: "AI 配置", icon: Bot, href: "/settings/ai-models", iconColor: "text-purple-400" },
      { key: "agents", label: "智能体配置", icon: Bot, href: "/settings/agents", iconColor: "text-violet-400" },
      { key: "storage", label: "存储配置", icon: HardDrive, href: "/settings/storage", iconColor: "text-orange-400" },
    ]
    : [
      { key: "profile", label: "个人设置", icon: Users, href: "/settings/profile", iconColor: "text-blue-400" },
      { key: "agents", label: "智能体配置", icon: Bot, href: "/settings/agents", iconColor: "text-violet-400" },
    ];

  // 若外部已传入 project，则不在组件内自行请求
  const project =
    projectProp !== undefined
      ? projectProp
      : projectLocalState?.id === projectId
        ? projectLocalState.project
        : null;

  useEffect(() => {
    if (projectProp !== undefined) return; // 由外部管理，跳过
    if (!projectId) return;

    let cancelled = false;
    projectApi.get(projectId)
      .then((projectData) => {
        if (!cancelled) {
          setProjectLocalState({ id: projectId, project: projectData });
        }
      })
      .catch((error) => {
        if (!cancelled) toastApiError(error, "加载项目信息失败");
      });

    return () => {
      cancelled = true;
    };
  }, [projectId, projectProp]);

  // ========== 当前激活的一级模块（仅用于高亮，不影响展开状态） ==========
  let activeModuleKey = "dashboard";
  if (projectId || pathname.startsWith("/projects")) {
    activeModuleKey = "projects";
  } else if (pathname.startsWith("/dashboard")) {
    activeModuleKey = "dashboard";
  } else if (pathname.startsWith("/assets")) {
    activeModuleKey = "assets";
  } else if (pathname.startsWith("/generate")) {
    activeModuleKey = "tools";
  } else if (pathname.startsWith("/settings")) {
    activeModuleKey = "settings";
  }

  // 手风琴展开状态：初始仅展开当前模块，之后完全由用户点击一级菜单控制，
  // 路由切换绝不改变展开状态 → 跳转页面时左侧菜单保持固定不闪动。
  const [expandedKey, setExpandedKey] = useState<string | null>(activeModuleKey);

  // 项目模块的二级子菜单：项目详情时包含"返回项目列表"入口
  const projectChildren: SidebarItem[] = projectId
    ? [
      { key: "back", label: "返回项目列表", icon: ArrowLeft, href: "/projects", iconColor: "text-muted-foreground" },
      ...projectDetailItems.map((item) => ({
        ...item,
        href: `/projects/${projectId}${item.href}`,
      })),
    ]
    : projectListItems;

  // 树状导航：一级项 + 二级子菜单（children 按当前路由/权限动态组装）
  const sections: NavSection[] = primaryNavItems.map((item) => {
    const children =
      item.key === "dashboard"
        ? dashboardItems
        : item.key === "projects"
          ? projectChildren
          : item.key === "assets"
            ? assetItems
            : item.key === "tools"
              ? generationItems
              : settingsItems;
    return {
      key: item.key,
      label: item.label,
      href: item.href,
      icon: item.icon,
      iconColor: item.iconColor,
      children,
    };
  });

  const getIsActive = (href: string) => {
    if (projectId) {
      const basePath = `/projects/${projectId}`;
      if (href === basePath) return pathname === basePath;
      return pathname.startsWith(href);
    }
    return pathname === href;
  };

  const handleNav = (href: string) => {
    router.push(href);
    onNavigate?.();
  };

  // 一级菜单点击：只切换手风琴展开状态，不跳转页面
  const handlePrimaryClick = (section: NavSection) => {
    if (collapsed) {
      // 折叠态：点击一级展开侧边栏并展开该模块
      onCollapsedChange?.(false);
      setExpandedKey(section.key);
      return;
    }
    setExpandedKey((prev) => (prev === section.key ? null : section.key));
  };

  return (
    <div
      className={cn(
        "w-full h-[calc(100vh-6rem)] rounded-2xl p-2",
        "bg-card border border-border/40",
        "shadow-lg"
      )}
    >
      {/* 折叠态顶部工具按钮：展开侧栏 / 返回项目列表 */}
      {collapsed && (
        <div className="px-1 pt-2 pb-2 flex flex-col items-center gap-2">
          {onCollapsedChange && (
            <button
              type="button"
              onClick={() => onCollapsedChange(false)}
              className="h-10 w-10 rounded-xl flex items-center justify-center text-muted-foreground hover:text-primary hover:bg-primary/8 transition-colors"
              title="展开菜单栏"
              aria-label="展开菜单栏"
            >
              <PanelLeftOpen className="h-4 w-4" />
            </button>
          )}
          {projectId && (
            <button
              type="button"
              onClick={() => {
                router.push("/projects");
                onNavigate?.();
              }}
              className="h-10 w-10 rounded-xl flex items-center justify-center text-muted-foreground hover:text-foreground hover:bg-foreground/5 transition-colors"
              title="返回项目列表"
              aria-label="返回项目列表"
            >
              <ArrowLeft className="h-4 w-4" />
            </button>
          )}
        </div>
      )}

      {/* 树状导航：一级 + 可展开的二级子菜单（手风琴，无动画） */}
      <div className={cn("flex flex-col overflow-y-auto scrollbar-none min-h-0", collapsed ? "px-1 py-2 gap-1" : "p-1.5 gap-0.5")}>
        {sections.map((section) => {
          const Icon = section.icon;
          const isExpanded = !collapsed && expandedKey === section.key;

          return (
            <div key={section.key} className="w-full">
              {/* 一级项（点击展开/收起二级，不跳转；不高亮选中态，选中态仅由二级项表达） */}
              <button
                onClick={() => handlePrimaryClick(section)}
                title={section.label}
                aria-label={section.label}
                className={cn(
                  "w-full flex items-center rounded-xl text-sm",
                  collapsed ? "h-10 justify-center px-0" : "gap-2.5 px-3 py-2",
                  "text-muted-foreground hover:text-foreground hover:bg-linear-to-r hover:from-violet-500/10 hover:via-indigo-500/8 hover:to-blue-500/10 transition-colors duration-150"
                )}
              >
                <Icon className="h-[18px] w-[18px]" />
                {!collapsed && (
                  <>
                    <span className="flex-1 text-left">{section.label}</span>
                    <ChevronDown
                      className={cn(
                        "h-3.5 w-3.5 text-muted-foreground/50 transition-transform duration-200",
                        isExpanded && "rotate-180"
                      )}
                    />
                  </>
                )}
              </button>

              {/* 二级子菜单（静态展开/收起，无动画保持菜单稳定） */}
              {isExpanded && (
                <div className="mt-1 ml-2 pl-2 border-l border-border/20 space-y-0.5">
                  {section.key === "projects" && projectId && project?.name && (
                    <div className="px-3 pt-1 pb-0.5">
                      <h3 className="text-[11px] font-semibold text-foreground/70 truncate">
                        项目: {project.name}
                      </h3>
                      {project?.description && (
                        <p className="text-[10px] text-muted-foreground/50 truncate">{project.description}</p>
                      )}
                    </div>
                  )}
                  {section.children.map((child) => {
                    const ChildIcon = child.icon;
                    const childActive =
                      child.key === "back" ? pathname === "/projects" : getIsActive(child.href);
                    return (
                      <button
                        key={child.key}
                        onClick={() => handleNav(child.href)}
                        title={child.label}
                        aria-label={child.label}
                        className={cn(
                          "w-full flex items-center gap-2 rounded-lg text-[13px] px-3 py-1.5",
                          "transition-colors duration-150",
                          childActive
                            ? "font-medium text-foreground bg-linear-to-r from-violet-500/18 via-indigo-500/14 to-blue-500/18 shadow-sm"
                            : "text-muted-foreground hover:text-foreground hover:bg-linear-to-r hover:from-violet-500/10 hover:via-indigo-500/8 hover:to-blue-500/10"
                        )}
                      >
                        <ChildIcon className={cn("h-3.5 w-3.5 shrink-0 transition-colors", childActive ? "text-violet-500 dark:text-violet-300" : "")} />
                        <span className="truncate">{child.label}</span>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
