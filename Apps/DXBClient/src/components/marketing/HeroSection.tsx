'use client'

import { ChevronDown } from 'lucide-react'
import Image from 'next/image'
import { useState } from 'react'

type HeroSectionProps = {
  title: string
  subtitle?: string
  badge?: string
  imageSrc: string
  imageAlt: string
  fullPage?: boolean
  children?: React.ReactNode
}

export default function HeroSection({
  title,
  subtitle,
  badge,
  imageSrc,
  imageAlt,
  fullPage = false,
  children,
}: HeroSectionProps) {
  const [imgError, setImgError] = useState(false)

  return (
    <section
      className={`relative flex overflow-hidden ${fullPage
        ? 'min-h-[calc(100vh-5rem)] items-center'
        : 'min-h-[40vh] items-end'
        }`}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900" />

      {!imgError && (
        <Image
          src={imageSrc}
          alt={imageAlt}
          fill
          className="object-cover"
          priority
          unoptimized
          onError={() => setImgError(true)}
        />
      )}

      <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/40 to-black/20" />

      <div className={`relative z-10 w-full ${fullPage ? 'py-20' : 'pb-12 pt-24'}`}>
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          {badge && (
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-white/20 bg-white/10 backdrop-blur-sm text-white text-xs font-semibold tracking-wide mb-6 animate-fade-in-up">
              <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse" />
              {badge}
            </div>
          )}

          <h1
            className={`font-bold tracking-tight text-white animate-fade-in-up ${fullPage
              ? 'text-4xl sm:text-5xl lg:text-6xl max-w-3xl'
              : 'text-3xl sm:text-4xl lg:text-5xl max-w-3xl'
              }`}
          >
            {title}
          </h1>

          {subtitle && (
            <p
              className={`mt-5 text-white/80 animate-fade-in-up stagger-1 ${fullPage
                ? 'text-lg sm:text-xl max-w-2xl'
                : 'text-base sm:text-lg max-w-2xl'
                }`}
            >
              {subtitle}
            </p>
          )}

          {children}
        </div>
      </div>

      {fullPage && (
        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 z-10 animate-bounce-gentle">
          <ChevronDown className="w-6 h-6 text-white/60" />
        </div>
      )}
    </section>
  )
}
