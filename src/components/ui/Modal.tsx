import { AnimatePresence, motion } from 'framer-motion'
import { springs } from '../../lib/springs'
import { X } from 'lucide-react'
import type { ReactNode } from 'react'

interface ModalProps {
  open: boolean
  onClose: () => void
  title?: string
  children: ReactNode
}

export function Modal({ open, onClose, title, children }: ModalProps) {
  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div
            initial={{ opacity: 0, backdropFilter: 'blur(0px)' }}
            animate={{ opacity: 1, backdropFilter: 'blur(20px)' }}
            exit={{ opacity: 0, backdropFilter: 'blur(0px)' }}
            transition={{ duration: 0.28 }}
            className="fixed inset-0 z-50 bg-black/20"
            onClick={onClose}
          />
          <motion.div
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={0.2}
            onDragEnd={(_, info) => {
              if (info.offset.y > 100 || info.velocity.y > 500) onClose()
            }}
            initial={{ opacity: 0, scale: 0.92 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={springs.smooth}
            className="glass fixed top-1/2 left-1/2 z-50 max-h-[85vh] w-[min(92vw,480px)] -translate-x-1/2 -translate-y-1/2 overflow-auto rounded-2xl p-5 shadow-[var(--shadow-xl)]"
          >
            <div className="mb-4 flex items-center justify-between">
              {title && <h2 className="text-lg font-semibold">{title}</h2>}
              <button type="button" onClick={onClose} className="ml-auto rounded-full p-2">
                <X size={18} />
              </button>
            </div>
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

interface SheetProps {
  open: boolean
  onClose: () => void
  children: ReactNode
}

export function BottomSheet({ open, onClose, children }: SheetProps) {
  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/30"
            onClick={onClose}
          />
          <motion.div
            drag="y"
            dragConstraints={{ top: 0 }}
            dragElastic={0.15}
            onDragEnd={(_, info) => {
              if (info.offset.y > 80 || info.velocity.y > 400) onClose()
            }}
            initial={{ y: '100%' }}
            animate={{ y: '40%' }}
            exit={{ y: '100%' }}
            transition={springs.gentle}
            className="glass safe-bottom fixed inset-x-0 bottom-0 z-50 max-h-[60vh] rounded-t-3xl p-5 shadow-[var(--shadow-xl)]"
          >
            <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-[var(--text-tertiary)]" />
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export function DetailSheet({ open, onClose, children }: SheetProps) {
  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="fixed inset-0 z-50 bg-black/30" onClick={onClose} />
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={springs.gentle}
            className="glass safe-bottom fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-auto rounded-t-3xl p-5 shadow-[var(--shadow-xl)] md:max-w-lg md:left-1/2 md:-translate-x-1/2"
          >
            <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-[var(--text-tertiary)]" />
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
