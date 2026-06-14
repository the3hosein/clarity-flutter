import { Routes, Route, NavLink } from 'react-router-dom'
import { TargetPage } from './TargetPage'
import { ChannelsPage } from './ChannelsPage'
import { JournalPage } from './JournalPage'

export function MindPage() {
  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="mb-4 text-[var(--font-xl)] font-bold">Mind</h1>
      <nav className="mb-6 flex gap-2 overflow-x-auto">
        {[
          { to: '/mind', label: 'Target', end: true },
          { to: '/mind/channels', label: 'Channels' },
          { to: '/mind/journal', label: 'Journal' },
        ].map((tab) => (
          <NavLink
            key={tab.to}
            to={tab.to}
            end={tab.end}
            className={({ isActive }) =>
              `rounded-full px-4 py-2 text-sm font-medium transition-colors duration-150 ${isActive ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)] text-[var(--text-secondary)]'}`
            }
          >
            {tab.label}
          </NavLink>
        ))}
      </nav>
      <Routes>
        <Route index element={<TargetPage />} />
        <Route path="channels" element={<ChannelsPage />} />
        <Route path="journal/*" element={<JournalPage />} />
      </Routes>
    </div>
  )
}
