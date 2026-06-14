import { motion } from 'framer-motion'
import { springs } from '../../lib/springs'

interface ToggleProps {
  checked: boolean
  onChange: (v: boolean) => void
  label?: string
}

export function Toggle({ checked, onChange, label }: ToggleProps) {
  return (
    <label className="flex cursor-pointer items-center gap-3">
      {label && <span className="text-sm">{label}</span>}
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        onClick={() => onChange(!checked)}
        className={`relative h-8 w-[52px] rounded-full transition-colors duration-150 ${checked ? 'bg-[var(--accent)]' : 'bg-[var(--text-tertiary)]'}`}
      >
        <motion.span
          layout
          transition={springs.snappy}
          className="absolute top-1 left-1 h-6 w-6 rounded-full bg-white shadow"
          animate={{ x: checked ? 20 : 0 }}
        />
      </button>
    </label>
  )
}

interface CheckboxProps {
  checked: boolean
  onChange: (v: boolean) => void
  label?: string
}

export function Checkbox({ checked, onChange, label }: CheckboxProps) {
  return (
    <label className="flex cursor-pointer items-center gap-3">
      <motion.button
        type="button"
        whileTap={{ scale: 0.9 }}
        transition={springs.bouncy}
        onClick={() => onChange(!checked)}
        className={`flex h-6 w-6 items-center justify-center rounded-md border-2 ${checked ? 'border-[var(--accent)] bg-[var(--accent)]' : 'border-[var(--text-tertiary)]'}`}
      >
        {checked && (
          <motion.svg
            initial={{ pathLength: 0, scale: 0.5 }}
            animate={{ pathLength: 1, scale: 1 }}
            transition={springs.bouncy}
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="white"
            strokeWidth="3"
          >
            <motion.path d="M5 13l4 4L19 7" />
          </motion.svg>
        )}
      </motion.button>
      {label && <span className="text-sm">{label}</span>}
    </label>
  )
}
