"use client";

import * as React from "react";
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts";
import { cn } from "@/lib/utils";

interface TypePieChartProps {
  data: Array<{ name: string; value: number }>;
  total: number;
  className?: string;
}

const CHART_COLORS = ["#A855F7", "#3B82F6", "#22D3EE"];

interface PieTooltipContentProps {
  active?: boolean;
  payload?: Array<{ name?: string; value?: number | string; payload?: { name: string } }>;
}

function PieTooltip({ active, payload }: PieTooltipContentProps) {
  if (!active || !payload || payload.length === 0) return null;
  const entry = payload[0];
  return (
    <div
      className={cn(
        "rounded-lg border border-border/40 bg-popover/90 backdrop-blur-sm px-3 py-2",
        "shadow-lg text-xs"
      )}
    >
      <p className="flex items-center gap-1.5">
        <span className="text-muted-foreground">{entry.name}</span>
        <span className="ml-auto pl-3 font-medium tabular-nums">{entry.value}</span>
      </p>
    </div>
  );
}

export function TypePieChart({ data, total, className }: TypePieChartProps) {
  const hasData = data.length > 0 && total > 0;

  return (
    <div className={cn("rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-4", className)}>
      <h3 className="text-sm font-semibold">任务类型分布</h3>
      <div className="h-[280px] mt-3">
        {hasData ? (
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data}
                dataKey="value"
                nameKey="name"
                cx="50%"
                cy="50%"
                innerRadius={70}
                outerRadius={100}
                paddingAngle={4}
                strokeWidth={0}
              >
                {data.map((entry, index) => (
                  <Cell key={entry.name} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip content={<PieTooltip />} />
            </PieChart>
          </ResponsiveContainer>
        ) : (
          <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
            暂无创作任务
          </div>
        )}
      </div>

      {hasData && (
        <div className="flex flex-col gap-2 mt-2">
          {data.map((entry, index) => {
            const pct = total > 0 ? Math.round((entry.value / total) * 100) : 0;
            return (
              <div key={entry.name} className="flex items-center gap-2 text-xs">
                <span
                  className="h-2.5 w-2.5 rounded-sm shrink-0"
                  style={{ backgroundColor: CHART_COLORS[index % CHART_COLORS.length] }}
                />
                <span className="text-muted-foreground">{entry.name}</span>
                <span className="ml-auto tabular-nums font-medium">{entry.value}</span>
                <span className="tabular-nums text-muted-foreground/70 w-9 text-right">{pct}%</span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
