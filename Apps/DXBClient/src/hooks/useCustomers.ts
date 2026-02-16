'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { Customer, CustomerInsert, CustomerUpdate } from '@/lib/database.types'
import { toast } from 'sonner'

const QUERY_KEY = ['customers']

async function fetchCustomers(): Promise<Customer[]> {
  const { data, error } = await supabase
    .from('customers')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('[useCustomers] fetchCustomers error:', error.message)
    throw new Error(error.message)
  }

  return data ?? []
}

async function createCustomer(input: CustomerInsert): Promise<Customer> {
  const { data, error } = await supabase
    .from('customers')
    .insert(input)
    .select()
    .single()

  if (error) {
    console.error('[useCustomers] createCustomer error:', error.message)
    throw new Error(error.message)
  }

  return data
}

async function updateCustomer({ id, ...input }: CustomerUpdate & { id: string }): Promise<Customer> {
  const { data, error } = await supabase
    .from('customers')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) {
    console.error('[useCustomers] updateCustomer error:', error.message)
    throw new Error(error.message)
  }

  return data
}

async function deleteCustomer(id: string): Promise<void> {
  const { error } = await supabase
    .from('customers')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('[useCustomers] deleteCustomer error:', error.message)
    throw new Error(error.message)
  }
}

export function useCustomers() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: fetchCustomers,
    staleTime: 1000 * 60 * 5,
  })
}

export function useCreateCustomer() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: createCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Client créé')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useUpdateCustomer() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: updateCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Client mis à jour')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useDeleteCustomer() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: deleteCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Client supprimé')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}
