/**
 * Client centralisé pour l'API eSIM Access
 * - Fail-fast sur secrets manquants au démarrage
 * - Timeout 10s par défaut
 * - Classe d'erreur typée pour une gestion homogène
 */

const BASE_URL = 'https://api.esimaccess.com/api/v1'

export class ESIMAccessError extends Error {
  constructor(
    public readonly status: number,
    public readonly body: string,
    public readonly endpoint: string,
  ) {
    super(`[ESIMAccess] ${endpoint} → HTTP ${status}: ${body}`)
    this.name = 'ESIMAccessError'
  }
}

/**
 * Construit les headers d'authentification.
 * Lance une erreur explicite si les variables d'env sont absentes.
 */
function getHeaders(): Record<string, string> {
  const code = process.env.ESIM_ACCESS_CODE
  const secret = process.env.ESIM_SECRET_KEY

  if (!code || !secret) {
    throw new Error(
      '[ESIMAccess] Variables manquantes : ESIM_ACCESS_CODE et/ou ESIM_SECRET_KEY non définies'
    )
  }

  return {
    'Content-Type': 'application/json',
    'RT-AccessCode': code,
    'RT-SecretKey': secret,
  }
}

type ESIMPostOptions = {
  /** Revalidation ISR Next.js (en secondes). Mutuellement exclusif avec le timeout. */
  revalidate?: number
}

/**
 * Effectue un appel POST vers l'API eSIM Access.
 *
 * - Sans `revalidate` : timeout 10s appliqué via AbortSignal
 * - Avec `revalidate` : cache ISR Next.js activé (pas de timeout — géré par le cache)
 *
 * @throws {ESIMAccessError} si la réponse HTTP n'est pas 2xx
 * @throws {Error} si les variables d'env sont absentes
 */
export async function esimPost<T = unknown>(
  endpoint: string,
  body: object = {},
  options: ESIMPostOptions = {},
): Promise<T> {
  const fetchOptions: RequestInit & { next?: { revalidate: number } } = {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(body),
  }

  if (options.revalidate !== undefined) {
    fetchOptions.next = { revalidate: options.revalidate }
  } else {
    fetchOptions.signal = AbortSignal.timeout(10_000)
  }

  const res = await fetch(`${BASE_URL}${endpoint}`, fetchOptions)

  if (!res.ok) {
    const text = await res.text().catch(() => '')
    throw new ESIMAccessError(res.status, text, endpoint)
  }

  return res.json() as Promise<T>
}
