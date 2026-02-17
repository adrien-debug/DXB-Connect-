'use client'

import Sidebar from '@/components/Sidebar'
import UserMenu from '@/components/UserMenu'
import { useState } from 'react'
import { Menu, X, Wifi } from 'lucide-react'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <div className="flex min-h-screen relative overflow-hidden bg-[#F3F4FA]">
      {/* Soft lavender background with purple blobs */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        {/* Large decorative purple blob - top right */}
        <div
          className="absolute -top-32 -right-32 w-[500px] h-[500px] rounded-full opacity-60"
          style={{
            background: 'linear-gradient(135deg, #7C3AED 0%, #8B5CF6 50%, #A78BFA 100%)',
            filter: 'blur(80px)',
          }}
        />

        {/* Secondary blob - bottom left */}
        <div
          className="absolute -bottom-48 -left-48 w-[400px] h-[400px] rounded-full opacity-40"
          style={{
            background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
            filter: 'blur(100px)',
          }}
        />

        {/* Small accent blob - center */}
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[300px] h-[300px] rounded-full opacity-20"
          style={{
            background: 'linear-gradient(135deg, #A78BFA 0%, #C4B5FD 100%)',
            filter: 'blur(60px)',
          }}
        />
      </div>

      {/* Mobile header */}
      <header className="lg:hidden fixed top-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-sm border-b border-gray-100 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center">
              <Wifi className="w-4 h-4 text-white" />
            </div>
            <div>
              <h1 className="text-sm font-semibold text-gray-800">DXB Connect</h1>
              <p className="text-[10px] text-gray-400">Premium Suite</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <UserMenu />
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-xl hover:bg-gray-50 text-gray-600 transition-colors"
              aria-label="Menu"
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </header>

      {/* Desktop header - top right */}
      <header className="hidden lg:block fixed top-0 right-0 z-40 p-4">
        <UserMenu />
      </header>

      {/* Mobile menu overlay */}
      {mobileMenuOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-30"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={`
        lg:relative fixed inset-y-0 left-0 z-40
        transform transition-transform duration-300 ease-out
        ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        <Sidebar onNavigate={() => setMobileMenuOpen(false)} />
      </div>

      {/* Main content */}
      <main className="flex-1 relative z-10 p-4 sm:p-6 lg:p-8 overflow-auto pt-20 lg:pt-8">
        <div className="max-w-[1600px] mx-auto">
          {children}
        </div>
      </main>
    </div>
  )
}
