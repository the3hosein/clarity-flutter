import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Plus, Moon, CheckSquare, FileText, CalendarPlus, X } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { springs } from '../../lib/springs'
import { hapticMedium } from '../../lib/haptics'

const actions = [
  { icon: Moon, label: 'Sleep', path: '/daily/sleep', angle: -90 },
  { icon: CheckSquare, label: 'Habit', path: '/daily/habits', angle: -135 },
  { icon: FileText, label: 'Note', path: '/mind/journal', angle: -45 },
  { icon: CalendarPlus, label: 'Event', path: '/calendar', angle: 0 },
]

export function FloatingActionButton() {
  const [open, setOpen] = useState(false)
  const navigate = useNavigate()

  return (
    <div className="fixed right-5 bottom-20 z-50 md:bottom-8">
      <AnimatePresence>
        {open &&
          actions.map((action, i) => {
            const rad = (action.angle * Math.PI) / 180
            const x = Math.cos(rad) * 80
            const y = Math.sin(rad) * 80
            return (
              <motion.button
                key={action.label}
                type="button"
                initial={{ scale: 0, x: 0, y: 0, opacity: 0 }}
                animate={{ scale: 1, x, y, opacity: 1 }}
                exit={{ scale: 0, x: 0, y: 0, opacity: 0 }}
                transition={{ ...springs.bouncy, delay: i * 0.06 }}
                onClick={() => {
                  navigate(action.path)
                  setOpen(false)
                }}
                className="absolute flex h-12 w-12 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full bg-[var(--card)] shadow-[var(--shadow-md)]"
                style={{ right: 24, bottom: 24 }}
              >
                <action.icon size={20} className="text-[var(--accent)]" />
              </motion.button>
            )
          })}
      </AnimatePresence>

      <motion.button
        type="button"
        animate={{ scale: open ? 1 : [1, 1.04, 1] }}
        transition={open ? springs.bouncy : { repeat: Infinity, duration: 3, ease: 'easeInOut' }}
        whileTap={{ scale: 0.9 }}
        onClick={() => {
          hapticMedium()
          setOpen(!open)
        }}
        className="flex h-14 w-14 items-center justify-center rounded-full bg-[var(--accent)] text-white shadow-[var(--shadow-lg)]"
      >
        <motion.div animate={{ rotate: open ? 45 : 0 }} transition={springs.bouncy}>
          {open ? <X size={24} /> : <Plus size={24} />}
        </motion.div>
      </motion.button>
    </div>
  )
}
