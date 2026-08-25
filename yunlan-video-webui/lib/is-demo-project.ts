import type { Project } from "@/lib/api/project";

/**
 * 判断项目是否为演示项目（系统内置参考数据，不可删除/修改）。
 * project.properties 可能是 JSON 字符串或已解析对象。
 */
export function isDemoProject(project: Project | null | undefined): boolean {
  const raw = project?.properties;
  if (raw == null) return false;
  const props =
    typeof raw === "string"
      ? (() => {
          try {
            return JSON.parse(raw);
          } catch {
            return null;
          }
        })()
      : raw;
  return Boolean((props as { demo?: boolean } | null)?.demo === true);
}
