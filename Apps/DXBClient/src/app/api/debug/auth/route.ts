import { NextResponse } from 'next/server'

export async function GET() {
  if (process.env.NODE_ENV === 'production') {
    return NextResponse.json({ error: 'Not found' }, { status: 404 })
  }

  return NextResponse.json({
    message: 'Debug endpoint disabled in production',
    env: process.env.NODE_ENV,
  })
}
