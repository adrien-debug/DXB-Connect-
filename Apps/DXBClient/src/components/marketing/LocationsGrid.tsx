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
        <div key={l.region} className="glass-card p-6 hover:border-gray transition-colors">
          <div className="text-sm font-semibold text-black">{l.region}</div>
          <div className="mt-2 text-sm text-gray">{l.detail}</div>
        </div>
      ))}
    </div>
  )
}
