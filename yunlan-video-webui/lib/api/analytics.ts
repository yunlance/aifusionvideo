"use client";

import { projectApi, type Project } from "./project";
import {
  generationApi,
  type GenerationTaskBase,
  type ImageGenerationTask,
  type VideoGenerationTask,
} from "./generation";
import type { PageResult } from "./types";

// 后端 PageParam 限制 pageSize 最大 100
const PAGE_SIZE = 100;
// 安全上限：最多翻 50 页（5000 条），避免异常数据拖垮前端
const MAX_PAGES = 50;

export interface TrendPoint {
  /** 完整日期键，如 2026-08-01 */
  date: string;
  /** 展示标签，如 08-01 */
  label: string;
  image: number;
  video: number;
}

export interface AnalyticsSummary {
  projectCount: number;
  imageTaskCount: number;
  videoTaskCount: number;
  /** 成功任务数 */
  successCount: number;
  /** 总任务数 */
  totalCount: number;
  /** 整体成功率 0~1 */
  successRate: number;
  /** 近 30 天趋势，日期升序、补零 */
  trend: TrendPoint[];
  /** 类型分布：生图 / 生视频 */
  typeDistribution: { name: string; value: number }[];
}

// ============================================================
// 工具
// ============================================================

function formatLocalKey(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/** ISO 字符串 → 本地日期键（YYYY-MM-DD） */
function toDateKey(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return formatLocalKey(d);
}

function toLabel(dateKey: string): string {
  return dateKey.slice(5);
}

/** 生成最近 days 天的连续日期键数组（升序） */
function buildRecentDateKeys(days = 30): string[] {
  const keys: string[] = [];
  const today = new Date();
  for (let i = days - 1; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(today.getDate() - i);
    keys.push(formatLocalKey(d));
  }
  return keys;
}

// ============================================================
// 全量拉取
// ============================================================

/**
 * 循环翻页拉取当前用户的全量数据。
 * 分页接口按 userId 过滤、createTime 倒序，pageSize 上限 100。
 */
async function fetchAllPage<T>(
  fetchPage: (pageNo: number, pageSize: number) => Promise<PageResult<T>>,
): Promise<T[]> {
  const all: T[] = [];
  for (let pageNo = 1; pageNo <= MAX_PAGES; pageNo++) {
    const page = await fetchPage(pageNo, PAGE_SIZE);
    all.push(...page.list);
    if (page.list.length === 0 || all.length >= page.total) break;
  }
  return all;
}

export interface AnalyticsRawData {
  projects: Project[];
  imageTasks: ImageGenerationTask[];
  videoTasks: VideoGenerationTask[];
}

/** 并行拉取项目 + 生图 + 生视频全量数据 */
export async function fetchAnalyticsRaw(): Promise<AnalyticsRawData> {
  const [projects, imageTasks, videoTasks] = await Promise.all([
    projectApi.list(),
    fetchAllPage<ImageGenerationTask>((p, s) => generationApi.pageImageTasks(p, s)),
    fetchAllPage<VideoGenerationTask>((p, s) => generationApi.pageVideoTasks(p, s)),
  ]);
  return { projects, imageTasks, videoTasks };
}

// ============================================================
// 聚合
// ============================================================

/** 统计全部任务的成功率（successCount 之和 / count 之和） */
function calcSuccessStats(tasks: GenerationTaskBase[]): { successCount: number; totalCount: number } {
  let total = 0;
  let success = 0;
  for (const task of tasks) {
    total += task.count ?? 0;
    success += task.successCount ?? 0;
  }
  return { successCount: success, totalCount: total };
}

export function aggregateAnalytics(raw: AnalyticsRawData): AnalyticsSummary {
  const { projects, imageTasks, videoTasks } = raw;

  const dateKeys = buildRecentDateKeys(30);
  const bucket = new Map<string, { image: number; video: number }>();
  for (const key of dateKeys) {
    bucket.set(key, { image: 0, video: 0 });
  }

  for (const task of imageTasks) {
    const key = toDateKey(task.createTime);
    const slot = bucket.get(key);
    if (slot) slot.image += 1;
  }
  for (const task of videoTasks) {
    const key = toDateKey(task.createTime);
    const slot = bucket.get(key);
    if (slot) slot.video += 1;
  }

  const trend: TrendPoint[] = dateKeys.map((date) => {
    const slot = bucket.get(date)!;
    return { date, label: toLabel(date), image: slot.image, video: slot.video };
  });

  const imageTaskCount = imageTasks.length;
  const videoTaskCount = videoTasks.length;

  const successStats = calcSuccessStats([...imageTasks, ...videoTasks]);
  const successRate =
    successStats.totalCount > 0 ? Math.min(1, successStats.successCount / successStats.totalCount) : 0;

  const typeDistribution: { name: string; value: number }[] = [];
  if (imageTaskCount > 0) typeDistribution.push({ name: "生图任务", value: imageTaskCount });
  if (videoTaskCount > 0) typeDistribution.push({ name: "生视频任务", value: videoTaskCount });

  return {
    projectCount: projects.length,
    imageTaskCount,
    videoTaskCount,
    successCount: successStats.successCount,
    totalCount: successStats.totalCount,
    successRate,
    trend,
    typeDistribution,
  };
}

// ============================================================
// 数据 Hook（供页面使用）
// ============================================================

import { useCallback, useEffect, useRef, useState } from "react";

export interface UseAnalyticsDataResult {
  data: AnalyticsSummary | null;
  loading: boolean;
  error: string | null;
  refresh: () => void;
}

export function useAnalyticsData(): UseAnalyticsDataResult {
  const [data, setData] = useState<AnalyticsSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const requestSeq = useRef(0);

  const load = useCallback(async () => {
    const seq = ++requestSeq.current;
    setLoading(true);
    setError(null);
    try {
      const raw = await fetchAnalyticsRaw();
      // 若期间触发过新的加载，丢弃本次过期结果
      if (seq !== requestSeq.current) return;
      setData(aggregateAnalytics(raw));
    } catch (err) {
      if (seq !== requestSeq.current) return;
      setError(err instanceof Error ? err.message : "数据加载失败");
    } finally {
      if (seq === requestSeq.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  return { data, loading, error, refresh: load };
}
