import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useStore } from '../store'
import { springs, springTransitions } from '../animations'
import { Target, MessageCircle, BookOpen, Plus, Send, Trash2, Pin, X, ChevronDown, GripVertical, Smile, Frown, Meh, SmilePlus, Angry } from 'lucide-react'

const moods = [
  { value: 1, emoji: '😡', label: 'Angry' },
  { value: 2, emoji: '😞', label: 'Sad' },
  { value: 3, emoji: '😐', label: 'Meh' },
  { value: 4, emoji: '😊', label: 'Happy' },
  { value: 5, emoji: '🤩', label: 'Amazing' },
]

const quotes = [
  '"The only way to do great work is to love what you do." — Steve Jobs',
  '"Believe you can and you\'re halfway there." — Theodore Roosevelt',
  '"Your time is limited, don\'t waste it living someone else\'s life." — Steve Jobs',
  '"The future belongs to those who believe in the beauty of their dreams." — Eleanor Roosevelt',
  '"It does not matter how slowly you go as long as you do not stop." — Confucius',
]

function TargetSection() {
  const { state, dispatch } = useStore()
  const [editing, setEditing] = useState(false)
  const [title, setTitle] = useState(state.targets.title || '')
  const [newGoal, setNewGoal] = useState('')

  const handleSave = () => {
    dispatch({ type: 'SET_TARGET', payload: { ...state.targets, title } })
    setEditing(false)
  }

  return (
    <motion.div
      className="rounded-2xl p-5"
      style={{ background: `linear-gradient(135deg, ${state.accentColor}15, ${state.accentColor}08)`, boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={springs.smooth}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <Target size={20} style={{ color: 'var(--accent)' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>My Main Target</h2>
        </div>
        <motion.button
          className="text-xs px-3 py-1.5 rounded-full font-medium"
          style={{ background: 'var(--accent)', color: 'white' }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setEditing(true)}
        >
          Edit
        </motion.button>
      </div>
      {editing ? (
        <div className="space-y-3">
          <input
            className="w-full rounded-xl px-4 py-2.5 text-lg font-bold outline-none"
            style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="What's your main target?"
            autoFocus
          />
          <div className="flex gap-2">
            <motion.button className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: 'var(--accent)', color: 'white' }} whileTap={{ scale: 0.95 }} onClick={handleSave}>Save</motion.button>
            <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }} whileTap={{ scale: 0.95 }} onClick={() => setEditing(false)}>Cancel</motion.button>
          </div>
        </div>
      ) : (
        <p className="text-xl font-bold mb-4" style={{ color: 'var(--text-primary)' }}>{state.targets.title || 'Set your main target'}</p>
      )}
      <div className="space-y-2 mb-3">
        {state.targets.subGoals.map((g, i) => (
          <motion.div
            key={g.id}
            className="rounded-xl p-3"
            style={{ background: 'var(--card)' }}
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={springTransitions.staggerItem(i)}
          >
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm font-medium truncate" style={{ color: 'var(--text-primary)' }}>{g.text}</span>
              <motion.button
                whileTap={{ scale: 0.9 }}
                onClick={() => dispatch({ type: 'DELETE_SUB_GOAL', payload: g.id })}
              >
                <X size={14} style={{ color: 'var(--text-tertiary)' }} />
              </motion.button>
            </div>
            <div className="relative h-2 rounded-full" style={{ background: 'var(--border)' }}>
              <motion.div
                className="absolute inset-y-0 left-0 rounded-full"
                style={{ background: 'var(--accent)' }}
                initial={{ width: 0 }}
                animate={{ width: `${g.progress}%` }}
                transition={springs.smooth}
              />
            </div>
            <input
              type="range"
              min="0" max="100"
              value={g.progress}
              onChange={e => dispatch({ type: 'UPDATE_SUB_GOAL', payload: { id: g.id, data: { progress: +e.target.value } } })}
              className="w-full mt-1 accent-[var(--accent)]"
            />
          </motion.div>
        ))}
      </div>
      <div className="flex gap-2">
        <input
          className="flex-1 rounded-xl px-3 py-2 text-sm outline-none"
          style={{ background: 'var(--card)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
          placeholder="Add sub-goal..."
          value={newGoal}
          onChange={e => setNewGoal(e.target.value)}
          onKeyDown={e => { if (e.key === 'Enter' && newGoal.trim()) { dispatch({ type: 'ADD_SUB_GOAL', payload: newGoal.trim() }); setNewGoal('') } }}
        />
        <motion.button
          className="p-2 rounded-xl"
          style={{ background: 'var(--accent)', color: 'white' }}
          whileTap={{ scale: 0.9 }}
          onClick={() => { if (newGoal.trim()) { dispatch({ type: 'ADD_SUB_GOAL', payload: newGoal.trim() }); setNewGoal('') } }}
        >
          <Plus size={18} />
        </motion.button>
      </div>
      <motion.p
        className="text-xs italic mt-3"
        style={{ color: 'var(--text-secondary)' }}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ ...springs.gentle, delay: 0.2 }}
      >
        {quotes[new Date().getDate() % quotes.length]}
      </motion.p>
    </motion.div>
  )
}

