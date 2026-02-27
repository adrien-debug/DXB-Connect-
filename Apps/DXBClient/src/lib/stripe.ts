import { loadStripe, Stripe as StripeJS } from '@stripe/stripe-js'
import Stripe from 'stripe'

// Server-side Stripe client
export const stripe = process.env.STRIPE_SECRET_KEY
  ? new Stripe(process.env.STRIPE_SECRET_KEY, {
    apiVersion: '2026-01-28.clover',
    typescript: true,
  })
  : null

// Client-side Stripe promise (lazy loaded)
let stripePromise: Promise<StripeJS | null> | null = null

export const getStripe = () => {
  if (!stripePromise) {
    const publishableKey = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
    if (publishableKey) {
      stripePromise = loadStripe(publishableKey)
    } else {
      stripePromise = Promise.resolve(null)
    }
  }
  return stripePromise
}

// Check if Stripe server-side is configured (publishable key is client-side only)
export const isStripeConfigured = () => {
  const key = process.env.STRIPE_SECRET_KEY
  return !!(key && key.startsWith('sk_') && key.length > 20)
}
