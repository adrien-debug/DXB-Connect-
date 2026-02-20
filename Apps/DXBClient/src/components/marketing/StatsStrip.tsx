type Stat = { value: string; label: string }

export default function StatsStrip({ stats }: { stats: Stat[] }) {
  return (
    <div className="mt-10 glass-card px-6 py-6">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        {stats.map((s, i) => (
          <div key={s.label} className="relative">
            <div className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
              {s.value}
            </div>
            <div className="mt-1 text-xs sm:text-sm text-zinc-400">
              {s.label}
            </div>
            {i < stats.length - 1 && (
              <div className="hidden md:block absolute right-0 top-1/2 -translate-y-1/2 w-px h-8 bg-zinc-800" />
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

