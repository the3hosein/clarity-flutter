import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type {
  AppState,
  Book,
  CalendarEvent,
  Channel,
  Habit,
  JournalNote,
  LessonCheck,
  LessonSlot,
  Message,
  Movie,
  Playlist,
  SleepEntry,
  SocialPlatform,
  SubGoal,
  Track,
  YouTubeFolder,
  YouTubeVideo,
  UserSettings,
  MainTarget,
} from '../types'
import { MOTIVATIONAL_QUOTES, todayKey } from '../lib/constants'
import { uid } from '../lib/storage'

const defaultSettings: UserSettings = {
  name: 'Hossein',
  avatar: '🎓',
  accentColor: '#007AFF',
  theme: 'system',
  sleepGoalHours: 8,
  notificationsEnabled: false,
}

const defaultTarget: MainTarget = {
  title: 'Graduate with excellence and build meaningful skills',
  subGoals: [
    { id: uid(), title: 'Maintain 85%+ average', progress: 72 },
    { id: uid(), title: 'Complete portfolio project', progress: 45 },
    { id: uid(), title: 'Read 12 books this year', progress: 33 },
  ],
  quoteIndex: 0,
  quoteDate: todayKey(),
}

const defaultSlots: LessonSlot[] = [
  { id: uid(), day: 1, startTime: '09:00', endTime: '10:30', subject: 'Mathematics', color: '#007AFF' },
  { id: uid(), day: 1, startTime: '11:00', endTime: '12:30', subject: 'Physics', color: '#5856D6' },
  { id: uid(), day: 2, startTime: '09:00', endTime: '10:30', subject: 'Computer Science', color: '#34C759' },
  { id: uid(), day: 3, startTime: '14:00', endTime: '15:30', subject: 'Literature', color: '#FF9500' },
  { id: uid(), day: 4, startTime: '10:00', endTime: '11:30', subject: 'History', color: '#AF52DE' },
  { id: uid(), day: 5, startTime: '09:00', endTime: '10:30', subject: 'Chemistry', color: '#FF2D55' },
]

const defaultHabits: Habit[] = [
  { id: uid(), name: 'Morning review', color: '#007AFF', completions: {} },
  { id: uid(), name: 'Exercise 30min', color: '#34C759', completions: {} },
  { id: uid(), name: 'Read 20 pages', color: '#FF9500', completions: {} },
]

const defaultSocial: SocialPlatform[] = [
  { id: uid(), name: 'Instagram', icon: 'instagram', dailyLimitMinutes: 30, logs: {} },
  { id: uid(), name: 'X', icon: 'twitter', dailyLimitMinutes: 20, logs: {} },
  { id: uid(), name: 'TikTok', icon: 'music', dailyLimitMinutes: 15, logs: {} },
]

const defaultChannels: Channel[] = [
  { id: uid(), name: 'Ideas', createdAt: new Date().toISOString() },
  { id: uid(), name: 'Study Notes', createdAt: new Date().toISOString() },
]

const defaultPlaylists: Playlist[] = [
  { id: uid(), name: 'Focus Flow', mood: 'Focus' },
  { id: uid(), name: 'Chill Evenings', mood: 'Chill' },
]

const defaultFolders: YouTubeFolder[] = [{ id: uid(), name: 'Watch Later' }]

interface AppActions {
  logActivity: (action: string, section: string) => void
  updateSettings: (patch: Partial<UserSettings>) => void
  setSidebarCollapsed: (v: boolean) => void
  setGreetingAnimated: (v: boolean) => void
  importState: (data: Partial<AppState>) => void
  resetAll: () => void
  updateTarget: (title: string, subGoals: SubGoal[]) => void
  rotateQuote: () => string
  addChannel: (name: string) => void
  deleteChannel: (id: string) => void
  addMessage: (msg: Omit<Message, 'id' | 'createdAt' | 'updatedAt'>) => void
  updateMessage: (id: string, content: string) => void
  deleteMessage: (id: string) => void
  addNote: (note?: Partial<JournalNote>) => string
  updateNote: (id: string, patch: Partial<JournalNote>) => void
  deleteNote: (id: string) => void
  toggleNotePin: (id: string) => void
  setLessonCheck: (slotId: string, date: string, status: LessonCheck['status']) => void
  addSleepEntry: (entry: Omit<SleepEntry, 'id'>) => void
  updateSleepEntry: (id: string, patch: Partial<SleepEntry>) => void
  deleteSleepEntry: (id: string) => void
  logSocialMinutes: (id: string, minutes: number, date?: string) => void
  addSocialPlatform: (platform: Omit<SocialPlatform, 'id' | 'logs'>) => void
  toggleHabit: (id: string, date?: string) => void
  addHabit: (name: string, color: string) => void
  addMovie: (movie: Omit<Movie, 'id' | 'userRating'>) => void
  updateMovie: (id: string, patch: Partial<Movie>) => void
  deleteMovie: (id: string) => void
  addPlaylist: (name: string, mood: string) => string
  addTrack: (track: Omit<Track, 'id'>) => void
  deleteTrack: (id: string) => void
  addBook: (book: Omit<Book, 'id'>) => void
  updateBook: (id: string, patch: Partial<Book>) => void
  deleteBook: (id: string) => void
  addYouTubeFolder: (name: string) => string
  addYouTubeVideo: (video: Omit<YouTubeVideo, 'id' | 'addedAt'>) => void
  updateYouTubeVideo: (id: string, patch: Partial<YouTubeVideo>) => void
  deleteYouTubeVideo: (id: string) => void
  addEvent: (event: Omit<CalendarEvent, 'id'>) => void
  updateEvent: (id: string, patch: Partial<CalendarEvent>) => void
  deleteEvent: (id: string) => void
}

