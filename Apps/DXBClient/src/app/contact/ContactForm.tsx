'use client'

import { CheckCircle, Loader2, Send } from 'lucide-react'
import { useState } from 'react'

type FormState = 'idle' | 'loading' | 'success' | 'error'

export default function ContactForm() {
  const [state, setState] = useState<FormState>('idle')
  const [errorMsg, setErrorMsg] = useState('')

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setState('loading')
    setErrorMsg('')

    const form = e.currentTarget
    const data = new FormData(form)
    const name = data.get('name') as string
    const email = data.get('email') as string
    const subject = data.get('subject') as string
    const message = data.get('message') as string

    if (!name || !email || !subject || !message) {
      setState('error')
      setErrorMsg('Please fill in all fields.')
      return
    }

    try {
      // Simulate sending — replace with real API call via Railway
      await new Promise((resolve) => setTimeout(resolve, 1500))
      setState('success')
      form.reset()
    } catch {
      setState('error')
      setErrorMsg('Something went wrong. Please try again.')
    }
  }

  if (state === 'success') {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <div className="w-16 h-16 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center mb-4">
          <CheckCircle className="w-8 h-8 text-lime-600" />
        </div>
        <h3 className="text-lg font-bold text-black">Message sent!</h3>
        <p className="mt-2 text-sm text-gray max-w-sm">
          We&apos;ll get back to you within 24 hours. Check your email for a confirmation.
        </p>
        <button onClick={() => setState('idle')} className="btn-secondary mt-6 text-sm">
          Send another message
        </button>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Name</label>
          <input name="name" type="text" className="input-premium" placeholder="Your name" required />
        </div>
        <div>
          <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Email</label>
          <input name="email" type="email" className="input-premium" placeholder="you@example.com" required />
        </div>
      </div>

      <div>
        <label className="block text-xs font-semibold text-gray uppercase tracking-wide mb-2">Subject</label>
        <select name="subject" className="select-premium" required>
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
        <textarea name="message" className="input-premium min-h-[120px]" placeholder="Describe your request..." required />
      </div>

      {state === 'error' && errorMsg && (
        <div className="p-3 rounded-xl bg-red-50 border border-red-200 text-sm text-red-600">
          {errorMsg}
        </div>
      )}

      <button type="submit" className="btn-premium" disabled={state === 'loading'}>
        {state === 'loading' ? (
          <>
            <Loader2 className="w-4 h-4 animate-spin" />
            Sending...
          </>
        ) : (
          <>
            <Send className="w-4 h-4" />
            Send message
          </>
        )}
      </button>
    </form>
  )
}
