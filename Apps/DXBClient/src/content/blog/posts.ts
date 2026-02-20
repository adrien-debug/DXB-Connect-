export type BlogPost = {
  slug: string
  title: string
  excerpt: string
  dateISO: string
  tags: string[]
  content: {
    paragraphs: string[]
    bullets?: string[]
  }
}

const posts: BlogPost[] = [
  {
    slug: 'bien-demarrer-avec-une-esim',
    title: 'Bien démarrer avec une eSIM en voyage',
    excerpt: 'Choisir une offre, activer via QR code, éviter les erreurs courantes.',
    dateISO: '2026-02-20',
    tags: ['esim', 'voyage', 'guide'],
    content: {
      paragraphs: [
        'La eSIM permet d’ajouter une ligne mobile sans carte physique. C’est idéal en voyage: tu achètes un forfait data, tu scannes un QR code et tu te connectes.',
        'Avant l’achat, vérifie la compatibilité eSIM de ton appareil et assure-toi d’avoir une connexion Wi‑Fi disponible au moment de l’installation.',
        'Après activation, coupe le roaming de ta SIM principale (si besoin) et sélectionne la ligne eSIM pour les données mobiles.',
      ],
      bullets: [
        'Installe la eSIM avant d’atterrir (si possible).',
        'Conserve le QR code / LPA en lieu sûr.',
        'Active le data switch automatique uniquement si tu comprends l’impact.',
      ],
    },
  },
  {
    slug: 'comment-choisir-son-forfait-data',
    title: 'Comment choisir son forfait data',
    excerpt: 'Durée, volume, zones: les 3 critères pour choisir vite et bien.',
    dateISO: '2026-02-18',
    tags: ['forfait', 'data', 'conseils'],
    content: {
      paragraphs: [
        'Commence par la durée: un city-trip n’a pas les mêmes besoins qu’un mois de déplacement.',
        'Ensuite le volume: navigation + maps + messagerie consomment peu, mais vidéo et hotspot peuvent exploser la conso.',
        'Enfin la zone: pays unique, région, ou global. Choisis au plus proche de ton itinéraire pour optimiser le prix.',
      ],
    },
  },
]

export function getAllPosts(): BlogPost[] {
  return [...posts].sort((a, b) => (a.dateISO < b.dateISO ? 1 : -1))
}

export function getPostBySlug(slug: string): BlogPost | null {
  return posts.find((p) => p.slug === slug) ?? null
}

