import { NavLink, useLocation } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Brain,
  Calendar,
  ChevronLeft,
  ChevronRight,
  Globe,
  Home,
  Settings,
  Sun,
} from 'lucide-react'
import { springs } from '../../lib/springs'
import { useAppStore } from '../../stores/useAppStore'
import { useIsMobile, useIsTablet } from '../../hooks/useMediaQuery'

const navItems = [
  { to: '/', icon: Home, label: 'Home' },
  { to: '/mind', icon: Brain, label: 'Mind' },
  { to: '/daily', icon: Sun, label: 'Daily' },
  { to: '/world', icon: Globe, label: 'World' },
  { to: '/calendar', icon: Calendar, label: 'Calendar' },
  { to: '/settings', icon: Settings, label: 'Settings' },
]

export function Sidebar() {
  const collapsed = useAppStore((s) => s.sidebarCollapsed)
  const setCollapsed = useAppStore((s) => s.setSidebarCollapsed)
  const isTablet = useIsTablet()
  const location = useLocation()

  if (useIsMobile()) return null

  const width = collapsed ? 72 : 240

  return (
    <motion.aside
      animate={{ width }}
      transition={springs.gentle}
      className="fixed top-0 left-0 z-40 flex h-full flex-col border-r border-[var(--border)] bg-[var(--card)] safe-top"
    >
      <div className="flex items-center justify-between p-4">
        {!collapsed && (
          <motion.span initial={{ opacity: 0, x: -8 }} animate={{ opacity: 1, x: 0 }} className="text-lg font-bold">
            Clarity
          </motion.span>
        )}
        {isTablet && (
          <button type="button" onClick={() => setCollapsed(!collapsed)} className="rounded-lg p-2">
            {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
          </button>
        )}
      </div>
      <nav className="flex flex-1 flex-col gap-1 px-2">
        {navItems.map((item, i) => {
          const active = item.to === '/' ? location.pathname === '/' : location.pathname.startsWith(item.to)
          return (
            <NavLink key={item.to} to={item.to} className="relative block">
              <motion.div
                initial={{ opacity: 0, x: -12 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ ...springs.gentle, delay: collapsed ? 0 : i * 0.05 }}
                whileHover={{ scale: 1.02 }}
                className={`flex min-h-[44px] items-center gap-3 rounded-xl px-3 py-2 transition-colors duration-150 ${active ? 'text-[var(--accent)]' : 'text-[var(--text-secondary)] hover:bg-[var(--bg)]'}`}
              >
                {active && (
                  <motion.span
                    layoutId="sidebar-pill"
                    transition={springs.snappy}
                    className="absolute inset-0 rounded-xl bg-[var(--accent-soft)]"
                  />
                )}
                <item.icon size={20} className="relative z-10 shrink-0" />
                {!collapsed && <span className="relative z-10 text-sm font-medium">{item.label}</span>}
              </motion.div>
            </NavLink>
          )
        })}
      </nav>
    </motion.aside>
  )
}

export function BottomTabBar() {
  const location = useLocation()
  const isMobile = useIsMobile()
  const tabs = navItems.filter((n) => n.to !== '/settings')

  if (!isMobile) return null

  return (
    <nav className="fixed right-0 bottom-0 left-0 z-40 border-t border-[var(--border)] bg-[var(--glass)] backdrop-blur-xl safe-bottom">
      <div className="flex justify-around px-2 py-2">
        {tabs.map((tab) => {
          const active = tab.to === '/' ? location.pathname === '/' : location.pathname.startsWith(tab.to)
          return (
            <NavLink key={tab.to} to={tab.to} className="flex min-h-[44px] min-w-[44px] flex-col items-center justify-center">
              <motion.div animate={{ scale: active ? 1.2 : 1, color: active ? 'var(--accent)' : 'var(--text-secondary)' }} transition={springs.snappy}>
                <tab.icon size={22} />
              </motion.div>
              <span className={`mt-0.5 text-[10px] ${active ? 'text-[var(--accent)]' : 'text-[var(--text-secondary)]'}`}>{tab.label}</span>
            </NavLink>
          )
        })}
      </div>
    </nav>
  )
}

export function PageTransition({ children }: { children: React.ReactNode }) {
  const location = useLocation()
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0, x: 24 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -24 }}
        transition={springs.smooth}
        className="min-h-full"
      >
        {children}
      </motion.div>
    </AnimatePresence>
  )
}
