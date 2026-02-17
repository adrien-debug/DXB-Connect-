'use client'

import { useState } from 'react'
import { 
  X, CreditCard, Smartphone, ShoppingBag, Check, Loader2, 
  Shield, Lock, ChevronRight, AlertCircle
} from 'lucide-react'
import { useCreateOrder, useUpdateOrderPayment } from '@/hooks/useOrders'
import { useClearCart } from '@/hooks/useCart'
import { toast } from 'sonner'

// Payment method icons (inline SVGs for Apple Pay, Google Pay, PayPal)
const ApplePayIcon = () => (
  <svg viewBox="0 0 24 24" className="w-8 h-5" fill="currentColor">
    <path d="M17.72 8.2c-.11.08-2.07 1.19-2.07 3.64 0 2.84 2.5 3.84 2.57 3.87-.01.05-.4 1.36-1.31 2.69-.82 1.17-1.67 2.34-3.01 2.34-1.31 0-1.74-.77-3.24-.77-1.47 0-1.99.79-3.2.79-1.21 0-2.04-1.08-3-2.42-1.14-1.57-2.05-4.03-2.05-6.34 0-3.72 2.42-5.69 4.8-5.69 1.27 0 2.32.83 3.11.83.77 0 1.96-.88 3.42-.88.55 0 2.53.05 3.83 1.94zm-4.52-3.56c.59-.71 1.01-1.69 1.01-2.68 0-.14-.01-.28-.04-.39-.96.04-2.11.64-2.8 1.44-.54.62-1.05 1.6-1.05 2.6 0 .15.02.3.04.35.07.01.17.03.28.03.87 0 1.95-.58 2.56-1.35z"/>
  </svg>
)

const GooglePayIcon = () => (
  <svg viewBox="0 0 24 24" className="w-8 h-5">
    <path fill="#4285F4" d="M12.24 10.28v2.7h3.84a3.3 3.3 0 01-1.43 2.16l2.31 1.79c1.35-1.24 2.13-3.07 2.13-5.24 0-.51-.04-1-.13-1.46h-6.72v.05z"/>
    <path fill="#34A853" d="M5.88 13.19l-.52.4-1.84 1.43A8.99 8.99 0 0012 20a8.59 8.59 0 005.96-2.18l-2.31-1.79a5.36 5.36 0 01-8-2.81l-.77-.03z"/>
    <path fill="#FBBC05" d="M3.52 7.98A8.89 8.89 0 003 12c0 1.45.35 2.82.97 4.02l2.36-1.83a5.33 5.33 0 010-4.38L3.52 7.98z"/>
    <path fill="#EA4335" d="M12 6.58c1.32 0 2.5.45 3.44 1.35l2.58-2.58A8.65 8.65 0 0012 3a8.99 8.99 0 00-8.48 5.98l2.81 2.18A5.36 5.36 0 0112 6.58z"/>
  </svg>
)

const PayPalIcon = () => (
  <svg viewBox="0 0 24 24" className="w-8 h-5">
    <path fill="#003087" d="M7.076 21.337H2.47a.641.641 0 01-.633-.74L4.944 3.72a.641.641 0 01.633-.54h6.13c2.044 0 3.564.5 4.52 1.485.892.92 1.18 2.158.857 3.685l-.013.07c-.414 2.63-2.067 4.22-4.922 4.73-.43.08-.884.12-1.352.12H8.8l-.714 4.538a.641.641 0 01-.633.54h-.377v2.989z"/>
    <path fill="#0070E0" d="M19.106 8.148c-.414 2.63-2.067 4.22-4.922 4.73-.43.08-.884.12-1.352.12h-1.997l-.714 4.538a.641.641 0 01-.633.54H7.076v2.261h2.78c.31 0 .578-.224.626-.531l.546-3.462h1.855c3.398 0 5.554-2.134 6.16-5.35.234-1.237.11-2.27-.41-3.073a3.63 3.63 0 00-.527-.773z"/>
  </svg>
)

