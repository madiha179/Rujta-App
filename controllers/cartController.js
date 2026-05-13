import { addToCart,getAllCart,removeFromCart,clearCart } from "../model/cartModel.js"
export const addToCartController = (req, res) => {
  const { drug_id, branch_id, quantity } = req.body;
  const user_id = req.user.id; 
  if (!drug_id || !branch_id || !quantity) {
    return res.status(400).json({ message: "drug_id, branch_id, quantity required" });
  }

  addToCart(user_id, drug_id, branch_id, quantity, (err, result) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    res.status(200).json({ message: "drug added successfly"});
  });
};

export const getAllCartController = (req, res) => {
  const user_id = req.user.id;

  getAllCart(user_id, (err, results) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    if (results.length === 0) return res.status(404).json({ message: "cart is empty" });

    const total = results.reduce((sum, item) => sum + parseFloat(item.total_price), 0);

    res.status(200).json({
      cart: results,
      total_price: total.toFixed(2),
    });
  });
};

export const removeFromCartController = (req, res) => {
  const cart_id = req.params.id;
  const user_id = req.user.id;

  removeFromCart(cart_id, user_id, (err, result) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    if (result.affectedRows === 0) return res.status(404).json({ message: "Item not found"});
    res.status(200).json({ message: "drug successfly deleted"});
  });
};

export const clearCartController = (req, res) => {
  const user_id = req.user.id;

  clearCart(user_id, (err, result) => {
    if (err) return res.status(500).json({ message: "Database error", error: err });
    res.status(200).json({ message: "cart clear successfly"});
  });
};