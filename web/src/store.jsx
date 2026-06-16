import { createContext, useContext, useReducer, useEffect, useCallback } from 'react'

const STORAGE_KEY = 'clarity-data'

const initialState = {
  theme: 'system',
  accentColor: '#007AFF',
  userName: 'Hossein',
  avatarEmoji: '🧑‍💻',
  sleepGoal: 8,
  lessons: [],
  sleepLogs: [],
  habits: [],
  socialPlatforms: [],
  targets: { title: '', subGoals: [] },
  channels: [],
  journalEntries: [],
  currentMood: 3,
  movies: [],
  musicPlaylists: [],
  books: [],
  youtubeFolders: [],
  calendarEvents: [],
  activityFeed: [],
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return { ...initialState, ...JSON.parse(raw) }
  } catch {}
  return { ...initialState }
}

function reducer(state, action) {
  const addActivity = (text, emoji = '📌') => ({
    ...state,
    activityFeed: [{ id: Date.now(), text, emoji, time: new Date().toISOString() }, ...state.activityFeed].slice(0, 50),
  })

  switch (action.type) {
    case 'SET_THEME':
      return { ...state, theme: action.payload }

    case 'SET_ACCENT':
      return { ...state, accentColor: action.payload }

    case 'SET_USER_NAME':
      return { ...state, userName: action.payload }

    case 'SET_AVATAR':
      return { ...state, avatarEmoji: action.payload }

    case 'SET_SLEEP_GOAL':
      return { ...state, sleepGoal: action.payload }

    case 'SET_CURRENT_MOOD':
      return { ...state, currentMood: action.payload }

    case 'SET_TARGET':
      return { ...state, targets: action.payload }

    case 'ADD_SUB_GOAL': {
      const sg = [...state.targets.subGoals, { id: Date.now(), text: action.payload, progress: 0 }]
      return { ...addActivity(`Added sub-goal: ${action.payload}`, '🎯'), targets: { ...state.targets, subGoals: sg } }
    }

    case 'UPDATE_SUB_GOAL': {
      const sg = state.targets.subGoals.map(g => g.id === action.payload.id ? { ...g, ...action.payload.data } : g)
      return { ...state, targets: { ...state.targets, subGoals: sg } }
    }

    case 'DELETE_SUB_GOAL':
      return { ...state, targets: { ...state.targets, subGoals: state.targets.subGoals.filter(g => g.id !== action.payload) } }

    case 'ADD_CHANNEL':
      return { ...addActivity(`Created channel: ${action.payload.name}`, '💭'), channels: [...state.channels, { id: Date.now(), messages: [], ...action.payload }] }

    case 'SEND_MESSAGE': {
      const ch = state.channels.map(c => c.id === action.payload.channelId
        ? { ...c, messages: [...c.messages, { id: Date.now(), text: action.payload.text, timestamp: new Date().toISOString(), type: 'text' }] }
        : c)
      return { ...state, channels: ch }
    }

    case 'DELETE_MESSAGE': {
      const ch = state.channels.map(c => c.id === action.payload.channelId
        ? { ...c, messages: c.messages.filter(m => m.id !== action.payload.messageId) }
        : c)
      return { ...state, channels: ch }
    }

    case 'ADD_JOURNAL':
      return { ...addActivity(`Wrote journal entry: ${action.payload.title || 'Untitled'}`, '📝'), journalEntries: [{ id: Date.now(), pinned: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString(), ...action.payload }, ...state.journalEntries] }

    case 'UPDATE_JOURNAL':
      return { ...state, journalEntries: state.journalEntries.map(e => e.id === action.payload.id ? { ...e, ...action.payload.data, updatedAt: new Date().toISOString() } : e) }

    case 'DELETE_JOURNAL':
      return { ...state, journalEntries: state.journalEntries.filter(e => e.id !== action.payload) }

    case 'PIN_JOURNAL':
      return { ...state, journalEntries: state.journalEntries.map(e => e.id === action.payload ? { ...e, pinned: !e.pinned } : e) }

    case 'ADD_LESSON':
      return { ...addActivity(`Added lesson: ${action.payload.title}`, '📚'), lessons: [...state.lessons, { id: Date.now(), completed: false, skipped: false, ...action.payload }] }

    case 'TOGGLE_LESSON': {
      const ls = state.lessons.map(l => l.id === action.payload ? { ...l, completed: !l.completed, skipped: false } : l)
      return { ...state, lessons: ls }
    }

    case 'SKIP_LESSON': {
      const ls = state.lessons.map(l => l.id === action.payload ? { ...l, skipped: !l.skipped, completed: false } : l)
      return { ...state, lessons: ls }
    }

    case 'DELETE_LESSON':
      return { ...state, lessons: state.lessons.filter(l => l.id !== action.payload) }

    case 'ADD_SLEEP':
      return { ...addActivity(`Logged sleep: ${action.payload.duration}`, '🌙'), sleepLogs: [{ id: Date.now(), ...action.payload }, ...state.sleepLogs] }

    case 'UPDATE_SLEEP':
      return { ...state, sleepLogs: state.sleepLogs.map(s => s.id === action.payload.id ? { ...s, ...action.payload.data } : s) }

    case 'DELETE_SLEEP':
      return { ...state, sleepLogs: state.sleepLogs.filter(s => s.id !== action.payload) }

    case 'ADD_HABIT':
      return { ...addActivity(`New habit: ${action.payload.name}`, '✅'), habits: [...state.habits, { id: Date.now(), days: {}, ...action.payload }] }

    case 'TOGGLE_HABIT_DAY': {
      const h = state.habits.map(hab => hab.id === action.payload.habitId
        ? { ...hab, days: { ...hab.days, [action.payload.date]: !hab.days[action.payload.date] } }
        : hab)
      return { ...state, habits: h }
    }

    case 'DELETE_HABIT':
      return { ...state, habits: state.habits.filter(h => h.id !== action.payload) }

    case 'ADD_PLATFORM':
      return { ...addActivity(`Added social: ${action.payload.name}`, '📱'), socialPlatforms: [...state.socialPlatforms, { id: Date.now(), ...action.payload }] }

    case 'UPDATE_PLATFORM_TIME':
      return { ...state, socialPlatforms: state.socialPlatforms.map(p => p.id === action.payload.id ? { ...p, minutesToday: action.payload.minutes } : p) }

    case 'DELETE_PLATFORM':
      return { ...state, socialPlatforms: state.socialPlatforms.filter(p => p.id !== action.payload) }

    case 'ADD_MOVIE':
      return { ...addActivity(`Added movie: ${action.payload.title}`, '🎬'), movies: [...state.movies, { id: Date.now(), ...action.payload }] }

    case 'UPDATE_MOVIE':
      return { ...state, movies: state.movies.map(m => m.id === action.payload.id ? { ...m, ...action.payload.data } : m) }

    case 'DELETE_MOVIE':
      return { ...state, movies: state.movies.filter(m => m.id !== action.payload) }

    case 'ADD_BOOK':
      return { ...addActivity(`Added book: ${action.payload.title}`, '📖'), books: [...state.books, { id: Date.now(), ...action.payload }] }

    case 'UPDATE_BOOK':
      return { ...state, books: state.books.map(b => b.id === action.payload.id ? { ...b, ...action.payload.data } : b) }

    case 'DELETE_BOOK':
      return { ...state, books: state.books.filter(b => b.id !== action.payload) }

    case 'ADD_MUSIC_TRACK':
      return { ...state, musicPlaylists: state.musicPlaylists.map(p => p.id === action.payload.playlistId
        ? { ...p, tracks: [...(p.tracks || []), action.payload.track] } : p) }

    case 'ADD_PLAYLIST':
      return { ...addActivity(`Created playlist: ${action.payload.name}`, '🎵'), musicPlaylists: [...state.musicPlaylists, { id: Date.now(), tracks: [], ...action.payload }] }

    case 'ADD_YOUTUBE_VIDEO':
      return { ...addActivity(`Saved video: ${action.payload.title}`, '▶️'), youtubeFolders: state.youtubeFolders.map(f => f.id === action.payload.folderId
        ? { ...f, videos: [...(f.videos || []), action.payload.video] } : f) }

    case 'ADD_YOUTUBE_FOLDER':
      return { ...addActivity(`Created folder: ${action.payload.name}`, '📁'), youtubeFolders: [...state.youtubeFolders, { id: Date.now(), videos: [], ...action.payload }] }

    case 'ADD_EVENT':
      return { ...addActivity(`Added event: ${action.payload.title}`, '📅'), calendarEvents: [...state.calendarEvents, { id: Date.now(), ...action.payload }] }

    case 'UPDATE_EVENT':
      return { ...state, calendarEvents: state.calendarEvents.map(e => e.id === action.payload.id ? { ...e, ...action.payload.data } : e) }

    case 'DELETE_EVENT':
      return { ...state, calendarEvents: state.calendarEvents.filter(e => e.id !== action.payload) }

    case 'IMPORT_DATA':
      return { ...state, ...action.payload, activityFeed: state.activityFeed }

    case 'RESET_ALL':
      return { ...initialState }

    case 'LOAD_STATE':
      return { ...state, ...action.payload }

    default:
      return state
  }
}

const StoreContext = createContext(null)

export function StoreProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, null, loadState)

  useEffect(() => {
    const timer = setInterval(() => {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
    }, 2000)
    return () => clearInterval(timer)
  }, [state])

  useEffect(() => {
    if (state.theme === 'dark' || (state.theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }, [state.theme])

  const dispatchAndSave = useCallback((action) => {
    dispatch(action)
  }, [])

  return (
    <StoreContext.Provider value={{ state, dispatch: dispatchAndSave }}>
      {children}
    </StoreContext.Provider>
  )
}

export function useStore() {
  const ctx = useContext(StoreContext)
  if (!ctx) throw new Error('useStore must be inside StoreProvider')
  return ctx
}
