import { useRef, useState } from 'react'
import { motion } from 'framer-motion'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Toggle } from '../../components/ui/Toggle'
import { Modal } from '../../components/ui/Modal'
import { useAppStore, exportAppState } from '../../stores/useAppStore'
import { exportData, importData } from '../../lib/storage'
import { ACCENT_PRESETS } from '../../lib/constants'
import { springs } from '../../lib/springs'
import { LocalNotifications } from '@capacitor/local-notifications'
import type { ThemeMode } from '../../types'

const AVATARS = ['🎓', '🚀', '⭐', '🌟', '🎯', '📚', '💡', '🔥']

export function SettingsPage() {
  const settings = useAppStore((s) => s.settings)
  const updateSettings = useAppStore((s) => s.updateSettings)
  const importState = useAppStore((s) => s.importState)
  const resetAll = useAppStore((s) => s.resetAll)

  const [confirmReset, setConfirmReset] = useState(false)
  const [customAccent, setCustomAccent] = useState(settings.accentColor)
  const fileRef = useRef<HTMLInputElement>(null)

  const handleImport = async (file: File) => {
    const data = await importData(file) as ReturnType<typeof exportAppState>
    importState(data)
  }

  const requestNotifications = async () => {
    try {
      await LocalNotifications.requestPermissions()
      updateSettings({ notificationsEnabled: true })
    } catch {
      if ('Notification' in window) {
        const perm = await Notification.requestPermission()
        updateSettings({ notificationsEnabled: perm === 'granted' })
      }
    }
  }

  return (
    <div className="mx-auto max-w-lg space-y-6">
      <h1 className="text-[var(--font-xl)] font-bold">Settings</h1>

      <Card>
        <h3 className="mb-3 font-semibold">Profile</h3>
        <label className="mb-3 block text-sm">Name
          <input value={settings.name} onChange={(e) => updateSettings({ name: e.target.value })} className="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3" />
        </label>
        <p className="mb-2 text-sm">Avatar</p>
        <div className="flex flex-wrap gap-2">
          {AVATARS.map((a) => (
            <motion.button
              key={a}
              type="button"
              whileTap={{ scale: 1.2 }}
              transition={springs.bouncy}
              onClick={() => updateSettings({ avatar: a })}
              className={`text-2xl rounded-xl p-2 ${settings.avatar === a ? 'bg-[var(--accent-soft)] ring-2 ring-[var(--accent)]' : 'bg-[var(--bg)]'}`}
            >
              {a}
            </motion.button>
          ))}
        </div>
      </Card>

      <Card>
        <h3 className="mb-3 font-semibold">Appearance</h3>
        <div className="mb-4 flex gap-2">
          {(['light', 'dark', 'system'] as ThemeMode[]).map((t) => (
            <Button key={t} variant={settings.theme === t ? 'primary' : 'secondary'} onClick={() => updateSettings({ theme: t })} className="flex-1 capitalize">
              {t}
            </Button>
          ))}
        </div>
        <p className="mb-2 text-sm">Accent color</p>
        <div className="mb-3 flex flex-wrap gap-2">
          {ACCENT_PRESETS.map((c) => (
            <button key={c} type="button" onClick={() => updateSettings({ accentColor: c })} className={`h-8 w-8 rounded-full ${settings.accentColor === c ? 'ring-2 ring-offset-2 ring-[var(--text-primary)]' : ''}`} style={{ background: c }} />
          ))}
        </div>
        <div className="flex gap-2">
          <input value={customAccent} onChange={(e) => setCustomAccent(e.target.value)} placeholder="#007AFF" className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2 text-sm" />
          <Button variant="secondary" onClick={() => updateSettings({ accentColor: customAccent })}>Apply</Button>
        </div>
      </Card>

      <Card>
        <h3 className="mb-3 font-semibold">Preferences</h3>
        <label className="mb-3 block text-sm">Sleep goal (hours)
          <input type="number" min={4} max={12} value={settings.sleepGoalHours} onChange={(e) => updateSettings({ sleepGoalHours: Number(e.target.value) })} className="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3" />
        </label>
        <Toggle checked={settings.notificationsEnabled} onChange={(v) => (v ? requestNotifications() : updateSettings({ notificationsEnabled: false }))} label="Notifications" />
      </Card>

      <Card>
        <h3 className="mb-3 font-semibold">Data</h3>
        <div className="space-y-2">
          <Button variant="secondary" className="w-full" onClick={() => exportData(exportAppState())}>Export JSON</Button>
          <input ref={fileRef} type="file" accept=".json" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) handleImport(f) }} />
          <Button variant="secondary" className="w-full" onClick={() => fileRef.current?.click()}>Import JSON</Button>
          <Button variant="danger" className="w-full" onClick={() => setConfirmReset(true)}>Reset all data</Button>
        </div>
      </Card>

      <Modal open={confirmReset} onClose={() => setConfirmReset(false)} title="Reset all data?">
        <p className="mb-4 text-sm text-[var(--text-secondary)]">This will permanently delete all your Clarity data. This cannot be undone.</p>
        <div className="flex gap-2">
          <Button variant="secondary" className="flex-1" onClick={() => setConfirmReset(false)}>Cancel</Button>
          <Button variant="danger" className="flex-1" onClick={() => { resetAll(); setConfirmReset(false) }}>Reset</Button>
        </div>
      </Modal>
    </div>
  )
}
