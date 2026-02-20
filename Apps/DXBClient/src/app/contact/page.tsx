'use client'

import { ChevronDown, Mail, MessageSquare, Send } from 'lucide-react'
import { useState } from 'react'
import MarketingShell from '@/components/marketing/MarketingShell'

const faqs = [
  {
    question: 'Qu\'est-ce qu\'une eSIM ?',
    answer: 'Une eSIM est une SIM numérique intégrée à votre appareil. Elle permet d\'activer un forfait mobile sans carte physique, directement via un QR code.',
  },
  {
    question: 'Mon téléphone est-il compatible ?',
    answer: 'La plupart des iPhones depuis le XS/XR et de nombreux Android récents supportent l\'eSIM. Vérifiez dans Réglages > Données cellulaires.',
  },
  {
    question: 'Combien de temps prend l\'activation ?',
    answer: 'L\'activation prend généralement 2-3 minutes. Vous recevez un QR code immédiatement après l\'achat.',
  },
  {
    question: 'Puis-je recharger ma eSIM ?',
    answer: 'Oui, vous pouvez acheter un top-up à tout moment via l\'application. Le volume est crédité instantanément.',
  },
  {
    question: 'Les appels et SMS sont-ils inclus ?',
    answer: 'La plupart de nos forfaits sont data-only. Pour les appels, utilisez WhatsApp, FaceTime ou Skype via votre connexion data.',
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
                Comment pouvons-nous vous aider ?
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Une question ? Consultez notre FAQ ou contactez-nous directement.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-semibold text-black mb-6">Questions fréquentes</h2>
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
          <h2 className="text-xl font-semibold text-black mb-6">Nous contacter</h2>
          <div className="grid lg:grid-cols-5 gap-8">
            {/* Form */}
            <div className="lg:col-span-3 glass-card p-6 sm:p-8">
              <form className="space-y-5">
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Nom</label>
                    <input type="text" className="input-premium" placeholder="Votre nom" />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Email</label>
                    <input type="email" className="input-premium" placeholder="vous@exemple.com" />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Sujet</label>
                  <select className="select-premium">
                    <option value="">Sélectionner un sujet</option>
                    <option value="support">Support technique</option>
                    <option value="sales">Question commerciale</option>
                    <option value="partnership">Partenariat</option>
                    <option value="other">Autre</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Message</label>
                  <textarea className="input-premium min-h-[120px]" placeholder="Décrivez votre demande..." />
                </div>

                <button type="submit" className="btn-premium">
                  <Send className="w-4 h-4" />
                  Envoyer
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
                <h3 className="text-base font-semibold text-black">Heures de réponse</h3>
                <p className="text-sm text-gray mt-2">
                  Lundi - Vendredi : 9h - 18h (CET)<br />
                  Réponse sous 24h ouvrées
                </p>
              </div>

              <div className="glass-card p-6 border-lime-400/30 bg-lime-400/5">
                <h3 className="text-base font-semibold text-black">Partenaires B2B</h3>
                <p className="text-sm text-gray mt-2">
                  Pour les intégrations API et partenariats
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
