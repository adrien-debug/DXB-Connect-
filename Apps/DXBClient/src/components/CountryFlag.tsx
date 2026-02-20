'use client'

import * as Flags from 'country-flag-icons/react/3x2'
import { ComponentType, SVGProps } from 'react'

type FlagCode = keyof typeof Flags

interface CountryFlagProps {
  code: string
  className?: string
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
}

const sizeClasses = {
  xs: 'w-4 h-3',
  sm: 'w-6 h-4',
  md: 'w-8 h-6',
  lg: 'w-12 h-8',
  xl: 'w-16 h-12',
}

export function CountryFlag({ code, className = '', size = 'md' }: CountryFlagProps) {
  const upperCode = code.toUpperCase() as FlagCode
  const FlagComponent = Flags[upperCode] as ComponentType<SVGProps<SVGSVGElement>> | undefined

  if (!FlagComponent) {
    return (
      <div
        className={`${sizeClasses[size]} ${className} bg-slate-100 rounded flex items-center justify-center`}
      >
        <span className="text-slate-400 text-xs">🌍</span>
      </div>
    )
  }

  return (
    <FlagComponent
      className={`${sizeClasses[size]} ${className} rounded-sm shadow-sm`}
    />
  )
}

export function CountryFlagWithName({
  code,
  name,
  size = 'sm',
  className = ''
}: CountryFlagProps & { name?: string }) {
  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <CountryFlag code={code} size={size} />
      {name && <span className="text-sm font-medium text-slate-700">{name}</span>}
    </div>
  )
}
