'use client'

import { useInView } from '@/hooks/useInView'

type Props = {
  children: React.ReactNode
  className?: string
  animation?: 'fade-in-up' | 'fade-in-scale' | 'slide-in-right'
  delay?: number
}

export default function AnimateOnScroll({
  children,
  className = '',
  animation = 'fade-in-up',
  delay = 0,
}: Props) {
  const { ref, isInView } = useInView()

  return (
    <div
      ref={ref}
      className={className}
      style={{
        opacity: isInView ? 1 : 0,
        transform: isInView
          ? 'translateY(0) scale(1)'
          : animation === 'fade-in-scale'
            ? 'scale(0.95)'
            : animation === 'slide-in-right'
              ? 'translateX(-20px)'
              : 'translateY(20px)',
        transition: `opacity 0.5s ease-out ${delay}s, transform 0.5s ease-out ${delay}s`,
      }}
    >
      {children}
    </div>
  )
}
