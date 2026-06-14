import { useEffect, useState } from 'react'
import { Skeleton } from '../../components/ui/Skeleton'
import { WeatherIcon } from './WeatherCard'
import { useGeolocation } from '../../hooks/useGeolocation'
import { fetchWeather, weatherLabel } from '../../lib/api/weather'

export function WeatherCard() {
  const { coords, error } = useGeolocation()
  const [weather, setWeather] = useState<{ temperature: number; weatherCode: number } | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!coords) return
    fetchWeather(coords.lat, coords.lon)
      .then(setWeather)
      .catch(() => setWeather(null))
      .finally(() => setLoading(false))
  }, [coords])

  if (loading) return <Skeleton className="h-20 w-full" />
  if (error || !weather) return <p className="text-sm text-[var(--text-secondary)]">Weather unavailable</p>

  return (
    <div className="flex items-center justify-between">
      <div>
        <p className="text-sm text-[var(--text-secondary)]">{weatherLabel(weather.weatherCode)}</p>
        <p className="text-3xl font-bold">{Math.round(weather.temperature)}°</p>
      </div>
      <WeatherIcon code={weather.weatherCode} />
    </div>
  )
}
