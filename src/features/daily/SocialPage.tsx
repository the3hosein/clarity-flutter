import { motion } from 'framer-motion'
import { Camera, Music2, Share2 } from 'lucide-react'
import { format, subDays } from 'date-fns'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { AnimatedBarChart } from '../../components/charts/SleepChart'
import { useAppStore } from '../../stores/useAppStore'
import { todayKey } from '../../lib/constants'
import { springs } from '../../lib/springs'

const ICONS: Record<string, typeof Camera> = { instagram: Camera, twitter: Share2, music: Music2, youtube: Music2 }

export function SocialPage() {
  const platforms = useAppStore((s) => s.socialPlatforms)
  const logSocialMinutes = useAppStore((s) => s.logSocialMinutes)
  const addSocialPlatform = useAppStore((s) => s.addSocialPlatform)
  const today = todayKey()

  const totalToday = platforms.reduce((sum, p) => sum + (p.logs[today] ?? 0), 0)
  const totalLimit = platforms.reduce((sum, p) => sum + p.dailyLimitMinutes, 0)

  const weekData = Array.from({ length: 7 }, (_, i) => {
    const d = format(subDays(new Date(), 6 - i), 'yyyy-MM-dd')
    const total = platforms.reduce((sum, p) => sum + (p.logs[d] ?? 0), 0)
    return { label: format(subDays(new Date(), 6 - i), 'EEE'), value: Math.min(100, (total / Math.max(totalLimit, 1)) * 100), color: total > totalLimit ? '#FF3B30' : 'var(--accent)' }
  })

  return (
    <div className="space-y-6">
      <Card>
        <p className="text-sm text-[var(--text-secondary)]">Today's screen time</p>
        <p className="text-3xl font-bold">{totalToday}m <span className="text-base font-normal text-[var(--text-secondary)]">/ {totalLimit}m limit</span></p>
      </Card>

      <Card>
        <h4 className="mb-3 text-sm font-medium">Weekly usage</h4>
        <AnimatedBarChart data={weekData} />
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        {platforms.map((p) => {
          const used = p.logs[today] ?? 0
          const over = used > p.dailyLimitMinutes
          const Icon = ICONS[p.icon] ?? Music2
          return (
            <Card key={p.id}>
              <div className="mb-3 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Icon size={20} className="text-[var(--accent)]" />
                  <span className="font-medium">{p.name}</span>
                </div>
                {over && (
                  <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} transition={springs.bouncy} className="rounded-full bg-red-500/10 px-2 py-0.5 text-xs text-[var(--danger)]">
                    Over limit
                  </motion.span>
                )}
              </div>
              <p className="mb-2 text-sm text-[var(--text-secondary)]">{used} / {p.dailyLimitMinutes} min</p>
              <div className="flex gap-2">
                {[15, 30, 45, 60].map((m) => (
                  <Button key={m} variant="secondary" className="!min-h-8 flex-1 !px-1 text-xs" onClick={() => logSocialMinutes(p.id, m)}>
                    {m}m
                  </Button>
                ))}
              </div>
            </Card>
          )
        })}
      </div>

      <Button variant="secondary" onClick={() => addSocialPlatform({ name: 'YouTube', icon: 'youtube', dailyLimitMinutes: 30 })}>
        Add platform
      </Button>
    </div>
  )
}
