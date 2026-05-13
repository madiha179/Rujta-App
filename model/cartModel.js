import db from "../config/data.js";
export const addToCart=(user_id, drug_id, branch_id, quantity,callback)=>{
  const sql=`
  INSERT INTO cart(user_id, drug_id, branch_id, quantity) VALUES(?,?,?,?)
  ON DUPLICATE KEY UPDATE quantity = quantity + 1;
  `;
  db.query(sql,[user_id, drug_id, branch_id, quantity],callback);
}
export const getAllCart=(user_id,callback)=>{
  const sql=`
  SELECT 
  `
}