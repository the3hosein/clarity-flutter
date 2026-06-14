export interface iTunesTrack {
  trackId: number
  trackName: string
  artistName: string
  collectionName: string
  artworkUrl100: string
  previewUrl: string
  trackTimeMillis: number
}

export async function searchMusic(query: string): Promise<iTunesTrack[]> {
  const url = `https://itunes.apple.com/search?term=${encodeURIComponent(query)}&entity=musicTrack&limit=15&media=music`
  const res = await fetch(url)
  const data = await res.json()
  return data.results ?? []
}

export function hdArtwork(url: string) {
  return url.replace('100x100', '600x600')
}

export function formatDuration(ms: number) {
  const mins = Math.floor(ms / 60000)
  const secs = Math.floor((ms % 60000) / 1000)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}
