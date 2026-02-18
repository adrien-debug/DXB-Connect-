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
  color?: 'blue' | 'green' | 'purple' | 'orange' | 'red' | 'indigo'
}

const colorConfig = {
  blue: {
    accent: 'from-sky-500 to-sky-400',
    iconBg: 'bg-sky-50',
    iconColor: 'text-sky-600',
    ring: 'ring-sky-100',
  },
  green: {
    accent: 'from-emerald-500 to-emerald-400',
    iconBg: 'bg-emerald-50',
    iconColor: 'text-emerald-600',
    ring: 'ring-emerald-100',
  },
  purple: {
    accent: 'from-violet-500 to-violet-400',
    iconBg: 'bg-violet-50',
    iconColor: 'text-violet-600',
    ring: 'ring-violet-100',
  },
  orange: {
    accent: 'from-amber-500 to-orange-400',
    iconBg: 'bg-amber-50',
    iconColor: 'text-amber-600',
    ring: 'ring-amber-100',
  },
  red: {
    accent: 'from-rose-500 to-rose-400',
    iconBg: 'bg-rose-50',
    iconColor: 'text-rose-600',
    ring: 'ring-rose-100',
  },
  indigo: {
    accent: 'from-indigo-500 to-indigo-400',
    iconBg: 'bg-indigo-50',
    iconColor: 'text-indigo-600',
    ring: 'ring-indigo-100',
  },
}

export default function StatCard({ title, value, icon: Icon, trend, color = 'purple' }: StatCardProps) {
  const config = colorConfig[color]

  return (
    <div
      className="
        group relative bg-white rounded-2xl overflow-hidden
        shadow-[0_1px_3px_rgba(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgba(0,0,0,0.08)]
        transition-all duration-500 ease-out
        border border-gray-100
        hover:-translate-y-0.5
      "
    >
      <div className={`absolute top-0 left-0 right-0 h-[3px] bg-gradient-to-r ${config.accent}`} />

      <div className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1.5 min-w-0 flex-1">
            <p className="text-[11px] sm:text-xs font-semibold text-gray-400 uppercase tracking-wider truncate">
              {title}
            </p>
            <p className="text-xl sm:text-2xl font-bold text-gray-900 tracking-tight break-words">
              {value}
            </p>
            {trend && (
              <div className={`
                inline-flex items-center gap-1 text-[11px] font-semibold mt-1
                ${trend.isPositive ? 'text-emerald-600' : 'text-rose-500'}
              `}>
                <span className={`
                  inline-flex items-center justify-center w-4 h-4 rounded-full text-[9px]
                  ${trend.isPositive ? 'bg-emerald-100' : 'bg-rose-100'}
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
