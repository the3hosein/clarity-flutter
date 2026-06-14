import { motion } from 'framer-motion'
import { springs } from '../../lib/springs'
import type { ReactNode } from 'react'

interface CardProps {
  children: ReactNode
  className?: string
  onClick?: () => void
  delay?: number
}

export function Card({ children, className = '', onClick, delay = 0 }: CardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ ...springs.smooth, delay }}
      whileTap={onClick ? { scale: 0.97 } : undefined}
      onClick={onClick}
      className={`rounded-2xl bg-[var(--card)] p-4 shadow-[var(--shadow-sm)] ${onClick ? 'cursor-pointer' : ''} ${className}`}
    >
      {children}
    </motion.div>
  )
}
