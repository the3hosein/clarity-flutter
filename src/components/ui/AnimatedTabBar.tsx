import { motion } from 'framer-motion'
import { springs } from '../../lib/springs'

interface AnimatedTabBarProps {
  tabs: { id: string; label: string }[]
  active: string
  onChange: (id: string) => void
}

export function AnimatedTabBar({ tabs, active, onChange }: AnimatedTabBarProps) {
  return (
    <div className="relative flex gap-1 rounded-xl bg-[var(--bg)] p-1">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          type="button"
          onClick={() => onChange(tab.id)}
          className={`relative z-10 flex-1 rounded-lg px-3 py-2 text-sm font-medium transition-colors duration-150 ${active === tab.id ? 'text-white' : 'text-[var(--text-secondary)]'}`}
        >
          {active === tab.id && (
            <motion.span
              layoutId="tab-pill"
              transition={springs.snappy}
              className="absolute inset-0 rounded-lg bg-[var(--accent)]"
              style={{ zIndex: -1 }}
            />
          )}
          {tab.label}
        </button>
      ))}
    </div>
  )
}

interface ProgressBarProps {
  value: number
  delay?: number
  color?: string
}

export function ProgressBar({ value, delay = 0, color = 'var(--accent)' }: ProgressBarProps) {
  return (
    <div className="h-2 overflow-hidden rounded-full bg-[var(--bg)]">
      <motion.div
        initial={{ width: 0 }}
        animate={{ width: `${Math.min(100, Math.max(0, value))}%` }}
        transition={{ ...springs.smooth, delay }}
        className="h-full rounded-full"
        style={{ background: color }}
      />
    </div>
  )
}
