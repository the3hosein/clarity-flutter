import { Fragment, useMemo, useState } from 'react'
import {
  addMonths,
  eachDayOfInterval,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  isToday,
  parseISO,
  startOfMonth,
  startOfWeek,
  addHours,
  isBefore,
} from 'date-fns'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { AnimatedTabBar } from '../../components/ui/AnimatedTabBar'
import { Toggle } from '../../components/ui/Toggle'
import { useAppStore } from '../../stores/useAppStore'
import { CATEGORY_COLORS } from '../../lib/constants'
import { springs } from '../../lib/springs'
import type { CalendarEvent, EventCategory, RepeatRule } from '../../types'
import { LocalNotifications } from '@capacitor/local-notifications'

const VIEWS = [
  { id: 'month', label: 'Month' },
  { id: 'week', label: 'Week' },
  { id: 'agenda', label: 'Agenda' },
]

const CATEGORIES: EventCategory[] = ['study', 'personal', 'health', 'social', 'other']

export function CalendarPage() {
  const events = useAppStore((s) => s.calendarEvents)
  const lessonSlots = useAppStore((s) => s.lessonSlots)
  const sleepEntries = useAppStore((s) => s.sleepEntries)
  const habits = useAppStore((s) => s.habits)
  const addEvent = useAppStore((s) => s.addEvent)
  const updateEvent = useAppStore((s) => s.updateEvent)
  const deleteEvent = useAppStore((s) => s.deleteEvent)

  const [view, setView] = useState('month')
  const [current, setCurrent] = useState(new Date())
  const [selectedDay, setSelectedDay] = useState<Date | null>(null)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<CalendarEvent | null>(null)
  const [form, setForm] = useState({
    title: '',
    start: format(new Date(), "yyyy-MM-dd'T'09:00"),
    end: format(new Date(), "yyyy-MM-dd'T'10:00"),
    category: 'study' as EventCategory,
    notes: '',
    repeat: 'none' as RepeatRule,
    reminder: false,
  })

  const monthDays = useMemo(() => {
    const start = startOfWeek(startOfMonth(current))
    const end = endOfWeek(endOfMonth(current))
    return eachDayOfInterval({ start, end })
  }, [current])

  const weekDays = useMemo(() => {
    const start = startOfWeek(current)
    return eachDayOfInterval({ start, end: addHours(start, 24 * 6) })
  }, [current])

  const dayEvents = (day: Date) =>
    events.filter((e) => isSameDay(parseISO(e.start), day))

  const upcoming = useMemo(
    () => [...events].sort((a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()),
    [events],
  )

  const openCreate = (day?: Date) => {
    const d = day ?? new Date()
    setEditing(null)
    setForm({
      title: '',
      start: format(d, "yyyy-MM-dd'T'09:00"),
      end: format(d, "yyyy-MM-dd'T'10:00"),
      category: 'study',
      notes: '',
      repeat: 'none',
      reminder: false,
    })
    setModalOpen(true)
  }

  const saveEvent = async () => {
    const payload = { ...form }
    if (editing) updateEvent(editing.id, payload)
    else {
      addEvent(payload)
      if (payload.reminder) {
        try {
          await LocalNotifications.requestPermissions()
          await LocalNotifications.schedule({
            notifications: [{
              id: Math.floor(Math.random() * 100000),
              title: payload.title,
              body: 'Upcoming event reminder',
              schedule: { at: new Date(new Date(payload.start).getTime() - 15 * 60000) },
            }],
          })
        } catch { /* web fallback */ }
      }
    }
    setModalOpen(false)
  }

  const integrationsForDay = (day: Date) => {
    const dateKey = format(day, 'yyyy-MM-dd')
    const dayNum = day.getDay() || 7
    const lessons = lessonSlots.filter((s) => s.day === dayNum).length
    const sleep = sleepEntries.some((e) => e.date === dateKey)
    const habitCount = habits.filter((h) => h.completions[dateKey]).length
    return { lessons, sleep, habitCount }
  }

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-[var(--font-xl)] font-bold">Calendar</h1>
        <Button onClick={() => openCreate()}>New event</Button>
      </div>

      <AnimatedTabBar tabs={VIEWS} active={view} onChange={setView} />

      <div className="flex items-center justify-between">
        <button type="button" onClick={() => setCurrent(addMonths(current, -1))} className="rounded-lg p-2"><ChevronLeft size={20} /></button>
        <span className="font-semibold">{format(current, 'MMMM yyyy')}</span>
        <button type="button" onClick={() => setCurrent(addMonths(current, 1))} className="rounded-lg p-2"><ChevronRight size={20} /></button>
      </div>

      {view === 'month' && (
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-[1fr_280px]">
          <Card>
            <div className="mb-2 grid grid-cols-7 gap-1 text-center text-xs font-medium text-[var(--text-secondary)]">
              {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => <div key={d}>{d}</div>)}
            </div>
            <div className="grid grid-cols-7 gap-1">
              {monthDays.map((day) => {
                const evts = dayEvents(day)
                const integ = integrationsForDay(day)
                return (
                  <button
                    key={day.toISOString()}
                    type="button"
                    onClick={() => setSelectedDay(day)}
                    className={`min-h-[64px] rounded-xl p-1 text-left text-sm ${!isSameMonth(day, current) ? 'opacity-30' : ''} ${isToday(day) ? 'ring-2 ring-[var(--accent)]' : 'bg-[var(--bg)]'}`}
                  >
                    <span className={`inline-flex h-6 w-6 items-center justify-center rounded-full ${isToday(day) ? 'bg-[var(--accent)] text-white' : ''}`}>
                      {format(day, 'd')}
                    </span>
                    <div className="mt-1 flex flex-wrap gap-0.5">
                      {evts.slice(0, 3).map((e) => (
                        <span key={e.id} className="h-1.5 w-1.5 rounded-full" style={{ background: CATEGORY_COLORS[e.category] }} />
                      ))}
                      {integ.sleep && <span className="text-[10px]">🌙</span>}
                      {integ.habitCount > 0 && <span className="text-[10px]">✓{integ.habitCount}</span>}
                    </div>
                  </button>
                )
              })}
            </div>
          </Card>

          <AnimatePresence>
            {selectedDay && (
              <motion.div initial={{ x: 40, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: 40, opacity: 0 }} transition={springs.smooth}>
                <Card>
                  <h3 className="mb-3 font-semibold">{format(selectedDay, 'EEEE, MMM d')}</h3>
                  {dayEvents(selectedDay).length === 0 ? (
                    <p className="text-sm text-[var(--text-secondary)]">No events</p>
                  ) : (
                    dayEvents(selectedDay).map((e) => (
                      <div key={e.id} className="mb-2 rounded-lg p-2" style={{ background: `${CATEGORY_COLORS[e.category]}22` }}>
                        <p className="font-medium">{e.title}</p>
                        <p className="text-xs text-[var(--text-secondary)]">{format(parseISO(e.start), 'h:mm a')}</p>
                      </div>
                    ))
                  )}
                  <Button variant="secondary" className="mt-2 w-full" onClick={() => openCreate(selectedDay)}>Add event</Button>
                </Card>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      )}

      {view === 'week' && (
        <Card className="overflow-x-auto">
          <div className="grid min-w-[700px] grid-cols-8 gap-1">
            <div />
            {weekDays.map((d) => (
              <div key={d.toISOString()} className="p-2 text-center text-xs font-medium">
                {format(d, 'EEE d')}
              </div>
            ))}
            {Array.from({ length: 12 }, (_, h) => h + 8).map((hour) => (
              <Fragment key={`hour-${hour}`}>
                <div className="p-1 text-xs text-[var(--text-tertiary)]">{hour}:00</div>
                {weekDays.map((d) => {
                  const slotEvents = events.filter((e) => {
                    const start = parseISO(e.start)
                    return isSameDay(start, d) && start.getHours() === hour
                  })
                  return (
                    <div key={`${d.toISOString()}-${hour}`} className="min-h-[40px] border-t border-[var(--border)] p-0.5" onDoubleClick={() => openCreate(d)}>
                      {slotEvents.map((e) => (
                        <div key={e.id} className="truncate rounded px-1 text-[10px] text-white" style={{ background: CATEGORY_COLORS[e.category] }}>
                          {e.title}
                        </div>
                      ))}
                    </div>
                  )
                })}
              </Fragment>
            ))}
          </div>
          <div className="relative mt-2 h-0.5 bg-red-500" style={{ top: `${((new Date().getHours() - 8) / 12) * 100}%` }} />
        </Card>
      )}

      {view === 'agenda' && (
        <div className="space-y-4">
          {upcoming.length === 0 ? (
            <Card><p className="text-center text-[var(--text-secondary)]">No upcoming events — plan something great!</p></Card>
          ) : (
            upcoming.map((e) => {
              const overdue = isBefore(parseISO(e.end), new Date())
              return (
                <Card key={e.id} className={overdue ? 'shake border border-red-500/30' : ''}>
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="font-semibold">{e.title}</p>
                      <p className="text-sm text-[var(--text-secondary)]">{format(parseISO(e.start), 'MMM d, h:mm a')}</p>
                      {e.notes && <p className="mt-1 text-sm">{e.notes}</p>}
                    </div>
                    <div className="flex gap-2">
                      <Button variant="ghost" className="!min-h-8 !px-2" onClick={() => { setEditing(e); setForm({ title: e.title, start: e.start.slice(0, 16), end: e.end.slice(0, 16), category: e.category, notes: e.notes, repeat: e.repeat, reminder: e.reminder }); setModalOpen(true) }}>Edit</Button>
                      <Button variant="danger" className="!min-h-8 !px-2" onClick={() => deleteEvent(e.id)}>Delete</Button>
                    </div>
                  </div>
                </Card>
              )
            })
          )}
        </div>
      )}

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Edit event' : 'New event'}>
        <div className="space-y-3">
          <input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Title" className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3" />
          <div className="grid grid-cols-2 gap-3">
            <input type="datetime-local" value={form.start} onChange={(e) => setForm({ ...form, start: e.target.value })} className="rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2 text-sm" />
            <input type="datetime-local" value={form.end} onChange={(e) => setForm({ ...form, end: e.target.value })} className="rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2 text-sm" />
          </div>
          <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value as EventCategory })} className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2">
            {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
          <select value={form.repeat} onChange={(e) => setForm({ ...form, repeat: e.target.value as RepeatRule })} className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2">
            {['none', 'daily', 'weekly', 'monthly'].map((r) => <option key={r} value={r}>{r}</option>)}
          </select>
          <textarea value={form.notes} onChange={(e) => setForm({ ...form, notes: e.target.value })} placeholder="Notes" className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3 text-sm" rows={2} />
          <Toggle checked={form.reminder} onChange={(v) => setForm({ ...form, reminder: v })} label="Reminder notification" />
          <Button onClick={saveEvent} className="w-full">Save</Button>
        </div>
      </Modal>
    </div>
  )
}
