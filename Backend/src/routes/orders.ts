import { Router, Request, Response } from 'express';

const router = Router();

// GET /api/orders
router.get('/', async (req: Request, res: Response) => {
  try {
    const orders = [
      { id: '1', userId: '1', planId: '1', status: 'active', createdAt: new Date().toISOString() },
      { id: '2', userId: '2', planId: '2', status: 'pending', createdAt: new Date().toISOString() }
    ];
    res.json({ data: orders });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// POST /api/orders
router.post('/', async (req: Request, res: Response) => {
  try {
    const { userId, planId } = req.body;
    const order = {
      id: Date.now().toString(),
      userId,
      planId,
      status: 'pending',
      createdAt: new Date().toISOString()
    };
    res.status(201).json({ data: order });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

export default router;
