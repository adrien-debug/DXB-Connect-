import { Router } from 'express';
import usersRouter from './users';
import ordersRouter from './orders';
import plansRouter from './plans';

const router = Router();

router.use('/users', usersRouter);
router.use('/orders', ordersRouter);
router.use('/plans', plansRouter);

export default router;
