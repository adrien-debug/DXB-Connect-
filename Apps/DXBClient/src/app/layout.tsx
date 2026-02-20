import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { QueryProvider } from '@/providers/QueryProvider'
import { Toaster } from 'sonner'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

export const metadata: Metadata = {
  title: 'SimPass - Premium Dashboard',
  description: 'Plateforme de gestion centralisée premium',
  icons: {
    icon: '/favicon.svg',
    apple: '/favicon.svg',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" className={inter.variable}>
      <body className={`${inter.className} antialiased`}>
        <QueryProvider>
          {children}
          <Toaster
            position="top-right"
            richColors
            closeButton
            toastOptions={{
              duration: 3000,
              style: {
                background: 'rgba(24, 24, 27, 0.95)',
                backdropFilter: 'blur(12px)',
                border: '1px solid rgba(63, 63, 70, 0.5)',
                boxShadow: '0 8px 32px rgba(0, 0, 0, 0.4)',
                color: '#FAFAFA',
              },
            }}
          />
        </QueryProvider>
      </body>
    </html>
  )
}
