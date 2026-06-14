import { useMemo, useState } from 'react'
import { format, subDays } from 'date-fns'
import { Pencil, Trash2 } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { StarRating } from '../../components/ui/StarRating'
import { SwipeableRow } from '../../components/ui/SwipeableRow'
import { AnimatedBarChart } from '../../components/charts/SleepChart'
import { useAppStore } from '../../stores/useAppStore'
import { moonPhase, sleepDuration } from '../../lib/constants'
import type { SleepEntry } from '../../types'

export function SleepPage() {
  const entries = useAppStore((s) => s.sleepEntries)
  const addSleepEntry = useAppStore((s) => s.addSleepEntry)
  const updateSleepEntry = useAppStore((s) => s.updateSleepEntry)
  const deleteSleepEntry = useAppStore((s) => s.deleteSleepEntry)
  const sleepGoal = useAppStore((s) => s.settings.sleepGoalHours)

  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<SleepEntry | null>(null)
  const [form, setForm] = useState({ date: format(new Date(), 'yyyy-MM-dd'), bedtime: '23:00', wakeTime: '07:00', quality: 3, note: '' })

  const chartData = useMemo(() => {
    return Array.from({ length: 7 }, (_, i) => {
      const d = format(subDays(new Date(), 6 - i), 'yyyy-MM-dd')
      const entry = entries.find((e) => e.date === d)
      const hours = entry ? sleepDuration(entry.bedtime, entry.wakeTime).hours + sleepDuration(entry.bedtime, entry.wakeTime).minutes / 60 : 0
      const color = entry ? (entry.quality >= 4 ? '#34C759' : entry.quality >= 2 ? '#FF9500' : '#FF3B30') : 'var(--bg)'
      return { label: format(subDays(new Date(), 6 - i), 'EEE'), value: Math.round((hours / sleepGoal) * 100), color }
    })
  }, [entries, sleepGoal])

  const stats = useMemo(() => {
    if (!entries.length) return null
    const durations = entries.map((e) => sleepDuration(e.bedtime, e.wakeTime).totalMinutes)
    const avg = durations.reduce((a, b) => a + b, 0) / durations.length
    const best = Math.max(...durations)
    const worst = Math.min(...durations)
    const debt = Math.max(0, sleepGoal * 60 - avg)
    return { avg, best, worst, debt }
  }, [entries, sleepGoal])

  const openNew = () => { setEditing(null); setForm({ date: format(new Date(), 'yyyy-MM-dd'), bedtime: '23:00', wakeTime: '07:00', quality: 3, note: '' }); setModalOpen(true) }
  const openEdit = (e: SleepEntry) => { setEditing(e); setForm({ date: e.date, bedtime: e.bedtime, wakeTime: e.wakeTime, quality: e.quality, note: e.note }); setModalOpen(true) }

  const save = () => {
    if (editing) updateSleepEntry(editing.id, form)
    else addSleepEntry(form)
    setModalOpen(false)
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between">
        <h3 className="font-semibold">Sleep log</h3>
        <Button onClick={openNew}>Log sleep</Button>
      </div>

      <Card>
        <h4 className="mb-3 text-sm font-medium text-[var(--text-secondary)]">Weekly overview</h4>
        <AnimatedBarChart data={chartData} />
      </Card>

      {stats && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
          {[
            { label: 'Average', value: `${Math.floor(stats.avg / 60)}h ${Math.round(stats.avg % 60)}m` },
            { label: 'Best night', value: `${Math.floor(stats.best / 60)}h ${stats.best % 60}m` },
            { label: 'Worst night', value: `${Math.floor(stats.worst / 60)}h ${stats.worst % 60}m` },
            { label: 'Sleep debt', value: `${Math.floor(stats.debt / 60)}h ${Math.round(stats.debt % 60)}m` },
          ].map((s) => (
            <Card key={s.label} className="!p-3 text-center">
              <p className="text-xs text-[var(--text-secondary)]">{s.label}</p>
              <p className="font-semibold">{s.value}</p>
            </Card>
          ))}
        </div>
      )}

      <div className="space-y-2">
        {entries.map((entry) => {
          const dur = sleepDuration(entry.bedtime, entry.wakeTime)
          return (
            <SwipeableRow key={entry.id} rightActions={[{ label: 'Delete', color: '#FF3B30', onClick: () => deleteSleepEntry(entry.id) }]}>
              <div className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{moonPhase(new Date(entry.date))}</span>
                  <div>
                    <p className="font-medium">{entry.date}</p>
                    <p className="text-sm text-[var(--text-secondary)]">{entry.bedtime} → {entry.wakeTime} · {dur.hours}h {dur.minutes}m</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <StarRating value={entry.quality} />
                  <button type="button" onClick={() => openEdit(entry)} className="p-2"><Pencil size={16} /></button>
                  <button type="button" onClick={() => deleteSleepEntry(entry.id)} className="hidden p-2 md:block"><Trash2 size={16} /></button>
                </div>
              </div>
            </SwipeableRow>
          )
        })}
      </div>

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Edit sleep' : 'Log sleep'}>
        <div className="space-y-3">
          <input type="date" value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3" />
          <div className="grid grid-cols-2 gap-3">
            <label className="text-sm">Bedtime<input type="time" value={form.bedtime} onChange={(e) => setForm({ ...form, bedtime: e.target.value })} className="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2" /></label>
            <label className="text-sm">Wake<input type="time" value={form.wakeTime} onChange={(e) => setForm({ ...form, wakeTime: e.target.value })} className="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2" /></label>
          </div>
          <div><p className="mb-1 text-sm">Quality</p><StarRating value={form.quality} onChange={(q) => setForm({ ...form, quality: q })} /></div>
          <textarea value={form.note} onChange={(e) => setForm({ ...form, note: e.target.value })} placeholder="Note (optional)" className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3 text-sm" rows={2} />
          <Button onClick={save} className="w-full">Save</Button>
        </div>
      </Modal>
    </div>
  )
}
