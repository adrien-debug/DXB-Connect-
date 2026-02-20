'use client'

import Accordion from '@/components/ui/Accordion'
import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import { Search } from 'lucide-react'
import { useMemo, useState } from 'react'

const categories = [
  {
    title: 'eSIM Basics',
    faqs: [
      { question: 'What is an eSIM?', answer: 'An eSIM is a digital SIM embedded in your device. It lets you activate a mobile plan without a physical card, directly via a QR code.' },
      { question: 'Is my phone compatible?', answer: 'Most iPhones since XS/XR and many recent Android devices support eSIM. Check in Settings > Cellular Data to see if the eSIM option is available.' },
      { question: 'How long does activation take?', answer: 'Activation typically takes 2-3 minutes. You receive a QR code immediately after purchase, then scan it to activate.' },
      { question: 'Can I top up my eSIM?', answer: 'Yes, you can buy a top-up anytime from the app. Additional data is credited instantly.' },
      { question: 'Are calls and SMS included?', answer: 'Most plans are data-only. For calls, use apps like WhatsApp, FaceTime, or Skype over your data connection.' },
      { question: 'Does my eSIM expire?', answer: 'Yes, each plan has a validity period (e.g., 7, 14, or 30 days). You can check the expiration date in the app.' },
    ],
  },
  {
    title: 'Membership Plans',
    faqs: [
      { question: 'What are the membership plans?', answer: 'SimPass offers 3 tiers: Privilege (-15% off eSIMs, $9.99/mo), Elite (-30% off, $19.99/mo), and Black (-50% off, $39.99/mo). Each tier includes progressively more benefits.' },
      { question: 'Can I change or cancel my plan?', answer: 'Yes, you can upgrade, downgrade, or cancel your subscription anytime from the app. Changes take effect at the next billing cycle.' },
      { question: 'Do discounts apply automatically?', answer: 'Yes, your membership discount is applied automatically at checkout on every eSIM purchase.' },
      { question: "What's included in the Black plan?", answer: 'Black members get 50% off one eSIM per month, 30% off all others, VIP airport lounge access, premium transfer deals, and priority support.' },
    ],
  },
  {
    title: 'Travel Perks',
    faqs: [
      { question: 'What travel perks are included?', answer: 'All SimPass users get access to partner discounts: activities with GetYourGuide/Klook/Tiqets, airport lounges via LoungeBuddy, travel insurance with SafetyWing, and hotel deals.' },
      { question: 'How do I access partner discounts?', answer: 'Open the Perks tab in the SimPass app. Discounts are available based on your location and are applied via unique promo codes or deep links.' },
      { question: 'Are perks available in all countries?', answer: 'We have global perks (available everywhere) and local perks (specific to your destination). Coverage grows as we add new partners.' },
    ],
  },
  {
    title: 'Rewards Program',
    faqs: [
      { question: 'How does the rewards program work?', answer: 'Every action earns you XP and points: purchases (+100 XP), daily check-ins (+25 XP), referrals (+200 XP), and weekly missions. Level up from Bronze to Platinum.' },
      { question: 'What can I do with points?', answer: 'Points can be used to enter raffles for real travel prizes, including free eSIM data, flight vouchers, and exclusive experiences.' },
      { question: 'How do raffles work?', answer: 'Active raffles appear in the Rewards Hub. Use your raffle tickets (earned through purchases and missions) to enter. Winners are drawn automatically.' },
      { question: 'Does my XP level reset?', answer: 'No, XP is cumulative and never resets. Your level (Bronze, Silver, Gold, Platinum) is permanent and unlocks increasingly better perks.' },
    ],
  },
  {
    title: 'Payments',
    faqs: [
      { question: 'What payment methods are accepted?', answer: 'We accept Apple Pay, credit/debit cards (via Stripe), and cryptocurrency (USDC and USDT on multiple chains).' },
      { question: 'Is crypto payment safe?', answer: 'Yes, crypto payments are processed through Fireblocks, an institutional-grade platform. Your payment is confirmed on-chain before the eSIM is activated.' },
      { question: 'Can I get a refund?', answer: 'Refunds are available for unactivated eSIMs within 14 days of purchase. Contact support for assistance.' },
    ],
  },
]

export default function FAQContent() {
  const [search, setSearch] = useState('')

  const filtered = useMemo(() => {
    if (!search.trim()) return categories
    const q = search.toLowerCase()
    return categories
      .map((cat) => ({
        ...cat,
        faqs: cat.faqs.filter(
          (f) => f.question.toLowerCase().includes(q) || f.answer.toLowerCase().includes(q)
        ),
      }))
      .filter((cat) => cat.faqs.length > 0)
  }, [search])

  return (
    <section className="section-padding-md">
      <div className="mx-auto max-w-3xl px-4 sm:px-6">
        {/* Search */}
        <div className="relative mb-12">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-gray" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search questions..."
            className="input-premium pl-14 py-4 text-base"
          />
        </div>

        {/* Categories */}
        <div className="space-y-10">
          {filtered.length === 0 ? (
            <div className="text-center py-12">
              <div className="text-base font-semibold text-black">No results found</div>
              <div className="mt-2 text-sm text-gray">Try different keywords or browse all categories.</div>
              <button onClick={() => setSearch('')} className="btn-secondary mt-4 text-sm">
                Clear search
              </button>
            </div>
          ) : (
            filtered.map((cat, i) => (
              <AnimateOnScroll key={cat.title} delay={i * 0.05}>
                <h2 className="text-lg font-bold text-black mb-5 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
                    <span className="w-2 h-2 rounded-full bg-lime-400" />
                  </div>
                  {cat.title}
                </h2>
                <Accordion items={cat.faqs} defaultOpen={i === 0 && !search ? 0 : -1} />
              </AnimateOnScroll>
            ))
          )}
        </div>
      </div>
    </section>
  )
}
