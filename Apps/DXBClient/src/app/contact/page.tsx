'use client'

import { ChevronDown, Gift, Mail, MessageSquare, Send, Star } from 'lucide-react'
import { useState } from 'react'
import MarketingShell from '@/components/marketing/MarketingShell'

const faqs = [
  {
    question: 'What is an eSIM?',
    answer: 'An eSIM is a digital SIM embedded in your device. It lets you activate a mobile plan without a physical card, directly via a QR code.',
  },
  {
    question: 'Is my phone compatible?',
    answer: 'Most iPhones since XS/XR and many recent Android devices support eSIM. Check in Settings > Cellular Data.',
  },
  {
    question: 'How long does activation take?',
    answer: 'Activation typically takes 2-3 minutes. You receive a QR code immediately after purchase.',
  },
  {
    question: 'Can I top up my eSIM?',
    answer: 'Yes, you can buy a top-up anytime from the app. Data is credited instantly.',
  },
  {
    question: 'What are SimPass membership plans?',
    answer: 'SimPass offers 3 tiers: Privilege (-15%), Elite (-30%), and Black (-50%). Subscribe to save on every eSIM purchase and unlock exclusive travel perks.',
  },
  {
    question: 'How does the rewards program work?',
    answer: 'Every purchase, daily check-in, and mission earns you XP and points. Level up from Bronze to Platinum, enter raffles, and win real travel prizes.',
  },
  {
    question: 'What travel perks are included?',
    answer: 'All SimPass users get access to discounts on activities (GetYourGuide, Klook), airport lounges, travel insurance, hotel deals, and more.',
  },
]

export default function ContactPage() {
  const [openFaq, setOpenFaq] = useState<number | null>(0)

  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <MessageSquare className="w-3 h-3" />
                Contact & Support
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                How can we help?
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Check our FAQ for instant answers or reach out to our team directly.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-semibold text-black mb-6">Frequently asked questions</h2>
          <div className="space-y-3 max-w-3xl">
            {faqs.map((faq, idx) => {
              const isOpen = openFaq === idx
              return (
                <div key={idx} className="glass-card overflow-hidden">
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : idx)}
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
      </section>

      {/* Contact Form + Info */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-semibold text-black mb-6">Get in touch</h2>
          <div className="grid lg:grid-cols-5 gap-8">
            {/* Form */}
            <div className="lg:col-span-3 glass-card p-6 sm:p-8">
              <form className="space-y-5">
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Name</label>
                    <input type="text" className="input-premium" placeholder="Your name" />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Email</label>
                    <input type="email" className="input-premium" placeholder="you@example.com" />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Subject</label>
                  <select className="select-premium">
                    <option value="">Select a subject</option>
                    <option value="support">Technical support</option>
                    <option value="sales">Sales inquiry</option>
                    <option value="partnership">Partnership</option>
                    <option value="perks">Perks & Rewards</option>
                    <option value="subscription">Subscription</option>
                    <option value="other">Other</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Message</label>
                  <textarea className="input-premium min-h-[120px]" placeholder="Describe your request..." />
                </div>

                <button type="submit" className="btn-premium">
                  <Send className="w-4 h-4" />
                  Send message
                </button>
              </form>
            </div>

            {/* Info */}
            <div className="lg:col-span-2 space-y-5">
              <div className="glass-card p-6">
                <div className="w-12 h-12 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center mb-4">
                  <Mail className="w-6 h-6 text-black" />
                </div>
                <h3 className="text-base font-semibold text-black">Email</h3>
                <a href="mailto:support@simpass.io" className="mt-2 inline-block text-sm text-gray hover:text-black transition-colors">
                  support@simpass.io
                </a>
              </div>

              <div className="glass-card p-6">
                <div className="w-12 h-12 rounded-2xl bg-blue-100 border border-blue-200 flex items-center justify-center mb-4">
                  <Gift className="w-6 h-6 text-blue-600" />
                </div>
                <h3 className="text-base font-semibold text-black">Perks & Rewards</h3>
                <p className="text-sm text-gray mt-2">
                  Questions about travel perks, membership plans, or the rewards program? We&apos;re here to help.
                </p>
              </div>

              <div className="glass-card p-6 border-lime-400/30 bg-lime-400/5">
                <div className="w-12 h-12 rounded-2xl bg-purple-100 border border-purple-200 flex items-center justify-center mb-4">
                  <Star className="w-6 h-6 text-purple-600" />
                </div>
                <h3 className="text-base font-semibold text-black">B2B Partners</h3>
                <p className="text-sm text-gray mt-2">
                  API integrations and business partnerships
                </p>
                <a href="mailto:partners@simpass.io" className="mt-3 inline-block text-sm text-black hover:underline">
                  partners@simpass.io
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