type Store = AppState & AppActions

const initialState: AppState = {
  settings: defaultSettings,
  target: defaultTarget,
  channels: defaultChannels,
  messages: [],
  journalNotes: [],
  lessonSlots: defaultSlots,
  lessonChecks: [],
  sleepEntries: [],
  socialPlatforms: defaultSocial,
  habits: defaultHabits,
  movies: [],
  playlists: defaultPlaylists,
  tracks: [],
  books: [],
  youtubeFolders: defaultFolders,
  youtubeVideos: [],
  calendarEvents: [],
  activityLog: [],
  sidebarCollapsed: false,
  greetingAnimated: false,
}

export const useAppStore = create<Store>()(
  persist(
    (set, get) => ({
      ...initialState,

      logActivity: (action, section) =>
        set((s) => ({
          activityLog: [
            { id: uid(), action, section, timestamp: new Date().toISOString() },
            ...s.activityLog,
          ].slice(0, 50),
        })),

      updateSettings: (patch) => set((s) => ({ settings: { ...s.settings, ...patch } })),

      setSidebarCollapsed: (v) => set({ sidebarCollapsed: v }),
      setGreetingAnimated: (v) => set({ greetingAnimated: v }),

      importState: (data) => set((s) => ({ ...s, ...data })),

      resetAll: () => set({ ...initialState, settings: get().settings }),

      updateTarget: (title, subGoals) => {
        set((s) => ({ target: { ...s.target, title, subGoals } }))
        get().logActivity('Updated main target', 'Mind')
      },

      rotateQuote: () => {
        const today = todayKey()
        const { target } = get()
        if (target.quoteDate === today) {
          return MOTIVATIONAL_QUOTES[target.quoteIndex % MOTIVATIONAL_QUOTES.length]
        }
        const nextIndex = (target.quoteIndex + 1) % MOTIVATIONAL_QUOTES.length
        set({ target: { ...target, quoteIndex: nextIndex, quoteDate: today } })
        return MOTIVATIONAL_QUOTES[nextIndex]
      },

      addChannel: (name) => {
        const ch: Channel = { id: uid(), name, createdAt: new Date().toISOString() }
        set((s) => ({ channels: [...s.channels, ch] }))
        get().logActivity(`Created channel "${name}"`, 'Mind')
      },

      deleteChannel: (id) =>
        set((s) => ({
          channels: s.channels.filter((c) => c.id !== id),
          messages: s.messages.filter((m) => m.channelId !== id),
        })),

      addMessage: (msg) => {
        const now = new Date().toISOString()
        const message: Message = { ...msg, id: uid(), createdAt: now, updatedAt: now }
        set((s) => ({ messages: [...s.messages, message] }))
        get().logActivity('Added channel message', 'Mind')
      },

      updateMessage: (id, content) =>
        set((s) => ({
          messages: s.messages.map((m) =>
            m.id === id ? { ...m, content, updatedAt: new Date().toISOString() } : m,
          ),
        })),

      deleteMessage: (id) => set((s) => ({ messages: s.messages.filter((m) => m.id !== id) })),

      addNote: (note) => {
        const id = uid()
        const now = new Date().toISOString()
        const newNote: JournalNote = {
          id,
          title: note?.title ?? '',
          body: note?.body ?? '',
          mood: note?.mood ?? null,
          pinned: note?.pinned ?? false,
          tags: note?.tags ?? [],
          createdAt: now,
          updatedAt: now,
        }
        set((s) => ({ journalNotes: [newNote, ...s.journalNotes] }))
        get().logActivity('Created journal note', 'Mind')
        return id
      },

      updateNote: (id, patch) =>
        set((s) => ({
          journalNotes: s.journalNotes.map((n) =>
            n.id === id ? { ...n, ...patch, updatedAt: new Date().toISOString() } : n,
          ),
        })),

      deleteNote: (id) => set((s) => ({ journalNotes: s.journalNotes.filter((n) => n.id !== id) })),

      toggleNotePin: (id) =>
        set((s) => ({
          journalNotes: s.journalNotes.map((n) => (n.id === id ? { ...n, pinned: !n.pinned } : n)),
        })),

      setLessonCheck: (slotId, date, status) =>
        set((s) => {
          const existing = s.lessonChecks.find((c) => c.slotId === slotId && c.date === date)
          const checks = existing
            ? s.lessonChecks.map((c) => (c.slotId === slotId && c.date === date ? { ...c, status } : c))
            : [...s.lessonChecks, { slotId, date, status }]
          get().logActivity(`Marked lesson ${status}`, 'Daily')
          return { lessonChecks: checks }
        }),

      addSleepEntry: (entry) => {
        set((s) => ({ sleepEntries: [{ ...entry, id: uid() }, ...s.sleepEntries] }))
        get().logActivity('Logged sleep', 'Daily')
      },

      updateSleepEntry: (id, patch) =>
        set((s) => ({
          sleepEntries: s.sleepEntries.map((e) => (e.id === id ? { ...e, ...patch } : e)),
        })),

      deleteSleepEntry: (id) => set((s) => ({ sleepEntries: s.sleepEntries.filter((e) => e.id !== id) })),

      logSocialMinutes: (id, minutes, date = todayKey()) =>
        set((s) => ({
          socialPlatforms: s.socialPlatforms.map((p) =>
            p.id === id ? { ...p, logs: { ...p.logs, [date]: minutes } } : p,
          ),
        })),

      addSocialPlatform: (platform) =>
        set((s) => ({
          socialPlatforms: [...s.socialPlatforms, { ...platform, id: uid(), logs: {} }],
        })),

      toggleHabit: (id, date = todayKey()) =>
        set((s) => ({
          habits: s.habits.map((h) => {
            if (h.id !== id) return h
            const done = !h.completions[date]
            get().logActivity(done ? 'Completed habit' : 'Unchecked habit', 'Daily')
            return { ...h, completions: { ...h.completions, [date]: done } }
          }),
        })),

      addHabit: (name, color) =>
        set((s) => ({ habits: [...s.habits, { id: uid(), name, color, completions: {} }] })),

      addMovie: (movie) => {
        set((s) => ({ movies: [{ ...movie, id: uid(), userRating: 0 }, ...s.movies] }))
        get().logActivity(`Added movie "${movie.title}"`, 'World')
      },

      updateMovie: (id, patch) =>
        set((s) => ({ movies: s.movies.map((m) => (m.id === id ? { ...m, ...patch } : m)) })),

      deleteMovie: (id) => set((s) => ({ movies: s.movies.filter((m) => m.id !== id) })),

      addPlaylist: (name, mood) => {
        const id = uid()
        set((s) => ({ playlists: [...s.playlists, { id, name, mood }] }))
        return id
      },

      addTrack: (track) => {
        set((s) => ({ tracks: [...s.tracks, { ...track, id: uid() }] }))
        get().logActivity(`Added track "${track.trackName}"`, 'World')
      },

      deleteTrack: (id) => set((s) => ({ tracks: s.tracks.filter((t) => t.id !== id) })),

      addBook: (book) => {
        set((s) => ({ books: [{ ...book, id: uid() }, ...s.books] }))
        get().logActivity(`Added book "${book.title}"`, 'World')
      },

      updateBook: (id, patch) =>
        set((s) => ({ books: s.books.map((b) => (b.id === id ? { ...b, ...patch } : b)) })),

      deleteBook: (id) => set((s) => ({ books: s.books.filter((b) => b.id !== id) })),

      addYouTubeFolder: (name) => {
        const id = uid()
        set((s) => ({ youtubeFolders: [...s.youtubeFolders, { id, name }] }))
        return id
      },

      addYouTubeVideo: (video) => {
        set((s) => ({
          youtubeVideos: [{ ...video, id: uid(), addedAt: new Date().toISOString() }, ...s.youtubeVideos],
        }))
        get().logActivity(`Saved video "${video.title}"`, 'World')
      },

      updateYouTubeVideo: (id, patch) =>
        set((s) => ({
          youtubeVideos: s.youtubeVideos.map((v) => (v.id === id ? { ...v, ...patch } : v)),
        })),

      deleteYouTubeVideo: (id) =>
        set((s) => ({ youtubeVideos: s.youtubeVideos.filter((v) => v.id !== id) })),

      addEvent: (event) => {
        set((s) => ({ calendarEvents: [...s.calendarEvents, { ...event, id: uid() }] }))
        get().logActivity(`Created event "${event.title}"`, 'Calendar')
      },

      updateEvent: (id, patch) =>
        set((s) => ({
          calendarEvents: s.calendarEvents.map((e) => (e.id === id ? { ...e, ...patch } : e)),
        })),

      deleteEvent: (id) => set((s) => ({ calendarEvents: s.calendarEvents.filter((e) => e.id !== id) })),
    }),
    { name: 'clarity-v1' },
  ),
)

export function exportAppState(): AppState {
  const {
    settings, target, channels, messages, journalNotes, lessonSlots, lessonChecks,
    sleepEntries, socialPlatforms, habits, movies, playlists, tracks, books,
    youtubeFolders, youtubeVideos, calendarEvents, activityLog, sidebarCollapsed, greetingAnimated,
  } = useAppStore.getState()
  return {
    settings, target, channels, messages, journalNotes, lessonSlots, lessonChecks,
    sleepEntries, socialPlatforms, habits, movies, playlists, tracks, books,
    youtubeFolders, youtubeVideos, calendarEvents, activityLog, sidebarCollapsed, greetingAnimated,
  }
}
