export async function searchMovies(query: string) {
  const key = import.meta.env.VITE_OMDB_API_KEY
  if (!key || key === 'your_api_key_here') {
    throw new Error('Add VITE_OMDB_API_KEY to your .env file')
  }
  const res = await fetch(`https://www.omdbapi.com/?s=${encodeURIComponent(query)}&apikey=${key}`)
  const data = await res.json()
  if (data.Response === 'False') throw new Error(data.Error || 'No results')
  return data.Search as Array<{ imdbID: string; Title: string; Year: string; Type: string; Poster: string }>
}

export async function getMovieDetails(imdbId: string) {
  const key = import.meta.env.VITE_OMDB_API_KEY
  const res = await fetch(`https://www.omdbapi.com/?i=${imdbId}&apikey=${key}`)
  const data = await res.json()
  if (data.Response === 'False') throw new Error(data.Error)
  return data
}
