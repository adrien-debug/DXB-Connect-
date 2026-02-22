import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://api-github-production-a848.up.railway.app'

  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/dashboard', '/esim', '/customers', '/suppliers', '/orders', '/products', '/ads'],
    },
    sitemap: `${baseUrl}/sitemap.xml`,
  }
}

