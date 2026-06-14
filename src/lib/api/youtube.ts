export async function fetchYouTubeOEmbed(url: string) {
  const res = await fetch(`https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`)
  if (!res.ok) throw new Error('Invalid YouTube URL')
  return res.json() as Promise<{ title: string; author_name: string; thumbnail_url: string }>
}

export function extractVideoId(url: string) {
  const match = url.match(/(?:v=|youtu\.be\/)([\w-]{11})/)
  return match?.[1] ?? crypto.randomUUID()
}
