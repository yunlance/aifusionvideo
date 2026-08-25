"use client";

import { BarChart3, FolderKanban, Image as ImageIcon, Film, Target, Loader2 } from "lucide-react";
import { motion } from "framer-motion";
import { useReducedMotion } from "framer-motion";
import { cn } from "@/lib/utils";
import { useAnalyticsData } from "@/lib/api/analytics";
import { KpiCard } from "@/components/analytics/kpi-card";
import { TrendLineChart } from "@/components/analytics/trend-line-chart";
import { TypePieChart } from "@/components/analytics/type-pie-chart";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.1 },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 16 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.45, ease: [0.25, 0.46, 0.45, 0.94] as [number, number, number, number] },
  },
};

function formatPercent(rate: number): string {
  return `${(rate * 100).toFixed(1)}%`;
}

export default function AnalyticsPage() {
  const { data, loading, error, refresh } = useAnalyticsData();
  const reduceMotion = useReducedMotion();

  const motionProps = reduceMotion
    ? undefined
    : { variants: itemVariants };

  return (
    <motion.div
      className="max-w-[1200px]"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <motion.div {...motionProps} className="mb-8">
        <h1 className="text-2xl font-bold tracking-tight flex items-center gap-2">
          <BarChart3 className="h-6 w-6 text-purple-400" />
          数据分析
        </h1>
        <p className="text-sm text-muted-foreground mt-1">
          项目与创作数据的可视化分析
        </p>
      </motion.div>

      {loading && (
        <div className="flex items-center justify-center py-32">
          <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
        </div>
      )}

      {!loading && error && (
        <motion.div
          {...motionProps}
          className={cn(
            "rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm",
            "flex flex-col items-center justify-center py-24 text-center"
          )}
        >
          <p className="text-sm text-muted-foreground max-w-sm mb-4">
            数据加载失败：{error}
          </p>
          <button
            onClick={refresh}
            className={cn(
              "rounded-xl px-4 py-2 text-sm font-medium",
              "bg-linear-to-r from-purple-500 to-blue-500 text-white",
              "hover:opacity-90 transition-opacity cursor-pointer"
            )}
          >
            重新加载
          </button>
        </motion.div>
      )}

      {!loading && !error && data && (
        <>
          {/* ========== KPI 概览 ========== */}
          <motion.div
            {...motionProps}
            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mb-6"
          >
            <KpiCard
              label="项目总数"
              value={String(data.projectCount)}
              icon={FolderKanban}
              iconColor="text-blue-400"
              iconBg="bg-blue-500/10"
            />
            <KpiCard
              label="生图任务"
              value={String(data.imageTaskCount)}
              icon={ImageIcon}
              iconColor="text-purple-400"
              iconBg="bg-purple-500/10"
            />
            <KpiCard
              label="生视频任务"
              value={String(data.videoTaskCount)}
              icon={Film}
              iconColor="text-cyan-400"
              iconBg="bg-cyan-500/10"
            />
            <KpiCard
              label="整体成功率"
              value={formatPercent(data.successRate)}
              hint={`成功 ${data.successCount} / 共 ${data.totalCount} 个`}
              icon={Target}
              iconColor="text-green-400"
              iconBg="bg-green-500/10"
            />
          </motion.div>

          {/* ========== 图表区 ========== */}
          <motion.div
            {...motionProps}
            className="grid grid-cols-1 lg:grid-cols-3 gap-3"
          >
            <TrendLineChart data={data.trend} className="lg:col-span-2" />
            <TypePieChart data={data.typeDistribution} total={data.totalCount} />
          </motion.div>
        </>
      )}
    </motion.div>
  );
}
