export type ThemeMode = 'light' | 'dark' | 'system'
export type LessonStatus = 'pending' | 'done' | 'skipped' | 'partial'
export type MovieStatus = 'want' | 'watching' | 'watched'
export type BookStatus = 'want' | 'reading' | 'finished'
export type YouTubeStatus = 'to-watch' | 'watching' | 'done'
export type EventCategory = 'study' | 'personal' | 'health' | 'social' | 'other'
export type RepeatRule = 'none' | 'daily' | 'weekly' | 'monthly'
export type MessageType = 'text' | 'photo' | 'voice'
export type Mood = '😊' | '😐' | '😔' | '😤' | '🤩' | null

export interface SubGoal {
  id: string
  title: string
  progress: number
}

export interface MainTarget {
  title: string
  subGoals: SubGoal[]
  quoteIndex: number
  quoteDate: string
}

export interface Channel {
  id: string
  name: string
  createdAt: string
}

export interface Message {
  id: string
  channelId: string
  type: MessageType
  content: string
  createdAt: string
  updatedAt: string
}

export interface JournalNote {
  id: string
  title: string
  body: string
  mood: Mood
  pinned: boolean
  tags: string[]
  createdAt: string
  updatedAt: string
}

export interface LessonSlot {
  id: string
  day: number
  startTime: string
  endTime: string
  subject: string
  color: string
}

export interface LessonCheck {
  slotId: string
  date: string
  status: LessonStatus
}

export interface SleepEntry {
  id: string
  date: string
  bedtime: string
  wakeTime: string
  quality: number
  note: string
}

export interface SocialPlatform {
  id: string
  name: string
  icon: string
  dailyLimitMinutes: number
  logs: Record<string, number>
}

export interface Habit {
  id: string
  name: string
  color: string
  completions: Record<string, boolean>
}

export interface Movie {
  id: string
  imdbId?: string
  title: string
  year: string
  genre: string
  poster: string
  plot: string
  director: string
  cast: string[]
  runtime: string
  rated: string
  awards: string
  imdbRating: string
  status: MovieStatus
  userRating: number
}

export interface Track {
  id: string
  trackName: string
  artist: string
  album: string
  artwork: string
  previewUrl: string
  duration: string
  playlistId: string
}

export interface Playlist {
  id: string
  name: string
  mood: string
}

export interface Book {
  id: string
  title: string
  authors: string[]
  publisher: string
  publishedDate: string
  pageCount: number
  currentPage: number
  description: string
  categories: string[]
  averageRating: number
  isbn: string
  cover: string
  status: BookStatus
  notes: string
}

export interface YouTubeFolder {
  id: string
  name: string
}

export interface YouTubeVideo {
  id: string
  url: string
  title: string
  channel: string
  thumbnail: string
  folderId: string
  status: YouTubeStatus
  addedAt: string
}

export interface CalendarEvent {
  id: string
  title: string
  start: string
  end: string
  category: EventCategory
  notes: string
  repeat: RepeatRule
  reminder: boolean
}

export interface ActivityLogEntry {
  id: string
  action: string
  section: string
  timestamp: string
}

export interface UserSettings {
  name: string
  avatar: string
  accentColor: string
  theme: ThemeMode
  sleepGoalHours: number
  notificationsEnabled: boolean
}

export interface AppState {
  settings: UserSettings
  target: MainTarget
  channels: Channel[]
  messages: Message[]
  journalNotes: JournalNote[]
  lessonSlots: LessonSlot[]
  lessonChecks: LessonCheck[]
  sleepEntries: SleepEntry[]
  socialPlatforms: SocialPlatform[]
  habits: Habit[]
  movies: Movie[]
  playlists: Playlist[]
  tracks: Track[]
  books: Book[]
  youtubeFolders: YouTubeFolder[]
  youtubeVideos: YouTubeVideo[]
  calendarEvents: CalendarEvent[]
  activityLog: ActivityLogEntry[]
  sidebarCollapsed: boolean
  greetingAnimated: boolean
}
