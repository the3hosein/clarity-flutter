import { useEffect } from 'react'
import { useAppStore } from '../stores/useAppStore'

export function useThemeEffect() {
  const theme = useAppStore((s) => s.settings.theme)
  const accent = useAppStore((s) => s.settings.accentColor)

  useEffect(() => {
    document.documentElement.style.setProperty('--accent', accent)
    document.documentElement.style.setProperty('--accent-soft', `${accent}1f`)

    const apply = (mode: 'light' | 'dark') => {
      document.documentElement.setAttribute('data-theme', mode)
      document.querySelector('meta[name="theme-color"]')?.setAttribute('content', mode === 'dark' ? '#000000' : '#F2F2F7')
    }

    if (theme === 'system') {
      const mq = window.matchMedia('(prefers-color-scheme: dark)')
      apply(mq.matches ? 'dark' : 'light')
      const handler = (e: MediaQueryListEvent) => apply(e.matches ? 'dark' : 'light')
      mq.addEventListener('change', handler)
      return () => mq.removeEventListener('change', handler)
    }
    apply(theme)
  }, [theme, accent])
}
