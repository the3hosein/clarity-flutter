import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { useStore } from '../store'
import { springs, springTransitions } from '../animations'
import { CloudSun, Moon, Sun, Sunrise, Sparkles, BookOpen, Brain, Globe, Dumbbell, Zap } from 'lucide-react'

function Greeting() {
  const { state } = useStore()
  const hour = new Date().getHours()
  const greet = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening'
  const Icon = hour < 12 ? Sunrise : hour < 17 ? Sun : Moon
  const text = `${greet}, ${state.userName}`
  return (
    <motion.div
      className="flex items-center gap-3"
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={springs.gentle}
    >
      <motion.div
        animate={{ rotate: [0, 10, -5, 0] }}
        transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
      >
        <Icon size={36} style={{ color: 'var(--accent)' }} />
      </motion.div>
      <div>
        <motion.h1
          className="text-2xl font-bold"
          style={{ color: 'var(--text-primary)' }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ staggerChildren: 0.03 }}
        >
          {text.split('').map((ch, i) => (
            <motion.span
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={springTransitions.staggerItem(i, 0.02)}
            >
              {ch}
            </motion.span>
          ))}
        </motion.h1>
        <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
          {new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
        </p>
      </div>
    </motion.div>
  )
}

function WeatherCard() {
  const [weather, setWeather] = useState(null)
  useEffect(() => {
    fetch('https://api.open-meteo.com/v1/forecast?latitude=35.6892&longitude=51.3890&current_weather=true')
      .then(r => r.json()).then(d => setWeather(d.current_weather)).catch(() => {})
  }, [])
  return (
    <motion.div
      className="rounded-2xl p-4 flex items-center gap-4"
      style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={springs.smooth}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.97 }}
    >
      <motion.div animate={{ rotate: [0, 360] }} transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}>
        <CloudSun size={40} style={{ color: 'var(--accent)' }} />
      </motion.div>
      <div>
        <p className="text-2xl font-bold" style={{ color: 'var(--text-primary)' }}>
          {weather ? `${Math.round(weather.temperature)}°C` : '--°C'}
        </p>
        <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
          {weather ? `Wind: ${weather.windspeed} km/h` : 'Loading...'}
        </p>
      </div>
    </motion.div>
  )
}

function ProgressRing({ value, max, label, color, icon: Icon }) {
  const pct = max > 0 ? Math.min(value / max, 1) : 0
  const circumference = 2 * Math.PI * 36
  const offset = circumference * (1 - pct)
  return (
    <motion.div
      className="flex flex-col items-center gap-1"
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={springs.bouncy}
    >
      <div className="relative w-20 h-20">
        <svg width="80" height="80" viewBox="0 0 80 80">
          <circle cx="40" cy="40" r="36" fill="none" stroke="var(--border)" strokeWidth="6" />
          <motion.circle
            cx="40" cy="40" r="36" fill="none"
            stroke={color || 'var(--accent)'} strokeWidth="6"
            strokeLinecap="round"
            strokeDasharray={circumference}
            initial={{ strokeDashoffset: circumference }}
            animate={{ strokeDashoffset: offset }}
            transition={springs.smooth}
            transform="rotate(-90 40 40)"
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          {Icon && <Icon size={18} style={{ color: color || 'var(--accent)' }} />}
        </div>
      </div>
      <span className="text-xs font-medium" style={{ color: 'var(--text-primary)' }}>{value}/{max}</span>
      <span className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{label}</span>
    </motion.div>
  )
}

function NextEvent() {
  const { state } = useStore()
  const now = new Date()
  const next = state.calendarEvents
    .filter(e => new Date(e.start) > now)
    .sort((a, b) => new Date(a.start) - new Date(b.start))[0]
  if (!next) return null
  const diff = new Date(next.start) - now
  const hours = Math.floor(diff / 3600000)
  const mins = Math.floor((diff % 3600000) / 60000)
  return (
    <motion.div
      className="rounded-2xl p-4"
      style={{ background: `color-mix(in srgb, var(--accent) 12%, var(--card))`, boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ ...springs.smooth, delay: 0.1 }}
      whileHover={{ scale: 1.02 }}
    >
      <p className="text-xs font-medium uppercase tracking-wider" style={{ color: 'var(--accent)' }}>Next Event</p>
      <p className="text-lg font-bold mt-1" style={{ color: 'var(--text-primary)' }}>{next.title}</p>
      {diff < 86400000 && (
        <motion.p
          className="text-sm mt-1 font-semibold"
          style={{ color: 'var(--accent)' }}
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={springs.bouncy}
        >
          {hours}h {mins}m remaining
        </motion.p>
      )}
    </motion.div>
  )
}

function ActivityFeed() {
  const { state } = useStore()
  return (
    <div className="space-y-2">
      <h3 className="text-sm font-semibold uppercase tracking-wider" style={{ color: 'var(--text-secondary)' }}>Recent Activity</h3>
      {state.activityFeed.slice(0, 5).map((a, i) => (
        <motion.div
          key={a.id}
          className="flex items-center gap-3 rounded-xl p-3"
          style={{ background: 'var(--card)' }}
          initial={{ opacity: 0, x: -16 }}
          animate={{ opacity: 1, x: 0 }}
          transition={springTransitions.staggerItem(i)}
        >
          <span className="text-lg">{a.emoji}</span>
          <div className="flex-1 min-w-0">
            <p className="text-sm truncate" style={{ color: 'var(--text-primary)' }}>{a.text}</p>
            <p className="text-xs" style={{ color: 'var(--text-tertiary)' }}>
              {new Date(a.time).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
            </p>
          </div>
        </motion.div>
      ))}
    </div>
  )
}

export default function Dashboard() {
  const { state } = useStore()
  const lessonsDone = state.lessons.filter(l => l.completed).length
  const lessonsTotal = state.lessons.length || 1
  const habitsDone = state.habits.filter(h => Object.values(h.days).filter(Boolean).length > 0).length
  const habitsTotal = state.habits.length || 1
  const lastSleep = state.sleepLogs[0]
  const hasJournalToday = state.journalEntries.some(e =>
    new Date(e.createdAt).toDateString() === new Date().toDateString()
  )

  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-6xl mx-auto space-y-6 pb-24 md:pb-8">
      <Greeting />
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <WeatherCard />
        <NextEvent />
        <motion.div
          className="rounded-2xl p-4 flex items-center gap-3"
          style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ ...springs.smooth, delay: 0.15 }}
        >
          <Sparkles size={28} style={{ color: 'var(--accent)' }} />
          <div>
            <p className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>Daily Quote</p>
            <motion.p
              className="text-xs italic"
              style={{ color: 'var(--text-secondary)' }}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ ...springs.gentle, delay: 0.3 }}
            >
              "The secret of getting ahead is getting started."
            </motion.p>
          </div>
        </motion.div>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <ProgressRing value={lessonsDone} max={lessonsTotal} label="Lessons" color="#34C759" icon={BookOpen} />
        <ProgressRing value={lastSleep ? parseFloat(lastSleep.duration) || 7 : 0} max={state.sleepGoal} label="Sleep (h)" color="#5E5CE6" icon={Moon} />
        <ProgressRing value={hasJournalToday ? 1 : 0} max={1} label="Journaled" color="#FF9500" icon={Brain} />
        <ProgressRing value={habitsDone} max={habitsTotal} label="Habits" color="#FF2D55" icon={Dumbbell} />
      </div>
      <ActivityFeed />
    </div>
  )
}
