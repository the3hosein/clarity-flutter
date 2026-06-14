import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { Pencil } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Modal } from '../../components/ui/Modal'
import { ProgressBar } from '../../components/ui/AnimatedTabBar'
import { useAppStore } from '../../stores/useAppStore'
import { springs } from '../../lib/springs'
import { MOTIVATIONAL_QUOTES } from '../../lib/constants'
import type { SubGoal } from '../../types'
import { uid } from '../../lib/storage'

export function TargetPage() {
  const target = useAppStore((s) => s.target)
  const updateTarget = useAppStore((s) => s.updateTarget)
  const rotateQuote = useAppStore((s) => s.rotateQuote)
  const [editOpen, setEditOpen] = useState(false)
  const [title, setTitle] = useState(target.title)
  const [subGoals, setSubGoals] = useState<SubGoal[]>(target.subGoals)

  useEffect(() => {
    rotateQuote()
  }, [rotateQuote])

  const quote = MOTIVATIONAL_QUOTES[target.quoteIndex % MOTIVATIONAL_QUOTES.length]

  const save = () => {
    updateTarget(title, subGoals)
    setEditOpen(false)
  }

  return (
    <div className="space-y-6">
      <Card className="relative overflow-hidden">
        <Button variant="ghost" className="absolute top-3 right-3 !min-h-0 !p-2" onClick={() => { setTitle(target.title); setSubGoals(target.subGoals); setEditOpen(true) }}>
          <Pencil size={18} />
        </Button>
        <p className="mb-2 text-sm font-medium text-[var(--accent)]">My Main Target</p>
        <h2 className="mb-6 text-[var(--font-xl)] font-bold leading-tight">{target.title}</h2>
        <div className="space-y-4">
          {target.subGoals.map((sg, i) => (
            <div key={sg.id}>
              <div className="mb-1 flex justify-between text-sm">
                <span>{sg.title}</span>
                <span className="text-[var(--text-secondary)]">{sg.progress}%</span>
              </div>
              <ProgressBar value={sg.progress} delay={i * 0.04} />
            </div>
          ))}
        </div>
      </Card>

      <motion.blockquote
        key={quote}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
        className="rounded-2xl border border-[var(--border)] bg-[var(--card)] p-5 text-center italic text-[var(--text-secondary)]"
      >
        "{quote}"
      </motion.blockquote>

      <Modal open={editOpen} onClose={() => setEditOpen(false)} title="Edit Target">
        <div className="space-y-4">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3"
            placeholder="Main life goal"
          />
          {subGoals.map((sg, i) => (
            <div key={sg.id} className="flex gap-2">
              <input
                value={sg.title}
                onChange={(e) => setSubGoals(subGoals.map((s, j) => (j === i ? { ...s, title: e.target.value } : s)))}
                className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2 text-sm"
              />
              <input
                type="number"
                min={0}
                max={100}
                value={sg.progress}
                onChange={(e) => setSubGoals(subGoals.map((s, j) => (j === i ? { ...s, progress: Number(e.target.value) } : s)))}
                className="w-16 rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2 text-sm"
              />
            </div>
          ))}
          <Button variant="secondary" onClick={() => setSubGoals([...subGoals, { id: uid(), title: 'New sub-goal', progress: 0 }])}>
            Add sub-goal
          </Button>
          <Button onClick={save} className="w-full">Save</Button>
        </div>
      </Modal>
    </div>
  )
}
