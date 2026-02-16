import { Router, Request, Response } from 'express';

const router = Router();

// GET /api/users
router.get('/', async (req: Request, res: Response) => {
  try {
    const users = [
      { id: '1', email: 'user1@dxb.com', name: 'User One' },
      { id: '2', email: 'user2@dxb.com', name: 'User Two' }
    ];
    res.json({ data: users });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// GET /api/users/:id
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const user = { id, email: `user${id}@dxb.com`, name: `User ${id}` };
    res.json({ data: user });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

export default router;
