import express from 'express';
import authController from '../controllers/authController.js';
const authRouter=express.Router();
authRouter.post('/signup',authController.registerUser);
authRouter.post('/login',authController.login);
authRouter.post('/verifyemail',authController.verifyEmail);
export default authRouter;