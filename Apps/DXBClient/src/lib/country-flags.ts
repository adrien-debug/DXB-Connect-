/**
 * Mapping des codes pays ISO vers drapeaux emoji
 * Source: Unicode flag emojis
 */

export const COUNTRY_FLAGS: Record<string, string> = {
  // Moyen-Orient
  'AE': '🇦🇪', // Émirats Arabes Unis
  'SA': '🇸🇦', // Arabie Saoudite
  'QA': '🇶🇦', // Qatar
  'BH': '🇧🇭', // Bahreïn
  'KW': '🇰🇼', // Koweït
  'OM': '🇴🇲', // Oman
  'JO': '🇯🇴', // Jordanie
  'LB': '🇱🇧', // Liban
  'IL': '🇮🇱', // Israël
  'IQ': '🇮🇶', // Irak
  'TR': '🇹🇷', // Turquie

  // Europe
  'FR': '🇫🇷', // France
  'DE': '🇩🇪', // Allemagne
  'GB': '🇬🇧', // Royaume-Uni
  'ES': '🇪🇸', // Espagne
  'IT': '🇮🇹', // Italie
  'PT': '🇵🇹', // Portugal
  'NL': '🇳🇱', // Pays-Bas
  'BE': '🇧🇪', // Belgique
  'CH': '🇨🇭', // Suisse
  'AT': '🇦🇹', // Autriche
  'SE': '🇸🇪', // Suède
  'NO': '🇳🇴', // Norvège
  'DK': '🇩🇰', // Danemark
  'FI': '🇫🇮', // Finlande
  'PL': '🇵🇱', // Pologne
  'CZ': '🇨🇿', // République Tchèque
  'GR': '🇬🇷', // Grèce
  'IE': '🇮🇪', // Irlande
  'RO': '🇷🇴', // Roumanie
  'HU': '🇭🇺', // Hongrie
  'BG': '🇧🇬', // Bulgarie
  'HR': '🇭🇷', // Croatie
  'SI': '🇸🇮', // Slovénie
  'SK': '🇸🇰', // Slovaquie
  'LT': '🇱🇹', // Lituanie
  'LV': '🇱🇻', // Lettonie
  'EE': '🇪🇪', // Estonie
  'IS': '🇮🇸', // Islande
  'MT': '🇲🇹', // Malte
  'CY': '🇨🇾', // Chypre
  'LU': '🇱🇺', // Luxembourg
  'MC': '🇲🇨', // Monaco

  // Amérique du Nord
  'US': '🇺🇸', // États-Unis
  'CA': '🇨🇦', // Canada
  'MX': '🇲🇽', // Mexique

  // Amérique du Sud
  'BR': '🇧🇷', // Brésil
  'AR': '🇦🇷', // Argentine
  'CL': '🇨🇱', // Chili
  'CO': '🇨🇴', // Colombie
  'PE': '🇵🇪', // Pérou
  'VE': '🇻🇪', // Venezuela
  'EC': '🇪🇨', // Équateur
  'UY': '🇺🇾', // Uruguay
  'PY': '🇵🇾', // Paraguay
  'BO': '🇧🇴', // Bolivie

  // Asie
  'CN': '🇨🇳', // Chine
  'JP': '🇯🇵', // Japon
  'KR': '🇰🇷', // Corée du Sud
  'IN': '🇮🇳', // Inde
  'TH': '🇹🇭', // Thaïlande
  'VN': '🇻🇳', // Vietnam
  'SG': '🇸🇬', // Singapour
  'MY': '🇲🇾', // Malaisie
  'ID': '🇮🇩', // Indonésie
  'PH': '🇵🇭', // Philippines
  'HK': '🇭🇰', // Hong Kong
  'TW': '🇹🇼', // Taïwan
  'MO': '🇲🇴', // Macao
  'KH': '🇰🇭', // Cambodge
  'LA': '🇱🇦', // Laos
  'MM': '🇲🇲', // Myanmar
  'BD': '🇧🇩', // Bangladesh
  'PK': '🇵🇰', // Pakistan
  'LK': '🇱🇰', // Sri Lanka
  'NP': '🇳🇵', // Népal
  'MN': '🇲🇳', // Mongolie
  'KZ': '🇰🇿', // Kazakhstan
  'UZ': '🇺🇿', // Ouzbékistan

  // Océanie
  'AU': '🇦🇺', // Australie
  'NZ': '🇳🇿', // Nouvelle-Zélande
  'FJ': '🇫🇯', // Fidji

  // Afrique
  'ZA': '🇿🇦', // Afrique du Sud
  'EG': '🇪🇬', // Égypte
  'MA': '🇲🇦', // Maroc
  'TN': '🇹🇳', // Tunisie
  'DZ': '🇩🇿', // Algérie
  'KE': '🇰🇪', // Kenya
  'NG': '🇳🇬', // Nigeria
  'GH': '🇬🇭', // Ghana
  'TZ': '🇹🇿', // Tanzanie
  'UG': '🇺🇬', // Ouganda
  'ET': '🇪🇹', // Éthiopie
  'SN': '🇸🇳', // Sénégal
  'CI': '🇨🇮', // Côte d'Ivoire
  'CM': '🇨🇲', // Cameroun
  'RW': '🇷🇼', // Rwanda

  // Autres
  'RU': '🇷🇺', // Russie
  'UA': '🇺🇦', // Ukraine
  'BY': '🇧🇾', // Biélorussie
  'MD': '🇲🇩', // Moldavie
  'GE': '🇬🇪', // Géorgie
  'AM': '🇦🇲', // Arménie
  'AZ': '🇦🇿', // Azerbaïdjan
}

/**
 * Obtenir le drapeau pour un code pays
 */
export function getCountryFlag(countryCode: string): string {
  return COUNTRY_FLAGS[countryCode.toUpperCase()] || '🌍'
}

/**
 * Obtenir le nom du pays avec drapeau
 */
export function getCountryDisplay(countryCode: string, countryName?: string): string {
  const flag = getCountryFlag(countryCode)
  const name = countryName || countryCode
  return `${flag} ${name}`
}

/**
 * Noms de pays en français (mapping commun)
 */
export const COUNTRY_NAMES_FR: Record<string, string> = {
  'AE': 'Émirats Arabes Unis',
  'SA': 'Arabie Saoudite',
  'QA': 'Qatar',
  'FR': 'France',
  'DE': 'Allemagne',
  'GB': 'Royaume-Uni',
  'ES': 'Espagne',
  'IT': 'Italie',
  'US': 'États-Unis',
  'CA': 'Canada',
  'CN': 'Chine',
  'JP': 'Japon',
  'KR': 'Corée du Sud',
  'IN': 'Inde',
  'TH': 'Thaïlande',
  'SG': 'Singapour',
  'AU': 'Australie',
  'NZ': 'Nouvelle-Zélande',
  'BR': 'Brésil',
  'MX': 'Mexique',
  'TR': 'Turquie',
  'ZA': 'Afrique du Sud',
  'EG': 'Égypte',
  'MA': 'Maroc',
}
