"use client";

import React from "react";
import { motion } from "framer-motion";

/**
 * 点状地球 + 环绕轨道装饰组件
 *
 * 视觉构成：
 * - 中心：点阵模拟的地球（同心圆点网格），带淡蓝紫渐变光晕
 * - 轨道：两条倾斜角度不同的紫色椭圆轨道（轨道固定不动）
 * - 光点：轨道上滑动的蓝色/白色光点（SVG animateMotion 沿椭圆路径运动）
 *
 * 支持明暗双主题配色，鼠标 hover 时轻微旋转。
 */
export function OrbitGlobe({
  className,
  isDark = true,
  size = 360,
}: {
  className?: string;
  /** 是否深色主题（影响点阵与轨道配色） */
  isDark?: boolean;
  /** SVG 渲染尺寸（1:1 正方形） */
  size?: number;
}) {
  const dotColor = isDark ? "#8b9dc9" : "#64748b";
  const dotHighlight = isDark ? "#c7d6f0" : "#334155";
  const orbitColor = isDark ? "rgba(168,85,247,0.45)" : "rgba(168,85,247,0.4)";
  const orbitColorStrong = isDark ? "rgba(168,85,247,0.75)" : "rgba(139,92,246,0.7)";
  const glowColor = isDark ? "rgba(99,102,241,0.28)" : "rgba(99,102,241,0.16)";
  const sphereGradA = isDark ? "#818cf8" : "#a5b4fc";
  const sphereGradB = isDark ? "#312e81" : "#e0e7ff";

  const cx = 140;
  const cy = 140;

  // 球体点阵：由多个半径的圆上的点组成（模拟地球经纬网格），确定性生成避免 SSR 不一致
  const dots: { x: number; y: number; r: number; dim?: boolean }[] = [];
  const rings = [
    { radius: 34, count: 10 },
    { radius: 62, count: 16 },
    { radius: 88, count: 22 },
    { radius: 110, count: 28 },
  ];
  for (let ring = 0; ring < rings.length; ring++) {
    const { radius, count } = rings[ring];
    const yCompress = 0.42 + ring * 0.13;
    for (let i = 0; i < count; i++) {
      const angle = (i / count) * Math.PI * 2;
      const x = cx + Math.cos(angle) * radius;
      const y = cy + Math.sin(angle) * radius * yCompress;
      dots.push({ x, y, r: ring < 2 ? 1.6 : 1.2, dim: ring >= 2 });
    }
  }
  // 中心密集点（球心区域）
  for (let i = 0; i < 18; i++) {
    const angle = (i / 18) * Math.PI * 2 + (i % 3) * 0.35;
    const radius = 6 + ((i * 37) % 17);
    const x = cx + Math.cos(angle) * radius;
    const y = cy + Math.sin(angle) * radius * 0.6;
    dots.push({ x, y, r: 1.1, dim: true });
  }

  // 椭圆轨道路径（用于 animateMotion）：从椭圆左侧点出发绕一圈回到同一点
  const orbit1Path = `M ${cx - 142} ${cy} A 142 52 0 1 1 ${142 * 2} 0 A 142 52 0 1 1 ${-142 * 2} 0`;
  const orbit2Path = `M ${cx - 152} ${cy} A 152 58 0 1 1 ${152 * 2} 0 A 152 58 0 1 1 ${-152 * 2} 0`;

  return (
    <motion.div
      className={className}
      whileHover={{ rotate: 8, scale: 1.03 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
      style={{ width: size, height: size }}
      aria-hidden
    >
      <svg viewBox="0 0 280 280" className="h-full w-full overflow-visible">
        <defs>
          <radialGradient id="orbit-sphere-grad" cx="38%" cy="32%" r="75%">
            <stop offset="0%" stopColor={sphereGradA} stopOpacity="0.55" />
            <stop offset="100%" stopColor={sphereGradB} stopOpacity="0.12" />
          </radialGradient>
          <radialGradient id="orbit-glow-grad" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor={glowColor} />
            <stop offset="100%" stopColor="transparent" />
          </radialGradient>
        </defs>

        {/* 球体光晕 */}
        <circle cx={cx} cy={cy} r={118} fill="url(#orbit-glow-grad)" />

        {/* 点状地球：球体持续自转，轨道保持固定 */}
        <motion.g
          animate={{ rotate: 360 }}
          transition={{ duration: 40, repeat: Infinity, ease: "linear" }}
          style={{ transformOrigin: `${cx}px ${cy}px` }}
        >
          <circle cx={cx} cy={cy} r={112} fill="url(#orbit-sphere-grad)" />
          <circle
            cx={cx}
            cy={cy}
            r={112}
            fill="none"
            stroke={orbitColor}
            strokeWidth="0.8"
            strokeOpacity="0.35"
          />
          {dots.map((d, i) => (
            <circle
              key={i}
              cx={d.x}
              cy={d.y}
              r={d.r}
              fill={d.dim ? dotColor : dotHighlight}
              opacity={d.dim ? 0.5 : 0.85}
            />
          ))}
          {/* 球体高光点 */}
          <circle cx={cx - 30} cy={cy - 34} r={2.4} fill={isDark ? "#e0e7ff" : "#ffffff"} opacity={0.9} />
        </motion.g>

        {/* 轨道 1：水平椭圆，固定，光点沿椭圆滑动 */}
        <g>
          <ellipse
            cx={cx}
            cy={cy}
            rx={142}
            ry={52}
            fill="none"
            stroke={orbitColor}
            strokeWidth="1.2"
            strokeDasharray="4 6"
          />
          <circle cx={cx - 142} cy={cy} r={4} fill={isDark ? "#93c5fd" : "#3b82f6"}>
            <animateMotion dur="14s" repeatCount="indefinite" path={orbit1Path} />
          </circle>
        </g>

        {/* 轨道 2：倾斜椭圆，固定，光点沿椭圆滑动 */}
        <g transform={`rotate(-22 ${cx} ${cy})`}>
          <ellipse
            cx={cx}
            cy={cy}
            rx={152}
            ry={58}
            fill="none"
            stroke={orbitColorStrong}
            strokeWidth="1.4"
          />
          <circle cx={cx - 152} cy={cy} r={4.5} fill={isDark ? "#a5b4fc" : "#8b5cf6"}>
            <animateMotion dur="20s" repeatCount="indefinite" path={orbit2Path} />
          </circle>
        </g>

        {/* 顶部亮点 */}
        <circle cx={cx} cy={cy - 116} r={2.6} fill={isDark ? "#f0abfc" : "#a855f7"} opacity={0.9} />
      </svg>
    </motion.div>
  );
}
