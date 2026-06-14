import { useState } from 'react'
import { Search } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { AnimatedTabBar } from '../../components/ui/AnimatedTabBar'
import { StarRating } from '../../components/ui/StarRating'
import { DetailSheet } from '../../components/ui/Modal'
import { useAppStore } from '../../stores/useAppStore'
import { searchMovies, getMovieDetails } from '../../lib/api/omdb'
import type { Movie, MovieStatus } from '../../types'

const STATUS_TABS = [
  { id: 'want', label: 'Want to Watch' },
  { id: 'watching', label: 'Watching' },
  { id: 'watched', label: 'Watched' },
]

export function MoviesPage() {
  const movies = useAppStore((s) => s.movies)
  const addMovie = useAppStore((s) => s.addMovie)
  const updateMovie = useAppStore((s) => s.updateMovie)
  const deleteMovie = useAppStore((s) => s.deleteMovie)

  const [query, setQuery] = useState('')
  const [results, setResults] = useState<Array<{ imdbID: string; Title: string; Year: string; Poster: string }>>([])
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [statusFilter, setStatusFilter] = useState<MovieStatus | 'all'>('all')
  const [selected, setSelected] = useState<Movie | null>(null)

  const search = async () => {
    if (!query.trim()) return
    setLoading(true)
    setError('')
    try {
      setResults(await searchMovies(query))
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Search failed')
    } finally {
      setLoading(false)
    }
  }

  const importMovie = async (imdbId: string) => {
    try {
      const d = await getMovieDetails(imdbId)
      addMovie({
        imdbId,
        title: d.Title,
        year: d.Year,
        genre: d.Genre,
        poster: d.Poster !== 'N/A' ? d.Poster : '',
        plot: d.Plot,
        director: d.Director,
        cast: d.Actors?.split(', ').slice(0, 3) ?? [],
        runtime: d.Runtime,
        rated: d.Rated,
        awards: d.Awards,
        imdbRating: d.imdbRating,
        status: 'want',
      })
      setResults([])
      setQuery('')
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Import failed')
    }
  }

  const filtered = movies.filter((m) => statusFilter === 'all' || m.status === statusFilter)

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search size={16} className="absolute top-3 left-3 text-[var(--text-secondary)]" />
          <input value={query} onChange={(e) => setQuery(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && search()} placeholder="Search movies..." className="w-full rounded-xl border border-[var(--border)] bg-[var(--card)] py-2.5 pr-3 pl-9" />
        </div>
        <Button onClick={search} disabled={loading}>{loading ? '...' : 'Search'}</Button>
      </div>
      {error && <p className="text-sm text-[var(--danger)]">{error}</p>}

      {results.length > 0 && (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {results.map((r) => (
            <Card key={r.imdbID} onClick={() => importMovie(r.imdbID)} className="flex gap-3 !p-3">
              {r.Poster !== 'N/A' && <img src={r.Poster} alt="" className="h-20 w-14 rounded-lg object-cover" />}
              <div>
                <p className="font-medium">{r.Title}</p>
                <p className="text-sm text-[var(--text-secondary)]">{r.Year}</p>
              </div>
            </Card>
          ))}
        </div>
      )}

      <AnimatedTabBar tabs={[{ id: 'all', label: 'All' }, ...STATUS_TABS]} active={statusFilter} onChange={(id) => setStatusFilter(id as MovieStatus | 'all')} />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((m, i) => (
          <Card key={m.id} delay={i * 0.04} onClick={() => setSelected(m)} className="overflow-hidden !p-0">
            <div className="flex">
              {m.poster && <img src={m.poster} alt="" className="h-32 w-24 object-cover" />}
              <div className="flex-1 p-3">
                <div className="flex justify-between">
                  <h4 className="font-semibold">{m.title}</h4>
                  {m.imdbRating !== 'N/A' && <span className="rounded bg-yellow-500/20 px-1.5 text-xs">⭐ {m.imdbRating}</span>}
                </div>
                <p className="text-xs text-[var(--text-secondary)]">{m.year} · {m.genre}</p>
                {m.userRating > 0 && <StarRating value={m.userRating} />}
              </div>
            </div>
          </Card>
        ))}
      </div>

      <DetailSheet open={!!selected} onClose={() => setSelected(null)}>
        {selected && (
          <div className="space-y-3">
            <h2 className="text-xl font-bold">{selected.title}</h2>
            <p className="text-sm text-[var(--text-secondary)]">{selected.year} · {selected.runtime} · {selected.rated}</p>
            <p className="text-sm">{selected.plot}</p>
            <p className="text-sm"><strong>Director:</strong> {selected.director}</p>
            <p className="text-sm"><strong>Cast:</strong> {selected.cast.join(', ')}</p>
            <AnimatedTabBar tabs={STATUS_TABS} active={selected.status} onChange={(id) => { updateMovie(selected.id, { status: id as MovieStatus }); setSelected({ ...selected, status: id as MovieStatus }) }} />
            <div><p className="mb-1 text-sm">Your rating</p><StarRating value={selected.userRating} onChange={(v) => { updateMovie(selected.id, { userRating: v }); setSelected({ ...selected, userRating: v }) }} /></div>
            <Button variant="danger" onClick={() => { deleteMovie(selected.id); setSelected(null) }}>Remove</Button>
          </div>
        )}
      </DetailSheet>
    </div>
  )
}
