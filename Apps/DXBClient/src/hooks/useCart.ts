'use client'

import { CartItem, supabaseAny as supabase } from '@/lib/supabase'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { useAuth } from './useAuth'

export function useCart() {
  const { user } = useAuth()

  return useQuery({
    queryKey: ['cart', user?.id],
    queryFn: async () => {
      if (!user?.id) return []

      const { data, error } = await supabase
        .from('cart_items')
        .select('*, product:products(*, supplier:suppliers(*))')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as CartItem[]
    },
    enabled: !!user?.id,
  })
}

export function useCartTotal() {
  const { data: cartItems } = useCart()

  const itemCount = cartItems?.reduce((sum, item) => sum + item.quantity, 0) || 0
  const total = cartItems?.reduce((sum, item) => {
    const price = item.product?.price || 0
    return sum + (price * item.quantity)
  }, 0) || 0

  return { itemCount, total, cartItems }
}

export function useAddToCart() {
  const queryClient = useQueryClient()
  const { user } = useAuth()

  return useMutation({
    mutationFn: async ({ productId, quantity = 1 }: { productId: string; quantity?: number }) => {
      if (!user?.id) throw new Error('Non authentifié')

      // Vérifier si le produit est déjà dans le panier
      const { data: existing } = await supabase
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .single()

      if (existing) {
        // Mettre à jour la quantité
        const { error } = await supabase
          .from('cart_items')
          .update({
            quantity: existing.quantity + quantity,
            updated_at: new Date().toISOString()
          })
          .eq('id', existing.id)

        if (error) throw error
      } else {
        // Créer un nouvel item
        const { error } = await supabase
          .from('cart_items')
          .insert([{
            user_id: user.id,
            product_id: productId,
            quantity
          }])

        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
      toast.success('Ajouté au panier')
    },
    onError: (error) => {
      console.error('Error adding to cart:', error)
      toast.error('Erreur lors de l\'ajout au panier')
    },
  })
}

export function useUpdateCartItem() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, quantity }: { id: string; quantity: number }) => {
      if (quantity <= 0) {
        const { error } = await supabase.from('cart_items').delete().eq('id', id)
        if (error) throw error
      } else {
        const { error } = await supabase
          .from('cart_items')
          .update({ quantity, updated_at: new Date().toISOString() })
          .eq('id', id)

        if (error) throw error
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
    onError: (error) => {
      console.error('Error updating cart:', error)
      toast.error('Erreur lors de la mise à jour')
    },
  })
}

export function useRemoveFromCart() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('cart_items').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
      toast.success('Retiré du panier')
    },
    onError: (error) => {
      console.error('Error removing from cart:', error)
      toast.error('Erreur lors de la suppression')
    },
  })
}

export function useClearCart() {
  const queryClient = useQueryClient()
  const { user } = useAuth()

  return useMutation({
    mutationFn: async () => {
      if (!user?.id) throw new Error('Non authentifié')

      const { error } = await supabase
        .from('cart_items')
        .delete()
        .eq('user_id', user.id)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
      toast.success('Panier vidé')
    },
    onError: (error) => {
      console.error('Error clearing cart:', error)
      toast.error('Erreur lors du vidage du panier')
    },
  })
}
