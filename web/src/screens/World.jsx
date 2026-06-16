import { useState, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from '../store'
import { springs, springTransitions } from '../animations'
import { Search, Film, Music, BookOpen, Video, Plus, Star, ExternalLink, X, ChevronDown, Play, Folder, Check, Clock, Eye, Monitor } from 'lucide-react'

function useDebounce(fn, delay = 500) {
  let timer
  return useCallback((...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => fn(...args), delay)
  }, [fn, delay])
}

function MovieSection() {
  const { state, dispatch } = useStore()
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [searching, setSearching] = useState(false)

  const search = useCallback(async (q) => {
    if (!q.trim()) return
    setSearching(true)
    try {
      const res = await fetch(`https://www.omdbapi.com/?s=${encodeURIComponent(q)}&apikey=4a3b711b`)
      const data = await res.json()
      if (data.Search) {
        const details = await Promise.all(data.Search.slice(0, 5).map(async (m) => {
          const d = await fetch(`https://www.omdbapi.com/?i=${m.imdbID}&apikey=4a3b711b`).then(r => r.json())
          return d
        }))
        setResults(details.filter(d => d.Response !== 'False'))
      }
    } catch {} finally { setSearching(false) }
  }, [])

  const debouncedSearch = useDebounce(search, 600)

  const statusColors = { 'Want to Watch': '#007AFF', 'Watching': '#FF9500', 'Watched': '#34C759' }

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={springs.smooth}>
      <div className="flex items-center gap-2 mb-4">
        <Film size={20} style={{ color: '#007AFF' }} />
        <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Movies</h2>
      </div>
      <div className="flex gap-2 mb-4">
        <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
          placeholder="Search movies..." value={query} onChange={e => { setQuery(e.target.value); debouncedSearch(e.target.value) }} />
        {searching && <div className="p-2"><div className="w-5 h-5 rounded-full border-2 border-t-transparent animate-spin" style={{ borderColor: 'var(--accent)', borderTopColor: 'transparent' }} /></div>}
      </div>
      <AnimatePresence>
        {results.length > 0 && (
          <motion.div className="space-y-2 mb-4" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {results.map((m, i) => (
              <motion.div key={m.imdbID} className="flex gap-3 rounded-xl p-3" style={{ background: 'var(--bg)' }}
                initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
                {m.Poster && m.Poster !== 'N/A' && (
                  <img src={m.Poster} alt={m.Title} className="w-12 h-16 rounded-lg object-cover shrink-0" />
                )}
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{m.Title}</p>
                  <p className="text-xs" style={{ color: 'var(--text-secondary)' }}>{m.Year} · {m.Genre}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[10px] px-1.5 py-0.5 rounded font-bold" style={{ background: '#F5C51820', color: '#F5C518' }}>
                      ★ {m.imdbRating}
                    </span>
                    <span className="text-[10px]" style={{ color: 'var(--text-tertiary)' }}>{m.Runtime}</span>
                  </div>
                </div>
                <motion.button className="p-2 rounded-xl shrink-0" style={{ background: '#007AFF20' }} whileTap={{ scale: 0.9 }}
                  onClick={() => {
                    if (!state.movies.find(mv => mv.imdbID === m.imdbID)) {
                      dispatch({ type: 'ADD_MOVIE', payload: { title: m.Title, year: m.Year, poster: m.Poster, imdbRating: m.imdbRating, genre: m.Genre, plot: m.Plot, director: m.Director, actors: m.Actors, runtime: m.Runtime, rated: m.Rated, imdbID: m.imdbID, status: 'Want to Watch' } })
                    }
                  }}>
                  <Plus size={16} style={{ color: '#007AFF' }} />
                </motion.button>
              </motion.div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
        {state.movies.map((m, i) => (
          <motion.div key={m.id} className="rounded-xl p-3 flex gap-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} transition={springTransitions.staggerItem(i)} layout>
            {m.poster && <img src={m.poster} alt={m.title} className="w-10 h-14 rounded-lg object-cover shrink-0" />}
            <div className="flex-1 min-w-0">
              <p className="text-xs font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{m.title}</p>
              <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{m.year}</p>
              <select value={m.status} onChange={e => dispatch({ type: 'UPDATE_MOVIE', payload: { id: m.id, data: { status: e.target.value } } })}
                className="text-[10px] rounded px-1 py-0.5 mt-1 outline-none" style={{ background: 'var(--card)', color: statusColors[m.status] || 'var(--text-primary)', border: '1px solid var(--border)' }}>
                <option>Want to Watch</option>
                <option>Watching</option>
                <option>Watched</option>
              </select>
            </div>
            <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_MOVIE', payload: m.id })}>
              <X size={14} style={{ color: 'var(--text-tertiary)' }} />
            </motion.button>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

function MusicSection() {
  const { state, dispatch } = useStore()
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [searching, setSearching] = useState(false)
  const [playing, setPlaying] = useState(null)

  const search = useCallback(async (q) => {
    if (!q.trim()) return
    setSearching(true)
    try {
      const res = await fetch(`https://itunes.apple.com/search?term=${encodeURIComponent(q)}&entity=musicTrack&limit=10&media=music`)
      const data = await res.json()
      setResults(data.results || [])
    } catch {} finally { setSearching(false) }
  }, [])

  const debouncedSearch = useDebounce(search, 600)

  const [playlistName, setPlaylistName] = useState('')
  const [showNewPlaylist, setShowNewPlaylist] = useState(false)

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.1 }}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Music size={20} style={{ color: '#FF2D55' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Music</h2>
        </div>
        <motion.button className="p-2 rounded-xl" style={{ background: '#FF2D5520' }} whileTap={{ scale: 0.9 }}
          onClick={() => setShowNewPlaylist(!showNewPlaylist)}>
          <Plus size={18} style={{ color: '#FF2D55' }} />
        </motion.button>
      </div>
      <AnimatePresence>
        {showNewPlaylist && (
          <motion.div className="flex gap-2 mb-3" initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Playlist name..." value={playlistName} onChange={e => setPlaylistName(e.target.value)} autoFocus />
            <select className="rounded-xl px-2 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              defaultValue="Chill">
              <option>Chill</option><option>Focus</option><option>Hype</option><option>Sad</option>
            </select>
            <motion.button className="p-2 rounded-xl" style={{ background: '#FF2D55', color: 'white' }} whileTap={{ scale: 0.9 }}
              onClick={() => { if (playlistName.trim()) { dispatch({ type: 'ADD_PLAYLIST', payload: { name: playlistName.trim() } }); setPlaylistName(''); setShowNewPlaylist(false) } }}>
              <Plus size={18} />
            </motion.button>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="flex gap-2 mb-3">
        <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
          placeholder="Search music..." value={query} onChange={e => { setQuery(e.target.value); debouncedSearch(e.target.value) }} />
      </div>
      <AnimatePresence>
        {results.length > 0 && (
          <motion.div className="space-y-2 mb-3 max-h-48 overflow-y-auto" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {results.map((t, i) => (
              <motion.div key={t.trackId} className="flex items-center gap-3 rounded-xl p-2.5" style={{ background: 'var(--bg)' }}
                initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
                {t.artworkUrl100 && <img src={t.artworkUrl100.replace('100x100', '200x200')} alt={t.album} className="w-10 h-10 rounded-lg object-cover shrink-0" />}
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{t.trackName}</p>
                  <p className="text-[10px] truncate" style={{ color: 'var(--text-secondary)' }}>{t.artistName} · {t.album}</p>
                </div>
                {t.previewUrl && (
                  <motion.button whileTap={{ scale: 0.9 }} onClick={() => setPlaying(playing === t.trackId ? null : t.trackId)}
                    className="p-1.5 rounded-full" style={{ background: playing === t.trackId ? '#FF2D55' : 'var(--card)' }}>
                    <Play size={14} style={{ color: playing === t.trackId ? 'white' : 'var(--accent)' }} fill={playing === t.trackId ? 'white' : 'var(--accent)'} />
                  </motion.button>
                )}
                {t.trackViewUrl && (
                  <motion.a href={t.trackViewUrl} target="_blank" rel="noopener noreferrer" whileTap={{ scale: 0.9 }}>
                    <ExternalLink size={14} style={{ color: 'var(--text-tertiary)' }} />
                  </motion.a>
                )}
                <motion.button className="p-1.5 rounded-xl" whileTap={{ scale: 0.9 }}
                  onClick={() => {
                    if (state.musicPlaylists.length > 0) {
                      dispatch({ type: 'ADD_MUSIC_TRACK', payload: { playlistId: state.musicPlaylists[0].id, track: { trackId: t.trackId, trackName: t.trackName, artistName: t.artistName, album: t.album, artworkUrl: t.artworkUrl100, previewUrl: t.previewUrl } } })
                    }
                  }}>
                  <Plus size={14} style={{ color: 'var(--accent)' }} />
                </motion.button>
              </motion.div>
            ))}
            {playing && <audio src={results.find(t => t.trackId === playing)?.previewUrl} autoPlay onEnded={() => setPlaying(null)} />}
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-2">
        {state.musicPlaylists.map((pl, i) => (
          <motion.div key={pl.id} className="rounded-xl p-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={springTransitions.staggerItem(i)}>
            <p className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>{pl.name} <span className="text-[10px] font-normal" style={{ color: 'var(--text-tertiary)' }}>({pl.tracks?.length || 0} tracks)</span></p>
            {pl.tracks?.slice(0, 3).map(t => (
              <p key={t.trackId} className="text-xs truncate" style={{ color: 'var(--text-secondary)' }}>🎵 {t.trackName}</p>
            ))}
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

function BookSection() {
  const { state, dispatch } = useStore()
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [searching, setSearching] = useState(false)

  const search = useCallback(async (q) => {
    if (!q.trim()) return
    setSearching(true)
    try {
      const res = await fetch(`https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(q)}&maxResults=5`)
      const data = await res.json()
      setResults(data.items || [])
    } catch {} finally { setSearching(false) }
  }, [])

  const debouncedSearch = useDebounce(search, 600)

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.2 }}>
      <div className="flex items-center gap-2 mb-4">
        <BookOpen size={20} style={{ color: '#FF9500' }} />
        <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Books</h2>
      </div>
      <div className="flex gap-2 mb-3">
        <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
          placeholder="Search books..." value={query} onChange={e => { setQuery(e.target.value); debouncedSearch(e.target.value) }} />
      </div>
      <AnimatePresence>
        {results.length > 0 && (
          <motion.div className="space-y-2 mb-3" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            {results.map((b, i) => {
              const v = b.volumeInfo
              return (
                <motion.div key={b.id} className="flex gap-3 rounded-xl p-3" style={{ background: 'var(--bg)' }}
                  initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }} transition={springTransitions.staggerItem(i)}>
                  {v.imageLinks?.thumbnail && (
                    <img src={v.imageLinks.thumbnail.replace('zoom=1', 'zoom=2')} alt={v.title} className="w-10 h-14 rounded-lg object-cover shrink-0" />
                  )}
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{v.title}</p>
                    <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{v.authors?.join(', ') || ''} · {v.publishedDate}</p>
                    {v.averageRating && <span className="text-[10px]" style={{ color: '#F5C518' }}>★ {v.averageRating}</span>}
                  </div>
                  <motion.button className="p-2 rounded-xl shrink-0" style={{ background: '#FF950020' }} whileTap={{ scale: 0.9 }}
                    onClick={() => {
                      if (!state.books.find(bk => bk.googleId === b.id)) {
                        dispatch({ type: 'ADD_BOOK', payload: { title: v.title, authors: v.authors, thumbnail: v.imageLinks?.thumbnail, pages: v.pageCount, rating: v.averageRating, googleId: b.id, status: 'Want to Read', progress: 0 } })
                      }
                    }}>
                    <Plus size={16} style={{ color: '#FF9500' }} />
                  </motion.button>
                </motion.div>
              )
            })}
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-2">
        {state.books.map((b, i) => (
          <motion.div key={b.id} className="rounded-xl p-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={springTransitions.staggerItem(i)} layout>
            <div className="flex items-center gap-3">
              {b.thumbnail && <img src={b.thumbnail} alt={b.title} className="w-8 h-11 rounded object-cover shrink-0" />}
              <div className="flex-1 min-w-0">
                <p className="text-xs font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{b.title}</p>
                <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{b.authors?.join(', ')}</p>
                <select value={b.status} onChange={e => dispatch({ type: 'UPDATE_BOOK', payload: { id: b.id, data: { status: e.target.value } } })}
                  className="text-[10px] rounded px-1 py-0.5 mt-1 outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}>
                  <option>Want to Read</option><option>Reading</option><option>Finished</option>
                </select>
              </div>
              <div className="flex items-center gap-1">
                <input type="number" min="0" max={b.pages || 1000} value={b.progress || 0}
                  onChange={e => dispatch({ type: 'UPDATE_BOOK', payload: { id: b.id, data: { progress: +e.target.value } } })}
                  className="w-14 text-[10px] rounded px-1 py-1 text-center outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }} />
                <span className="text-[10px]" style={{ color: 'var(--text-tertiary)' }}>/ {b.pages || '?'}</span>
              </div>
              <motion.button whileTap={{ scale: 0.9 }} onClick={() => dispatch({ type: 'DELETE_BOOK', payload: b.id })}>
                <X size={14} style={{ color: 'var(--text-tertiary)' }} />
              </motion.button>
            </div>
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

function VideoSection() {
  const { state, dispatch } = useStore()
  const [url, setUrl] = useState('')
  const [fetched, setFetched] = useState(null)
  const [folderName, setFolderName] = useState('')
  const [showNewFolder, setShowNewFolder] = useState(false)

  const fetchVideo = async () => {
    if (!url.trim()) return
    try {
      const res = await fetch(`https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`)
      const data = await res.json()
      setFetched({ ...data, url })
    } catch {} 
  }

  return (
    <motion.div className="rounded-2xl p-5" style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ ...springs.smooth, delay: 0.3 }}>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Video size={20} style={{ color: '#FF3B30' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>YouTube</h2>
        </div>
        <motion.button className="p-2 rounded-xl" style={{ background: '#FF3B3020' }} whileTap={{ scale: 0.9 }}
          onClick={() => setShowNewFolder(!showNewFolder)}>
          <Plus size={18} style={{ color: '#FF3B30' }} />
        </motion.button>
      </div>
      <AnimatePresence>
        {showNewFolder && (
          <motion.div className="flex gap-2 mb-3" initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }} transition={springs.smooth}>
            <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Folder name..." value={folderName} onChange={e => setFolderName(e.target.value)} autoFocus />
            <motion.button className="p-2 rounded-xl" style={{ background: '#FF3B30', color: 'white' }} whileTap={{ scale: 0.9 }}
              onClick={() => { if (folderName.trim()) { dispatch({ type: 'ADD_YOUTUBE_FOLDER', payload: { name: folderName.trim() } }); setFolderName(''); setShowNewFolder(false) } }}>
              <Plus size={18} />
            </motion.button>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="flex gap-2 mb-3">
        <input className="flex-1 rounded-xl px-3 py-2 text-sm outline-none" style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
          placeholder="Paste YouTube URL..." value={url} onChange={e => setUrl(e.target.value)} />
        <motion.button className="px-3 py-2 rounded-xl text-sm font-medium" style={{ background: '#FF3B30', color: 'white' }} whileTap={{ scale: 0.95 }} onClick={fetchVideo}>
          Fetch
        </motion.button>
      </div>
      <AnimatePresence>
        {fetched && (
          <motion.div className="flex items-center gap-3 rounded-xl p-3 mb-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}>
            {fetched.thumbnail_url && <img src={fetched.thumbnail_url} alt={fetched.title} className="w-16 h-10 rounded object-cover shrink-0" />}
            <div className="flex-1 min-w-0">
              <p className="text-xs font-semibold truncate" style={{ color: 'var(--text-primary)' }}>{fetched.title}</p>
              <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{fetched.author_name}</p>
            </div>
            <select className="text-[10px] rounded px-1 py-1 outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              defaultValue=""
              onChange={e => {
                if (e.target.value) {
                  dispatch({ type: 'ADD_YOUTUBE_VIDEO', payload: { folderId: +e.target.value, video: { id: Date.now(), title: fetched.title, thumbnail: fetched.thumbnail_url, channel: fetched.author_name, url, status: 'To Watch' } } })
                  setFetched(null); setUrl('')
                }
              }}>
              <option value="" disabled>Add to folder...</option>
              {state.youtubeFolders.map(f => <option key={f.id} value={f.id}>{f.name}</option>)}
            </select>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="space-y-3">
        {state.youtubeFolders.map((f, i) => (
          <motion.div key={f.id} className="rounded-xl p-3" style={{ background: 'var(--bg)' }}
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={springTransitions.staggerItem(i)}>
            <div className="flex items-center gap-2 mb-2">
              <Folder size={14} style={{ color: '#FF3B30' }} />
              <p className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>{f.name}</p>
              <span className="text-[10px]" style={{ color: 'var(--text-tertiary)' }}>({f.videos?.length || 0})</span>
            </div>
            {f.videos?.slice(0, 3).map((v, j) => (
              <div key={v.id} className="flex items-center gap-2 py-1">
                {v.thumbnail && <img src={v.thumbnail} alt={v.title} className="w-12 h-8 rounded object-cover shrink-0" />}
                <div className="flex-1 min-w-0">
                  <p className="text-[10px] font-medium truncate" style={{ color: 'var(--text-primary)' }}>{v.title}</p>
                  <p className="text-[10px]" style={{ color: 'var(--text-secondary)' }}>{v.channel}</p>
                </div>
                <select value={v.status} onChange={e => {/* update status */}}
                  className="text-[10px] rounded px-1 outline-none" style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}>
                  <option>To Watch</option><option>Watching</option><option>Done</option>
                </select>
              </div>
            ))}
          </motion.div>
        ))}
      </div>
    </motion.div>
  )
}

export default function World() {
  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto space-y-6 pb-24 md:pb-8">
      <MovieSection />
      <MusicSection />
      <BookSection />
      <VideoSection />
    </div>
  )
}
