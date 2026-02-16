'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'
import { Supplier, SupplierInsert, SupplierUpdate } from '@/lib/database.types'
import { toast } from 'sonner'

const QUERY_KEY = ['suppliers']

// Fetch all suppliers
async function fetchSuppliers(): Promise<Supplier[]> {
  const { data, error } = await supabase
    .from('suppliers')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('[useSuppliers] fetchSuppliers error:', error.message)
    throw new Error(error.message)
  }

  return data ?? []
}

// Create supplier
async function createSupplier(input: SupplierInsert): Promise<Supplier> {
  const { data, error } = await supabase
    .from('suppliers')
    .insert(input)
    .select()
    .single()

  if (error) {
    console.error('[useSuppliers] createSupplier error:', error.message)
    throw new Error(error.message)
  }

  return data
}

// Update supplier
async function updateSupplier({ id, ...input }: SupplierUpdate & { id: string }): Promise<Supplier> {
  const { data, error } = await supabase
    .from('suppliers')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) {
    console.error('[useSuppliers] updateSupplier error:', error.message)
    throw new Error(error.message)
  }

  return data
}

// Delete supplier
async function deleteSupplier(id: string): Promise<void> {
  const { error } = await supabase
    .from('suppliers')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('[useSuppliers] deleteSupplier error:', error.message)
    throw new Error(error.message)
  }
}

export function useSuppliers() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: fetchSuppliers,
    staleTime: 1000 * 60 * 5, // 5 minutes
  })
}

export function useCreateSupplier() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: createSupplier,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Fournisseur créé')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useUpdateSupplier() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: updateSupplier,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Fournisseur mis à jour')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useDeleteSupplier() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: deleteSupplier,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Fournisseur supprimé')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}
