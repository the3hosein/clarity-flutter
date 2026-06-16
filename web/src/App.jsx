import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from './store'
import { springs, springTransitions } from './animations'
import { Menu, X, LayoutDashboard, Brain, Sun, Globe, Calendar, Settings } from 'lucide-react'
import Dashboard from './screens/Dashboard'
import Mind from './screens/Mind'
import Daily from './screens/Daily'
import World from './screens/World'
import CalendarScreen from './screens/Calendar'
import SettingsScreen from './screens/Settings'

const tabs = [
  { id: 'dashboard', label: 'Home', icon: LayoutDashboard },
  { id: 'mind', label: 'Mind', icon: Brain },
  { id: 'daily', label: 'Daily', icon: Sun },
  { id: 'world', label: 'World', icon: Globe },
  { id: 'calendar', label: 'Calendar', icon: Calendar },
  { id: 'settings', label: 'Settings', icon: Settings },
]

function Sidebar({ active, setActive, collapsed, setCollapsed }) {
  const { state } = useStore()

  return (
    <motion.aside
      className="h-full flex flex-col border-r overflow-hidden"
      style={{ borderColor: 'var(--border)', background: 'var(--card)' }}
      animate={{ width: collapsed ? 72 : 240 }}
      transition={springs.gentle}
    >
      <div className="flex items-center justify-between px-4 h-16 shrink-0" style={{ borderBottom: '1px solid var(--border)' }}>
        <AnimatePresence mode="wait">
          {!collapsed && (
            <motion.span
              key="title"
              className="text-lg font-bold truncate"
              initial={{ opacity: 0, x: -8 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -8 }}
              transition={springs.smooth}
            >
              <span style={{ color: 'var(--accent)' }}>Clarity</span>
            </motion.span>
          )}
        </AnimatePresence>
        <button onClick={() => setCollapsed(!collapsed)} className="p-2 rounded-lg hover:opacity-70" style={{ color: 'var(--text-secondary)' }}>
          {collapsed ? <Menu size={20} /> : <X size={20} />}
        </button>
      </div>
      <nav className="flex-1 py-3 space-y-1 px-2">
        {tabs.map((tab, i) => {
          const Icon = tab.icon
          const isActive = active === tab.id
          return (
            <motion.button
              key={tab.id}
              className="relative flex items-center gap-3 w-full rounded-xl text-sm font-medium h-11 px-3"
              style={{ color: isActive ? 'var(--accent)' : 'var(--text-secondary)' }}
              onClick={() => setActive(tab.id)}
              initial={{ opacity: 0, x: -16 }}
              animate={{ opacity: 1, x: 0 }}
              transition={springTransitions.staggerItem(i)}
              whileHover={{ scale: 1.02, background: 'var(--border)' }}
              whileTap={{ scale: 0.97 }}
            >
              {isActive && (
                <motion.div
                  className="absolute inset-0 rounded-xl"
                  style={{ background: `color-mix(in srgb, var(--accent) 12%, transparent)` }}
                  layoutId="sidebar-pill"
                  transition={springs.snappy}
                />
              )}
              <Icon size={20} className="shrink-0" />
              <AnimatePresence mode="wait">
                {!collapsed && (
                  <motion.span
                    key="label"
                    className="truncate"
                    initial={{ opacity: 0, x: -8 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -8 }}
                    transition={springs.smooth}
                  >
                    {tab.label}
                  </motion.span>
                )}
              </AnimatePresence>
            </motion.button>
          )
        })}
      </nav>
    </motion.aside>
  )
}

function TabBar({ active, setActive }) {
  return (
    <nav className="flex items-center justify-around h-16 shrink-0 border-t safe-bottom" style={{ background: 'var(--card)', borderColor: 'var(--border)' }}>
      {tabs.map(tab => {
        const Icon = tab.icon
        const isActive = active === tab.id
        return (
          <motion.button
            key={tab.id}
            className="flex flex-col items-center justify-center gap-0.5 flex-1 h-full relative"
            style={{ color: isActive ? 'var(--accent)' : 'var(--text-tertiary)' }}
            onClick={() => setActive(tab.id)}
            whileTap={{ scale: 0.9 }}
          >
            <motion.div
              animate={isActive ? { scale: 1.2 } : { scale: 1 }}
              transition={springs.snappy}
            >
              <Icon size={22} />
            </motion.div>
            <span className="text-[10px] font-medium">{tab.label}</span>
          </motion.button>
        )
      })}
    </nav>
  )
}

function ScreenContent({ active }) {
  const screens = {
    dashboard: Dashboard,
    mind: Mind,
    daily: Daily,
    world: World,
    calendar: CalendarScreen,
    settings: SettingsScreen,
  }
  const Screen = screens[active]

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={active}
        className="flex-1 overflow-y-auto"
        initial={{ opacity: 0, x: 40 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -40 }}
        transition={springs.smooth}
      >
        <Screen />
      </motion.div>
    </AnimatePresence>
  )
}

export default function App() {
  const { state } = useStore()
  const [active, setActive] = useState('dashboard')
  const [collapsed, setCollapsed] = useState(false)
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768)

  useEffect(() => {
    const onResize = () => setIsMobile(window.innerWidth < 768)
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  const style = { '--accent': state.accentColor, '--accent-hover': state.accentColor + 'cc' }

  return (
      <div className="h-full w-full flex" style={style}>
      {isMobile ? (
        <div className="flex flex-col flex-1">
          <div className="flex-1 overflow-hidden relative">
            <ScreenContent active={active} />
          </div>
          <TabBar active={active} setActive={setActive} />
        </div>
      ) : (
        <>
          <Sidebar active={active} setActive={setActive} collapsed={collapsed} setCollapsed={setCollapsed} />
          <div className="flex-1 overflow-hidden relative">
            <ScreenContent active={active} />
          </div>
        </>
      )}
    </div>
  )
}
