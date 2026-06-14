import { useIsMobile } from '../../hooks/useMediaQuery'
import { Routes, Route, useNavigate, useParams } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Bold, Italic, List, Plus, Underline } from 'lucide-react'
import { format, isSameDay, parseISO } from 'date-fns'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { SwipeableRow } from '../../components/ui/SwipeableRow'
import { useAppStore } from '../../stores/useAppStore'
import { useAutoSave } from '../../hooks/useAutoSave'
import { autoTags } from '../../lib/constants'
import { springs } from '../../lib/springs'
import type { Mood } from '../../types'
import { useMemo, useState } from 'react'

const MOODS: Mood[] = ['😊', '😐', '😔', '😤', '🤩']

function NoteList() {
  const notes = useAppStore((s) => s.journalNotes)
  const addNote = useAppStore((s) => s.addNote)
  const deleteNote = useAppStore((s) => s.deleteNote)
  const toggleNotePin = useAppStore((s) => s.toggleNotePin)
  const navigate = useNavigate()
  const [filterDate, setFilterDate] = useState<Date | null>(null)

  const sorted = useMemo(() => {
    let list = [...notes].sort((a, b) => {
      if (a.pinned !== b.pinned) return a.pinned ? -1 : 1
      return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
    })
    if (filterDate) list = list.filter((n) => isSameDay(parseISO(n.updatedAt), filterDate))
    return list
  }, [notes, filterDate])

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold">Notes</h3>
        <Button variant="secondary" className="!min-h-9" onClick={() => { const id = addNote(); navigate(id) }}>
          <Plus size={16} /> New
        </Button>
      </div>
      <input type="date" onChange={(e) => setFilterDate(e.target.value ? new Date(e.target.value) : null)} className="rounded-lg border border-[var(--border)] bg-[var(--bg)] px-2 py-1 text-sm" />
      {sorted.map((note) => (
        <SwipeableRow
          key={note.id}
          leftActions={[{ label: 'Pin', color: '#FF9500', onClick: () => toggleNotePin(note.id) }]}
          rightActions={[{ label: 'Delete', color: '#FF3B30', onClick: () => deleteNote(note.id) }]}
        >
          <button type="button" onClick={() => navigate(note.id)} className="w-full p-4 text-left">
            <p className="font-semibold">{note.title || 'Untitled'}</p>
            <p className="line-clamp-2 text-sm text-[var(--text-secondary)]">{note.body.replace(/<[^>]+>/g, '')}</p>
            <p className="mt-1 text-xs text-[var(--text-tertiary)]">{format(parseISO(note.updatedAt), 'MMM d, yyyy')}</p>
          </button>
        </SwipeableRow>
      ))}
    </div>
  )
}

function NoteEditor() {
  const { noteId } = useParams()
  const note = useAppStore((s) => s.journalNotes.find((n) => n.id === noteId))
  const updateNote = useAppStore((s) => s.updateNote)
  const navigate = useNavigate()
  const [saved, setSaved] = useState(false)

  const save = (patch: Parameters<typeof updateNote>[1]) => {
    if (!noteId) return
    updateNote(noteId, patch)
    setSaved(true)
    setTimeout(() => setSaved(false), 1500)
  }

  useAutoSave(note?.body ?? '', (body) => save({ body, tags: autoTags(body.replace(/<[^>]+>/g, ' ')) }), 2000)

  if (!note) return <p>Note not found</p>

  const exec = (cmd: string) => {
    document.execCommand(cmd)
    save({ body: document.getElementById('journal-editor')?.innerHTML ?? note.body })
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Button variant="ghost" onClick={() => navigate('/mind/journal')}>← Back</Button>
        {saved && <motion.span initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-xs text-[var(--success)]">Saved</motion.span>}
      </div>
      <div className="flex flex-wrap gap-2 rounded-xl bg-[var(--card)] p-2 shadow-[var(--shadow-sm)]">
        {[['bold', Bold], ['italic', Italic], ['underline', Underline], ['insertUnorderedList', List]].map(([cmd, Icon]) => (
          <button key={cmd as string} type="button" onClick={() => exec(cmd as string)} className="rounded-lg p-2 hover:bg-[var(--bg)]">
            <Icon size={16} />
          </button>
        ))}
      </div>
      <div className="flex gap-2">
        {MOODS.map((m) => (
          <motion.button
            key={m}
            type="button"
            whileTap={{ scale: 1.3 }}
            transition={springs.bouncy}
            onClick={() => save({ mood: m })}
            className={`text-2xl ${note.mood === m ? 'scale-125' : 'opacity-50'}`}
          >
            {m}
          </motion.button>
        ))}
      </div>
      <div
        id="journal-editor"
        contentEditable
        suppressContentEditableWarning
        onInput={(e) => {
          const html = e.currentTarget.innerHTML
          const title = e.currentTarget.innerText.split('\n')[0] ?? ''
          save({ body: html, title })
        }}
        dangerouslySetInnerHTML={{ __html: note.body || '<h1>Title</h1><p>Start writing...</p>' }}
        className="min-h-[400px] rounded-2xl p-6 outline-none"
        style={{ background: 'var(--paper)' }}
      />
      {note.tags.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {note.tags.map((t) => (
            <span key={t} className="rounded-full bg-[var(--accent-soft)] px-2 py-0.5 text-xs text-[var(--accent)]">#{t}</span>
          ))}
        </div>
      )}
    </div>
  )
}

export function JournalPage() {
  const isMobile = useIsMobile()

  if (isMobile) {
    return (
      <Routes>
        <Route index element={<NoteList />} />
        <Route path=":noteId" element={<NoteEditor />} />
      </Routes>
    )
  }

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <NoteList />
      <Routes>
        <Route index element={<Card><p className="text-[var(--text-secondary)]">Select a note to edit</p></Card>} />
        <Route path=":noteId" element={<NoteEditor />} />
      </Routes>
    </div>
  )
}
