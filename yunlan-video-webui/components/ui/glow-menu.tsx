"use client"

import * as React from "react"
import { motion } from "framer-motion"
import { useTheme } from "next-themes"
import { cn } from "@/lib/utils"

interface TopBarProps {
  className?: string
  /** 左侧区域（如 Logo + 品牌名） */
  leftContent?: React.ReactNode
  /** 右侧区域（如主题切换、通知、用户头像） */
  rightContent?: React.ReactNode
  /** 移动端额外控件（如汉堡按钮），在移动布局中渲染 */
  mobileControls?: React.ReactNode
}

const navGlowVariants = {
  initial: { opacity: 0 },
  hover: {
    opacity: 1,
    transition: { duration: 0.5, ease: [0.4, 0, 0.2, 1] as [number, number, number, number] },
  },
}

/**
 * 顶部栏容器。
 * 仅承载 Logo/品牌与右侧操作区，不再渲染横向导航菜单。
 * 保留毛玻璃 + 细边框 + 光晕外壳，视觉与原有顶部栏一致。
 */
export const TopBar = React.forwardRef<HTMLDivElement, TopBarProps>(
  ({ className, leftContent, rightContent, mobileControls }, ref) => {
    const { resolvedTheme } = useTheme()
    const [mounted, setMounted] = React.useState(false)

    React.useEffect(() => {
      setMounted(true)
    }, [])

    const isDarkTheme = mounted ? resolvedTheme === "dark" : true

    return (
      <motion.div
        ref={ref}
        className={cn(
          "p-2 rounded-2xl bg-linear-to-b from-background/80 to-background/40 backdrop-blur-lg border border-border/40 shadow-lg relative overflow-hidden",
          className,
        )}
        initial="initial"
        whileHover="hover"
      >
        <motion.div
          className={`absolute -inset-2 bg-gradient-radial from-transparent ${
            isDarkTheme
              ? "via-blue-400/30 via-30% via-purple-400/30 via-60% via-red-400/30 via-90%"
              : "via-blue-400/20 via-30% via-purple-400/20 via-60% via-red-400/20 via-90%"
          } to-transparent rounded-3xl z-0 pointer-events-none`}
          variants={navGlowVariants}
        />
        <div className="flex items-center w-full relative z-10 justify-between">
          {leftContent && <div className="shrink-0 mr-2 md:mr-4">{leftContent}</div>}
          {mobileControls && (
            <div className="flex items-center lg:hidden">{mobileControls}</div>
          )}
          {rightContent && <div className="shrink-0 ml-auto md:ml-4">{rightContent}</div>}
        </div>
      </motion.div>
    )
  },
)

TopBar.displayName = "TopBar"
