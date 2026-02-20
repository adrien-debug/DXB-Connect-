import { describe, expect, it } from 'vitest'
import { getAllPosts, getPostBySlug } from '@/content/blog/posts'

describe('blog posts', () => {
  it('returns posts sorted by date desc', () => {
    const posts = getAllPosts()
    expect(posts.length).toBeGreaterThan(0)
    for (let i = 1; i < posts.length; i++) {
      expect(posts[i - 1].dateISO >= posts[i].dateISO).toBe(true)
    }
  })

  it('gets post by slug', () => {
    const first = getAllPosts()[0]
    const found = getPostBySlug(first.slug)
    expect(found?.slug).toBe(first.slug)
  })
})