interface PaymentItem {
  product_id: string | null
  product_name: string
  product_sku?: string
  quantity: number
  unit_price: number
  image_url?: string
}

interface PaymentModalProps {
  isOpen: boolean
  onClose: () => void
  items: PaymentItem[]
  onSuccess?: (orderId: string) => void
  type?: 'cart' | 'esim'
}

type PaymentMethod = 'card' | 'apple_pay' | 'google_pay' | 'paypal'

export default function PaymentModal({ 
  isOpen, 
  onClose, 
  items,
  onSuccess,
  type = 'cart'
}: PaymentModalProps) {
  const [step, setStep] = useState<'review' | 'payment' | 'processing' | 'success'>('review')
  const [selectedMethod, setSelectedMethod] = useState<PaymentMethod>('card')
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')
  const [cardNumber, setCardNumber] = useState('')
  const [cardExpiry, setCardExpiry] = useState('')
  const [cardCvc, setCardCvc] = useState('')
  const [error, setError] = useState<string | null>(null)

  const createOrder = useCreateOrder()
  const updatePayment = useUpdateOrderPayment()
  const clearCart = useClearCart()

  // Calculate totals
  const subtotal = items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0)
  const tax = subtotal * 0.05 // 5% VAT
  const total = subtotal + tax

  const formatPrice = (amount: number) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount)
  }

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '')
    const matches = v.match(/\d{4,16}/g)
    const match = (matches && matches[0]) || ''
    const parts = []
    for (let i = 0, len = match.length; i < len; i += 4) {
      parts.push(match.substring(i, i + 4))
    }
    return parts.length ? parts.join(' ') : value
  }

  const formatExpiry = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '')
    if (v.length >= 2) {
      return v.substring(0, 2) + '/' + v.substring(2, 4)
    }
    return v
  }

  const handlePayment = async () => {
    setError(null)

    // Validation
    if (!email || !name) {
      setError('Veuillez remplir tous les champs obligatoires')
      return
    }

    if (selectedMethod === 'card') {
      if (!cardNumber || !cardExpiry || !cardCvc) {
        setError('Veuillez remplir les informations de carte')
        return
      }
      if (cardNumber.replace(/\s/g, '').length < 16) {
        setError('Numéro de carte invalide')
        return
      }
    }

    setStep('processing')

    try {
      // Map payment method
      const paymentMethod = selectedMethod === 'card' ? 'stripe' : selectedMethod

      // Create order
      const order = await createOrder.mutateAsync({
        items: items.map(item => ({
          product_id: item.product_id,
          product_name: item.product_name,
          product_sku: item.product_sku,
          quantity: item.quantity,
          unit_price: item.unit_price
        })),
        payment_method: paymentMethod as 'stripe' | 'apple_pay' | 'google_pay' | 'paypal',
        customer_email: email,
        customer_name: name,
        metadata: { type }
      })

      // Simulate payment processing (in production, this would call Stripe/PayPal API)
      await new Promise(resolve => setTimeout(resolve, 2000))

      // Update order as paid
      await updatePayment.mutateAsync({
        orderId: order.id,
        payment_status: 'paid',
        status: 'processing',
        payment_intent_id: `pi_simulated_${Date.now()}`
      })

      // Clear cart if it's a cart order
      if (type === 'cart') {
        await clearCart.mutateAsync()
      }

      setStep('success')
      toast.success('Paiement effectué avec succès!')

      // Callback
      if (onSuccess) {
        onSuccess(order.id)
      }
    } catch (err) {
      console.error('Payment error:', err)
      setError('Erreur lors du paiement. Veuillez réessayer.')
      setStep('payment')
    }
  }

  const handleClose = () => {
    setStep('review')
    setError(null)
    setSelectedMethod('card')
    setEmail('')
    setName('')
    setCardNumber('')
    setCardExpiry('')
    setCardCvc('')
    onClose()
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-gray-900/30 backdrop-blur-sm animate-fade-in"
        onClick={step !== 'processing' ? handleClose : undefined}
      />

      {/* Modal */}
      <div className="relative w-full max-w-lg bg-white rounded-3xl shadow-xl overflow-hidden animate-scale-in border border-gray-100/50">
        {/* Header */}
        <div className="p-6 border-b border-gray-100">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-sky-100 flex items-center justify-center">
                <ShoppingBag className="w-5 h-5 text-sky-600" />
              </div>
              <div>
                <h2 className="text-base font-semibold text-gray-800">
                  {step === 'success' ? 'Commande confirmée' : 'Paiement sécurisé'}
                </h2>
                <p className="text-sm text-gray-400">
                  {step === 'review' && `${items.length} article(s)`}
                  {step === 'payment' && 'Informations de paiement'}
                  {step === 'processing' && 'Traitement en cours...'}
                  {step === 'success' && 'Merci pour votre achat!'}
                </p>
              </div>
            </div>
            {step !== 'processing' && (
              <button
                onClick={handleClose}
                className="p-2 rounded-xl text-gray-400 hover:text-sky-600 hover:bg-sky-50 transition-all"
              >
                <X size={18} />
              </button>
            )}
          </div>

          {/* Steps indicator */}
          {step !== 'success' && step !== 'processing' && (
            <div className="flex items-center gap-2 mt-4">
              <div className={`flex-1 h-1 rounded-full ${step === 'review' ? 'bg-sky-500' : 'bg-sky-500'}`} />
              <div className={`flex-1 h-1 rounded-full ${step === 'payment' ? 'bg-sky-500' : 'bg-gray-100'}`} />
            </div>
          )}
        </div>

        {/* Content */}
        <div className="p-6 max-h-[60vh] overflow-y-auto">
          {/* Step 1: Review */}
          {step === 'review' && (
            <div className="space-y-4">
              {/* Items list */}
              <div className="space-y-3">
                {items.map((item, index) => (
                  <div key={index} className="flex items-center gap-3 p-3 bg-gray-50 rounded-2xl">
                    <div className="w-11 h-11 rounded-xl bg-gray-100 flex items-center justify-center flex-shrink-0">
                      {item.image_url ? (
                        <img src={item.image_url} alt={item.product_name} className="w-full h-full object-cover rounded-xl" />
                      ) : (
                        <ShoppingBag className="w-5 h-5 text-gray-300" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-800 text-sm truncate">{item.product_name}</p>
                      <p className="text-xs text-gray-400">Qté: {item.quantity}</p>
                    </div>
                    <span className="font-semibold text-gray-800 text-sm">
                      {formatPrice(item.unit_price * item.quantity)}
                    </span>
                  </div>
                ))}
              </div>

              {/* Totals */}
              <div className="border-t border-gray-100 pt-4 space-y-2">
                <div className="flex justify-between text-sm text-gray-500">
                  <span>Sous-total</span>
                  <span>{formatPrice(subtotal)}</span>
                </div>
                <div className="flex justify-between text-sm text-gray-500">
                  <span>TVA (5%)</span>
                  <span>{formatPrice(tax)}</span>
                </div>
                <div className="flex justify-between text-base font-semibold text-gray-800 pt-2 border-t border-gray-100">
                  <span>Total</span>
                  <span className="text-sky-600">{formatPrice(total)}</span>
                </div>
              </div>

              {/* Continue button */}
              <button
                onClick={() => setStep('payment')}
                className="w-full py-3.5 bg-gradient-to-r from-sky-600 to-sky-500 text-white font-medium rounded-2xl shadow-md shadow-sky-500/20 hover:shadow-lg hover:shadow-sky-500/25 hover:-translate-y-0.5 active:translate-y-0 transition-all flex items-center justify-center gap-2"
              >
                Continuer vers le paiement
                <ChevronRight size={16} />
              </button>
            </div>
          )}

          {/* Step 2: Payment */}
          {step === 'payment' && (
            <div className="space-y-5">
              {/* Error message */}
              {error && (
                <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-100 rounded-2xl text-red-600 text-sm">
                  <AlertCircle size={16} />
                  {error}
                </div>
              )}

              {/* Customer info */}
              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-600 mb-2">Email *</label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="votre@email.com"
                    className="w-full px-4 py-3 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 bg-gray-50 focus:bg-white transition-all"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-600 mb-2">Nom complet *</label>
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="John Doe"
                    className="w-full px-4 py-3 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 bg-gray-50 focus:bg-white transition-all"
                  />
                </div>
              </div>

              {/* Payment methods */}
              <div className="space-y-3">
                <label className="block text-sm font-medium text-gray-600">Mode de paiement</label>
                <div className="grid grid-cols-2 gap-3">
                  {/* Card */}
                  <button
                    onClick={() => setSelectedMethod('card')}
                    className={`p-4 rounded-2xl border transition-all flex flex-col items-center gap-2 ${
                      selectedMethod === 'card'
                        ? 'border-sky-300 bg-sky-50'
                        : 'border-gray-100 hover:border-gray-200 bg-gray-50'
                    }`}
                  >
                    <CreditCard className={`w-5 h-5 ${selectedMethod === 'card' ? 'text-sky-600' : 'text-gray-400'}`} />
                    <span className={`text-xs font-medium ${selectedMethod === 'card' ? 'text-sky-600' : 'text-gray-500'}`}>
                      Carte bancaire
                    </span>
                  </button>

                  {/* Apple Pay */}
                  <button
                    onClick={() => setSelectedMethod('apple_pay')}
                    className={`p-4 rounded-2xl border transition-all flex flex-col items-center gap-2 ${
                      selectedMethod === 'apple_pay'
                        ? 'border-sky-300 bg-sky-50'
                        : 'border-gray-100 hover:border-gray-200 bg-gray-50'
                    }`}
                  >
                    <ApplePayIcon />
                    <span className={`text-xs font-medium ${selectedMethod === 'apple_pay' ? 'text-sky-600' : 'text-gray-500'}`}>
                      Apple Pay
                    </span>
                  </button>

                  {/* Google Pay */}
                  <button
                    onClick={() => setSelectedMethod('google_pay')}
                    className={`p-4 rounded-2xl border transition-all flex flex-col items-center gap-2 ${
                      selectedMethod === 'google_pay'
                        ? 'border-sky-300 bg-sky-50'
                        : 'border-gray-100 hover:border-gray-200 bg-gray-50'
                    }`}
                  >
                    <GooglePayIcon />
                    <span className={`text-xs font-medium ${selectedMethod === 'google_pay' ? 'text-sky-600' : 'text-gray-500'}`}>
                      Google Pay
                    </span>
                  </button>

                  {/* PayPal */}
                  <button
                    onClick={() => setSelectedMethod('paypal')}
                    className={`p-4 rounded-2xl border transition-all flex flex-col items-center gap-2 ${
                      selectedMethod === 'paypal'
                        ? 'border-sky-300 bg-sky-50'
                        : 'border-gray-100 hover:border-gray-200 bg-gray-50'
                    }`}
                  >
                    <PayPalIcon />
                    <span className={`text-xs font-medium ${selectedMethod === 'paypal' ? 'text-sky-600' : 'text-gray-500'}`}>
                      PayPal
                    </span>
                  </button>
                </div>
              </div>

              {/* Card details (only shown for card payment) */}
              {selectedMethod === 'card' && (
                <div className="space-y-3 p-4 bg-gray-50 rounded-2xl">
                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-2">Numéro de carte</label>
                    <input
                      type="text"
                      value={cardNumber}
                      onChange={(e) => setCardNumber(formatCardNumber(e.target.value))}
                      placeholder="1234 5678 9012 3456"
                      maxLength={19}
                      className="w-full px-4 py-3 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 bg-white"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-600 mb-2">Expiration</label>
                      <input
                        type="text"
                        value={cardExpiry}
                        onChange={(e) => setCardExpiry(formatExpiry(e.target.value))}
                        placeholder="MM/YY"
                        maxLength={5}
                        className="w-full px-4 py-3 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 bg-white"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-600 mb-2">CVC</label>
                      <input
                        type="text"
                        value={cardCvc}
                        onChange={(e) => setCardCvc(e.target.value.replace(/\D/g, '').slice(0, 4))}
                        placeholder="123"
                        maxLength={4}
                        className="w-full px-4 py-3 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 bg-white"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* Apple Pay / Google Pay message */}
              {(selectedMethod === 'apple_pay' || selectedMethod === 'google_pay') && (
                <div className="p-4 bg-gray-50 rounded-2xl text-center">
                  <Smartphone className="w-7 h-7 text-gray-300 mx-auto mb-2" />
                  <p className="text-sm text-gray-500">
                    Vous serez redirigé vers {selectedMethod === 'apple_pay' ? 'Apple Pay' : 'Google Pay'} pour finaliser le paiement.
                  </p>
                </div>
              )}

              {/* PayPal message */}
              {selectedMethod === 'paypal' && (
                <div className="p-4 bg-gray-50 rounded-2xl text-center">
                  <PayPalIcon />
                  <p className="text-sm text-gray-500 mt-2">
                    Vous serez redirigé vers PayPal pour vous connecter et finaliser le paiement.
                  </p>
                </div>
              )}

              {/* Total and pay button */}
              <div className="border-t border-gray-100 pt-4">
                <div className="flex justify-between items-center mb-4">
                  <span className="text-gray-500">Total à payer</span>
                  <span className="text-xl font-semibold text-sky-600">{formatPrice(total)}</span>
                </div>

                <button
                  onClick={handlePayment}
                  className="w-full py-3.5 bg-gradient-to-r from-sky-600 to-sky-500 text-white font-medium rounded-2xl shadow-md shadow-sky-500/20 hover:shadow-lg hover:shadow-sky-500/25 hover:-translate-y-0.5 active:translate-y-0 transition-all flex items-center justify-center gap-2"
                >
                  <Lock size={16} />
                  Payer maintenant
                </button>

                {/* Security badge */}
                <div className="flex items-center justify-center gap-2 mt-4 text-xs text-gray-400">
                  <Shield size={12} />
                  Paiement 100% sécurisé par cryptage SSL
                </div>
              </div>
            </div>
          )}

          {/* Processing */}
          {step === 'processing' && (
            <div className="py-12 text-center">
              <div className="relative w-16 h-16 mx-auto mb-6">
                <div className="absolute inset-0 rounded-full bg-sky-500 animate-ping opacity-20" />
                <div className="relative w-16 h-16 rounded-full bg-gradient-to-br from-sky-500 to-sky-600 flex items-center justify-center">
                  <Loader2 className="w-8 h-8 text-white animate-spin" />
                </div>
              </div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Traitement du paiement</h3>
              <p className="text-gray-400 text-sm">Veuillez patienter, ne fermez pas cette fenêtre...</p>
            </div>
          )}

          {/* Success */}
          {step === 'success' && (
            <div className="py-8 text-center">
              <div className="w-16 h-16 mx-auto mb-6 rounded-full bg-emerald-100 flex items-center justify-center">
                <Check className="w-8 h-8 text-emerald-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-800 mb-2">Paiement réussi!</h3>
              <p className="text-gray-400 text-sm mb-6">
                Votre commande a été confirmée. Un email de confirmation vous a été envoyé.
              </p>
              <button
                onClick={handleClose}
                className="px-8 py-3 bg-gradient-to-r from-sky-600 to-sky-500 text-white font-medium rounded-2xl shadow-md shadow-sky-500/20 hover:shadow-lg hover:shadow-sky-500/25 hover:-translate-y-0.5 active:translate-y-0 transition-all"
              >
                Fermer
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
