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
    iconBg: 'bg-lime-400/20',
    iconColor: 'text-black',
    border: 'border-lime-400/30',
    accent: 'bg-lime-400',
  },
  green: {
    iconBg: 'bg-emerald-100',
    iconColor: 'text-emerald-600',
    border: 'border-emerald-200',
    accent: 'bg-emerald-400',
  },
  purple: {
    iconBg: 'bg-purple-100',
    iconColor: 'text-purple-600',
    border: 'border-purple-200',
    accent: 'bg-purple-400',
  },
  orange: {
    iconBg: 'bg-orange-100',
    iconColor: 'text-orange-600',
    border: 'border-orange-200',
    accent: 'bg-orange-400',
  },
  red: {
    iconBg: 'bg-red-100',
    iconColor: 'text-red-600',
    border: 'border-red-200',
    accent: 'bg-red-400',
  },
  blue: {
    iconBg: 'bg-blue-100',
    iconColor: 'text-blue-600',
    border: 'border-blue-200',
    accent: 'bg-blue-400',
  },
}

export default function StatCard({ title, value, icon: Icon, trend, color = 'lime' }: StatCardProps) {
  const config = colorConfig[color]

  return (
    <div
      className="
        group relative bg-white rounded-2xl overflow-hidden
        border border-gray-light hover:border-gray hover:shadow-sm
        transition-all duration-500 ease-out
        hover:-translate-y-0.5
      "
    >
      <div className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1.5 min-w-0 flex-1">
            <p className="text-[11px] sm:text-xs font-semibold text-gray uppercase tracking-wider truncate">
              {title}
            </p>
            <p className="text-xl sm:text-2xl font-bold text-black tracking-tight break-words">
              {value}
            </p>
            {trend && (
              <div className={`
                inline-flex items-center gap-1 text-[11px] font-semibold mt-1
                ${trend.isPositive ? 'text-emerald-600' : 'text-rose-600'}
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
            ${config.iconBg} border ${config.border}
            transition-all duration-500
            group-hover:scale-110
          `}>
            <Icon size={20} className={config.iconColor} />
          </div>
        </div>
      </div>
    </div>
  )
}
