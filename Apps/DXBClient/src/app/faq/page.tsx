'use client'

import { ChevronDown, HelpCircle } from 'lucide-react'
import { useState } from 'react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const categories = [
  {
    title: 'eSIM Basics',
    faqs: [
      {
        question: 'What is an eSIM?',
        answer: 'An eSIM is a digital SIM embedded in your device. It lets you activate a mobile plan without a physical card, directly via a QR code.',
      },
      {
        question: 'Is my phone compatible?',
        answer: 'Most iPhones since XS/XR and many recent Android devices support eSIM. Check in Settings > Cellular Data to see if the eSIM option is available.',
      },
      {
        question: 'How long does activation take?',
        answer: 'Activation typically takes 2-3 minutes. You receive a QR code immediately after purchase, then scan it to activate.',
      },
      {
        question: 'Can I top up my eSIM?',
        answer: 'Yes, you can buy a top-up anytime from the app. Additional data is credited instantly.',
      },
      {
        question: 'Are calls and SMS included?',
        answer: 'Most plans are data-only. For calls, use apps like WhatsApp, FaceTime, or Skype over your data connection.',
      },
      {
        question: 'Does my eSIM expire?',
        answer: 'Yes, each plan has a validity period (e.g., 7, 14, or 30 days). You can check the expiration date in the app.',
      },
    ],
  },
  {
    title: 'Membership Plans',
    faqs: [
      {
        question: 'What are the membership plans?',
        answer: 'SimPass offers 3 tiers: Privilege (-15% off eSIMs, $9.99/mo), Elite (-30% off, $19.99/mo), and Black (-50% off, $39.99/mo). Each tier includes progressively more benefits.',
      },
      {
        question: 'Can I change or cancel my plan?',
        answer: 'Yes, you can upgrade, downgrade, or cancel your subscription anytime from the app. Changes take effect at the next billing cycle.',
      },
      {
        question: 'Do discounts apply automatically?',
        answer: 'Yes, your membership discount is applied automatically at checkout on every eSIM purchase.',
      },
      {
        question: 'What\'s included in the Black plan?',
        answer: 'Black members get 50% off one eSIM per month, 30% off all others, VIP airport lounge access, premium transfer deals, and priority support.',
      },
    ],
  },
  {
    title: 'Travel Perks',
    faqs: [
      {
        question: 'What travel perks are included?',
        answer: 'All SimPass users get access to partner discounts: activities with GetYourGuide/Klook/Tiqets, airport lounges via LoungeBuddy, travel insurance with SafetyWing, and hotel deals.',
      },
      {
        question: 'How do I access partner discounts?',
        answer: 'Open the Perks tab in the SimPass app. Discounts are available based on your location and are applied via unique promo codes or deep links.',
      },
      {
        question: 'Are perks available in all countries?',
        answer: 'We have global perks (available everywhere) and local perks (specific to your destination). Coverage grows as we add new partners.',
      },
    ],
  },
  {
    title: 'Rewards Program',
    faqs: [
      {
        question: 'How does the rewards program work?',
        answer: 'Every action earns you XP and points: purchases (+100 XP), daily check-ins (+25 XP), referrals (+200 XP), and weekly missions. Level up from Bronze to Platinum.',
      },
      {
        question: 'What can I do with points?',
        answer: 'Points can be used to enter raffles for real travel prizes, including free eSIM data, flight vouchers, and exclusive experiences.',
      },
      {
        question: 'How do raffles work?',
        answer: 'Active raffles appear in the Rewards Hub. Use your raffle tickets (earned through purchases and missions) to enter. Winners are drawn automatically.',
      },
      {
        question: 'Does my XP level reset?',
        answer: 'No, XP is cumulative and never resets. Your level (Bronze, Silver, Gold, Platinum) is permanent and unlocks increasingly better perks.',
      },
    ],
  },
  {
    title: 'Payments',
    faqs: [
      {
        question: 'What payment methods are accepted?',
        answer: 'We accept Apple Pay, credit/debit cards (via Stripe), and cryptocurrency (USDC and USDT on multiple chains).',
      },
      {
        question: 'Is crypto payment safe?',
        answer: 'Yes, crypto payments are processed through Fireblocks, an institutional-grade platform. Your payment is confirmed on-chain before the eSIM is activated.',
      },
      {
        question: 'Can I get a refund?',
        answer: 'Refunds are available for unactivated eSIMs within 14 days of purchase. Contact support for assistance.',
      },
    ],
  },
]

export default function FAQPage() {
  const [openItems, setOpenItems] = useState<Record<string, number | null>>({ 'eSIM Basics': 0 })

  const toggleItem = (category: string, idx: number) => {
    setOpenItems((prev) => ({
      ...prev,
      [category]: prev[category] === idx ? null : idx,
    }))
  }

  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <HelpCircle className="w-3 h-3" />
                FAQ
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                Frequently asked questions
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Everything you need to know about SimPass, plans, perks, and rewards.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ by category */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6 space-y-10">
          {categories.map((cat) => (
            <div key={cat.title}>
              <h2 className="text-lg font-bold text-black mb-4 flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-lime-400" />
                {cat.title}
              </h2>
              <div className="space-y-3">
                {cat.faqs.map((faq, idx) => {
                  const isOpen = openItems[cat.title] === idx
                  return (
                    <div key={idx} className="glass-card overflow-hidden">
                      <button
                        onClick={() => toggleItem(cat.title, idx)}
                        className="w-full flex items-center justify-between p-5 text-left"
                      >
                        <span className="text-sm font-semibold text-black pr-4">{faq.question}</span>
                        <ChevronDown
                          className={`w-5 h-5 text-gray flex-shrink-0 transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`}
                        />
                      </button>
                      <div className={`overflow-hidden transition-all duration-300 ${isOpen ? 'max-h-96' : 'max-h-0'}`}>
                        <div className="px-5 pb-5 text-sm text-gray leading-relaxed border-t border-gray-light pt-4">
                          {faq.answer}
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>
          ))}

          <CTASection
            title="Still have questions?"
            subtitle="Our team is here to help."
            primaryHref="/contact"
            primaryLabel="Contact us"
            secondaryHref="/how-it-works"
            secondaryLabel="How it works"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
