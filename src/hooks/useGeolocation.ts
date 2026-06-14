import { useEffect, useState } from 'react'
import { Geolocation } from '@capacitor/geolocation'

export function useGeolocation() {
  const [coords, setCoords] = useState<{ lat: number; lon: number } | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const pos = await Geolocation.getCurrentPosition({ enableHighAccuracy: false })
        if (!cancelled) {
          setCoords({ lat: pos.coords.latitude, lon: pos.coords.longitude })
        }
      } catch {
        if ('geolocation' in navigator) {
          navigator.geolocation.getCurrentPosition(
            (p) => !cancelled && setCoords({ lat: p.coords.latitude, lon: p.coords.longitude }),
            () => !cancelled && setError('Location unavailable'),
          )
        } else if (!cancelled) {
          setError('Location unavailable')
        }
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  return { coords, error }
}
