/**
 * Utilitaires partagés pour l'affichage des données eSIM.
 * Évite la duplication entre esim/page.tsx et esim/orders/page.tsx.
 */

/**
 * Formate un volume en bytes en format lisible (GB ou MB).
 * Exemples : 5368709120 → "5 GB" | 524288000 → "500 MB"
 */
export function formatVolume(bytes: number): string {
  const gb = bytes / (1024 * 1024 * 1024)
  if (gb >= 1) return `${gb.toFixed(0)} GB`
  const mb = bytes / (1024 * 1024)
  return `${mb.toFixed(0)} MB`
}

/**
 * Formate un prix en centimes en USD affichable.
 * Exemple : 1499 → "14.99"
 */
export function formatPrice(cents: number): string {
  return (cents / 100).toFixed(2)
}

/**
 * Formate une date ISO en date lisible fr-FR.
 * Exemple : "2026-03-15T00:00:00Z" → "15 mars 2026"
 */
export function formatDate(date: string | null | undefined): string {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })
}
