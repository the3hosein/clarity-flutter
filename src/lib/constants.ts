export const MOTIVATIONAL_QUOTES = [
  'Small steps every day lead to big changes.',
  'Focus on progress, not perfection.',
  'Your future self will thank you for today.',
  'Discipline is choosing what you want most over what you want now.',
  'One lesson at a time, one habit at a time.',
  'Clarity comes from action, not thought alone.',
  'Rest is part of the work.',
  'You are building something meaningful.',
]

export const CATEGORY_COLORS: Record<string, string> = {
  study: '#007AFF',
  personal: '#AF52DE',
  health: '#34C759',
  social: '#FF9500',
  other: '#8E8E93',
}

export const ACCENT_PRESETS = ['#007AFF', '#5856D6', '#AF52DE', '#FF2D55', '#FF9500', '#34C759']

export function getGreeting(name: string) {
  const hour = new Date().getHours()
  if (hour < 12) return `Good morning, ${name}`
  if (hour < 17) return `Good afternoon, ${name}`
  return `Good evening, ${name}`
}

export function moonPhase(date: Date) {
  const lp = 2551443
  const newMoon = new Date('2000-01-06').getTime()
  const phase = (((date.getTime() - newMoon) / 1000) % lp) / lp
  if (phase < 0.125) return '🌑'
  if (phase < 0.25) return '🌒'
  if (phase < 0.375) return '🌓'
  if (phase < 0.5) return '🌔'
  if (phase < 0.625) return '🌕'
  if (phase < 0.75) return '🌖'
  if (phase < 0.875) return '🌗'
  return '🌘'
}

export function sleepDuration(bedtime: string, wakeTime: string) {
  const [bh, bm] = bedtime.split(':').map(Number)
  const [wh, wm] = wakeTime.split(':').map(Number)
  let mins = (wh * 60 + wm) - (bh * 60 + bm)
  if (mins <= 0) mins += 24 * 60
  return { hours: Math.floor(mins / 60), minutes: mins % 60, totalMinutes: mins }
}

export function autoTags(text: string) {
  const words = text.toLowerCase().match(/\b[a-z]{4,}\b/g) ?? []
  const freq = new Map<string, number>()
  words.forEach((w) => freq.set(w, (freq.get(w) ?? 0) + 1))
  return [...freq.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([w]) => w)
}

export function todayKey() {
  return new Date().toISOString().slice(0, 10)
}
