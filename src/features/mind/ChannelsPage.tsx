import { useRef, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Image, Mic, Plus, Search, Send } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { SwipeableRow } from '../../components/ui/SwipeableRow'
import { useAppStore } from '../../stores/useAppStore'
import { springs } from '../../lib/springs'
import { format } from 'date-fns'

export function ChannelsPage() {
  const channels = useAppStore((s) => s.channels)
  const messages = useAppStore((s) => s.messages)
  const addChannel = useAppStore((s) => s.addChannel)
  const addMessage = useAppStore((s) => s.addMessage)
  const updateMessage = useAppStore((s) => s.updateMessage)
  const deleteMessage = useAppStore((s) => s.deleteMessage)

  const [activeChannel, setActiveChannel] = useState(channels[0]?.id ?? '')
  const [text, setText] = useState('')
  const [search, setSearch] = useState('')
  const [newChannel, setNewChannel] = useState('')
  const [editingId, setEditingId] = useState<string | null>(null)
  const [editText, setEditText] = useState('')
  const fileRef = useRef<HTMLInputElement>(null)
  const mediaRef = useRef<MediaRecorder | null>(null)

  const channelMessages = messages
    .filter((m) => m.channelId === activeChannel)
    .filter((m) => !search || m.content.toLowerCase().includes(search.toLowerCase()))
    .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())

  const sendText = () => {
    if (!text.trim() || !activeChannel) return
    addMessage({ channelId: activeChannel, type: 'text', content: text.trim() })
    setText('')
  }

  const handlePhoto = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file || !activeChannel) return
    const reader = new FileReader()
    reader.onload = () => {
      addMessage({ channelId: activeChannel, type: 'photo', content: reader.result as string })
    }
    reader.readAsDataURL(file)
  }

  const startVoice = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      const recorder = new MediaRecorder(stream)
      const chunks: BlobPart[] = []
      recorder.ondataavailable = (e) => chunks.push(e.data)
      recorder.onstop = () => {
        const blob = new Blob(chunks, { type: 'audio/webm' })
        const reader = new FileReader()
        reader.onload = () => {
          if (activeChannel) addMessage({ channelId: activeChannel, type: 'voice', content: reader.result as string })
        }
        reader.readAsDataURL(blob)
        stream.getTracks().forEach((t) => t.stop())
      }
      mediaRef.current = recorder
      recorder.start()
      setTimeout(() => recorder.stop(), 5000)
    } catch {
      alert('Microphone access unavailable')
    }
  }

  return (
    <div className="grid gap-4 lg:grid-cols-[220px_1fr]">
      <Card className="h-fit space-y-2">
        <div className="flex gap-2">
          <input
            value={newChannel}
            onChange={(e) => setNewChannel(e.target.value)}
            placeholder="New channel"
            className="flex-1 rounded-lg border border-[var(--border)] bg-[var(--bg)] px-2 py-1 text-sm"
          />
          <Button variant="secondary" className="!min-h-8 !px-2" onClick={() => { if (newChannel.trim()) { addChannel(newChannel.trim()); setNewChannel('') } }}>
            <Plus size={16} />
          </Button>
        </div>
        {channels.map((ch) => (
          <button
            key={ch.id}
            type="button"
            onClick={() => setActiveChannel(ch.id)}
            className={`w-full rounded-lg px-3 py-2 text-left text-sm ${activeChannel === ch.id ? 'bg-[var(--accent-soft)] text-[var(--accent)]' : ''}`}
          >
            {ch.name}
          </button>
        ))}
      </Card>

      <Card className="flex min-h-[400px] flex-col">
        <div className="relative mb-3">
          <Search size={16} className="absolute top-3 left-3 text-[var(--text-secondary)]" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search messages..."
            className="w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] py-2 pr-3 pl-9 text-sm"
          />
        </div>

        <div className="flex-1 space-y-3 overflow-y-auto pb-4">
          <AnimatePresence>
            {channelMessages.map((msg) => (
              <motion.div key={msg.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, height: 0 }} transition={springs.bouncy}>
                <SwipeableRow
                  rightActions={[
                    { label: 'Edit', color: '#007AFF', onClick: () => { setEditingId(msg.id); setEditText(msg.content) } },
                    { label: 'Delete', color: '#FF3B30', onClick: () => deleteMessage(msg.id) },
                  ]}
                >
                  <div className="p-3">
                    {msg.type === 'text' && (editingId === msg.id ? (
                      <div className="flex gap-2">
                        <input value={editText} onChange={(e) => setEditText(e.target.value)} className="flex-1 rounded-lg border px-2 py-1 text-sm" />
                        <Button variant="secondary" className="!min-h-8" onClick={() => { updateMessage(msg.id, editText); setEditingId(null) }}>Save</Button>
                      </div>
                    ) : (
                      <p className="text-sm">{msg.content}</p>
                    ))}
                    {msg.type === 'photo' && <img src={msg.content} alt="" className="max-h-48 rounded-lg" />}
                    {msg.type === 'voice' && <audio controls src={msg.content} className="w-full" />}
                    <p className="mt-1 text-[10px] text-[var(--text-tertiary)]">{format(new Date(msg.createdAt), 'h:mm a')}</p>
                  </div>
                </SwipeableRow>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>

        <div className="flex gap-2 border-t border-[var(--border)] pt-3">
          <input value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && sendText()} placeholder="Message..." className="flex-1 rounded-xl border border-[var(--border)] bg-[var(--bg)] px-3 py-2 text-sm" />
          <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handlePhoto} />
          <Button variant="ghost" className="!min-h-10 !px-2" onClick={() => fileRef.current?.click()}><Image size={18} /></Button>
          <Button variant="ghost" className="!min-h-10 !px-2" onClick={startVoice}><Mic size={18} /></Button>
          <Button variant="primary" className="!min-h-10 !px-3" onClick={sendText}><Send size={18} /></Button>
        </div>
      </Card>
    </div>
  )
}
