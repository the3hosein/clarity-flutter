import { useState, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from '../store'
import { springs } from '../animations'
import { Sun, Moon, Monitor, Palette, Download, Upload, RotateCcw, Trophy, Smartphone } from 'lucide-react'

const presetColors = ['#007AFF', '#34C759', '#FF9500', '#FF2D55', '#5E5CE6', '#FF3B30', '#00C7BE', '#AF52DE']
const emojis = ['🧑‍💻', '👨‍🎓', '👩‍🎓', '🌟', '🚀', '💡', '🎯', '🌈', '🔥', '⭐', '🦋', '🌻']

function SettingsScreen() {
  const { state, dispatch } = useStore()
  const [name, setName] = useState(state.userName)
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const fileRef = useRef(null)
  const [showReset, setShowReset] = useState(false)

  const handleExport = () => {
    const data = JSON.stringify(state, null, 2)
    const blob = new Blob([data], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url; a.download = 'clarity-backup.json'; a.click()
    URL.revokeObjectURL(url)
  }

  const handleImport = (e) => {
    const file = e.target.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (ev) => {
      try {
        const data = JSON.parse(ev.target.result)
        dispatch({ type: 'IMPORT_DATA', payload: data })
        alert('Data imported successfully!')
      } catch { alert('Invalid file format') }
    }
    reader.readAsText(file)
  }

  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-2xl mx-auto space-y-6 pb-24 md:pb-8">
      <h1 className="text-2xl font-bold" style={{ color: 'var(--text-primary)' }}>Settings</h1>

      <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
        initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={springs.smooth}>
        <h2 className="font-semibold mb-4" style={{ color: 'var(--text-primary)' }}>Profile</h2>
        <div className="flex items-center gap-4 mb-4">
          <motion.button
            className="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl relative"
            style={{ background: `color-mix(in srgb, var(--accent) 12%, transparent)` }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.9 }}
            onClick={() => setShowEmojiPicker(!showEmojiPicker)}
          >
            {state.avatarEmoji}
          </motion.button>
          <div className="flex-1">
            <input
              className="w-full rounded-xl px-4 py-2.5 text-base font-medium outline-none"
              style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              value={name}
              onChange={e => { setName(e.target.value); dispatch({ type: 'SET_USER_NAME', payload: e.target.value }) }}
              placeholder="Your name"
            />
          </div>
        </div>
        <AnimatePresence>
          {showEmojiPicker && (
            <motion.div className="flex flex-wrap gap-2 mb-2"
              initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
              {emojis.map(e => (
                <motion.button key={e} whileTap={{ scale: 0.8 }} className="text-2xl p-1.5 rounded-xl"
                  style={{ background: state.avatarEmoji === e ? `color-mix(in srgb, var(--accent) 12%, transparent)` : 'transparent' }}
                  onClick={() => { dispatch({ type: 'SET_AVATAR', payload: e }); setShowEmojiPicker(false) }}>
                  {e}
                </motion.button>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
        initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.1 }}>
        <h2 className="font-semibold mb-4" style={{ color: 'var(--text-primary)' }}>Appearance</h2>
        <div className="flex gap-2 mb-4">
          {[
            { value: 'light', icon: Sun, label: 'Light' },
            { value: 'dark', icon: Moon, label: 'Dark' },
            { value: 'system', icon: Monitor, label: 'System' },
          ].map(({ value, icon: Icon, label }) => (
            <motion.button key={value} whileTap={{ scale: 0.95 }}
              className="flex items-center gap-2 flex-1 px-3 py-2.5 rounded-xl text-sm font-medium"
              style={{
                background: state.theme === value ? 'var(--accent)' : 'var(--bg)',
                color: state.theme === value ? 'white' : 'var(--text-secondary)',
              }}
              onClick={() => dispatch({ type: 'SET_THEME', payload: value })}>
              <Icon size={16} />
              {label}
            </motion.button>
          ))}
        </div>

        <h3 className="text-sm font-medium mb-3" style={{ color: 'var(--text-secondary)' }}>Accent Color</h3>
        <div className="flex flex-wrap gap-3">
          {presetColors.map(color => (
            <motion.button key={color}
              className="w-9 h-9 rounded-xl flex items-center justify-center"
              style={{ background: color }}
              whileHover={{ scale: 1.15 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => dispatch({ type: 'SET_ACCENT', payload: color })}
            >
              {state.accentColor === color && (
                <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} transition={springs.bouncy}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3"><polyline points="20 6 9 17 4 12"/></svg>
                </motion.span>
              )}
            </motion.button>
          ))}
          <input type="color" value={state.accentColor} onChange={e => dispatch({ type: 'SET_ACCENT', payload: e.target.value })}
            className="w-9 h-9 rounded-xl border-0 cursor-pointer" style={{ background: 'var(--bg)' }} />
        </div>
      </motion.div>

      <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
        initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.2 }}>
        <h2 className="font-semibold mb-4" style={{ color: 'var(--text-primary)' }}>Sleep Goal</h2>
        <div className="flex items-center gap-4">
          <Trophy size={20} style={{ color: 'var(--accent)' }} />
          <input type="range" min="4" max="12" step="0.5" value={state.sleepGoal}
            onChange={e => dispatch({ type: 'SET_SLEEP_GOAL', payload: +e.target.value })}
            className="flex-1 accent-[var(--accent)]" />
          <span className="text-lg font-bold" style={{ color: 'var(--accent)' }}>{state.sleepGoal}h</span>
        </div>
      </motion.div>

      <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
        initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.3 }}>
        <h2 className="font-semibold mb-4" style={{ color: 'var(--text-primary)' }}>Data</h2>
        <div className="flex flex-wrap gap-3">
          <motion.button className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium"
            style={{ background: 'var(--bg)', color: 'var(--accent)', border: '1px solid var(--border)' }}
            whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.97 }} onClick={handleExport}>
            <Download size={16} /> Export Data
          </motion.button>
          <motion.button className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium"
            style={{ background: 'var(--bg)', color: 'var(--accent)', border: '1px solid var(--border)' }}
            whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.97 }} onClick={() => fileRef.current?.click()}>
            <Upload size={16} /> Import Data
          </motion.button>
          <input ref={fileRef} type="file" accept=".json" onChange={handleImport} style={{ display: 'none' }} />
          <motion.button className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium"
            style={{ background: '#FF3B3015', color: '#FF3B30', border: '1px solid #FF3B3030' }}
            whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.97 }} onClick={() => setShowReset(true)}>
            <RotateCcw size={16} /> Reset All
          </motion.button>
        </div>
        <AnimatePresence>
          {showReset && (
            <motion.div className="mt-4 p-4 rounded-xl" style={{ background: '#FF3B3010', border: '1px solid #FF3B3030' }}
              initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} transition={springs.smooth}>
              <p className="text-sm mb-3" style={{ color: 'var(--text-primary)' }}>Are you sure? This will delete ALL your data.</p>
              <div className="flex gap-2">
                <motion.button className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: '#FF3B30', color: 'white' }}
                  whileTap={{ scale: 0.95 }} onClick={() => { dispatch({ type: 'RESET_ALL' }); setShowReset(false) }}>
                  Yes, Reset Everything
                </motion.button>
                <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }}
                  whileTap={{ scale: 0.95 }} onClick={() => setShowReset(false)}>
                  Cancel
                </motion.button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      <p className="text-center text-xs" style={{ color: 'var(--text-tertiary)' }}>
        Clarity v1.0 · All data stored locally
      </p>
    </div>
  )
}

export default SettingsScreen
