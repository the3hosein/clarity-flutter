import { motion } from 'framer-motion'
import { RadialBarChart, RadialBar, ResponsiveContainer, PolarAngleAxis } from 'recharts'
import { springs } from '../../lib/springs'

interface RingChartProps {
  value: number
  label: string
  color?: string
  size?: number
}

export function RingChart({ value, label, color = 'var(--accent)', size = 80 }: RingChartProps) {
  const data = [{ name: label, value, fill: color }]
  return (
    <div className="flex flex-col items-center gap-1">
      <div style={{ width: size, height: size }}>
        <ResponsiveContainer>
          <RadialBarChart cx="50%" cy="50%" innerRadius="70%" outerRadius="100%" barSize={8} data={data} startAngle={90} endAngle={-270}>
            <PolarAngleAxis type="number" domain={[0, 100]} angleAxisId={0} tick={false} />
            <RadialBar background={{ fill: 'var(--bg)' }} dataKey="value" cornerRadius={4} animationDuration={600} animationEasing="ease-out" />
          </RadialBarChart>
        </ResponsiveContainer>
      </div>
      <span className="text-center text-xs text-[var(--text-secondary)]">{label}</span>
      <motion.span
        key={value}
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={springs.smooth}
        className="text-sm font-semibold"
      >
        {Math.round(value)}%
      </motion.span>
    </div>
  )
}
