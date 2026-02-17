'use client'

import { X } from 'lucide-react'
import { useEffect, useState } from 'react'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  children: React.ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

export default function Modal({ isOpen, onClose, title, children, size = 'md' }: ModalProps) {
  const [isVisible, setIsVisible] = useState(false)
  const [isAnimating, setIsAnimating] = useState(false)

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    
    if (isOpen) {
      document.addEventListener('keydown', handleEscape)
      document.body.style.overflow = 'hidden'
      // Trigger animation
      setIsVisible(true)
      requestAnimationFrame(() => {
        setIsAnimating(true)
      })
    } else {
      setIsAnimating(false)
      const timer = setTimeout(() => {
        setIsVisible(false)
      }, 200)
      return () => clearTimeout(timer)
    }
    
    return () => {
      document.removeEventListener('keydown', handleEscape)
      document.body.style.overflow = 'unset'
    }
  }, [isOpen, onClose])

  if (!isVisible) return null

  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto">
      {/* Backdrop */}
      <div 
        className={`
          fixed inset-0 
          bg-gray-900/30 backdrop-blur-sm
          transition-opacity duration-300
          ${isAnimating ? 'opacity-100' : 'opacity-0'}
        `}
        onClick={onClose}
      />
      
      {/* Modal */}
      <div 
        className={`
          relative w-full ${sizeClasses[size]} 
          my-8
          transition-all duration-300 ease-out
          ${isAnimating 
            ? 'opacity-100 scale-100 translate-y-0' 
            : 'opacity-0 scale-95 translate-y-4'
          }
        `}
      >
        <div className="bg-white rounded-3xl shadow-xl border border-gray-100/50 max-h-[calc(100vh-4rem)] flex flex-col">
          {/* Header */}
          <div className="px-5 sm:px-6 py-4 sm:py-5 border-b border-gray-100 bg-white flex-shrink-0">
            <div className="flex items-center justify-between gap-4">
              <h3 className="text-base sm:text-lg font-semibold text-gray-800 truncate">{title}</h3>
              <button
                onClick={onClose}
                className="
                  p-2 rounded-xl flex-shrink-0
                  text-gray-400 hover:text-violet-600
                  hover:bg-violet-50
                  transition-all duration-200
                "
                aria-label="Fermer"
              >
                <X size={18} />
              </button>
            </div>
          </div>
          
          {/* Content */}
          <div className="p-5 sm:p-6 overflow-y-auto flex-1 bg-white">
            {children}
          </div>
        </div>
      </div>
    </div>
  )
}
