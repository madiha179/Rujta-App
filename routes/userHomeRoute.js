import express from 'express';
import { getAllDrugsByLocationController ,searchDrugByLocationController} from '../controllers/userHomeController.js';
import { protect } from '../controllers/authController.js';
export const userHomeRouter=express.Router();
userHomeRouter.use(protect);
userHomeRouter.get('/drugsbylocation/:lng/:lat',getAllDrugsByLocationController);
userHomeRouter.get('/drugsbylocation/:lng/:lat/:key',searchDrugByLocationController)