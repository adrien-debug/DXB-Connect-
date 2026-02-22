'use client'

import { useEffect, useState, useCallback } from 'react'
import { Star, Target, Gift, TrendingUp, Flame, Trophy } from 'lucide-react'

const RAILWAY_API = process.env.NEXT_PUBLIC_RAILWAY_URL || 'https://api-github-production-a848.up.railway.app'

interface Mission {
  id: string
  type: string
  title: string
  description?: string
  xp_reward: number
  points_reward: number
  condition_value: number
  is_active: boolean
}

interface Raffle {
  id: string
  title: string
  prize_description: string
  draw_date: string
  is_active: boolean
  total_entries?: number
}

export default function RewardsPage() {
  const [missions, setMissions] = useState<Mission[]>([])
  const [raffles, setRaffles] = useState<Raffle[]>([])
  const [loading, setLoading] = useState(true)

  const loadData = useCallback(async () => {
    setLoading(true)
    try {
      const [missionsRes, rafflesRes] = await Promise.allSettled([
        fetch(`${RAILWAY_API}/api/rewards/missions`).then(r => r.json()),
        fetch(`${RAILWAY_API}/api/raffles/active`).then(r => r.json()),
      ])
      if (missionsRes.status === 'fulfilled') setMissions(missionsRes.value.data || [])
      if (rafflesRes.status === 'fulfilled') setRaffles(rafflesRes.value.data || [])
    } catch {
      console.error('Failed to load rewards data')
    }
    setLoading(false)
  }, [])

  useEffect(() => { loadData() }, [loadData])

  const activeMissions = missions.filter(m => m.is_active)
  const dailyMissions = activeMissions.filter(m => m.type === 'daily')
  const weeklyMissions = activeMissions.filter(m => m.type === 'weekly')

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-black">Rewards & Gamification</h1>
        <p className="text-sm text-gray mt-1">Missions, tirages au sort et fidélité</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatsCard icon={<Target size={20} />} label="Missions actives" value={activeMissions.length.toString()} color="bg-lime-400/20" />
        <StatsCard icon={<Flame size={20} />} label="Daily" value={dailyMissions.length.toString()} color="bg-orange-100" />
        <StatsCard icon={<Trophy size={20} />} label="Weekly" value={weeklyMissions.length.toString()} color="bg-blue-100" />
        <StatsCard icon={<Gift size={20} />} label="Raffles actifs" value={raffles.length.toString()} color="bg-purple-100" />
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-3 border-lime-400 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Missions */}
          <div className="bg-white border border-gray-light rounded-2xl p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-lg font-bold text-black flex items-center gap-2">
                <Target size={18} className="text-lime-500" />
                Missions
              </h2>
              <span className="text-xs font-semibold text-gray bg-gray-light px-2.5 py-1 rounded-lg">
                {activeMissions.length} actives
              </span>
            </div>

            <div className="space-y-3">
              {activeMissions.length === 0 ? (
                <p className="text-sm text-gray text-center py-8">Aucune mission active</p>
              ) : (
                activeMissions.map(mission => (
                  <div key={mission.id} className="flex items-center gap-4 p-4 bg-gray-light/50 rounded-xl">
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                      mission.type === 'daily' ? 'bg-orange-100' : 'bg-blue-100'
                    }`}>
                      {mission.type === 'daily' ? (
                        <Flame size={18} className="text-orange-500" />
                      ) : (
                        <Trophy size={18} className="text-blue-500" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-black">{mission.title}</p>
                      {mission.description && (
                        <p className="text-xs text-gray mt-0.5 truncate">{mission.description}</p>
                      )}
                      <div className="flex gap-3 mt-1.5">
                        <span className="text-xs font-bold text-lime-600">+{mission.xp_reward} XP</span>
                        {mission.points_reward > 0 && (
                          <span className="text-xs font-bold text-green-600">+{mission.points_reward} pts</span>
                        )}
                      </div>
                    </div>
                    <span className={`px-2 py-0.5 rounded-md text-[10px] font-bold uppercase ${
                      mission.type === 'daily' ? 'bg-orange-100 text-orange-600' : 'bg-blue-100 text-blue-600'
                    }`}>
                      {mission.type}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Raffles */}
          <div className="bg-white border border-gray-light rounded-2xl p-6">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-lg font-bold text-black flex items-center gap-2">
                <Gift size={18} className="text-purple-500" />
                Tirages au sort
              </h2>
              <span className="text-xs font-semibold text-gray bg-gray-light px-2.5 py-1 rounded-lg">
                {raffles.length} actifs
              </span>
            </div>

            <div className="space-y-3">
              {raffles.length === 0 ? (
                <div className="text-center py-8">
                  <Gift className="w-8 h-8 text-gray mx-auto mb-2" />
                  <p className="text-sm text-gray">Aucun tirage actif</p>
                  <p className="text-xs text-gray mt-1">Créez un raffle pour engager les utilisateurs</p>
                </div>
              ) : (
                raffles.map(raffle => (
                  <div key={raffle.id} className="p-4 bg-gray-light/50 rounded-xl">
                    <div className="flex items-start justify-between">
                      <div>
                        <p className="text-sm font-bold text-black">{raffle.title}</p>
                        <p className="text-xs text-gray mt-0.5">{raffle.prize_description}</p>
                      </div>
                      <Gift size={20} className="text-purple-400 flex-shrink-0" />
                    </div>
                    <div className="flex items-center gap-3 mt-3 text-xs text-gray">
                      <span>Tirage : {new Date(raffle.draw_date).toLocaleDateString('fr-FR')}</span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* XP System Overview */}
      <div className="bg-white border border-gray-light rounded-2xl p-6">
        <h2 className="text-lg font-bold text-black mb-4 flex items-center gap-2">
          <Star size={18} className="text-lime-500" />
          Système de points
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-4 bg-gray-light/50 rounded-xl">
            <p className="text-xs font-semibold text-gray uppercase">Achat eSIM</p>
            <p className="text-lg font-bold text-black mt-1">+100 XP, +50 pts, +1 ticket</p>
          </div>
          <div className="p-4 bg-gray-light/50 rounded-xl">
            <p className="text-xs font-semibold text-gray uppercase">Daily Check-in</p>
            <p className="text-lg font-bold text-black mt-1">+25 XP, +10 pts</p>
          </div>
          <div className="p-4 bg-gray-light/50 rounded-xl">
            <p className="text-xs font-semibold text-gray uppercase">Parrainage</p>
            <p className="text-lg font-bold text-black mt-1">+200 XP, +100 pts, +2 tickets</p>
          </div>
        </div>
      </div>
    </div>
  )
}

function StatsCard({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: string; color: string }) {
  return (
    <div className="bg-white border border-gray-light rounded-2xl p-5">
      <div className="flex items-center gap-3">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${color}`}>
          {icon}
        </div>
        <div>
          <p className="text-xs font-semibold text-gray uppercase tracking-wider">{label}</p>
          <p className="text-xl font-bold text-black">{value}</p>
        </div>
      </div>
    </div>
  )
}
