import { requireAdmin } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const VIATOR_PID = 'P00289757'
const VIATOR_MCID = '42383'
const vUrl = (path: string) => `https://www.viator.com${path}?pid=${VIATOR_PID}&mcid=${VIATOR_MCID}&medium=link`

const SEED_OFFERS = [
  // --- GLOBAL ---
  { partner_name: 'Viator', partner_slug: 'viator-global', category: 'activity', title: 'Tours & activities worldwide', description: 'Book 300,000+ experiences in 200+ countries. Trusted by 20M+ travelers.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours'), country_codes: [], is_global: true, sort_order: 1 },
  { partner_name: 'Viator', partner_slug: 'viator-attractions', category: 'activity', title: 'Skip-the-line attraction tickets', description: 'Skip the queue at top attractions worldwide with mobile tickets.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/attraction-tickets'), country_codes: [], is_global: true, sort_order: 2 },
  { partner_name: 'Viator', partner_slug: 'viator-transfers', category: 'transport', title: 'Airport & city transfers', description: 'Private and shared transfers in 150+ destinations.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/transfers'), country_codes: [], is_global: true, sort_order: 3 },
  { partner_name: 'Viator', partner_slug: 'viator-daytrips', category: 'activity', title: 'Day trips & excursions', description: 'Explore nearby destinations with guided day trips.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/day-trips'), country_codes: [], is_global: true, sort_order: 4 },
  { partner_name: 'Viator', partner_slug: 'viator-food', category: 'food', title: 'Food tours & tastings', description: 'Discover local cuisine with expert guides worldwide.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/food-tours'), country_codes: [], is_global: true, sort_order: 5 },

  // --- UAE ---
  { partner_name: 'Viator', partner_slug: 'viator-dubai-safari', category: 'activity', title: 'Desert Safari with BBQ Dinner', description: 'Evening desert safari with dune bashing, camel ride, BBQ dinner & entertainment.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Dubai/Desert-Safari'), country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 10 },
  { partner_name: 'Viator', partner_slug: 'viator-dubai-burj', category: 'activity', title: 'Burj Khalifa At The Top Tickets', description: 'Skip-the-line tickets to the observation deck of the world\'s tallest building.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Dubai/Burj-Khalifa'), country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 11 },
  { partner_name: 'Viator', partner_slug: 'viator-dubai-marina', category: 'activity', title: 'Dubai Marina Yacht Cruise', description: 'Luxury yacht cruise with stunning views of Dubai Marina skyline.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Dubai/Yacht-Cruise'), country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 12 },
  { partner_name: 'Viator', partner_slug: 'viator-dubai-frame', category: 'activity', title: 'Dubai Frame Entry Tickets', description: 'Visit the iconic Dubai Frame with panoramic city views.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Dubai/Dubai-Frame'), country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 13 },
  { partner_name: 'Viator', partner_slug: 'viator-dubai-aqua', category: 'activity', title: 'Aquaventure Waterpark Tickets', description: 'Full-day access to the region\'s largest waterpark at Atlantis.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Dubai/Aquaventure'), country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 14 },
  { partner_name: 'Viator', partner_slug: 'viator-abudhabi-mosque', category: 'activity', title: 'Sheikh Zayed Mosque & City Tour', description: 'Guided tour of Abu Dhabi\'s Grand Mosque, Royal Palace & Heritage Village.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Abu-Dhabi/Grand-Mosque-Tour'), country_codes: ['AE'], city: 'Abu Dhabi', is_global: false, sort_order: 15 },

  // --- Turkey ---
  { partner_name: 'Viator', partner_slug: 'viator-istanbul-bosphorus', category: 'activity', title: 'Bosphorus Cruise & Two Continents', description: 'Scenic cruise between Europe and Asia with guided city tour.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Istanbul/Bosphorus-Cruise'), country_codes: ['TR'], city: 'Istanbul', is_global: false, sort_order: 20 },
  { partner_name: 'Viator', partner_slug: 'viator-istanbul-hagia', category: 'activity', title: 'Hagia Sophia & Blue Mosque Tour', description: 'Guided historical tour of Istanbul\'s most iconic landmarks.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Istanbul/Hagia-Sophia-Tour'), country_codes: ['TR'], city: 'Istanbul', is_global: false, sort_order: 21 },
  { partner_name: 'Viator', partner_slug: 'viator-cappadocia-balloon', category: 'activity', title: 'Cappadocia Hot Air Balloon Ride', description: 'Sunrise balloon flight over the fairy chimneys and valleys.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Cappadocia/Hot-Air-Balloon'), country_codes: ['TR'], is_global: false, sort_order: 22 },

  // --- UK ---
  { partner_name: 'Viator', partner_slug: 'viator-london-eye', category: 'activity', title: 'London Eye Skip-the-Line', description: 'Fast-track entry to the London Eye with stunning Thames views.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/London/London-Eye'), country_codes: ['GB'], city: 'London', is_global: false, sort_order: 30 },
  { partner_name: 'Viator', partner_slug: 'viator-london-tower', category: 'activity', title: 'Tower of London & Crown Jewels', description: 'Explore 1000 years of history and see the Crown Jewels.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/London/Tower-of-London'), country_codes: ['GB'], city: 'London', is_global: false, sort_order: 31 },
  { partner_name: 'Viator', partner_slug: 'viator-london-harry', category: 'activity', title: 'Harry Potter Warner Bros Studio', description: 'Full-day Warner Bros Studio Tour with transport from London.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/London/Harry-Potter-Studio'), country_codes: ['GB'], city: 'London', is_global: false, sort_order: 32 },

  // --- France ---
  { partner_name: 'Viator', partner_slug: 'viator-paris-eiffel', category: 'activity', title: 'Eiffel Tower Summit Access', description: 'Skip-the-line access to the Eiffel Tower summit with guide.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Paris/Eiffel-Tower-Summit'), country_codes: ['FR'], city: 'Paris', is_global: false, sort_order: 40 },
  { partner_name: 'Viator', partner_slug: 'viator-paris-louvre', category: 'activity', title: 'Louvre Museum Guided Tour', description: 'Expert-guided tour including Mona Lisa and Venus de Milo.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Paris/Louvre-Museum'), country_codes: ['FR'], city: 'Paris', is_global: false, sort_order: 41 },
  { partner_name: 'Viator', partner_slug: 'viator-paris-versailles', category: 'activity', title: 'Versailles Palace Day Trip', description: 'Full-day guided tour of Versailles Palace and Gardens from Paris.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Paris/Versailles'), country_codes: ['FR'], city: 'Paris', is_global: false, sort_order: 42 },

  // --- Thailand ---
  { partner_name: 'Viator', partner_slug: 'viator-bangkok-temples', category: 'activity', title: 'Bangkok Temple & Grand Palace Tour', description: 'Visit Wat Pho, Wat Arun and the Grand Palace with expert guide.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Bangkok/Temple-Tour'), country_codes: ['TH'], city: 'Bangkok', is_global: false, sort_order: 50 },
  { partner_name: 'Viator', partner_slug: 'viator-phuket-phiphi', category: 'activity', title: 'Phi Phi Islands Day Trip', description: 'Speedboat trip to Phi Phi Islands with snorkeling and beach time.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Phuket/Phi-Phi-Islands'), country_codes: ['TH'], city: 'Phuket', is_global: false, sort_order: 51 },
  { partner_name: 'Viator', partner_slug: 'viator-chiangmai-elephant', category: 'activity', title: 'Ethical Elephant Sanctuary Visit', description: 'Half-day visit to an ethical elephant sanctuary in Chiang Mai.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Chiang-Mai/Elephant-Sanctuary'), country_codes: ['TH'], city: 'Chiang Mai', is_global: false, sort_order: 52 },

  // --- Saudi Arabia ---
  { partner_name: 'Viator', partner_slug: 'viator-riyadh-edge', category: 'activity', title: 'Edge of the World Day Trip', description: 'Drive to the stunning Edge of the World cliffs near Riyadh.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Riyadh/Edge-of-the-World'), country_codes: ['SA'], city: 'Riyadh', is_global: false, sort_order: 60 },
  { partner_name: 'Viator', partner_slug: 'viator-alula-hegra', category: 'activity', title: 'AlUla & Hegra Heritage Tour', description: 'Explore ancient Nabataean tombs and rock formations in AlUla.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/AlUla/Hegra-Heritage'), country_codes: ['SA'], is_global: false, sort_order: 61 },

  // --- USA ---
  { partner_name: 'Viator', partner_slug: 'viator-nyc-liberty', category: 'activity', title: 'Statue of Liberty & Ellis Island', description: 'Ferry tickets and guided tour of the Statue of Liberty.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/New-York/Statue-of-Liberty'), country_codes: ['US'], city: 'New York', is_global: false, sort_order: 70 },
  { partner_name: 'Viator', partner_slug: 'viator-nyc-topofrock', category: 'activity', title: 'Top of the Rock Observation Deck', description: 'Skip-the-line tickets to Rockefeller Center\'s observation deck.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/New-York/Top-of-the-Rock'), country_codes: ['US'], city: 'New York', is_global: false, sort_order: 71 },
  { partner_name: 'Viator', partner_slug: 'viator-la-hollywood', category: 'activity', title: 'Hollywood & Celebrity Homes Tour', description: 'Open-air bus tour through Hollywood, Beverly Hills & celebrity homes.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Los-Angeles/Hollywood-Tour'), country_codes: ['US'], city: 'Los Angeles', is_global: false, sort_order: 72 },

  // --- Japan ---
  { partner_name: 'Viator', partner_slug: 'viator-tokyo-tsukiji', category: 'activity', title: 'Tsukiji Fish Market Food Tour', description: 'Guided food tour through Tokyo\'s famous Tsukiji Outer Market.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Tokyo/Tsukiji-Food-Tour'), country_codes: ['JP'], city: 'Tokyo', is_global: false, sort_order: 80 },
  { partner_name: 'Viator', partner_slug: 'viator-kyoto-fushimi', category: 'activity', title: 'Fushimi Inari & Sake Tasting', description: 'Walk through thousands of torii gates and taste local sake.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Kyoto/Fushimi-Inari'), country_codes: ['JP'], city: 'Kyoto', is_global: false, sort_order: 81 },

  // --- Italy ---
  { partner_name: 'Viator', partner_slug: 'viator-rome-colosseum', category: 'activity', title: 'Colosseum & Roman Forum Tour', description: 'Skip-the-line guided tour of the Colosseum, Forum & Palatine Hill.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Rome/Colosseum'), country_codes: ['IT'], city: 'Rome', is_global: false, sort_order: 90 },
  { partner_name: 'Viator', partner_slug: 'viator-venice-gondola', category: 'activity', title: 'Venice Gondola Ride', description: 'Classic gondola ride through the canals of Venice.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Venice/Gondola-Ride'), country_codes: ['IT'], city: 'Venice', is_global: false, sort_order: 91 },

  // --- Spain ---
  { partner_name: 'Viator', partner_slug: 'viator-barcelona-sagrada', category: 'activity', title: 'Sagrada Familia Fast Track', description: 'Skip-the-line entry to Gaudi\'s iconic basilica with audio guide.', discount_percent: 0, discount_type: 'partner', affiliate_url_template: vUrl('/tours/Barcelona/Sagrada-Familia'), country_codes: ['ES'], city: 'Barcelona', is_global: false, sort_order: 95 },

  // --- Premium tier (Elite/Black) ---
  { partner_name: 'SimPass', partner_slug: 'simpass-lounge', category: 'lounge', title: 'VIP Airport Lounge – Free access', description: 'Complimentary lounge access at select airports for Elite & Black members.', discount_percent: 100, discount_type: 'free', affiliate_url_template: '', country_codes: [], is_global: true, tier_required: 'elite', sort_order: 200 },
  { partner_name: 'SimPass', partner_slug: 'simpass-transfer', category: 'transport', title: 'Premium Airport Transfer – 20% off', description: 'Luxury transfers at select airports for Black members.', discount_percent: 20, discount_type: 'percent', affiliate_url_template: '', country_codes: [], is_global: true, tier_required: 'black', sort_order: 201 },
]

