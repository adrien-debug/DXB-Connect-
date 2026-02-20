type Props = {
  eyebrow?: string
  title: string
  subtitle?: string
}

export default function SectionHeader({ eyebrow, title, subtitle }: Props) {
  return (
    <div className="max-w-3xl">
      {eyebrow && (
        <div className="text-xs font-semibold tracking-widest uppercase text-lime-400 mb-2">
          {eyebrow}
        </div>
      )}
      <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
        {title}
      </h2>
      {subtitle && (
        <p className="mt-3 text-sm sm:text-base text-zinc-400 leading-relaxed">
          {subtitle}
        </p>
      )}
    </div>
  )
}

