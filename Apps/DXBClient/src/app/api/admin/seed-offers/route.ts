import { requireAdmin } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const SEED_OFFERS = [
  // --- GLOBAL (toutes destinations) ---
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: '10% off any activity worldwide', description: 'Book tours, attractions and activities with 10% discount via SimPass.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/?partner_id=SIMPASS&subId={subId}', country_codes: [], is_global: true, sort_order: 1 },
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: '8% off museum & attraction tickets', description: 'Skip-the-line tickets to top attractions in 60+ countries.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/?utm_source=simpass&subId={subId}', country_codes: [], is_global: true, sort_order: 2 },
  { partner_name: 'Klook', partner_slug: 'klook', category: 'activity', title: '5% off travel experiences', description: 'Book things to do, transport & WiFi worldwide.', discount_percent: 5, discount_type: 'percent', affiliate_url_template: 'https://www.klook.com/?aid=simpass&subId={subId}', country_codes: [], is_global: true, sort_order: 3 },
  { partner_name: 'LoungeBuddy', partner_slug: 'loungebuddy', category: 'lounge', title: 'Airport lounge access from $32', description: 'Access premium airport lounges worldwide.', discount_percent: 15, discount_type: 'percent', affiliate_url_template: 'https://www.loungebuddy.com/?ref=simpass&subId={subId}', country_codes: [], is_global: true, sort_order: 4 },
  { partner_name: 'SafetyWing', partner_slug: 'safetywing', category: 'insurance', title: 'Travel insurance from $45/month', description: 'Nomad insurance covering 180+ countries.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://safetywing.com/?referenceID=simpass&subId={subId}', country_codes: [], is_global: true, sort_order: 5 },
  { partner_name: 'Booking.com', partner_slug: 'booking', category: 'hotel', title: 'Best hotel deals worldwide', description: 'Compare and book hotels at the best prices.', discount_percent: 0, discount_type: 'cashback', affiliate_url_template: 'https://www.booking.com/?aid=SIMPASS&subId={subId}', country_codes: [], is_global: true, sort_order: 6 },
  { partner_name: 'GetTransfer', partner_slug: 'gettransfer', category: 'transport', title: '10% off airport transfers', description: 'Book private transfers in 150+ countries.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://gettransfer.com/?utm_source=simpass&subId={subId}', country_codes: [], is_global: true, sort_order: 7 },

  // --- UAE ---
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Desert Safari Dubai – 15% off', description: 'Evening desert safari with BBQ dinner, dune bashing & entertainment.', discount_percent: 15, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/dubai-l173/desert-safari/?partner_id=SIMPASS&subId={subId}', country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 10 },
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: 'Burj Khalifa At The Top – 10% off', description: 'Skip-the-line tickets to the world\'s tallest building observation deck.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/en/dubai-attractions/burj-khalifa/?utm_source=simpass&subId={subId}', country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 11 },
  { partner_name: 'Klook', partner_slug: 'klook', category: 'activity', title: 'Dubai Frame – 8% off', description: 'Visit the iconic Dubai Frame with panoramic city views.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.klook.com/en-US/activity/dubai-frame/?aid=simpass&subId={subId}', country_codes: ['AE'], city: 'Dubai', is_global: false, sort_order: 12 },
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Abu Dhabi Grand Mosque Tour – 12% off', description: 'Guided tour of Sheikh Zayed Grand Mosque.', discount_percent: 12, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/abu-dhabi/?partner_id=SIMPASS&subId={subId}', country_codes: ['AE'], city: 'Abu Dhabi', is_global: false, sort_order: 13 },

  // --- Turkey ---
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Istanbul Bosphorus Cruise – 10% off', description: 'Scenic cruise along the Bosphorus strait.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/istanbul/?partner_id=SIMPASS&subId={subId}', country_codes: ['TR'], city: 'Istanbul', is_global: false, sort_order: 20 },
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: 'Hagia Sophia & Blue Mosque Tour – 8% off', description: 'Guided historical tour of Istanbul\'s iconic landmarks.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/en/istanbul/?utm_source=simpass&subId={subId}', country_codes: ['TR'], city: 'Istanbul', is_global: false, sort_order: 21 },
  { partner_name: 'Klook', partner_slug: 'klook', category: 'activity', title: 'Cappadocia Hot Air Balloon – 5% off', description: 'Sunrise balloon ride over the fairy chimneys.', discount_percent: 5, discount_type: 'percent', affiliate_url_template: 'https://www.klook.com/en-US/activity/cappadocia/?aid=simpass&subId={subId}', country_codes: ['TR'], is_global: false, sort_order: 22 },

  // --- UK ---
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: 'London Eye – 10% off', description: 'Skip-the-line tickets to the London Eye.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/en/london-attractions/london-eye/?utm_source=simpass&subId={subId}', country_codes: ['GB'], city: 'London', is_global: false, sort_order: 30 },
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Tower of London & Crown Jewels – 8% off', description: 'Explore 1000 years of history at the Tower of London.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/london/?partner_id=SIMPASS&subId={subId}', country_codes: ['GB'], city: 'London', is_global: false, sort_order: 31 },

  // --- France ---
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: 'Eiffel Tower Skip-the-Line – 10% off', description: 'Priority access to the Eiffel Tower summit.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/en/paris-attractions/eiffel-tower/?utm_source=simpass&subId={subId}', country_codes: ['FR'], city: 'Paris', is_global: false, sort_order: 40 },
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Louvre Museum Guided Tour – 12% off', description: 'Expert-guided tour of the world\'s most visited museum.', discount_percent: 12, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/paris/?partner_id=SIMPASS&subId={subId}', country_codes: ['FR'], city: 'Paris', is_global: false, sort_order: 41 },

  // --- Thailand ---
  { partner_name: 'Klook', partner_slug: 'klook', category: 'activity', title: 'Bangkok Temple Tour – 10% off', description: 'Visit Wat Pho, Wat Arun & Grand Palace with guide.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.klook.com/en-US/activity/bangkok-temples/?aid=simpass&subId={subId}', country_codes: ['TH'], city: 'Bangkok', is_global: false, sort_order: 50 },
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'Phuket Island Hopping – 8% off', description: 'Day trip to Phi Phi Islands with snorkeling.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/phuket/?partner_id=SIMPASS&subId={subId}', country_codes: ['TH'], city: 'Phuket', is_global: false, sort_order: 51 },

  // --- Saudi Arabia ---
  { partner_name: 'GetYourGuide', partner_slug: 'gyg', category: 'activity', title: 'AlUla Heritage Tour – 10% off', description: 'Explore the ancient Nabataean tombs of Hegra.', discount_percent: 10, discount_type: 'percent', affiliate_url_template: 'https://www.getyourguide.com/saudi-arabia/?partner_id=SIMPASS&subId={subId}', country_codes: ['SA'], is_global: false, sort_order: 60 },

  // --- USA ---
  { partner_name: 'Tiqets', partner_slug: 'tiqets', category: 'activity', title: 'Statue of Liberty & Ellis Island – 8% off', description: 'Ferry tickets and guided tour of Lady Liberty.', discount_percent: 8, discount_type: 'percent', affiliate_url_template: 'https://www.tiqets.com/en/new-york-attractions/?utm_source=simpass&subId={subId}', country_codes: ['US'], city: 'New York', is_global: false, sort_order: 70 },

  // --- Premium tier (Elite/Black) ---
  { partner_name: 'SimPass', partner_slug: 'simpass', category: 'lounge', title: 'VIP Airport Lounge – Free access', description: 'Complimentary lounge access at select airports for Elite & Black members.', discount_percent: 100, discount_type: 'free', affiliate_url_template: '', country_codes: [], is_global: true, tier_required: 'elite', sort_order: 100 },
  { partner_name: 'SimPass', partner_slug: 'simpass', category: 'transport', title: 'Premium Airport Transfer – 20% off', description: 'Luxury transfers at select airports for Black members.', discount_percent: 20, discount_type: 'percent', affiliate_url_template: '', country_codes: [], is_global: true, tier_required: 'black', sort_order: 101 },
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