const SEED_MISSIONS = [
  { type: 'daily', title: 'Daily Check-in', description: 'Open the app and check in', xp_reward: 25, points_reward: 10, tickets_reward: 0, condition_type: 'checkin', condition_value: 1 },
  { type: 'daily', title: 'Explore a Perk', description: 'View any partner offer', xp_reward: 15, points_reward: 5, tickets_reward: 0, condition_type: 'offer_view', condition_value: 1 },
  { type: 'weekly', title: 'Activate an eSIM', description: 'Purchase and activate an eSIM this week', xp_reward: 150, points_reward: 75, tickets_reward: 1, condition_type: 'purchase', condition_value: 1 },
  { type: 'weekly', title: 'Refer a Friend', description: 'Get a friend to sign up using your code', xp_reward: 200, points_reward: 100, tickets_reward: 2, condition_type: 'referral', condition_value: 1 },
  { type: 'weekly', title: '5-Day Streak', description: 'Check in 5 days in a row', xp_reward: 100, points_reward: 50, tickets_reward: 1, condition_type: 'streak', condition_value: 5 },
]

/**
 * POST /api/admin/seed-offers
 * Seeds partner offers + missions. Admin only.
 */
export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabase = await createClient() as SupabaseAny

    // Seed offers
    const { data: offers, error: offersError } = await supabase
      .from('partner_offers')
      .upsert(
        SEED_OFFERS.map(o => ({ ...o, is_active: true })),
        { onConflict: 'partner_slug,title' }
      )
      .select()

    // Seed missions
    const { data: missions, error: missionsError } = await supabase
      .from('missions')
      .upsert(
        SEED_MISSIONS.map(m => ({ ...m, is_active: true })),
        { onConflict: 'title' }
      )
      .select()

    console.log('[seed-offers] Seeded:', {
      offers: offers?.length || 0,
      missions: missions?.length || 0,
      userId: user.id,
    })

    return NextResponse.json({
      success: true,
      data: {
        offers_count: offers?.length || 0,
        offers_error: offersError?.message || null,
        missions_count: missions?.length || 0,
        missions_error: missionsError?.message || null,
      },
    })
  } catch (err) {
    console.error('[seed-offers] Error:', { userId: user?.id })
    return NextResponse.json({ error: 'Seeding failed' }, { status: 500 })
  }
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/admin/seed-offers',
    method: 'POST',
    description: 'Seeds partner offers and missions for SimPass',
    requiresAuth: 'admin',
  })
}
