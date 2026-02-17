'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase, supabaseAny } from '@/lib/supabase/client'
import { AdCampaign } from '@/lib/types'

// Types pour les opérations CRUD
type AdCampaignInsert = Partial<AdCampaign>
type AdCampaignUpdate = Partial<AdCampaign>
import { toast } from 'sonner'

const QUERY_KEY = ['campaigns']

async function fetchCampaigns(): Promise<AdCampaign[]> {
  const { data, error } = await supabase
    .from('ad_campaigns')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('[useCampaigns] fetchCampaigns error:', error.message)
    throw new Error(error.message)
  }

  return data ?? []
}

async function createCampaign(input: AdCampaignInsert): Promise<AdCampaign> {
  const { data, error } = await supabaseAny
    .from('ad_campaigns')
    .insert([input])
    .select()
    .single()

  if (error) {
    console.error('[useCampaigns] createCampaign error:', error.message)
    throw new Error(error.message)
  }

  return data as AdCampaign
}

async function updateCampaign({ id, ...input }: AdCampaignUpdate & { id: string }): Promise<AdCampaign> {
  const updateData = { ...input, updated_at: new Date().toISOString() }
  const { data, error } = await supabaseAny
    .from('ad_campaigns')
    .update(updateData)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    console.error('[useCampaigns] updateCampaign error:', error.message)
    throw new Error(error.message)
  }

  return data as AdCampaign
}

async function deleteCampaign(id: string): Promise<void> {
  const { error } = await supabase
    .from('ad_campaigns')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('[useCampaigns] deleteCampaign error:', error.message)
    throw new Error(error.message)
  }
}

export function useCampaigns() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: fetchCampaigns,
    staleTime: 1000 * 60 * 5,
  })
}

export function useCreateCampaign() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: createCampaign,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Campagne créée')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useUpdateCampaign() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: updateCampaign,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Campagne mise à jour')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}

export function useDeleteCampaign() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: deleteCampaign,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY })
      toast.success('Campagne supprimée')
    },
    onError: (error) => {
      toast.error(`Erreur: ${error.message}`)
    },
  })
}
