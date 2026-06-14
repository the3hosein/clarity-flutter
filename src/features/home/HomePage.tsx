import { useEffect, useState } from 'react'
import { format, isToday, parseISO, differenceInSeconds } from 'date-fns'
import { motion } from 'framer-motion'
import { Card } from '../../components/ui/Card'
import { RingChart } from '../../components/charts/RingChart'
import { WeatherCard } from './WeatherCardInner'
import { sleepDuration } from '../../lib/constants'
import { useAppStore } from '../../stores/useAppStore'
import { getGreeting, todayKey } from '../../lib/constants'
import { springs, stagger, fadeUp } from '../../lib/springs'

function AnimatedGreeting({ text, animate }: { text: string; animate: boolean }) {
  if (!animate) return <h1 className="text-[var(--font-2xl)] font-bold">{text}</h1>
  return (
    <h1 className="text-[var(--font-2xl)] font-bold">
      {text.split('').map((char, i) => (
        <motion.span
          key={i}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ ...springs.smooth, delay: i * 0.03 }}
        >
          {char}
        </motion.span>
      ))}
    </h1>
  )
}

export function HomePage() {
  const settings = useAppStore((s) => s.settings)
  const greetingAnimated = useAppStore((s) => s.greetingAnimated)
  const setGreetingAnimated = useAppStore((s) => s.setGreetingAnimated)
  const lessonSlots = useAppStore((s) => s.lessonSlots)
  const lessonChecks = useAppStore((s) => s.lessonChecks)
  const sleepEntries = useAppStore((s) => s.sleepEntries)
  const journalNotes = useAppStore((s) => s.journalNotes)
  const habits = useAppStore((s) => s.habits)
  const calendarEvents = useAppStore((s) => s.calendarEvents)
  const activityLog = useAppStore((s) => s.activityLog)

  const today = todayKey()
  const dayOfWeek = new Date().getDay() || 7

  const todayLessons = lessonSlots.filter((s) => s.day === dayOfWeek)
  const doneLessons = todayLessons.filter((l) =>
    lessonChecks.some((c) => c.slotId === l.id && c.date === today && c.status === 'done'),
  ).length

  const lastSleep = sleepEntries[0]
  const journalToday = journalNotes.some((n) => isToday(parseISO(n.updatedAt)))
  const habitsDone = habits.filter((h) => h.completions[today]).length

  const nextEvent = [...calendarEvents]
    .filter((e) => new Date(e.start) > new Date())
    .sort((a, b) => new Date(a.start).getTime() - new Date(b.start).getTime())[0]

  const [countdown, setCountdown] = useState('')
  useEffect(() => {
    if (!nextEvent) return
    const tick = () => {
      const secs = differenceInSeconds(parseISO(nextEvent.start), new Date())
      if (secs <= 0) setCountdown('Now')
      else if (secs < 86400) {
        const h = Math.floor(secs / 3600)
        const m = Math.floor((secs % 3600) / 60)
        setCountdown(`${h}h ${m}m`)
      } else setCountdown(format(parseISO(nextEvent.start), 'MMM d, h:mm a'))
    }
    tick()
    const id = setInterval(tick, 60000)
    return () => clearInterval(id)
  }, [nextEvent])

  useEffect(() => {
    if (!greetingAnimated) {
      const t = setTimeout(() => setGreetingAnimated(true), 1500)
      return () => clearTimeout(t)
    }
  }, [greetingAnimated, setGreetingAnimated])

  const lessonPct = todayLessons.length ? (doneLessons / todayLessons.length) * 100 : 0
  const habitPct = habits.length ? (habitsDone / habits.length) * 100 : 0

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div>
        <AnimatedGreeting text={getGreeting(settings.name)} animate={!greetingAnimated} />
        <p className="mt-1 text-[var(--font-lg)] text-[var(--text-secondary)]">{format(new Date(), 'EEEE, MMMM d')}</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card delay={0.05}>
          <WeatherCard />
        </Card>

        <Card delay={0.1} className="lg:col-span-2">
          <p className="mb-4 text-sm font-medium text-[var(--text-secondary)]">Today's summary</p>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <RingChart value={lessonPct} label="Lessons" />
            <div className="flex flex-col items-center justify-center">
              <span className="text-2xl font-bold">
                {lastSleep ? `${sleepDuration(lastSleep.bedtime, lastSleep.wakeTime).hours}h` : '—'}
              </span>
              <span className="text-xs text-[var(--text-secondary)]">Sleep</span>
            </div>
            <div className="flex flex-col items-center justify-center">
              <span className="text-2xl">{journalToday ? '✓' : '✗'}</span>
              <span className="text-xs text-[var(--text-secondary)]">Journal</span>
            </div>
            <RingChart value={habitPct} label="Habits" color="var(--success)" />
          </div>
        </Card>
      </div>

      {nextEvent && (
        <Card delay={0.15}>
          <p className="text-sm text-[var(--text-secondary)]">Next up</p>
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold">{nextEvent.title}</h3>
              <p className="text-sm text-[var(--text-secondary)]">{format(parseISO(nextEvent.start), 'h:mm a')}</p>
            </div>
            <motion.span key={countdown} initial={{ scale: 0.9 }} animate={{ scale: 1 }} transition={springs.smooth} className="rounded-full bg-[var(--accent-soft)] px-3 py-1 text-sm font-medium text-[var(--accent)]">
              {countdown}
            </motion.span>
          </div>
        </Card>
      )}

      <Card delay={0.2}>
        <h3 className="mb-3 font-semibold">Recent activity</h3>
        {activityLog.length === 0 ? (
          <p className="text-sm text-[var(--text-secondary)]">No activity yet — start exploring!</p>
        ) : (
          <motion.ul variants={stagger(0.05)} initial="hidden" animate="show" className="space-y-2">
            {activityLog.slice(0, 5).map((entry) => (
              <motion.li key={entry.id} variants={fadeUp} className="flex justify-between text-sm">
                <span>{entry.action}</span>
                <span className="text-[var(--text-secondary)]">{entry.section}</span>
              </motion.li>
            ))}
          </motion.ul>
        )}
      </Card>
    </div>
  )
}
