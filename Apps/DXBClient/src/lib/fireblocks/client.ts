/**
 * Fireblocks API client wrapper.
 * Toutes les clés sont côté Railway (env vars) — jamais côté client.
 *
 * Variables d'environnement requises:
 * - FIREBLOCKS_API_KEY
 * - FIREBLOCKS_API_SECRET (base64 encoded private key)
 * - FIREBLOCKS_VAULT_ID
 * - FIREBLOCKS_BASE_URL (optionnel, default: https://api.fireblocks.io)
 */

import crypto from 'crypto'
// eslint-disable-next-line @typescript-eslint/no-require-imports
import jwt from 'jsonwebtoken'

const FIREBLOCKS_BASE_URL = process.env.FIREBLOCKS_BASE_URL || 'https://api.fireblocks.io'

function getConfig() {
  const apiKey = process.env.FIREBLOCKS_API_KEY
  const apiSecret = process.env.FIREBLOCKS_API_SECRET
  const vaultId = process.env.FIREBLOCKS_VAULT_ID

  if (!apiKey || !apiSecret || !vaultId) {
    return null
  }

  return { apiKey, apiSecret, vaultId }
}

function signRequest(path: string, body: string, apiKey: string, apiSecret: string): string {
  const now = Math.floor(Date.now() / 1000)
  const nonce = crypto.randomBytes(16).toString('hex')

  const payload = {
    uri: path,
    nonce,
    iat: now,
    exp: now + 30,
    sub: apiKey,
    bodyHash: crypto.createHash('sha256').update(body || '').digest('hex'),
  }

  return jwt.sign(payload, apiSecret, { algorithm: 'RS256' })
}

async function fireblocksRequest<T>(
  method: string,
  path: string,
  body?: Record<string, unknown>
): Promise<T> {
  const config = getConfig()
  if (!config) {
    throw new Error('Fireblocks not configured')
  }

  const bodyStr = body ? JSON.stringify(body) : ''
  const token = signRequest(path, bodyStr, config.apiKey, config.apiSecret)

  const response = await fetch(`${FIREBLOCKS_BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': config.apiKey,
      'Authorization': `Bearer ${token}`,
    },
    body: body ? bodyStr : undefined,
  })

  if (!response.ok) {
    const text = await response.text()
    console.error('[Fireblocks] API error:', { status: response.status, path })
    throw new Error(`Fireblocks API error: ${response.status}`)
  }

  return response.json()
}

export function isFireblocksConfigured(): boolean {
  return getConfig() !== null
}

export interface DepositAddress {
  address: string
  tag?: string
  legacyAddress?: string
}

export async function createDepositAddress(
  assetId: string
): Promise<DepositAddress> {
  const config = getConfig()
  if (!config) throw new Error('Fireblocks not configured')

  return fireblocksRequest<DepositAddress>(
    'POST',
    `/v1/vault/accounts/${config.vaultId}/${assetId}/addresses`
  )
}

export async function getDepositAddresses(
  assetId: string
): Promise<DepositAddress[]> {
  const config = getConfig()
  if (!config) throw new Error('Fireblocks not configured')

  return fireblocksRequest<DepositAddress[]>(
    'GET',
    `/v1/vault/accounts/${config.vaultId}/${assetId}/addresses`
  )
}

export interface FireblocksTransaction {
  id: string
  status: string
  txHash?: string
  amount: number
  assetId: string
}

export async function getTransaction(txId: string): Promise<FireblocksTransaction> {
  return fireblocksRequest<FireblocksTransaction>('GET', `/v1/transactions/${txId}`)
}

/**
 * Vérifie la signature d'un webhook Fireblocks.
 */
export function verifyWebhookSignature(
  body: string,
  signature: string
): boolean {
  const secret = process.env.FIREBLOCKS_WEBHOOK_SECRET
  if (!secret) return false

  try {
    const publicKey = crypto.createPublicKey(secret)
    return crypto.verify(
      'sha512',
      Buffer.from(body),
      publicKey,
      Buffer.from(signature, 'base64')
    )
  } catch {
    return false
  }
}
