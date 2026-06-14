import { motion } from 'framer-motion'

export function WeatherIcon({ code }: { code: number }) {
  if (code === 0) {
    return (
      <svg width="48" height="48" viewBox="0 0 48 48" className="text-[var(--warning)]">
        <motion.circle
          cx="24"
          cy="24"
          r="10"
          fill="currentColor"
          animate={{ rotate: 360 }}
          transition={{ repeat: Infinity, duration: 8, ease: 'linear' }}
          style={{ originX: '24px', originY: '24px' }}
        />
      </svg>
    )
  }
  if (code <= 3) {
    return (
      <motion.svg width="48" height="48" viewBox="0 0 48 48" animate={{ x: [0, 6, 0] }} transition={{ repeat: Infinity, duration: 4 }}>
        <ellipse cx="24" cy="28" rx="14" ry="8" fill="var(--text-tertiary)" />
      </motion.svg>
    )
  }
  return (
    <svg width="48" height="48" viewBox="0 0 48 48">
      {[18, 24, 30].map((x, i) => (
        <motion.line
          key={x}
          x1={x}
          y1="20"
          x2={x}
          y2="32"
          stroke="var(--accent)"
          strokeWidth="2"
          animate={{ y1: [18, 22], y2: [28, 34], opacity: [0, 1, 0] }}
          transition={{ repeat: Infinity, duration: 1, delay: i * 0.2 }}
        />
      ))}
    </svg>
  )
}
