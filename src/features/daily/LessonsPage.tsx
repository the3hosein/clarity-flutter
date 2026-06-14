import { Fragment } from 'react'
import { motion } from 'framer-motion'
import { Card } from '../../components/ui/Card'
import { RingChart } from '../../components/charts/RingChart'
import { useAppStore } from '../../stores/useAppStore'
import { todayKey } from '../../lib/constants'
import { springs } from '../../lib/springs'
import type { LessonStatus } from '../../types'

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
const STATUSES: { id: LessonStatus; label: string; icon: string }[] = [
  { id: 'done', label: 'Done', icon: '✓' },
  { id: 'partial', label: 'Partial', icon: '◑' },
  { id: 'skipped', label: 'Skipped', icon: '✗' },
]

export function LessonsPage() {
  const slots = useAppStore((s) => s.lessonSlots)
  const checks = useAppStore((s) => s.lessonChecks)
  const setLessonCheck = useAppStore((s) => s.setLessonCheck)
  const today = todayKey()
  const dayOfWeek = new Date().getDay() || 7

  const todaySlots = slots.filter((s) => s.day === dayOfWeek)
  const weekDone = checks.filter((c) => c.status === 'done').length
  const weekTotal = slots.length
  const streakPct = weekTotal ? (weekDone / weekTotal) * 100 : 0

  const getStatus = (slotId: string) => checks.find((c) => c.slotId === slotId && c.date === today)?.status ?? 'pending'

  return (
    <div className="space-y-6">
      <Card>
        <h3 className="mb-4 font-semibold">Weekly timetable</h3>
        <div className="overflow-x-auto">
          <div className="grid min-w-[600px] grid-cols-8 gap-1 text-xs">
            <div />
            {DAYS.map((d) => (
              <div key={d} className="p-2 text-center font-medium text-[var(--text-secondary)]">{d}</div>
            ))}
            {[0, 1, 2].map((row) => (
              <Fragment key={`row-${row}`}>
                <div className="p-2 text-[var(--text-tertiary)]">{9 + row * 2}:00</div>
                {DAYS.map((_, di) => {
                  const daySlots = slots.filter((s) => s.day === di + 1)
                  const slot = daySlots[row]
                  return (
                    <div key={`${di}-${row}`} className="min-h-[40px] rounded-lg p-1" style={{ background: slot ? `${slot.color}22` : undefined }}>
                      {slot && <span className="block truncate rounded px-1 py-0.5 text-[10px]" style={{ color: slot.color }}>{slot.subject}</span>}
                    </div>
                  )
                })}
              </Fragment>
            ))}
          </div>
        </div>
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <h3 className="mb-4 font-semibold">Today's lessons</h3>
          <div className="space-y-3">
            {todaySlots.length === 0 && <p className="text-sm text-[var(--text-secondary)]">No lessons today</p>}
            {todaySlots.map((slot) => {
              const status = getStatus(slot.id)
              return (
                <div key={slot.id} className={`rounded-xl p-3 transition-colors duration-150 ${status === 'done' ? 'bg-green-500/10' : 'bg-[var(--bg)]'}`}>
                  <div className="mb-2 flex items-center justify-between">
                    <span className="font-medium" style={{ color: slot.color }}>{slot.subject}</span>
                    <span className="text-xs text-[var(--text-secondary)]">{slot.startTime}–{slot.endTime}</span>
                  </div>
                  <div className="flex gap-2">
                    {STATUSES.map((s) => (
                      <motion.button
                        key={s.id}
                        type="button"
                        whileTap={{ scale: 0.95 }}
                        transition={springs.snappy}
                        onClick={() => setLessonCheck(slot.id, today, s.id)}
                        className={`rounded-lg px-3 py-1 text-xs ${status === s.id ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)]'}`}
                      >
                        {s.icon} {s.label}
                      </motion.button>
                    ))}
                  </div>
                </div>
              )
            })}
          </div>
        </Card>
        <Card className="flex flex-col items-center justify-center">
          <RingChart value={streakPct} label="Weekly streak" />
        </Card>
      </div>
    </div>
  )
}
