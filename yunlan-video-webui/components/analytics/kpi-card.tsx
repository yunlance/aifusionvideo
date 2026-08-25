"use client";

import type { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface KpiCardProps {
  label: string;
  value: string;
  hint?: string;
  icon: LucideIcon;
  iconColor: string;
  iconBg: string;
}

export function KpiCard({ label, value, hint, icon: Icon, iconColor, iconBg }: KpiCardProps) {
  return (
    <div
      className={cn(
        "group rounded-xl border border-border/30 bg-card/50 backdrop-blur-sm p-4",
        "hover:border-border/50 hover:-translate-y-0.5 hover:shadow-sm",
        "transition-[border-color,transform,box-shadow] duration-200 ease-out"
      )}
    >
      <div className="flex items-center gap-2 mb-2.5">
        <div
          className={cn(
            "h-7 w-7 rounded-lg flex items-center justify-center",
            "transition-transform duration-200 ease-out group-hover:scale-110",
            iconBg
          )}
        >
          <Icon className={cn("h-3.5 w-3.5", iconColor)} />
        </div>
        <span className="text-xs text-muted-foreground">{label}</span>
      </div>
      <p className="text-2xl font-bold tracking-tight tabular-nums">{value}</p>
      {hint ? <p className="text-xs text-muted-foreground/70 mt-1">{hint}</p> : null}
    </div>
  );
}
