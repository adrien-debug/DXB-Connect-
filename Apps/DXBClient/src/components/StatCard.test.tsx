import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import StatCard from './StatCard'
import { Users } from 'lucide-react'

describe('StatCard', () => {
  it('renders title and value', () => {
    render(
      <StatCard
        title="Test Title"
        value={42}
        icon={Users}
        color="blue"
      />
    )

    expect(screen.getByText('Test Title')).toBeInTheDocument()
    expect(screen.getByText('42')).toBeInTheDocument()
  })

  it('renders string value correctly', () => {
    render(
      <StatCard
        title="Budget"
        value="10,000 €"
        icon={Users}
        color="green"
      />
    )

    expect(screen.getByText('Budget')).toBeInTheDocument()
    expect(screen.getByText('10,000 €')).toBeInTheDocument()
  })
})
