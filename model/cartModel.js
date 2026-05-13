import db from "../config/data.js";
export const addToCart=(user_id, drug_id, branch_id, quantity,callback)=>{
  const sql=`
  INSERT INTO cart(user_id, drug_id, branch_id, quantity) VALUES(?,?,?,?)
  ON DUPLICATE KEY UPDATE quantity = quantity + 1;
  `;
  db.query(sql,[user_id, drug_id, branch_id, quantity],callback);
}
export const getAllCart = (user_id, callback) => {
  const sql = `
    SELECT 
      cart.id,
      cart.drug_id,
      cart.branch_id,
      d.imgae_url AS image_url,
      d.name AS drug_name,
      p.name AS pharmacy_name,
      cart.quantity,
      bd.price AS price,
      (cart.quantity * bd.price) AS total_price
    FROM cart
    JOIN drugs d ON cart.drug_id = d.id
    JOIN branches b ON cart.branch_id = b.id
    JOIN pharmacies p ON b.pharmacy_id = p.id
    JOIN branch_drugs bd ON bd.drug_id = cart.drug_id AND bd.branch_id = cart.branch_id
    WHERE cart.user_id = ?
  `;
  db.query(sql, [user_id], callback);
};
export const removeFromCart = (cart_id, user_id, callback) => {
  const sql = `
    DELETE FROM cart WHERE id = ? AND user_id = ?
  `;
  db.query(sql, [cart_id, user_id], callback);
};

export const clearCart = (user_id, callback) => {
  const sql = `DELETE FROM cart WHERE user_id = ?`;
  db.query(sql, [user_id], callback);
};