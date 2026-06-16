import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from '../store'
import { springs, springTransitions } from '../animations'
import { BookOpen, Moon, Dumbbell, Smartphone, Plus, Check, X as XIcon, Clock, Star, Trash2, Edit3 } from 'lucide-react'
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer } from 'recharts'

function formatDuration(bed, wake) {
  if (!bed || !wake) return '0h'
  const [bh, bm] = bed.split(':').map(Number)
  const [wh, wm] = wake.split(':').map(Number)
  let total = (wh * 60 + wm) - (bh * 60 + bm)
  if (total < 0) total += 1440
  return `${Math.floor(total / 60)}h ${total % 60}m`
}

function Lessons() {
  const { state, dispatch } = useStore()
  const [showAdd, setShowAdd] = useState(false)
  const [title, setTitle] = useState('')
  const [subject, setSubject] = useState('')

  const todayLessons = state.lessons.filter(l => {
    if (!l.day) return true
    return l.day === new Date().toLocaleDateString('en-US', { weekday: 'short' }).toLowerCase()
  })

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={springs.smooth}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <BookOpen size={20} style={{ color: '#34C759' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Today's Lessons</h2>
        </div>
        <motion.button className="p-2 rounded-xl" style={{ background: '#34C75920' }} whileTap={{ scale: 0.9 }} onClick={() => setShowAdd(true)}>
          <Plus size={18} style={{ color: '#34C759' }} />
        </motion.button>
      </div>
      <AnimatePresence>
        {showAdd && (
          <motion.div className="flex gap-2 mb-3" initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Lesson title..." value={title} onChange={e => setTitle(e.target.value)} autoFocus />
            <input className="w-24 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Subject" value={subject} onChange={e => setSubject(e.target.value)} />
            <motion.button className="p-2 rounded-xl" style={{ background: '#34C759', color: 'white' }} whileTap={{ scale: 0.9 }}
              onClick={() => { if (title.trim()) { dispatch({ type: 'ADD_LESSON', payload: { title: title.trim(), subject: subject.trim() } }); setTitle(''); setSubject(''); setShowAdd(false) } }}>
              <Plus size={18} />
            </motion.button>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-2">
        {todayLessons.map((l, i) => (
          <motion.div key={l.id} className="flex items-center gap-3 rounded-xl p-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
            <motion.button whileTap={{ scale: 0.8 }}
              onClick={() => dispatch({ type: 'TOGGLE_LESSON', payload: l.id })}
              className="w-6 h-6 rounded-full border-2 flex items-center justify-center shrink-0"
              style={{ borderColor: l.completed ? '#34C759' : 'var(--border)' }}>
              {l.completed && <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} transition={springs.bouncy}>
                <Check size={14} style={{ color: '#34C759' }} />
              </motion.span>}
            </motion.button>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate" style={{ color: l.completed ? 'var(--text-tertiary)' : 'var(--text-primary)', textDecoration: l.completed ? 'line-through' : 'none' }}>
                {l.title}
              </p>
              {l.subject && <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{l.subject}</p>}
            </div>
            <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'SKIP_LESSON', payload: l.id })}>
              <XIcon size={16} style={{ color: l.skipped ? '#FF3B30' : 'var(--text-tertiary)' }} />
            </motion.button>
            <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_LESSON', payload: l.id })}>
              <Trash2 size={14} style={{ color: 'var(--text-tertiary)' }} />
            </motion.button>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

function SleepReporter() {
  const { state, dispatch } = useStore()
  const [showAdd, setShowAdd] = useState(false)
  const [bedtime, setBedtime] = useState('23:00')
  const [wakeTime, setWakeTime] = useState('07:00')
  const [quality, setQuality] = useState(3)
  const [editingId, setEditingId] = useState(null)

  const handleSave = () => {
    const duration = formatDuration(bedtime, wakeTime)
    if (editingId) {
      dispatch({ type: 'UPDATE_SLEEP', payload: { id: editingId, data: { bedtime, wakeTime, duration, quality } } })
      setEditingId(null)
    } else {
      dispatch({ type: 'ADD_SLEEP', payload: { bedtime, wakeTime, duration, quality } })
    }
    setShowAdd(false)
  }

  const startEdit = (s) => {
    setBedtime(s.bedtime)
    setWakeTime(s.wakeTime)
    setQuality(s.quality || 3)
    setEditingId(s.id)
    setShowAdd(true)
  }

  const weeklyData = state.sleepLogs.slice(0, 7).map(s => ({
    day: new Date(s.id).toLocaleDateString('en-US', { weekday: 'short' }),
    hours: parseFloat(s.duration) || 0,
  })).reverse()

  const avg = state.sleepLogs.length > 0
    ? (state.sleepLogs.reduce((a, s) => a + (parseFloat(s.duration) || 0), 0) / state.sleepLogs.length).toFixed(1)
    : '0'

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.1 }}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Moon size={20} style={{ color: '#5E5CE6' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Sleep</h2>
        </div>
        <motion.button className="p-2 rounded-xl" style={{ background: '#5E5CE620' }} whileTap={{ scale: 0.9 }} onClick={() => { setEditingId(null); setBedtime('23:00'); setWakeTime('07:00'); setQuality(3); setShowAdd(true) }}>
          <Plus size={18} style={{ color: '#5E5CE6' }} />
        </motion.button>
      </div>
      <div className="flex gap-4 mb-3 text-sm">
        <span style={{ color: 'var(--text-secondary)' }}>Avg: <strong style={{ color: 'var(--text-primary)' }}>{avg}h</strong></span>
        <span style={{ color: 'var(--text-secondary)' }}>Goal: <strong style={{ color: 'var(--accent)' }}>{state.sleepGoal}h</strong></span>
      </div>
      <AnimatePresence>
        {showAdd && (
          <motion.div className="space-y-3 mb-3 p-3 rounded-xl" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <div className="flex gap-3">
              <div className="flex-1">
                <label className="text-xs" style={{ color: 'var(--text-secondary)' }}>Bedtime</label>
                <input type="time" value={bedtime} onChange={e => setBedtime(e.target.value)}
                  className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
              </div>
              <div className="flex-1">
                <label className="text-xs" style={{ color: 'var(--text-secondary)' }}>Wake</label>
                <input type="time" value={wakeTime} onChange={e => setWakeTime(e.target.value)}
                  className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
              </div>
            </div>
            <div>
              <label className="text-xs" style={{ color: 'var(--text-secondary)' }}>Quality</label>
              <div className="flex gap-1 mt-1">
                {[1, 2, 3, 4, 5].map(n => (
                  <motion.button key={n} whileTap={{ scale: 0.8 }}
                    onClick={() => setQuality(n)}
                    className="p-1 rounded">
                    <Star size={18} style={{ color: n <= quality ? '#FF9500' : 'var(--text-tertiary)' }} fill={n <= quality ? '#FF9500' : 'none'} />
                  </motion.button>
                ))}
              </div>
            </div>
            <div className="flex gap-2">
              <motion.button className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: 'var(--accent)', color: 'white' }} whileTap={{ scale: 0.95 }} onClick={handleSave}>
                {editingId ? 'Update' : 'Log Sleep'}
              </motion.button>
              <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }} whileTap={{ scale: 0.95 }} onClick={() => setShowAdd(false)}>Cancel</motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
      {weeklyData.length > 0 && (
        <div className="h-24 mb-3">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={weeklyData}>
              <XAxis dataKey="day" tick={{ fontSize: 10, fill: 'var(--text-tertiary)' }} axisLine={false} tickLine={false} />
              <YAxis hide domain={[0, 12]} />
              <Bar dataKey="hours" radius={[4, 4, 0, 0]}>
                {weeklyData.map((entry, i) => (
                  <rect key={i} fill={entry.hours >= state.sleepGoal ? '#34C759' : entry.hours >= state.sleepGoal * 0.75 ? '#FF9500' : '#FF3B30'} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
      <div className="space-y-2 max-h-48 overflow-y-auto">
        {state.sleepLogs.slice(0, 5).map((s, i) => (
          <motion.div key={s.id} className="flex items-center justify-between rounded-xl p-2.5" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={springTransitions.staggerItem(i)}>
            <div>
              <p className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>{s.bedtime} → {s.wakeTime}</p>
              <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>{s.duration}</p>
            </div>
            <div className="flex items-center gap-2">
              <div className="flex gap-0.5">
                {[1, 2, 3, 4, 5].map(n => <Star key={n} size={10} style={{ color: n <= (s.quality || 3) ? '#FF9500' : 'var(--text-tertiary)' }} fill={n <= (s.quality || 3) ? '#FF9500' : 'none'} />)}
              </div>
              <motion.button whileTap={{ scale: 0.9 }} onClick={() => startEdit(s)}><Edit3 size={14} style={{ color: 'var(--text-tertiary)' }} /></motion.button>
              <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_SLEEP', payload: s.id })}><Trash2 size={14} style={{ color: 'var(--text-tertiary)' }} /></motion.button>
            </div>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

function Habits() {
  const { state, dispatch } = useStore()
  const [showAdd, setShowAdd] = useState(false)
  const [name, setName] = useState('')
  const today = new Date().toISOString().split('T')[0]

  const todayDone = state.habits.filter(h => h.days[today]).length
  const total = state.habits.length || 1

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.15 }}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Dumbbell size={20} style={{ color: '#FF9500' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Habits</h2>
        </div>
        <span className="text-xs font-medium px-2 py-1 rounded-full" style={{ background: '#FF950020', color: '#FF9500' }}>{todayDone}/{total} today</span>
      </div>
      <AnimatePresence>
        {showAdd && (
          <motion.div className="flex gap-2 mb-3" initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Habit name..." value={name} onChange={e => setName(e.target.value)} autoFocus />
            <motion.button className="p-2 rounded-xl" style={{ background: '#FF9500', color: 'white' }} whileTap={{ scale: 0.9 }}
              onClick={() => { if (name.trim()) { dispatch({ type: 'ADD_HABIT', payload: { name: name.trim() } }); setName(''); setShowAdd(false) } }}>
              <Plus size={18} />
            </motion.button>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-2">
        {state.habits.map((h, i) => (
          <motion.div key={h.id} className="flex items-center gap-3 rounded-xl p-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
            <motion.button whileTap={{ scale: 0.8 }}
              onClick={() => dispatch({ type: 'TOGGLE_HABIT_DAY', payload: { habitId: h.id, date: today } })}
              className="w-7 h-7 rounded-lg flex items-center justify-center shrink-0"
              style={{ background: h.days[today] ? '#FF9500' : 'var(--border)' }}>
              {h.days[today] && <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} transition={springs.bouncy}>
                <Check size={16} color="white" />
              </motion.span>}
            </motion.button>
            <span className="text-sm flex-1" style={{ color: 'var(--text-primary)' }}>{h.name}</span>
            <span className="text-[10px]" style={{ color: 'var(--text-tertiary)' }}>
              {Object.values(h.days).filter(Boolean).length}d streak
            </span>
            <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_HABIT', payload: h.id })}>
              <Trash2 size={14} style={{ color: 'var(--text-tertiary)' }} />
            </motion.button>
          </motion.div>
        ))}
      </div>
      {state.habits.length === 0 && !showAdd && (
        <motion.button className="w-full py-3 rounded-xl text-sm font-medium" style={{ background: 'var(--bg)', color: 'var(--accent)' }} whileTap={{ scale: 0.97 }} onClick={() => setShowAdd(true)}>
          + Add Habit
        </motion.button>
      )}
    </motion.div>
  )
}

function SocialLimits() {
  const { state, dispatch } = useStore()
  const [showAdd, setShowAdd] = useState(false)
  const [name, setName] = useState('')
  const [limit, setLimit] = useState(60)
  const [minutes, setMinutes] = useState(0)

  const icons = ['📱', '📷', '🐦', '▶️', '🎵', '💬', '👻', '📌']
  const [icon, setIcon] = useState(icons[0])

  const totalMinutes = state.socialPlatforms.reduce((a, p) => a + (p.minutesToday || 0), 0)

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.2 }}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Smartphone size={20} style={{ color: '#FF2D55' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Social Limits</h2>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs font-medium" style={{ color: totalMinutes > 120 ? '#FF3B30' : 'var(--text-secondary)' }}>
            {totalMinutes}m today
          </span>
          <motion.button className="p-2 rounded-xl" style={{ background: '#FF2D5520' }} whileTap={{ scale: 0.9 }} onClick={() => setShowAdd(true)}>
            <Plus size={18} style={{ color: '#FF2D55' }} />
          </motion.button>
        </div>
      </div>
      <AnimatePresence>
        {showAdd && (
          <motion.div className="space-y-2 mb-3 p-3 rounded-xl" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <input className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Platform name..." value={name} onChange={e => setName(e.target.value)} autoFocus />
            <div className="flex gap-2">
              <div className="flex-1">
                <label className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>Daily limit (min)</label>
                <input type="number" value={limit} onChange={e => setLimit(+e.target.value)}
                  className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
              </div>
              <div className="flex-1">
                <label className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>Minutes today</label>
                <input type="number" value={minutes} onChange={e => setMinutes(+e.target.value)}
                  className="w-full rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
              </div>
            </div>
            <div className="flex gap-1">
              {icons.map(ic => (
                <motion.button key={ic} whileTap={{ scale: 0.8 }}
                  className="p-1.5 rounded-lg" style={{ background: icon === ic ? 'var(--card)' : 'transparent' }}
                  onClick={() => setIcon(ic)}>
                  <span className="text-lg">{ic}</span>
                </motion.button>
              ))}
            </div>
            <div className="flex gap-2">
              <motion.button className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: 'var(--accent)', color: 'white' }} whileTap={{ scale: 0.95 }}
                onClick={() => { if (name.trim()) { dispatch({ type: 'ADD_PLATFORM', payload: { name: name.trim(), limit, minutesToday: minutes, icon } }); setName(''); setShowAdd(false) } }}>
                Add
              </motion.button>
              <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }} whileTap={{ scale: 0.95 }} onClick={() => setShowAdd(false)}>Cancel</motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-2">
        {state.socialPlatforms.map((p, i) => {
          const over = (p.minutesToday || 0) > p.limit
          return (
            <motion.div key={p.id} className="flex items-center gap-3 rounded-xl p-3" style={{ background: over ? '#FF3B3010' : 'var(--bg)' }}
              initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
              <span className="text-lg">{p.icon || '📱'}</span>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>{p.name}</span>
                  {over && <motion.span className="text-[10px] px-1.5 py-0.5 rounded-full font-medium" style={{ background: '#FF3B30', color: 'white' }}
                    initial={{ scale: 0 }} animate={{ scale: 1 }} transition={springs.bouncy}>Over!</motion.span>}
                </div>
                <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>{p.minutesToday || 0}m / {p.limit}m</p>
              </div>
              <input type="number" value={p.minutesToday || 0} onChange={e => dispatch({ type: 'UPDATE_PLATFORM_TIME', payload: { id: p.id, minutes: +e.target.value } })}
                className="w-16 text-sm rounded-lg px-2 py-1 outline-none text-center" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
              <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_PLATFORM', payload: p.id })}>
                <Trash2 size={14} style={{ color: 'var(--text-tertiary)' }} />
              </motion.button>
            </motion.div>
          )
        })}
      </div>
    </motion.div>
  )
}

export default function Daily() {
  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto space-y-6 pb-24 md:pb-8">
      <Lessons />
      <SleepReporter />
      <Habits />
      <SocialLimits />
    </div>
  )
}
