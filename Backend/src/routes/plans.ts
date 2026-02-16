import { Router, Request, Response } from 'express';

const router = Router();

// GET /api/plans
router.get('/', async (req: Request, res: Response) => {
  try {
    const plans = [
      { id: '1', name: 'Basic Plan', price: 29.99, features: ['Feature 1', 'Feature 2'] },
      { id: '2', name: 'Pro Plan', price: 99.99, features: ['Feature 1', 'Feature 2', 'Feature 3'] },
      { id: '3', name: 'Enterprise Plan', price: 299.99, features: ['All Features', 'Priority Support'] }
    ];
    res.json({ data: plans });
  } catch (error) {
    console.error('Error fetching plans:', error);
    res.status(500).json({ error: 'Failed to fetch plans' });
  }
});

// GET /api/plans/:id
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const plan = { id, name: `Plan ${id}`, price: 99.99, features: ['Feature 1', 'Feature 2'] };
    res.json({ data: plan });
  } catch (error) {
    console.error('Error fetching plan:', error);
    res.status(500).json({ error: 'Failed to fetch plan' });
  }
});

export default router;
