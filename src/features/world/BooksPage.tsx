import { useState } from 'react'
import { Search } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { AnimatedTabBar } from '../../components/ui/AnimatedTabBar'
import { ProgressBar } from '../../components/ui/AnimatedTabBar'
import { DetailSheet } from '../../components/ui/Modal'
import { useAppStore } from '../../stores/useAppStore'
import { searchBooks, hdCover } from '../../lib/api/googleBooks'
import type { Book, BookStatus } from '../../types'

const STATUS_TABS = [
  { id: 'want', label: 'Want to Read' },
  { id: 'reading', label: 'Reading' },
  { id: 'finished', label: 'Finished' },
]

export function BooksPage() {
  const books = useAppStore((s) => s.books)
  const addBook = useAppStore((s) => s.addBook)
  const updateBook = useAppStore((s) => s.updateBook)
  const deleteBook = useAppStore((s) => s.deleteBook)

  const [query, setQuery] = useState('')
  const [results, setResults] = useState<Array<{ id: string; volumeInfo: Record<string, unknown> }>>([])
  const [statusFilter, setStatusFilter] = useState<BookStatus | 'all'>('all')
  const [selected, setSelected] = useState<Book | null>(null)
  const [expanded, setExpanded] = useState(false)

  const search = async () => {
    if (!query.trim()) return
    setResults(await searchBooks(query))
  }

  const importBook = (item: (typeof results)[0]) => {
    const v = item.volumeInfo as {
      title: string
      authors?: string[]
      publisher?: string
      publishedDate?: string
      pageCount?: number
      description?: string
      categories?: string[]
      averageRating?: number
      industryIdentifiers?: Array<{ type: string; identifier: string }>
      imageLinks?: { thumbnail?: string }
    }
    addBook({
      title: v.title,
      authors: v.authors ?? [],
      publisher: v.publisher ?? '',
      publishedDate: v.publishedDate ?? '',
      pageCount: v.pageCount ?? 0,
      currentPage: 0,
      description: v.description ?? '',
      categories: v.categories ?? [],
      averageRating: v.averageRating ?? 0,
      isbn: v.industryIdentifiers?.find((i) => i.type === 'ISBN_13')?.identifier ?? '',
      cover: hdCover(v.imageLinks?.thumbnail),
      status: 'want',
      notes: '',
    })
    setResults([])
  }

  const filtered = books.filter((b) => statusFilter === 'all' || b.status === statusFilter)

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <input value={query} onChange={(e) => setQuery(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && search()} placeholder="Search books..." className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--card)] px-3 py-2" />
        <Button onClick={search}><Search size={16} /></Button>
      </div>

      {results.length > 0 && (
        <div className="grid gap-3 sm:grid-cols-2">
          {results.map((r) => {
            const v = r.volumeInfo as { title?: string; authors?: string[]; imageLinks?: { thumbnail?: string } }
            return (
              <Card key={r.id} onClick={() => importBook(r)} className="flex gap-3 !p-3">
                {v.imageLinks?.thumbnail && <img src={hdCover(v.imageLinks.thumbnail)} alt="" className="h-20 w-14 rounded object-cover" />}
                <div>
                  <p className="font-medium">{v.title}</p>
                  <p className="text-sm text-[var(--text-secondary)]">{v.authors?.join(', ')}</p>
                </div>
              </Card>
            )
          })}
        </div>
      )}

      <AnimatedTabBar tabs={[{ id: 'all', label: 'All' }, ...STATUS_TABS]} active={statusFilter} onChange={(id) => setStatusFilter(id as BookStatus | 'all')} />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((b, i) => (
          <Card key={b.id} delay={i * 0.04} onClick={() => setSelected(b)}>
            {b.cover && <img src={b.cover} alt="" className="mb-2 h-40 w-full rounded-lg object-cover" />}
            <h4 className="font-semibold">{b.title}</h4>
            <p className="text-sm text-[var(--text-secondary)]">{b.authors.join(', ')}</p>
            {b.pageCount > 0 && (
              <div className="mt-2">
                <ProgressBar value={(b.currentPage / b.pageCount) * 100} />
                <p className="mt-1 text-xs text-[var(--text-secondary)]">{b.currentPage} / {b.pageCount} pages</p>
              </div>
            )}
          </Card>
        ))}
      </div>

      <DetailSheet open={!!selected} onClose={() => { setSelected(null); setExpanded(false) }}>
        {selected && (
          <div className="space-y-3">
            <h2 className="text-xl font-bold">{selected.title}</h2>
            <p className="text-sm text-[var(--text-secondary)]">{selected.authors.join(', ')} · {selected.publishedDate}</p>
            <p className="text-sm">{expanded ? selected.description : `${selected.description.slice(0, 200)}${selected.description.length > 200 ? '...' : ''}`}</p>
            {selected.description.length > 200 && (
              <button type="button" onClick={() => setExpanded(!expanded)} className="text-sm text-[var(--accent)]">{expanded ? 'Show less' : 'Read more'}</button>
            )}
            <AnimatedTabBar tabs={STATUS_TABS} active={selected.status} onChange={(id) => { updateBook(selected.id, { status: id as BookStatus }); setSelected({ ...selected, status: id as BookStatus }) }} />
            <label className="block text-sm">Current page
              <input type="number" value={selected.currentPage} onChange={(e) => { const v = Number(e.target.value); updateBook(selected.id, { currentPage: v }); setSelected({ ...selected, currentPage: v }) }} className="mt-1 w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-2" />
            </label>
            <textarea value={selected.notes} onChange={(e) => { updateBook(selected.id, { notes: e.target.value }); setSelected({ ...selected, notes: e.target.value }) }} placeholder="Notes..." className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] p-3 text-sm" rows={3} />
            <Button variant="danger" onClick={() => { deleteBook(selected.id); setSelected(null) }}>Remove</Button>
          </div>
        )}
      </DetailSheet>
    </div>
  )
}
