import { motion } from 'framer-motion'
import { springs } from '../../lib/springs'
import { hapticLight } from '../../lib/haptics'
import type { ReactNode } from 'react'

interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  children: ReactNode
  className?: string
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void
}

const variants = {
  primary: 'bg-[var(--accent)] text-white',
  secondary: 'bg-[var(--accent-soft)] text-[var(--accent)]',
  ghost: 'bg-transparent text-[var(--text-primary)]',
  danger: 'bg-red-500/10 text-[var(--danger)]',
}

export function Button({ variant = 'primary', children, className = '', onClick, disabled, type = 'button' }: ButtonProps) {
  return (
    <motion.button
      type={type}
      disabled={disabled}
      whileTap={{ scale: 0.95 }}
      transition={springs.snappy}
      className={`inline-flex min-h-[44px] items-center justify-center gap-2 rounded-xl px-4 py-2 text-sm font-medium ${variants[variant]} ${className}`}
      onClick={(e) => {
        hapticLight()
        onClick?.(e)
      }}
    >
      {children}
    </motion.button>
  )
}
