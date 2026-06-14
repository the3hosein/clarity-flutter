import { useMemo, useState } from 'react'
import { motion } from 'framer-motion'
import { format, subDays } from 'date-fns'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Checkbox } from '../../components/ui/Toggle'
import { StreakGrid } from '../../components/charts/SleepChart'
import { useAppStore } from '../../stores/useAppStore'
import { todayKey } from '../../lib/constants'
import { springs } from '../../lib/springs'

export function HabitsPage() {
  const habits = useAppStore((s) => s.habits)
  const toggleHabit = useAppStore((s) => s.toggleHabit)
  const addHabit = useAppStore((s) => s.addHabit)
  const [name, setName] = useState('')
  const today = todayKey()

  const gridData = useMemo(() => {
    return Array.from({ length: 30 }, (_, col) =>
      Array.from({ length: 7 }, (_, row) => {
        const date = format(subDays(new Date(), (29 - col) * 7 + (6 - row)), 'yyyy-MM-dd')
        return habits.some((h) => h.completions[date])
      }),
    )
  }, [habits])

  return (
    <div className="space-y-6">
      <Card>
        <h3 className="mb-4 font-semibold">Today</h3>
        <div className="space-y-3">
          {habits.map((h) => (
            <motion.div key={h.id} whileTap={{ scale: 0.98 }} transition={springs.bouncy} className="flex items-center gap-3 rounded-xl bg-[var(--bg)] p-3">
              <Checkbox checked={!!h.completions[today]} onChange={() => toggleHabit(h.id)} />
              <span style={{ color: h.color }} className="font-medium">{h.name}</span>
            </motion.div>
          ))}
        </div>
      </Card>

      <Card>
        <h3 className="mb-4 font-semibold">30-day streak</h3>
        <StreakGrid data={gridData} />
      </Card>

      <div className="flex gap-2">
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="New habit" className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--bg)] px-3 py-2" />
        <Button onClick={() => { if (name.trim()) { addHabit(name.trim(), '#007AFF'); setName('') } }}>Add</Button>
      </div>
    </div>
  )
}
