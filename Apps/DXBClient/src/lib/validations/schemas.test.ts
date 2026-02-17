import { describe, it, expect } from 'vitest'
import { loginSchema, supplierSchema, customerSchema } from './schemas'

describe('loginSchema', () => {
  it('validates correct login data', () => {
    const result = loginSchema.safeParse({
      email: 'test@example.com',
      password: 'password123',
    })
    expect(result.success).toBe(true)
  })

  it('rejects invalid email', () => {
    const result = loginSchema.safeParse({
      email: 'invalid-email',
      password: 'password123',
    })
    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues[0].message).toBe('Email invalide')
    }
  })

  it('rejects short password', () => {
    const result = loginSchema.safeParse({
      email: 'test@example.com',
      password: '12345',
    })
    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues[0].message).toBe('Mot de passe minimum 6 caractères')
    }
  })
})

describe('supplierSchema', () => {
  it('validates correct supplier data', () => {
    const result = supplierSchema.safeParse({
      name: 'Test Supplier',
      email: 'supplier@test.com',
      status: 'active',
    })
    expect(result.success).toBe(true)
  })

  it('rejects empty name', () => {
    const result = supplierSchema.safeParse({
      name: '',
      status: 'active',
    })
    expect(result.success).toBe(false)
  })

  it('validates with optional fields', () => {
    const result = supplierSchema.safeParse({
      name: 'Test',
      category: 'telecom',
      status: 'inactive',
    })
    expect(result.success).toBe(true)
  })
})

describe('customerSchema', () => {
  it('validates correct customer data', () => {
    const result = customerSchema.safeParse({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com',
      segment: 'premium',
    })
    expect(result.success).toBe(true)
  })

  it('rejects missing required fields', () => {
    const result = customerSchema.safeParse({
      first_name: 'John',
      // last_name missing
    })
    expect(result.success).toBe(false)
  })

  it('validates lifetime_value defaults to 0', () => {
    const result = customerSchema.safeParse({
      first_name: 'John',
      last_name: 'Doe',
    })
    expect(result.success).toBe(true)
    if (result.success) {
      expect(result.data.lifetime_value).toBe(0)
    }
  })
})
