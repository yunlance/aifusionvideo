import {
  LayoutDashboard,
  FolderKanban,
  Images,
  Wrench,
  Settings,
  type LucideIcon,
} from "lucide-react";

/**
 * 一级导航配置。
 * 由侧边栏顶部导航区与顶部栏共用，避免重复定义。
 * icon 采用 LucideIcon 以保持设计语言一致；iconColor 用于选中态语义色高亮。
 */
export interface PrimaryNavItem {
  key: string;
  label: string;
  href: string;
  icon: LucideIcon;
  iconColor: string;
  gradient: string;
}

export const primaryNavItems: PrimaryNavItem[] = [
  {
    key: "dashboard",
    label: "工作台",
    href: "/dashboard",
    icon: LayoutDashboard,
    iconColor: "text-blue-500",
    gradient:
      "radial-gradient(circle, rgba(59,130,246,0.15) 0%, rgba(37,99,235,0.06) 50%, rgba(29,78,216,0) 85%, rgba(29,78,216,0) 100%)",
  },
  {
    key: "projects",
    label: "项目管理",
    href: "/projects",
    icon: FolderKanban,
    iconColor: "text-purple-500",
    gradient:
      "radial-gradient(circle, rgba(168,85,247,0.15) 0%, rgba(147,51,234,0.06) 50%, rgba(126,34,206,0) 85%, rgba(126,34,206,0) 100%)",
  },
  {
    key: "assets",
    label: "素材库",
    href: "/assets",
    icon: Images,
    iconColor: "text-orange-500",
    gradient:
      "radial-gradient(circle, rgba(249,115,22,0.15) 0%, rgba(234,88,12,0.06) 50%, rgba(194,65,12,0) 85%, rgba(194,65,12,0) 100%)",
  },
  {
    key: "tools",
    label: "创作工具",
    href: "/generate/image",
    icon: Wrench,
    iconColor: "text-cyan-500",
    gradient:
      "radial-gradient(circle, rgba(6,182,212,0.15) 0%, rgba(8,145,178,0.06) 50%, rgba(14,116,144,0) 85%, rgba(14,116,144,0) 100%)",
  },
  {
    key: "settings",
    label: "系统设置",
    href: "/settings",
    icon: Settings,
    iconColor: "text-green-500",
    gradient:
      "radial-gradient(circle, rgba(34,197,94,0.15) 0%, rgba(22,163,74,0.06) 50%, rgba(21,128,61,0) 85%, rgba(21,128,61,0) 100%)",
  },
];

/**
 * 根据路径判断一级导航是否处于激活态。
 * 一级菜单 href 通常是模块根路径（如 /generate/image 代表"工具"模块），
 * 因此按"模块前缀"匹配：/generate/image 与 /generate/video 均视为"工具"激活。
 */
export function isPrimaryActive(pathname: string, href: string): boolean {
  // 提取一级模块前缀（取前两段，如 /generate/image -> /generate）
  const modulePrefix = href.split("/").slice(0, 2).join("/") || href;
  return pathname === modulePrefix || pathname.startsWith(`${modulePrefix}/`) || pathname.startsWith(modulePrefix);
}
