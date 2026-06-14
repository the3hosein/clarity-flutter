import { useState } from 'react'
import { Link2 } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { AnimatedTabBar } from '../../components/ui/AnimatedTabBar'
import { useAppStore } from '../../stores/useAppStore'
import { fetchYouTubeOEmbed } from '../../lib/api/youtube'
import type { YouTubeStatus } from '../../types'

const STATUS_TABS = [
  { id: 'to-watch', label: 'To Watch' },
  { id: 'watching', label: 'Watching' },
  { id: 'done', label: 'Done' },
]

export function YouTubePage() {
  const folders = useAppStore((s) => s.youtubeFolders)
  const videos = useAppStore((s) => s.youtubeVideos)
  const addYouTubeFolder = useAppStore((s) => s.addYouTubeFolder)
  const addYouTubeVideo = useAppStore((s) => s.addYouTubeVideo)
  const updateYouTubeVideo = useAppStore((s) => s.updateYouTubeVideo)
  const deleteYouTubeVideo = useAppStore((s) => s.deleteYouTubeVideo)

  const [url, setUrl] = useState('')
  const [error, setError] = useState('')
  const [activeFolder, setActiveFolder] = useState(folders[0]?.id ?? '')
  const [statusFilter, setStatusFilter] = useState<YouTubeStatus | 'all'>('all')

  const importUrl = async () => {
    if (!url.trim()) return
    setError('')
    try {
      const data = await fetchYouTubeOEmbed(url)
      if (!activeFolder) {
        const id = addYouTubeFolder('Watch Later')
        setActiveFolder(id)
      }
      addYouTubeVideo({
        url,
        title: data.title,
        channel: data.author_name,
        thumbnail: data.thumbnail_url,
        folderId: activeFolder,
        status: 'to-watch',
      })
      setUrl('')
    } catch {
      setError('Invalid YouTube URL')
    }
  }

  const filtered = videos.filter((v) => {
    if (activeFolder && v.folderId !== activeFolder) return false
    if (statusFilter !== 'all' && v.status !== statusFilter) return false
    return true
  })

  return (
    <div className="space-y-4">
      <div className="flex gap-2 overflow-x-auto">
        {folders.map((f) => (
          <button key={f.id} type="button" onClick={() => setActiveFolder(f.id)} className={`shrink-0 rounded-full px-4 py-2 text-sm ${activeFolder === f.id ? 'bg-[var(--accent)] text-white' : 'bg-[var(--card)]'}`}>
            {f.name}
          </button>
        ))}
        <Button variant="secondary" className="!min-h-9 shrink-0" onClick={() => { const id = addYouTubeFolder('Folder'); setActiveFolder(id) }}>+ Folder</Button>
      </div>

      <div className="flex gap-2">
        <div className="relative flex-1">
          <Link2 size={16} className="absolute top-3 left-3 text-[var(--text-secondary)]" />
          <input value={url} onChange={(e) => setUrl(e.target.value)} placeholder="Paste YouTube URL..." className="w-full rounded-xl border border-[var(--border)] bg-[var(--card)] py-2.5 pr-3 pl-9" />
        </div>
        <Button onClick={importUrl}>Import</Button>
      </div>
      {error && <p className="text-sm text-[var(--danger)]">{error}</p>}

      <AnimatedTabBar tabs={[{ id: 'all', label: 'All' }, ...STATUS_TABS]} active={statusFilter} onChange={(id) => setStatusFilter(id as YouTubeStatus | 'all')} />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((v, i) => (
          <Card key={v.id} delay={i * 0.04}>
            <img src={v.thumbnail} alt="" className="mb-2 aspect-video w-full rounded-lg object-cover" />
            <h4 className="line-clamp-2 font-medium">{v.title}</h4>
            <p className="text-sm text-[var(--text-secondary)]">{v.channel}</p>
            <select value={v.status} onChange={(e) => updateYouTubeVideo(v.id, { status: e.target.value as YouTubeStatus })} className="mt-2 w-full rounded-lg border border-[var(--border)] bg-[var(--bg)] p-2 text-sm">
              {STATUS_TABS.map((s) => <option key={s.id} value={s.id}>{s.label}</option>)}
            </select>
            <Button variant="ghost" className="mt-2 w-full !min-h-8" onClick={() => deleteYouTubeVideo(v.id)}>Remove</Button>
          </Card>
        ))}
      </div>
    </div>
  )
}
