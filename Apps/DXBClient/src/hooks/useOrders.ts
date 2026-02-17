'use client'

import { supabaseAny as supabase } from '@/lib/supabase'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { useAuth } from './useAuth'

export interface OrderItem {
  id: string
  order_id: string
  product_id: string | null
  product_name: string
  product_sku: string | null
  quantity: number
  unit_price: number
  total_price: number
  metadata: Record<string, unknown> | null
  created_at: string
}

export interface Order {
  id: string
  user_id: string
  order_number: string
  status: 'pending' | 'processing' | 'completed' | 'cancelled' | 'refunded'
  payment_method: 'stripe' | 'apple_pay' | 'google_pay' | 'paypal' | null
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
  payment_intent_id: string | null
  subtotal: number
  tax: number
  total: number
  currency: string
  customer_email: string | null
  customer_name: string | null
  billing_address: Record<string, unknown> | null
  shipping_address: Record<string, unknown> | null
  notes: string | null
  metadata: Record<string, unknown> | null
  created_at: string
  updated_at: string
  items?: OrderItem[]
}

// Generate unique order number
function generateOrderNumber(): string {
  const timestamp = Date.now().toString(36).toUpperCase()
  const random = Math.random().toString(36).substring(2, 6).toUpperCase()
  return `DXB-${timestamp}-${random}`
}

export function useOrders() {
  const { user } = useAuth()

  return useQuery({
    queryKey: ['orders', user?.id],
    queryFn: async () => {
      if (!user?.id) return []

      const { data, error } = await supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as Order[]
    },
    enabled: !!user?.id,
  })
}

export function useOrder(orderId: string | null) {
  const { user } = useAuth()

  return useQuery({
    queryKey: ['order', orderId],
    queryFn: async () => {
      if (!orderId || !user?.id) return null

      const { data, error } = await supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('id', orderId)
        .eq('user_id', user.id)
        .single()

      if (error) throw error
      return data as Order
    },
    enabled: !!orderId && !!user?.id,
  })
}

interface CreateOrderInput {
  items: {
    product_id: string | null
    product_name: string
    product_sku?: string
    quantity: number
    unit_price: number
  }[]
  payment_method: 'stripe' | 'apple_pay' | 'google_pay' | 'paypal'
  customer_email?: string
  customer_name?: string
  billing_address?: Record<string, unknown>
  notes?: string
  metadata?: Record<string, unknown>
}

export function useCreateOrder() {
  const queryClient = useQueryClient()
  const { user } = useAuth()

  return useMutation({
    mutationFn: async (input: CreateOrderInput) => {
      if (!user?.id) throw new Error('Non authentifié')

      // Calculate totals
      const subtotal = input.items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0)
      const tax = subtotal * 0.05 // 5% VAT UAE
      const total = subtotal + tax

      // Create order
      const { data: order, error: orderError } = await supabase
        .from('orders')
        .insert([{
          user_id: user.id,
          order_number: generateOrderNumber(),
          status: 'pending',
          payment_method: input.payment_method,
          payment_status: 'pending',
          subtotal,
          tax,
          total,
          currency: 'EUR',
          customer_email: input.customer_email || user.email,
          customer_name: input.customer_name,
          billing_address: input.billing_address,
          notes: input.notes,
          metadata: input.metadata
        }])
        .select()
        .single()

      if (orderError) throw orderError

      // Create order items
      const orderItems = input.items.map(item => ({
        order_id: order.id,
        product_id: item.product_id,
        product_name: item.product_name,
        product_sku: item.product_sku || null,
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.unit_price * item.quantity
      }))

      const { error: itemsError } = await supabase
        .from('order_items')
        .insert(orderItems)

      if (itemsError) throw itemsError

      return order as Order
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
    onError: (error) => {
      console.error('Error creating order:', error)
      toast.error('Erreur lors de la création de la commande')
    },
  })
}

export function useUpdateOrderPayment() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      orderId,
      payment_status,
      payment_intent_id,
      status
    }: {
      orderId: string
      payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
      payment_intent_id?: string
      status?: 'pending' | 'processing' | 'completed' | 'cancelled' | 'refunded'
    }) => {
      const updateData: Partial<Order> = {
        payment_status,
        updated_at: new Date().toISOString()
      }

      if (payment_intent_id) {
        updateData.payment_intent_id = payment_intent_id
      }

      if (status) {
        updateData.status = status
      }

      const { error } = await supabase
        .from('orders')
        .update(updateData)
        .eq('id', orderId)

      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] })
    },
  })
}
