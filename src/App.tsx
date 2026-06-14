import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AppShell } from './components/layout/AppShell'
import { HomePage } from './features/home/HomePage'
import { MindPage } from './features/mind/MindPage'
import { DailyPage } from './features/daily/DailyPage'
import { WorldPage } from './features/world/WorldPage'
import { CalendarPage } from './features/calendar/CalendarPage'
import { SettingsPage } from './features/settings/SettingsPage'
import { useThemeEffect } from './hooks/useThemeEffect'

function AppRoutes() {
  useThemeEffect()
  return (
    <Routes>
      <Route element={<AppShell />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/mind/*" element={<MindPage />} />
        <Route path="/daily/*" element={<DailyPage />} />
        <Route path="/world/*" element={<WorldPage />} />
        <Route path="/calendar" element={<CalendarPage />} />
        <Route path="/settings" element={<SettingsPage />} />
      </Route>
    </Routes>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <AppRoutes />
    </BrowserRouter>
  )
}
