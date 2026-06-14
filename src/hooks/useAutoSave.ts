import { useEffect, useRef } from 'react'

export function useAutoSave<T>(value: T, save: (v: T) => void, delay = 2000) {
  const isFirst = useRef(true)

  useEffect(() => {
    if (isFirst.current) {
      isFirst.current = false
      return
    }
    const t = setTimeout(() => save(value), delay)
    return () => clearTimeout(t)
  }, [value, save, delay])
}

export function useDebouncedEffect(effect: () => void, deps: unknown[], delay = 500) {
  useEffect(() => {
    const t = setTimeout(effect, delay)
    return () => clearTimeout(t)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)
}
