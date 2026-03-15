import { hashSync } from 'bcrypt';
import db from '../config/data.js';
export const createUser=(name,email,phone,hashedPassword,role = "customer", callback)=>{
 const sql="INSERT INTO users(name,email,password,role,phone) VALUES (?,?,?,?,?)";
 db.query(sql,[name,email,hashedPassword,role,phone],callback);
};
export const findUser=(email,callback)=>{
  const sql="SELECT * FROM users WHERE email=?";
  db.query(sql,[email],callback);
};
export const verifyUserEmail = (email, callback) => {
  const sql = "UPDATE users SET is_verified = TRUE WHERE email = ?";
  db.query(sql, [email], callback);
};
export const updatePassword=(email,hashedPassword,callback)=>{
  const sql="UPDATE users SET password=? WHERE email =?";
  db.query(sql,[email,hashedPassword],callback);
};