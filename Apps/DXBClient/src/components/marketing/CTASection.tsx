import Link from 'next/link'
import { ArrowRight } from 'lucide-react'

type Props = {
  title: string
  subtitle?: string
  primaryHref: string
  primaryLabel: string
  secondaryHref?: string
  secondaryLabel?: string
}

export default function CTASection({
  title,
  subtitle,
  primaryHref,
  primaryLabel,
  secondaryHref,
  secondaryLabel,
}: Props) {
  return (
    <div className="mt-10 glow-card p-6 sm:p-8">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="text-sm font-semibold text-black">{title}</div>
          {subtitle && <div className="text-sm text-gray mt-1">{subtitle}</div>}
        </div>

        <div className="flex flex-col sm:flex-row gap-3">
          {secondaryHref && secondaryLabel && (
            <Link href={secondaryHref} className="btn-secondary">
              {secondaryLabel}
            </Link>
          )}
          <Link href={primaryHref} className="btn-premium">
            {primaryLabel} <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </div>
  )
}
