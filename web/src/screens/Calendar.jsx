import { useState, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from '../store'
import { springs, springTransitions } from '../animations'
import { ChevronLeft, ChevronRight, Plus, X, Clock, Repeat, AlertTriangle } from 'lucide-react'
import { format, startOfMonth, endOfMonth, eachDayOfInterval, getDay, isSameMonth, isSameDay, addMonths, subMonths, startOfWeek, endOfWeek, isToday } from 'date-fns'

const categoryColors = {
  Study: '#007AFF', Personal: '#34C759', Health: '#FF9500', Social: '#FF2D55', Other: '#5E5CE6',
}

function CalendarScreen() {
  const { state, dispatch } = useStore()
  const [currentDate, setCurrentDate] = useState(new Date())
  const [view, setView] = useState('month')
  const [selectedDate, setSelectedDate] = useState(null)
  const [showAdd, setShowAdd] = useState(false)
  const [editTitle, setEditTitle] = useState('')
  const [editStart, setEditStart] = useState('')
  const [editEnd, setEditEnd] = useState('')
  const [editCategory, setEditCategory] = useState('Study')
  const [editNotes, setEditNotes] = useState('')
  const [editingId, setEditingId] = useState(null)

  const monthStart = startOfMonth(currentDate)
  const monthEnd = endOfMonth(currentDate)
  const calStart = startOfWeek(monthStart)
  const calEnd = endOfWeek(monthEnd)
  const days = eachDayOfInterval({ start: calStart, end: calEnd })

  const dayEvents = useMemo(() => {
    const map = {}
    state.calendarEvents.forEach(e => {
      const d = new Date(e.start).toDateString()
      if (!map[d]) map[d] = []
      map[d].push(e)
    })
    return map
  }, [state.calendarEvents])

  const selectedEvents = selectedDate ? (dayEvents[selectedDate.toDateString()] || []) : []

  const handleSave = () => {
    if (!editTitle.trim() || !editStart) return
    if (editingId) {
      dispatch({ type: 'UPDATE_EVENT', payload: { id: editingId, data: { title: editTitle, start: editStart, end: editEnd || editStart, category: editCategory, notes: editNotes } } })
      setEditingId(null)
    } else {
      dispatch({ type: 'ADD_EVENT', payload: { title: editTitle, start: editStart, end: editEnd || editStart, category: editCategory, notes: editNotes } })
    }
    setShowAdd(false); setEditTitle(''); setEditStart(''); setEditEnd(''); setEditNotes('')
  }

  const openEdit = (e) => {
    setEditingId(e.id); setEditTitle(e.title); setEditStart(e.start); setEditEnd(e.end || ''); setEditCategory(e.category || 'Study'); setEditNotes(e.notes || ''); setShowAdd(true)
  }

  const views = ['month', 'week', 'agenda']

  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto pb-24 md:pb-8">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
          <motion.button whileTap={{ scale: 0.9 }} onClick={() => setCurrentDate(subMonths(currentDate, 1))}>
            <ChevronLeft size={20} style={{ color: 'var(--text-secondary)' }} />
          </motion.button>
          <h1 className="text-xl font-bold" style={{ color: 'var(--text-primary)' }}>{format(currentDate, 'MMMM yyyy')}</h1>
          <motion.button whileTap={{ scale: 0.9 }} onClick={() => setCurrentDate(addMonths(currentDate, 1))}>
            <ChevronRight size={20} style={{ color: 'var(--text-secondary)' }} />
          </motion.button>
        </div>
        <div className="flex items-center gap-2">
          <div className="flex rounded-xl overflow-hidden" style={{ border: '1px solid var(--border)' }}>
            {views.map(v => (
              <button key={v} onClick={() => setView(v)}
                className="px-3 py-1.5 text-xs font-medium capitalize"
                style={{ background: view === v ? 'var(--accent)' : 'transparent', color: view === v ? 'white' : 'var(--text-secondary)' }}>
                {v}
              </button>
            ))}
          </div>
          <motion.button className="p-2 rounded-xl" style={{ background: `color-mix(in srgb, var(--accent) 12%, transparent)` }} whileTap={{ scale: 0.9 }}
            onClick={() => { setEditingId(null); setEditTitle(''); setEditStart(''); setEditEnd(''); setEditCategory('Study'); setEditNotes(''); setShowAdd(true) }}>
            <Plus size={18} style={{ color: 'var(--accent)' }} />
          </motion.button>
        </div>
      </div>

      <div className="grid grid-cols-7 gap-1 mb-4">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(d => (
          <div key={d} className="text-center text-[10px] font-medium py-1" style={{ color: 'var(--text-tertiary)' }}>{d}</div>
        ))}
        {days.map((day, i) => {
          const events = dayEvents[day.toDateString()] || []
          const isSelected = selectedDate && isSameDay(day, selectedDate)
          const isCurrentMonth = isSameMonth(day, currentDate)
          return (
            <motion.button
              key={i}
              className="relative rounded-xl p-2 text-center min-h-[44px] flex flex-col items-center justify-center"
              style={{
                background: isSelected ? 'var(--accent)' : isToday(day) ? `color-mix(in srgb, var(--accent) 12%, transparent)` : 'transparent',
                color: isSelected ? 'white' : isCurrentMonth ? 'var(--text-primary)' : 'var(--text-tertiary)',
                opacity: isCurrentMonth ? 1 : 0.4,
              }}
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => setSelectedDate(day)}
            >
              <span className="text-sm font-medium">{format(day, 'd')}</span>
              {events.length > 0 && (
                <div className="flex gap-0.5 mt-0.5">
                  {events.slice(0, 3).map((e, j) => (
                    <div key={j} className="w-1 h-1 rounded-full" style={{ background: categoryColors[e.category] || categoryColors.Other }} />
                  ))}
                </div>
              )}
            </motion.button>
          )
        })}
      </div>

      <AnimatePresence>
        {showAdd && (
          <motion.div className="rounded-2xl p-5 mb-4" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-lg)' }}
            initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }} transition={springs.smooth}>
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold" style={{ color: 'var(--text-primary)' }}>{editingId ? 'Edit Event' : 'New Event'}</h3>
              <motion.button whileTap={{ scale: 0.9 }} onClick={() => setShowAdd(false)}><X size={18} style={{ color: 'var(--text-secondary)' }} /></motion.button>
            </div>
            <div className="space-y-3">
              <input className="w-full rounded-xl px-3 py-2.5 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
                placeholder="Event title..." value={editTitle} onChange={e => setEditTitle(e.target.value)} autoFocus />
              <div className="flex gap-3">
                <div className="flex-1">
                  <label className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>Start</label>
                  <input type="datetime-local" value={editStart} onChange={e => setEditStart(e.target.value)}
                    className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
                </div>
                <div className="flex-1">
                  <label className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>End</label>
                  <input type="datetime-local" value={editEnd} onChange={e => setEditEnd(e.target.value)}
                    className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
                </div>
              </div>
              <div className="flex gap-2">
                {Object.entries(categoryColors).map(([cat, color]) => (
                  <motion.button key={cat} whileTap={{ scale: 0.9 }}
                    className="px-3 py-1.5 rounded-full text-xs font-medium"
                    style={{
                      background: editCategory === cat ? color : 'var(--bg)',
                      color: editCategory === cat ? 'white' : 'var(--text-secondary)',
                    }}
                    onClick={() => setEditCategory(cat)}>
                    {cat}
                  </motion.button>
                ))}
              </div>
              <textarea className="w-full rounded-xl px-3 py-2 text-sm outline-none resize-none"
                style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)', minHeight: 60 }}
                placeholder="Notes..." value={editNotes} onChange={e => setEditNotes(e.target.value)} />
              <div className="flex gap-2">
                <motion.button className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: 'var(--accent)', color: 'white' }} whileTap={{ scale: 0.95 }} onClick={handleSave}>
                  {editingId ? 'Update' : 'Save'}
                </motion.button>
                <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }} whileTap={{ scale: 0.95 }} onClick={() => setShowAdd(false)}>Cancel</motion.button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {selectedDate && (
        <motion.div className="rounded-2xl p-4" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
          initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={springs.smooth}>
          <h3 className="text-sm font-semibold mb-3" style={{ color: 'var(--text-primary)' }}>
            {format(selectedDate, 'EEEE, MMMM d')} — {selectedEvents.length} events
          </h3>
          {selectedEvents.length === 0 ? (
            <p className="text-sm" style={{ color: 'var(--text-tertiary)' }}>No events. Tap + to add one.</p>
          ) : (
            <div className="space-y-2">
              {selectedEvents.map(e => (
                <motion.div key={e.id} className="flex items-center gap-3 rounded-xl p-3 cursor-pointer"
                  style={{ background: 'var(--bg)' }}
                  whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}
                  onClick={() => openEdit(e)}>
                  <div className="w-1 h-8 rounded-full shrink-0" style={{ background: categoryColors[e.category] || categoryColors.Other }} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{e.title}</p>
                    <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>
                      {new Date(e.start).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
                      {e.end ? ` — ${new Date(e.end).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}` : ''}
                    </p>
                  </div>
                  <span className="text-[10px] px-2 py-0.5 rounded-full font-medium" style={{ background: categoryColors[e.category] + '20', color: categoryColors[e.category] }}>
                    {e.category}
                  </span>
                  <motion.button whileTap={{ scale: 0.9 }} onClick={e => { e.stopPropagation(); dispatch({ type: 'DELETE_EVENT', payload: e.id }) }}>
                    <X size={14} style={{ color: 'var(--text-tertiary)' }} />
                  </motion.button>
                </motion.div>
              ))}
            </div>
          )}
        </motion.div>
      )}
    </div>
  )
}

export default CalendarScreen
