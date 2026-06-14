export function Skeleton({ className = '' }: { className?: string }) {
  return (
    <div
      className={`animate-[shimmer_1.5s_ease-in-out_infinite] rounded-xl bg-[var(--text-tertiary)]/20 ${className}`}
      style={{ animationName: 'shimmer' }}
    />
  )
}

export function SkeletonCard() {
  return (
    <div className="rounded-2xl bg-[var(--card)] p-4 shadow-[var(--shadow-sm)]">
      <Skeleton className="mb-3 h-4 w-2/3" />
      <Skeleton className="mb-2 h-3 w-full" />
      <Skeleton className="h-3 w-4/5" />
    </div>
  )
}
