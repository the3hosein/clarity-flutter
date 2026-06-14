import { motion } from 'framer-motion'
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'
import { springs } from '../../lib/springs'

interface SleepChartProps {
  data: { day: string; hours: number; color: string }[]
}

export function SleepChart({ data }: SleepChartProps) {
  return (
    <ResponsiveContainer width="100%" height={200}>
      <BarChart data={data}>
        <XAxis dataKey="day" tick={{ fontSize: 12, fill: 'var(--text-secondary)' }} axisLine={false} tickLine={false} />
        <YAxis hide domain={[0, 12]} />
        <Tooltip contentStyle={{ background: 'var(--card)', border: 'none', borderRadius: 12 }} />
        <Bar dataKey="hours" radius={[6, 6, 0, 0]} animationDuration={600}>
          {data.map((entry, i) => (
            <motion.rect key={entry.day} initial={{ scaleY: 0 }} animate={{ scaleY: 1 }} transition={{ ...springs.gentle, delay: i * 0.06 }} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}

interface AnimatedBarProps {
  data: { label: string; value: number; color?: string }[]
}

export function AnimatedBarChart({ data }: AnimatedBarProps) {
  return (
    <div className="space-y-3">
      {data.map((item, i) => (
        <div key={item.label}>
          <div className="mb-1 flex justify-between text-sm">
            <span>{item.label}</span>
            <span className="text-[var(--text-secondary)]">{item.value}</span>
          </div>
          <div className="h-3 overflow-hidden rounded-full bg-[var(--bg)]">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${item.value}%` }}
              transition={{ ...springs.smooth, delay: i * 0.06 }}
              className="h-full rounded-full"
              style={{ background: item.color ?? 'var(--accent)' }}
            />
          </div>
        </div>
      ))}
    </div>
  )
}

interface StreakGridProps {
  data: boolean[][]
  color?: string
}

export function StreakGrid({ data, color = 'var(--accent)' }: StreakGridProps) {
  return (
    <div className="grid grid-flow-col gap-1 overflow-x-auto">
      {data.map((col, ci) => (
        <div key={ci} className="grid grid-rows-7 gap-1">
          {col.map((active, ri) => (
            <motion.div
              key={ri}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ ...springs.bouncy, delay: (ci * 7 + ri) * 0.01 }}
              className="h-3 w-3 rounded-sm"
              style={{ background: active ? color : 'var(--bg)', opacity: active ? 1 : 0.35 }}
            />
          ))}
        </div>
      ))}
    </div>
  )
}
