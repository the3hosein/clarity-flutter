export interface WeatherData {
  temperature: number
  weatherCode: number
  windSpeed: number
}

export async function fetchWeather(lat: number, lon: number): Promise<WeatherData> {
  const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,wind_speed_10m`
  const res = await fetch(url)
  const data = await res.json()
  return {
    temperature: data.current.temperature_2m,
    weatherCode: data.current.weather_code,
    windSpeed: data.current.wind_speed_10m,
  }
}

export function weatherLabel(code: number) {
  if (code === 0) return 'Clear'
  if (code <= 3) return 'Cloudy'
  if (code <= 67) return 'Rain'
  if (code <= 77) return 'Snow'
  return 'Storm'
}
