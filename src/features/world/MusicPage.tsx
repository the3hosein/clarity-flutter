import { useRef, useState } from 'react'
import { motion } from 'framer-motion'
import { Pause, Play, Search } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { useAppStore } from '../../stores/useAppStore'
import { searchMusic, hdArtwork, formatDuration } from '../../lib/api/itunes'

export function MusicPage() {
  const playlists = useAppStore((s) => s.playlists)
  const tracks = useAppStore((s) => s.tracks)
  const addTrack = useAppStore((s) => s.addTrack)
  const addPlaylist = useAppStore((s) => s.addPlaylist)
  const deleteTrack = useAppStore((s) => s.deleteTrack)

  const [query, setQuery] = useState('')
  const [results, setResults] = useState<Awaited<ReturnType<typeof searchMusic>>>([])
  const [activePlaylist, setActivePlaylist] = useState(playlists[0]?.id ?? '')
  const [playing, setPlaying] = useState<string | null>(null)
  const audioRef = useRef<HTMLAudioElement | null>(null)

  const search = async () => {
    if (!query.trim()) return
    setResults(await searchMusic(query))
  }

  const playPreview = (trackId: string, url: string) => {
    if (playing === trackId) {
      audioRef.current?.pause()
      setPlaying(null)
      return
    }
    if (audioRef.current) audioRef.current.pause()
    const audio = new Audio(url)
    audioRef.current = audio
    audio.play()
    setPlaying(trackId)
    audio.onended = () => setPlaying(null)
  }

  const importTrack = (t: (typeof results)[0]) => {
    if (!activePlaylist) {
      const id = addPlaylist('New Playlist', 'Focus')
      setActivePlaylist(id)
    }
    addTrack({
      trackName: t.trackName,
      artist: t.artistName,
      album: t.collectionName,
      artwork: hdArtwork(t.artworkUrl100),
      previewUrl: t.previewUrl,
      duration: formatDuration(t.trackTimeMillis),
      playlistId: activePlaylist,
    })
  }

  const playlistTracks = tracks.filter((t) => t.playlistId === activePlaylist)

  return (
    <div className="space-y-4">
      <div className="flex gap-2 overflow-x-auto pb-2">
        {playlists.map((p) => (
          <button key={p.id} type="button" onClick={() => setActivePlaylist(p.id)} className={`shrink-0 rounded-full px-4 py-2 text-sm ${activePlaylist === p.id ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)]'}`}>
            {p.name} <span className="opacity-70">· {p.mood}</span>
          </button>
        ))}
        <Button variant="secondary" className="!min-h-9 shrink-0" onClick={() => { const id = addPlaylist('Playlist', 'Chill'); setActivePlaylist(id) }}>+ Playlist</Button>
      </div>

      <div className="flex gap-2">
        <input value={query} onChange={(e) => setQuery(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && search()} placeholder="Search songs or artists..." className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--card)] px-3 py-2" />
        <Button onClick={search}><Search size={16} /></Button>
      </div>

      {results.length > 0 && (
        <div className="space-y-2">
          {results.map((t) => (
            <Card key={t.trackId} className="flex items-center gap-3 !p-3">
              <img src={hdArtwork(t.artworkUrl100)} alt="" className="h-12 w-12 rounded-lg" />
              <div className="flex-1 min-w-0">
                <p className="truncate font-medium">{t.trackName}</p>
                <p className="truncate text-sm text-[var(--text-secondary)]">{t.artistName}</p>
              </div>
              <Button variant="secondary" className="!min-h-8" onClick={() => importTrack(t)}>Import</Button>
            </Card>
          ))}
        </div>
      )}

      <div className="space-y-2">
        {playlistTracks.map((t) => (
          <Card key={t.id} className="flex items-center gap-3 !p-3">
            <img src={t.artwork} alt="" className="h-12 w-12 rounded-lg" />
            <div className="flex-1 min-w-0">
              <p className="truncate font-medium">{t.trackName}</p>
              <p className="truncate text-sm text-[var(--text-secondary)]">{t.artist} · {t.duration}</p>
              {playing === t.id && (
                <div className="mt-1 flex h-4 items-end gap-0.5">
                  {[0, 1, 2, 3, 4].map((i) => (
                    <motion.div key={i} className="w-1 rounded-full bg-[var(--accent)]" animate={{ height: [4, 16, 8, 14, 4] }} transition={{ repeat: Infinity, duration: 0.8, delay: i * 0.1 }} />
                  ))}
                </div>
              )}
            </div>
            {t.previewUrl && (
              <button type="button" onClick={() => playPreview(t.id, t.previewUrl)} className="rounded-full bg-[var(--accent-soft)] p-2 text-[var(--accent)]">
                {playing === t.id ? <Pause size={16} /> : <Play size={16} />}
              </button>
            )}
            <Button variant="ghost" className="!min-h-8 !px-2 text-xs" onClick={() => deleteTrack(t.id)}>×</Button>
          </Card>
        ))}
      </div>
    </div>
  )
}
