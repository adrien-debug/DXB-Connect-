'use client'

import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import { ArrowRight, Check } from 'lucide-react'
import Link from 'next/link'
import { useState } from 'react'

const plans = [
  {
    name: 'Privilege',
    discount: 15,
    monthly: 9.99,
    yearly: 99,
    features: ['15% off all eSIMs', 'Global perks access', 'Daily rewards', 'Cancel anytime'],
    popular: false,
  },
  {
    name: 'Elite',
    discount: 30,
    monthly: 19.99,
    yearly: 199,
    features: ['30% off all eSIMs', 'Priority support', 'Monthly raffle entry', 'All Privilege perks'],
    popular: true,
  },
  {
    name: 'Black',
    discount: 50,
    monthly: 39.99,
    yearly: 399,
    features: ['50% off (1x/month)', '30% off remaining', 'VIP lounge access', 'Premium transfers', 'All Elite perks'],
    popular: false,
  },
]

export default function PricingPlans() {
  const [yearly, setYearly] = useState(false)

  return (
    <div>
      {/* Toggle */}
      <div className="flex items-center justify-center gap-4 mb-10">
        <span className={`text-sm font-semibold transition-colors ${!yearly ? 'text-black' : 'text-gray'}`}>Monthly</span>
        <button
          onClick={() => setYearly(!yearly)}
          className={`relative w-14 h-7 rounded-full transition-all ${yearly ? 'bg-lime-400 shadow-md shadow-lime-400/30' : 'bg-gray-200'}`}
        >
          <div className={`absolute top-1 w-5 h-5 rounded-full bg-white shadow-sm transition-transform ${yearly ? 'translate-x-8' : 'translate-x-1'}`} />
        </button>
        <span className={`text-sm font-semibold transition-colors ${yearly ? 'text-black' : 'text-gray'}`}>
          Yearly
          <span className="ml-2 px-2 py-0.5 rounded-full bg-lime-400/20 text-lime-700 text-[10px] font-bold">-17%</span>
        </span>
      </div>

      {/* Plans */}
      <div className="grid md:grid-cols-3 gap-6">
        {plans.map((plan, i) => (
          <AnimateOnScroll key={plan.name} delay={i * 0.1}>
            <div className={`relative p-7 hover-lift h-full flex flex-col ${plan.popular ? 'glow-card' : 'tech-card'}`}>
              {plan.popular && (
                <div className="absolute -top-3 right-5 px-4 py-1 bg-lime-400 text-black text-[10px] font-bold rounded-full tracking-wider shadow-lg shadow-lime-400/30">
                  MOST POPULAR
                </div>
              )}

              <div className="flex items-center justify-between mb-2">
                <h3 className="text-xl font-bold text-black">{plan.name}</h3>
                <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
                  <span className="text-sm font-bold text-lime-600">-{plan.discount}%</span>
                </div>
              </div>

              <div className="mb-6">
                <span className="text-3xl font-bold text-black">
                  ${yearly ? plan.yearly : plan.monthly.toFixed(2)}
                </span>
                <span className="text-sm text-gray ml-1">
                  {yearly ? '/year' : '/mo'}
                </span>
              </div>

              <ul className="space-y-3 mb-8 flex-1">
                {plan.features.map((f) => (
                  <li key={f} className="flex items-center gap-3 text-sm text-black">
                    <div className="w-5 h-5 rounded-full bg-lime-400/20 flex items-center justify-center flex-shrink-0">
                      <Check className="w-3 h-3 text-lime-600" />
                    </div>
                    {f}
                  </li>
                ))}
              </ul>

              <Link href="/login" className={`w-full text-sm py-3 ${plan.popular ? 'btn-premium' : 'btn-secondary'}`}>
                Subscribe <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </AnimateOnScroll>
        ))}
      </div>
    </div>
  )
}
