export async function searchBooks(query: string) {
  const url = `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(query)}&maxResults=10`
  const res = await fetch(url)
  const data = await res.json()
  return data.items ?? []
}

export function hdCover(thumbnail?: string) {
  if (!thumbnail) return ''
  return thumbnail.replace('zoom=1', 'zoom=2').replace('http:', 'https:')
}
