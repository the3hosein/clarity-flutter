import { Routes, Route, NavLink } from 'react-router-dom'
import { LessonsPage } from './LessonsPage'
import { SleepPage } from './SleepPage'
import { SocialPage } from './SocialPage'
import { HabitsPage } from './HabitsPage'

export function DailyPage() {
  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="mb-4 text-[var(--font-xl)] font-bold">Daily</h1>
      <nav className="mb-6 flex gap-2 overflow-x-auto">
        {[
          { to: '/daily', label: 'Lessons', end: true },
          { to: '/daily/sleep', label: 'Sleep' },
          { to: '/daily/social', label: 'Social' },
          { to: '/daily/habits', label: 'Habits' },
        ].map((tab) => (
          <NavLink key={tab.to} to={tab.to} end={tab.end} className={({ isActive }) => `rounded-full px-4 py-2 text-sm font-medium ${isActive ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)] text-[var(--text-secondary)]'}`}>
            {tab.label}
          </NavLink>
        ))}
      </nav>
      <Routes>
        <Route index element={<LessonsPage />} />
        <Route path="sleep" element={<SleepPage />} />
        <Route path="social" element={<SocialPage />} />
        <Route path="habits" element={<HabitsPage />} />
      </Routes>
    </div>
  )
}
