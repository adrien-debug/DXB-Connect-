import { z } from 'zod'

// === AUTH SCHEMAS ===
export const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(6, 'Mot de passe minimum 6 caractères'),
})

export const registerSchema = loginSchema.extend({
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['confirmPassword'],
})

export type LoginInput = z.infer<typeof loginSchema>
export type RegisterInput = z.infer<typeof registerSchema>

// === SUPPLIER SCHEMAS ===
export const supplierSchema = z.object({
  name: z.string().min(1, 'Nom requis').max(100),
  email: z.string().email('Email invalide').nullable().optional(),
  phone: z.string().max(20).nullable().optional(),
  company: z.string().max(100).nullable().optional(),
  address: z.string().max(500).nullable().optional(),
  country: z.string().max(50).nullable().optional(),
  category: z.enum(['telecom', 'hardware', 'software', 'logistics', 'services', 'other']).nullable().optional(),
  status: z.enum(['active', 'inactive']).default('active'),
  notes: z.string().max(1000).nullable().optional(),
})

export type SupplierInput = z.infer<typeof supplierSchema>

// === CUSTOMER SCHEMAS ===
export const customerSchema = z.object({
  first_name: z.string().min(1, 'Prénom requis').max(50),
  last_name: z.string().min(1, 'Nom requis').max(50),
  email: z.string().email('Email invalide').nullable().optional(),
  phone: z.string().max(20).nullable().optional(),
  company: z.string().max(100).nullable().optional(),
  address: z.string().max(500).nullable().optional(),
  city: z.string().max(50).nullable().optional(),
  country: z.string().max(50).nullable().optional(),
  segment: z.enum(['premium', 'standard', 'basic', 'prospect']).nullable().optional(),
  lifetime_value: z.number().min(0).default(0),
  status: z.enum(['active', 'inactive', 'churned']).default('active'),
  notes: z.string().max(1000).nullable().optional(),
})

export type CustomerInput = z.infer<typeof customerSchema>

// === AD CAMPAIGN SCHEMAS ===
export const adCampaignSchema = z.object({
  name: z.string().min(1, 'Nom requis').max(100),
  platform: z.enum(['google', 'facebook', 'instagram', 'linkedin', 'tiktok', 'other']),
  campaign_type: z.enum(['awareness', 'traffic', 'engagement', 'leads', 'sales']).nullable().optional(),
  status: z.enum(['draft', 'active', 'paused', 'completed']).default('draft'),
  budget: z.number().min(0).default(0),
  spent: z.number().min(0).default(0),
  impressions: z.number().int().min(0).default(0),
  clicks: z.number().int().min(0).default(0),
  conversions: z.number().int().min(0).default(0),
  cpc: z.number().min(0).default(0),
  ctr: z.number().min(0).max(100).default(0),
  start_date: z.string().nullable().optional(),
  end_date: z.string().nullable().optional(),
  target_audience: z.string().max(500).nullable().optional(),
  keywords: z.string().max(500).nullable().optional(),
  notes: z.string().max(1000).nullable().optional(),
})

export type AdCampaignInput = z.infer<typeof adCampaignSchema>
