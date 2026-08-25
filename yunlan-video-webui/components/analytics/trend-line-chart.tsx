"use client";

import * as React from "react";
import { useTheme } from "next-themes";
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import type { TrendPoint } from "@/lib/api/analytics";
import { cn } from "@/lib/utils";

interface TrendLineChartProps {
  data: TrendPoint[];
  className?: string;
}

interface TooltipContentProps {
  active?: boolean;
  payload?: Array<{ name?: string; value?: number | string; color?: string }>;
  label?: string | number;
}

function TrendTooltip({ active, payload, label }: TooltipContentProps) {
  if (!active || !payload || payload.length === 0) return null;
  return (
    <div
      className={cn(
        "rounded-lg border border-border/40 bg-popover/90 backdrop-blur-sm px-3 py-2",
        "shadow-lg text-xs"
      )}
    >
      <p className="font-medium mb-1.5">{label}</p>
      {payload.map((entry) => (
        <p key={String(entry.name)} className="flex items-center gap-1.5 leading-5">
          <span
            className="inline-block h-2 w-2 rounded-full"
            style={{ backgroundColor: entry.color }}
          />
          <span className="text-muted-foreground">{entry.name}</span>
          <span className="ml-auto pl-3 font-medium tabular-nums">{entry.value}</span>
        </p>
      ))}
    </div>
  );
}

export function TrendLineChart({ data, className }: TrendLineChartProps) {
  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = React.useState(false);

  React.useEffect(() => {
    setMounted(true);
  }, []);

  const isDark = mounted ? resolvedTheme === "dark" : false;

  const axisStroke = isDark ? "#64748B" : "#94A3B8";
  const gridStroke = isDark ? "rgba(148,163,184,0.14)" : "rgba(100,116,139,0.14)";

  const hasData = data.some((p) => p.image > 0 || p.video > 0);

  return (
    <div className={cn("rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-4", className)}>
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h3 className="text-sm font-semibold">近 30 天创作趋势</h3>
        <div className="flex items-center gap-4 text-xs text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full bg-purple-400" />
            生图任务
          </span>
          <span className="flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full bg-blue-400" />
            生视频任务
          </span>
        </div>
      </div>

      <div className="h-[280px] mt-3">
        {hasData ? (
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data} margin={{ top: 8, right: 4, bottom: 0, left: -16 }}>
              <defs>
                <linearGradient id="gradImage" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#A855F7" stopOpacity={0.32} />
                  <stop offset="100%" stopColor="#A855F7" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="gradVideo" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#3B82F6" stopOpacity={0.32} />
                  <stop offset="100%" stopColor="#3B82F6" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke={gridStroke} vertical={false} />
              <XAxis
                dataKey="label"
                tickLine={false}
                axisLine={false}
                tick={{ fontSize: 11, fill: axisStroke }}
                minTickGap={24}
                dy={6}
              />
              <YAxis
                tickLine={false}
                axisLine={false}
                tick={{ fontSize: 11, fill: axisStroke }}
                allowDecimals={false}
                width={40}
              />
              <Tooltip content={<TrendTooltip />} cursor={{ stroke: gridStroke, strokeDasharray: "4 4" }} />
              <Area
                type="monotone"
                dataKey="image"
                name="生图任务"
                stroke="#A855F7"
                strokeWidth={2}
                fill="url(#gradImage)"
                activeDot={{ r: 4 }}
              />
              <Area
                type="monotone"
                dataKey="video"
                name="生视频任务"
                stroke="#3B82F6"
                strokeWidth={2}
                fill="url(#gradVideo)"
                activeDot={{ r: 4 }}
              />
            </AreaChart>
          </ResponsiveContainer>
        ) : (
          <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
            近 30 天暂无创作任务
          </div>
        )}
      </div>
    </div>
  );
}
