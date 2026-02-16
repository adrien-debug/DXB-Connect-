'use client'

import { useEffect, useState } from 'react'

interface Plan {
  id: string
  name: string
  price: number
  features: string[]
}

export default function Home() {
  const [plans, setPlans] = useState<Plan[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('http://localhost:3001/api/plans')
      .then(res => res.json())
      .then(data => {
        setPlans(data.data)
        setLoading(false)
      })
      .catch(err => {
        console.error('Error fetching plans:', err)
        setLoading(false)
      })
  }, [])

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-center">DXB Connect</h1>
        
        <div className="mb-8 p-4 bg-blue-100 dark:bg-blue-900 rounded-lg">
          <h2 className="text-xl font-semibold mb-2">Bienvenue sur DXB Connect</h2>
          <p>Plateforme de gestion et de connexion</p>
        </div>

        <h2 className="text-2xl font-bold mb-4">Plans disponibles</h2>
        
        {loading ? (
          <p>Chargement...</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {plans.map(plan => (
              <div key={plan.id} className="border rounded-lg p-6 shadow-lg">
                <h3 className="text-xl font-bold mb-2">{plan.name}</h3>
                <p className="text-3xl font-bold mb-4">${plan.price}</p>
                <ul className="space-y-2">
                  {plan.features.map((feature, idx) => (
                    <li key={idx} className="flex items-center">
                      <span className="mr-2">✓</span>
                      {feature}
                    </li>
                  ))}
                </ul>
                <button className="mt-4 w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700">
                  Choisir ce plan
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  )
}
