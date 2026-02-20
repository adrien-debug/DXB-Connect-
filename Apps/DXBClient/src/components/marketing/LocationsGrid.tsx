const locations = [
  {
    region: 'Middle East',
    detail: 'UAE & Qatar · Headquarters',
  },
  {
    region: 'Europe',
    detail: 'France · Green Energy',
  },
  {
    region: 'Asia-Pacific',
    detail: 'HK & Singapore · APAC Hub',
  },
]

export default function LocationsGrid() {
  return (
    <div className="mt-10 grid md:grid-cols-3 gap-5">
      {locations.map((l) => (
        <div key={l.region} className="glass-card p-6 hover:border-zinc-700 transition-colors">
          <div className="text-sm font-semibold text-white">{l.region}</div>
          <div className="mt-2 text-sm text-zinc-400">{l.detail}</div>
        </div>
      ))}
    </div>
  )
}

