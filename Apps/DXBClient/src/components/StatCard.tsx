'use client'

import { LucideIcon } from 'lucide-react'

interface StatCardProps {
  title: string
  value: string | number
  icon: LucideIcon
  trend?: {
    value: number
    isPositive: boolean
  }
  color?: 'lime' | 'green' | 'purple' | 'orange' | 'red' | 'blue'
}

const colorConfig = {
  lime: {
    iconBg: 'bg-lime-400/10',
    iconColor: 'text-lime-400',
    ring: 'ring-lime-400/20',
    accent: 'bg-lime-400',
  },
  green: {
    iconBg: 'bg-emerald-500/10',
    iconColor: 'text-emerald-400',
    ring: 'ring-emerald-500/20',
    accent: 'bg-emerald-400',
  },
  purple: {
    iconBg: 'bg-violet-500/10',
    iconColor: 'text-violet-400',
    ring: 'ring-violet-500/20',
    accent: 'bg-violet-400',
  },
  orange: {
    iconBg: 'bg-amber-500/10',
    iconColor: 'text-amber-400',
    ring: 'ring-amber-500/20',
    accent: 'bg-amber-400',
  },
  red: {
    iconBg: 'bg-rose-500/10',
    iconColor: 'text-rose-400',
    ring: 'ring-rose-500/20',
    accent: 'bg-rose-400',
  },
  blue: {
    iconBg: 'bg-blue-500/10',
    iconColor: 'text-blue-400',
    ring: 'ring-blue-500/20',
    accent: 'bg-blue-400',
  },
}

export default function StatCard({ title, value, icon: Icon, trend, color = 'lime' }: StatCardProps) {
  const config = colorConfig[color]

  return (
    <div
      className="
        group relative bg-zinc-900 rounded-2xl overflow-hidden
        border border-zinc-800 hover:border-zinc-700
        transition-all duration-500 ease-out
        hover:-translate-y-0.5
      "
    >
      <div className={`absolute top-0 left-0 right-0 h-[3px] ${config.accent}`} />

      <div className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1.5 min-w-0 flex-1">
            <p className="text-[11px] sm:text-xs font-semibold text-zinc-500 uppercase tracking-wider truncate">
              {title}
            </p>
            <p className="text-xl sm:text-2xl font-bold text-white tracking-tight break-words">
              {value}
            </p>
            {trend && (
              <div className={`
                inline-flex items-center gap-1 text-[11px] font-semibold mt-1
                ${trend.isPositive ? 'text-emerald-400' : 'text-rose-400'}
              `}>
                <span className={`
                  inline-flex items-center justify-center w-4 h-4 rounded-full text-[9px]
                  ${trend.isPositive ? 'bg-emerald-500/20' : 'bg-rose-500/20'}
                `}>
                  {trend.isPositive ? '↑' : '↓'}
                </span>
                {Math.abs(trend.value)}%
              </div>
            )}
          </div>

          <div className={`
            flex items-center justify-center w-11 h-11 rounded-xl flex-shrink-0
            ${config.iconBg} ring-1 ${config.ring}
            transition-all duration-500
            group-hover:scale-110 group-hover:rotate-3
          `}>
            <Icon size={20} className={config.iconColor} />
          </div>
        </div>
      </div>
    </div>
  )
}
