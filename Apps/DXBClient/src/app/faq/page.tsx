'use client'

import { ChevronDown, HelpCircle } from 'lucide-react'
import { useState } from 'react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const faqs = [
  {
    question: 'Qu\'est-ce qu\'une eSIM ?',
    answer: 'Une eSIM est une SIM numérique intégrée à votre appareil. Elle permet d\'activer un forfait mobile sans carte physique, directement via un QR code.',
  },
  {
    question: 'Mon téléphone est-il compatible ?',
    answer: 'La plupart des iPhones depuis le XS/XR et de nombreux Android récents supportent l\'eSIM. Vérifiez dans Réglages > Données cellulaires si l\'option eSIM est disponible.',
  },
  {
    question: 'Combien de temps prend l\'activation ?',
    answer: 'L\'activation prend généralement 2-3 minutes. Vous recevez un QR code immédiatement après l\'achat, puis vous le scannez pour activer la ligne.',
  },
  {
    question: 'Puis-je recharger ma eSIM ?',
    answer: 'Oui, vous pouvez acheter un top-up à tout moment via l\'application. Le volume supplémentaire est crédité instantanément.',
  },
  {
    question: 'Que se passe-t-il si j\'ai un problème ?',
    answer: 'Notre support répond sous 24h. Vous pouvez nous contacter via le formulaire de contact ou par email à support@simpass.io.',
  },
  {
    question: 'Les appels et SMS sont-ils inclus ?',
    answer: 'La plupart de nos forfaits sont data-only. Pour les appels, utilisez des apps comme WhatsApp, FaceTime ou Skype via votre connexion data.',
  },
  {
    question: 'Ma eSIM expire-t-elle ?',
    answer: 'Oui, chaque forfait a une durée de validité (ex: 7, 14 ou 30 jours). Vous pouvez voir la date d\'expiration dans l\'app ou via le QR code d\'origine.',
  },
]

export default function FAQPage() {
  const [openIndex, setOpenIndex] = useState<number | null>(0)

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
                Questions fréquentes
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Tout ce que vous devez savoir sur nos services eSIM.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ List */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <div className="space-y-3">
            {faqs.map((faq, idx) => {
              const isOpen = openIndex === idx
              return (
                <div 
                  key={idx} 
                  className="glass-card overflow-hidden"
                >
                  <button
                    onClick={() => setOpenIndex(isOpen ? null : idx)}
                    className="w-full flex items-center justify-between p-5 text-left"
                  >
                    <span className="text-sm font-semibold text-black pr-4">{faq.question}</span>
                    <ChevronDown 
                      className={`w-5 h-5 text-gray flex-shrink-0 transition-transform duration-300 ${isOpen ? 'rotate-180' : ''}`}
                    />
                  </button>
                  <div 
                    className={`overflow-hidden transition-all duration-300 ${isOpen ? 'max-h-96' : 'max-h-0'}`}
                  >
                    <div className="px-5 pb-5 text-sm text-gray leading-relaxed border-t border-gray-light pt-4">
                      {faq.answer}
                    </div>
                  </div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Vous n'avez pas trouvé la réponse ?"
            subtitle="Notre équipe est là pour vous aider."
            primaryHref="/contact"
            primaryLabel="Nous contacter"
            secondaryHref="/how-it-works"
            secondaryLabel="Comment ça marche"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
