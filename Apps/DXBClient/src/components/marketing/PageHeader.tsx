import type { LucideIcon } from 'lucide-react'

type PageHeaderProps = {
  badge: string
  badgeIcon: LucideIcon
  title: string
  subtitle?: string
  children?: React.ReactNode
}

export default function PageHeader({
  badge,
  badgeIcon: Icon,
  title,
  subtitle,
  children,
}: PageHeaderProps) {
  return (
    <section className="pt-32 pb-14 bg-white">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5 animate-fade-in-up">
          <Icon className="w-3.5 h-3.5" />
          {badge}
        </div>
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-black tracking-tight animate-fade-in-up stagger-1">
          {title}
        </h1>
        {subtitle && (
          <p className="mt-5 text-base sm:text-lg text-gray max-w-2xl leading-relaxed animate-fade-in-up stagger-2">
            {subtitle}
          </p>
        )}
        {children && (
          <div className="mt-8 animate-fade-in-up stagger-3">
            {children}
          </div>
        )}
      </div>
    </section>
  )
}
