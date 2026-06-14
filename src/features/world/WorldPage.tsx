import { Routes, Route, NavLink } from 'react-router-dom'
import { MoviesPage } from './MoviesPage'
import { MusicPage } from './MusicPage'
import { BooksPage } from './BooksPage'
import { YouTubePage } from './YouTubePage'

export function WorldPage() {
  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="mb-4 text-[var(--font-xl)] font-bold">World</h1>
      <nav className="mb-6 flex gap-2 overflow-x-auto">
        {[
          { to: '/world', label: 'Movies', end: true },
          { to: '/world/music', label: 'Music' },
          { to: '/world/books', label: 'Books' },
          { to: '/world/youtube', label: 'YouTube' },
        ].map((tab) => (
          <NavLink key={tab.to} to={tab.to} end={tab.end} className={({ isActive }) => `rounded-full px-4 py-2 text-sm font-medium ${isActive ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)] text-[var(--text-secondary)]'}`}>
            {tab.label}
          </NavLink>
        ))}
      </nav>
      <Routes>
        <Route index element={<MoviesPage />} />
        <Route path="music" element={<MusicPage />} />
        <Route path="books" element={<BooksPage />} />
        <Route path="youtube" element={<YouTubePage />} />
      </Routes>
    </div>
  )
}
