'use client'

import { useState } from 'react'
import { X, ShoppingCart, Plus, Minus, Trash2, ShoppingBag } from 'lucide-react'
import { useCart, useCartTotal, useUpdateCartItem, useRemoveFromCart, useClearCart } from '@/hooks/useCart'
import PaymentModal from './PaymentModal'

interface CartDrawerProps {
  isOpen: boolean
  onClose: () => void
}

export default function CartDrawer({ isOpen, onClose }: CartDrawerProps) {
  const [paymentOpen, setPaymentOpen] = useState(false)
  const { data: cartItems, isLoading } = useCart()
  const { itemCount, total } = useCartTotal()
  const updateItem = useUpdateCartItem()
  const removeItem = useRemoveFromCart()
  const clearCart = useClearCart()

  const paymentItems = cartItems?.map(item => ({
    product_id: item.product_id,
    product_name: item.product?.name || 'Produit',
    product_sku: item.product?.sku || undefined,
    quantity: item.quantity,
    unit_price: item.product?.price || 0,
    image_url: item.product?.image_url || undefined
  })) || []

  const handlePaymentSuccess = () => {
    setPaymentOpen(false)
    onClose()
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm animate-fade-in"
        onClick={onClose}
      />

      <div
        className="relative w-full max-w-md h-full bg-zinc-900 shadow-xl shadow-black/40 flex flex-col animate-slide-in-right border-l border-zinc-800"
        style={{ animationDuration: '0.3s' }}
      >
        {/* Header */}
        <div className="p-5 border-b border-zinc-800">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-lime-400/10 flex items-center justify-center">
                <ShoppingCart className="w-5 h-5 text-lime-400" />
              </div>
              <div>
                <h2 className="text-base font-semibold text-white">Mon Panier</h2>
                <p className="text-sm text-zinc-500">{itemCount} article(s)</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-xl text-zinc-500 hover:text-lime-400 hover:bg-lime-400/10 transition-all"
            >
              <X size={18} />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 bg-zinc-950/50">
          {isLoading ? (
            <div className="flex items-center justify-center h-40">
              <div className="w-8 h-8 rounded-full border-2 border-lime-400 border-t-transparent animate-spin" />
            </div>
          ) : !cartItems?.length ? (
            <div className="flex flex-col items-center justify-center h-full text-center">
              <div className="w-16 h-16 rounded-2xl bg-zinc-800 flex items-center justify-center mb-4">
                <ShoppingBag className="w-8 h-8 text-zinc-600" />
              </div>
              <p className="text-zinc-400 font-medium text-sm">Votre panier est vide</p>
              <p className="text-xs text-zinc-600 mt-1">Ajoutez des produits pour commencer</p>
            </div>
          ) : (
            <div className="space-y-3">
              {cartItems.map((item, index) => (
                <div
                  key={item.id}
                  className="bg-zinc-900 rounded-2xl p-4 border border-zinc-800 animate-fade-in-up"
                  style={{ animationDelay: `${index * 0.03}s`, animationFillMode: 'backwards' }}
                >
                  <div className="flex gap-4">
                    <div className="w-14 h-14 rounded-xl bg-zinc-800 flex items-center justify-center flex-shrink-0">
                      {item.product?.image_url ? (
                        <img
                          src={item.product.image_url}
                          alt={item.product.name}
                          className="w-full h-full object-cover rounded-xl"
                        />
                      ) : (
                        <ShoppingBag className="w-5 h-5 text-zinc-600" />
                      )}
                    </div>

                    <div className="flex-1 min-w-0">
                      <h3 className="font-medium text-white text-sm truncate">
                        {item.product?.name || 'Produit'}
                      </h3>
                      {item.product?.supplier?.name && (
                        <p className="text-xs text-zinc-500 truncate">
                          {item.product.supplier.name}
                        </p>
                      )}
                      <p className="text-sm font-semibold text-lime-400 mt-1">
                        {item.product?.price?.toFixed(2) || 0} €
                      </p>
                    </div>

                    <div className="flex flex-col items-end justify-between">
                      <button
                        onClick={() => removeItem.mutate(item.id)}
                        className="p-1.5 rounded-lg text-zinc-500 hover:text-rose-400 hover:bg-rose-500/10 transition-all"
                      >
                        <Trash2 size={14} />
                      </button>

                      <div className="flex items-center gap-1.5 bg-zinc-800 rounded-xl p-1">
                        <button
                          onClick={() => updateItem.mutate({ id: item.id, quantity: item.quantity - 1 })}
                          className="w-6 h-6 rounded-lg bg-zinc-700 flex items-center justify-center hover:bg-zinc-600 transition-all text-zinc-300"
                        >
                          <Minus size={12} />
                        </button>
                        <span className="w-6 text-center text-sm font-medium text-white">{item.quantity}</span>
                        <button
                          onClick={() => updateItem.mutate({ id: item.id, quantity: item.quantity + 1 })}
                          className="w-6 h-6 rounded-lg bg-zinc-700 flex items-center justify-center hover:bg-zinc-600 transition-all text-zinc-300"
                        >
                          <Plus size={12} />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        {cartItems && cartItems.length > 0 && (
          <div className="p-5 border-t border-zinc-800 space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Total</span>
              <span className="text-xl font-semibold text-white">{total.toFixed(2)} €</span>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => clearCart.mutate()}
                className="flex-1 py-3 px-4 border border-zinc-700 rounded-2xl text-zinc-400 font-medium hover:bg-zinc-800 transition-all"
              >
                Vider
              </button>
              <button
                onClick={() => setPaymentOpen(true)}
                className="
                  flex-[2] py-3 px-4
                  bg-lime-400 hover:bg-lime-300
                  text-zinc-950 font-semibold rounded-xl
                  shadow-md shadow-lime-400/20 hover:shadow-lg hover:shadow-lime-400/30
                  transition-all duration-200
                "
              >
                Commander
              </button>
            </div>
          </div>
        )}
      </div>

      <PaymentModal
        isOpen={paymentOpen}
        onClose={() => setPaymentOpen(false)}
        items={paymentItems}
        onSuccess={handlePaymentSuccess}
        type="cart"
      />
    </div>
  )
}
