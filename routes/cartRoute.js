import express from "express";
import {
  addToCartController,
  getAllCartController,
  removeFromCartController,
  clearCartController,
} from "../controllers/cartController.js"
import { protect } from '../controllers/authController.js';
const cartRouter = express.Router();

cartRouter.post("/cart", protect, addToCartController);       
cartRouter.get("/cart", protect, getAllCartController);       
cartRouter.delete("/cart/:id", protect, removeFromCartController);
cartRouter.delete("/cart", protect, clearCartController);   
export default cartRouter;