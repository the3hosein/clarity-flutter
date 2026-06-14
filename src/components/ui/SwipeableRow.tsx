import { motion, useMotionValue, type PanInfo } from 'framer-motion'
import { springs } from '../../lib/springs'
import type { ReactNode } from 'react'

interface SwipeAction {
  label: string
  color: string
  onClick: () => void
}

interface SwipeableRowProps {
  children: ReactNode
  leftActions?: SwipeAction[]
  rightActions?: SwipeAction[]
}

export function SwipeableRow({ children, leftActions = [], rightActions = [] }: SwipeableRowProps) {
  const x = useMotionValue(0)
  const leftWidth = leftActions.length * 72
  const rightWidth = rightActions.length * 72

  const handleDragEnd = (_: unknown, info: PanInfo) => {
    if (info.offset.x > 60 && leftActions.length) x.set(leftWidth)
    else if (info.offset.x < -60 && rightActions.length) x.set(-rightWidth)
    else x.set(0)
  }

  return (
    <div className="relative overflow-hidden rounded-xl">
      {leftActions.length > 0 && (
        <div className="absolute inset-y-0 left-0 flex">
          {leftActions.map((a) => (
            <button
              key={a.label}
              type="button"
              onClick={a.onClick}
              className="flex w-[72px] items-center justify-center text-xs font-medium text-white"
              style={{ background: a.color }}
            >
              {a.label}
            </button>
          ))}
        </div>
      )}
      {rightActions.length > 0 && (
        <div className="absolute inset-y-0 right-0 flex">
          {rightActions.map((a) => (
            <button
              key={a.label}
              type="button"
              onClick={a.onClick}
              className="flex w-[72px] items-center justify-center text-xs font-medium text-white"
              style={{ background: a.color }}
            >
              {a.label}
            </button>
          ))}
        </div>
      )}
      <motion.div
        drag="x"
        dragConstraints={{ left: -rightWidth, right: leftWidth }}
        dragElastic={0.1}
        style={{ x }}
        onDragEnd={handleDragEnd}
        transition={springs.smooth}
        className="relative bg-[var(--card)]"
      >
        {children}
      </motion.div>
    </div>
  )
}
