import { motion } from 'framer-motion'
import { Star } from 'lucide-react'
import { springs } from '../../lib/springs'

interface StarRatingProps {
  value: number
  onChange?: (v: number) => void
  max?: number
}

export function StarRating({ value, onChange, max = 5 }: StarRatingProps) {
  return (
    <div className="flex gap-1">
      {Array.from({ length: max }, (_, i) => i + 1).map((star, idx) => (
        <motion.button
          key={star}
          type="button"
          initial={{ scale: 0, rotate: -30 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ ...springs.bouncy, delay: idx * 0.03 }}
          whileTap={{ scale: 0.85 }}
          onClick={() => onChange?.(star)}
          className={onChange ? 'cursor-pointer' : 'cursor-default'}
        >
          <Star
            size={20}
            fill={star <= value ? 'var(--accent)' : 'transparent'}
            stroke={star <= value ? 'var(--accent)' : 'var(--text-tertiary)'}
          />
        </motion.button>
      ))}
    </div>
  )
}
