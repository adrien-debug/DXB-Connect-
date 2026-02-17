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
    iconBg: 'bg-violet-100',
    iconColor: 'text-violet-600',
  },
  green: {
    iconBg: 'bg-emerald-100',
    iconColor: 'text-emerald-600',
  },
  purple: {
    iconBg: 'bg-violet-100',
    iconColor: 'text-violet-600',
  },
  orange: {
    iconBg: 'bg-amber-100',
    iconColor: 'text-amber-600',
  },
  red: {
    iconBg: 'bg-rose-100',
    iconColor: 'text-rose-600',
  },
  indigo: {
    iconBg: 'bg-indigo-100',
    iconColor: 'text-indigo-600',
  },
}

export default function StatCard({ title, value, icon: Icon, trend, color = 'purple' }: StatCardProps) {
  const config = colorConfig[color]

  return (
    <div 
      className="
        group relative bg-white rounded-3xl p-5 sm:p-6
        shadow-sm hover:shadow-md
        transition-all duration-300 ease-out
        border border-gray-100/50
      "
    >
      <div className="flex items-start justify-between gap-3">
        <div className="space-y-2 min-w-0 flex-1">
          <p className="text-xs sm:text-sm font-medium text-gray-400 truncate">
            {title}
          </p>
          <p className="text-2xl sm:text-3xl font-semibold text-gray-800 tracking-tight break-words">
            {value}
          </p>
          {trend && (
            <div className={`
              inline-flex items-center gap-1.5 text-xs font-medium
              ${trend.isPositive ? 'text-emerald-500' : 'text-rose-500'}
            `}>
              <svg 
                className={`w-3 h-3 flex-shrink-0 ${!trend.isPositive && 'rotate-180'}`} 
                fill="none" 
                viewBox="0 0 24 24" 
                stroke="currentColor"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 15l7-7 7 7" />
              </svg>
              {Math.abs(trend.value)}%
              <span className="text-gray-300 font-normal ml-1 hidden sm:inline">vs dernier mois</span>
            </div>
          )}
        </div>
        
        {/* Icon container - Soft rounded */}
        <div className={`
          flex items-center justify-center w-11 h-11 sm:w-12 sm:h-12 rounded-2xl flex-shrink-0
          ${config.iconBg}
          transition-all duration-300
          group-hover:scale-105
        `}>
          <Icon size={20} className={`sm:w-[22px] sm:h-[22px] ${config.iconColor}`} />
        </div>
      </div>
    </div>
  )
}