function Channels() {
  const { state, dispatch } = useStore()
  const [activeChannel, setActiveChannel] = useState(null)
  const [newChannelName, setNewChannelName] = useState('')
  const [newMsg, setNewMsg] = useState('')
  const [showNew, setShowNew] = useState(false)

  return (
    <motion.div
      className="rounded-2xl p-5"
      style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ ...springs.smooth, delay: 0.1 }}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <MessageCircle size={20} style={{ color: 'var(--accent)' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Thought Channels</h2>
        </div>
        <motion.button
          className="p-2 rounded-xl"
          style={{ background: `color-mix(in srgb, var(--accent) 12%, transparent)` }}
          whileTap={{ scale: 0.9 }}
          onClick={() => setShowNew(!showNew)}
        >
          <Plus size={18} style={{ color: 'var(--accent)' }} />
        </motion.button>
      </div>
      <AnimatePresence>
        {showNew && (
          <motion.div
            className="flex gap-2 mb-3"
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={springs.smooth}
          >
            <input
              className="flex-1 rounded-xl px-3 py-2 text-sm outline-none"
              style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Channel name..."
              value={newChannelName}
              onChange={e => setNewChannelName(e.target.value)}
              autoFocus
            />
            <motion.button
              className="p-2 rounded-xl" style={{ background: 'var(--accent)', color: 'white' }}
              whileTap={{ scale: 0.9 }}
              onClick={() => { if (newChannelName.trim()) { dispatch({ type: 'ADD_CHANNEL', payload: { name: newChannelName.trim() } }); setNewChannelName(''); setShowNew(false) } }}
            >
              <Plus size={18} />
            </motion.button>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="flex gap-2 overflow-x-auto pb-2 mb-3">
        {state.channels.map((ch, i) => (
          <motion.button
            key={ch.id}
            className="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap"
            style={{
              background: activeChannel?.id === ch.id ? 'var(--accent)' : 'var(--bg)',
              color: activeChannel?.id === ch.id ? 'white' : 'var(--text-secondary)',
            }}
            initial={{ opacity: 0, x: -8 }}
            animate={{ opacity: 1, x: 0 }}
            transition={springTransitions.staggerItem(i)}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => setActiveChannel(ch)}
          >
            # {ch.name}
          </motion.button>
        ))}
      </div>
      {activeChannel ? (
        <div>
          <div className="space-y-2 max-h-48 overflow-y-auto mb-3">
            {activeChannel.messages.map((m, i) => (
              <motion.div
                key={m.id}
                className="rounded-xl p-3 text-sm flex items-start gap-2"
                style={{ background: 'var(--bg)' }}
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={springTransitions.staggerItem(i)}
              >
                <div className="flex-1">
                  <p style={{ color: 'var(--text-primary)' }}>{m.text}</p>
                  <p className="text-[10px] mt-1" style={{ color: 'var(--text-tertiary)' }}>
                    {new Date(m.timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
                  </p>
                </div>
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={() => dispatch({ type: 'DELETE_MESSAGE', payload: { channelId: activeChannel.id, messageId: m.id } })}
                >
                  <Trash2 size={14} style={{ color: 'var(--text-tertiary)' }} />
                </motion.button>
              </motion.div>
            ))}
          </div>
          <div className="flex gap-2">
            <input
              className="flex-1 rounded-xl px-3 py-2 text-sm outline-none"
              style={{ background: 'var(--bg)', color: 'var(--text-primary)', border: '1px solid var(--border)' }}
              placeholder="Type a message..."
              value={newMsg}
              onChange={e => setNewMsg(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && newMsg.trim()) { dispatch({ type: 'SEND_MESSAGE', payload: { channelId: activeChannel.id, text: newMsg.trim() } }); setNewMsg('') } }}
            />
            <motion.button
              className="p-2 rounded-xl" style={{ background: 'var(--accent)', color: 'white' }}
              whileTap={{ scale: 0.9 }}
              onClick={() => { if (newMsg.trim()) { dispatch({ type: 'SEND_MESSAGE', payload: { channelId: activeChannel.id, text: newMsg.trim() } }); setNewMsg('') } }}
            >
              <Send size={18} />
            </motion.button>
          </div>
        </div>
      ) : (
        <p className="text-sm text-center py-4" style={{ color: 'var(--text-tertiary)' }}>Select or create a channel to start chatting</p>
      )}
    </motion.div>
  )
}

function Journal() {
  const { state, dispatch } = useStore()
  const [selectedNote, setSelectedNote] = useState(null)
  const [editTitle, setEditTitle] = useState('')
  const [editBody, setEditBody] = useState('')
  const [showNew, setShowNew] = useState(false)
  const [newTitle, setNewTitle] = useState('')
  const [newBody, setNewBody] = useState('')

  const saveNote = () => {
    if (selectedNote) {
      dispatch({ type: 'UPDATE_JOURNAL', payload: { id: selectedNote.id, data: { title: editTitle, body: editBody } } })
    }
  }

  const pinned = state.journalEntries.filter(e => e.pinned)
  const unpinned = state.journalEntries.filter(e => !e.pinned)

  return (
    <motion.div
      className="rounded-2xl overflow-hidden"
      style={{ background: 'var(--card)', boxShadow: 'var(--shadow-md)' }}
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ ...springs.smooth, delay: 0.2 }}
    >
      <div className="flex items-center justify-between p-5 border-b" style={{ borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-2">
          <BookOpen size={20} style={{ color: 'var(--accent)' }} />
          <h2 className="text-lg font-bold" style={{ color: 'var(--text-primary)' }}>Daily Journal</h2>
        </div>
        <motion.button
          className="p-2 rounded-xl" style={{ background: `color-mix(in srgb, var(--accent) 12%, transparent)` }}
          whileTap={{ scale: 0.9 }}
          onClick={() => setShowNew(true)}
        >
          <Plus size={18} style={{ color: 'var(--accent)' }} />
        </motion.button>
      </div>
      <AnimatePresence>
        {showNew && (
          <motion.div
            className="p-4 space-y-3 border-b" style={{ background: '#FAFAF8', borderColor: 'var(--border)' }}
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={springs.smooth}
          >
            <input
              className="w-full bg-transparent text-lg font-bold outline-none"
              style={{ color: 'var(--text-primary)' }}
              placeholder="Title..."
              value={newTitle}
              onChange={e => setNewTitle(e.target.value)}
              autoFocus
            />
            <textarea
              className="w-full bg-transparent text-sm outline-none resize-none"
              style={{ color: 'var(--text-primary)', minHeight: 80 }}
              placeholder="Start writing..."
              value={newBody}
              onChange={e => setNewBody(e.target.value)}
            />
            <div className="flex gap-2">
              <motion.button
                className="px-4 py-2 rounded-xl text-sm font-medium" style={{ background: 'var(--accent)', color: 'white' }}
                whileTap={{ scale: 0.95 }}
                onClick={() => { if (newBody.trim()) { dispatch({ type: 'ADD_JOURNAL', payload: { title: newTitle || 'Untitled', body: newBody } }); setNewTitle(''); setNewBody(''); setShowNew(false) } }}
              >
                Save
              </motion.button>
              <motion.button className="px-4 py-2 rounded-xl text-sm" style={{ color: 'var(--text-secondary)' }} whileTap={{ scale: 0.95 }} onClick={() => setShowNew(false)}>Cancel</motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
      <div className="flex">
        <div className="w-full md:w-1/2 border-r overflow-y-auto max-h-96" style={{ borderColor: 'var(--border)' }}>
          {pinned.map(n => <NoteItem key={n.id} note={n} selected={selectedNote?.id === n.id} onSelect={() => { setSelectedNote(n); setEditTitle(n.title); setEditBody(n.body) }} dispatch={dispatch} />)}
          {unpinned.map(n => <NoteItem key={n.id} note={n} selected={selectedNote?.id === n.id} onSelect={() => { setSelectedNote(n); setEditTitle(n.title); setEditBody(n.body) }} dispatch={dispatch} />)}
        </div>
        <div className="hidden md:block w-1/2 p-4" style={{ background: '#FAFAF8' }}>
          {selectedNote ? (
            <div>
              <input
                className="w-full bg-transparent text-lg font-bold outline-none mb-2"
                style={{ color: 'var(--text-primary)' }}
                value={editTitle}
                onChange={e => setEditTitle(e.target.value)}
                onBlur={saveNote}
              />
              <textarea
                className="w-full bg-transparent text-sm outline-none resize-none"
                style={{ color: 'var(--text-primary)', minHeight: 200 }}
                value={editBody}
                onChange={e => setEditBody(e.target.value)}
                onBlur={saveNote}
              />
              <p className="text-[10px] mt-2" style={{ color: 'var(--text-tertiary)' }}>Auto-saved</p>
            </div>
          ) : (
            <div className="flex items-center justify-center h-full">
              <p className="text-sm" style={{ color: 'var(--text-tertiary)' }}>Select a note to edit</p>
            </div>
          )}
        </div>
      </div>
      <div className="p-4 border-t" style={{ borderColor: 'var(--border)' }}>
        <p className="text-xs font-medium mb-2" style={{ color: 'var(--text-secondary)' }}>How are you feeling?</p>
        <div className="flex gap-3">
          {moods.map(m => (
            <motion.button
              key={m.value}
              className="flex flex-col items-center gap-1"
              whileHover={{ scale: 1.2 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => dispatch({ type: 'SET_CURRENT_MOOD', payload: m.value })}
            >
              <motion.span
                className="text-2xl"
                animate={state.currentMood === m.value ? { scale: 1.3 } : { scale: 0.8, opacity: 0.4 }}
                transition={springs.bouncy}
              >
                {m.emoji}
              </motion.span>
              <span className="text-[10px]" style={{ color: state.currentMood === m.value ? 'var(--accent)' : 'var(--text-tertiary)' }}>
                {m.label}
              </span>
            </motion.button>
          ))}
        </div>
      </div>
    </motion.div>
  )
}

function NoteItem({ note, selected, onSelect, dispatch }) {
  return (
    <motion.div
      className="p-3 border-b cursor-pointer" style={{ borderColor: 'var(--border)', background: selected ? 'var(--bg)' : 'transparent' }}
      whileHover={{ background: 'var(--bg)' }}
      whileTap={{ scale: 0.98 }}
      onClick={onSelect}
      layout
      transition={springs.smooth}
    >
      <div className="flex items-center gap-2">
        {note.pinned && <Pin size={12} style={{ color: 'var(--accent)' }} />}
        <p className="text-sm font-semibold truncate flex-1" style={{ color: 'var(--text-primary)' }}>{note.title || 'Untitled'}</p>
        <motion.button
          whileTap={{ scale: 0.9 }}
          onClick={e => { e.stopPropagation(); dispatch({ type: 'PIN_JOURNAL', payload: note.id }) }}
        >
          <Pin size={12} style={{ color: note.pinned ? 'var(--accent)' : 'var(--text-tertiary)' }} fill={note.pinned ? 'var(--accent)' : 'none'} />
        </motion.button>
        <motion.button
          whileTap={{ scale: 0.9 }}
          onClick={e => { e.stopPropagation(); dispatch({ type: 'DELETE_JOURNAL', payload: note.id }) }}
        >
          <Trash2 size={12} style={{ color: 'var(--text-tertiary)' }} />
        </motion.button>
      </div>
      <p className="text-xs truncate mt-0.5" style={{ color: 'var(--text-secondary)' }}>{note.body}</p>
      <p className="text-[10px] mt-0.5" style={{ color: 'var(--text-tertiary)' }}>
        {new Date(note.createdAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
      </p>
    </motion.div>
  )
}

export default function Mind() {
  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto space-y-6 pb-24 md:pb-8">
      <TargetSection />
      <Channels />
      <Journal />
    </div>
  )
}
