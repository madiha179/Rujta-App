import db from '../config/data.js';

export const createUser = (name, email, phone, hashedPassword, role = "customer", callback) => {
  const sql = "INSERT INTO users(name,email,password,role,phone) VALUES (?,?,?,?,?)";
  db.query(sql, [name, email, hashedPassword, role, phone], callback);
};

export const findUser = (email, callback) => {
  const sql = "SELECT * FROM users WHERE email=?";
  db.query(sql, [email], callback);
};

export const verifyUserEmail = (email, callback) => {
  const sql = "UPDATE users SET is_verified = TRUE WHERE email = ?";
  db.query(sql, [email], callback);
};

export const updatePassword = (email, hashedPassword, callback) => {
  const sql = "UPDATE users SET password = ? WHERE email = ?";
  db.query(sql, [hashedPassword, email], callback); 
};
export const getUserData=(id,callback)=>{
  const sql= `SELECT email,name,phone
  FROM users
  WHERE id=?;`;
db.query(sql,[id],callback);
};
export const updateUserName=(name,id,callback)=>{
  const sql=`UPDATE users 
  SET name=?
  WHERE id=?;
  `;
  db.query(sql,[name,id],callback);
};
export const updatePhone=(phone,id,callback)=>{
  const sql=`UPDATE users 
  SET phone=?
  WHERE id=?;
  `;
  db.query(sql,[phone,id],callback);
};
export const getPass=(id,callback)=>{
  const sql=`SELECT password
  FROM users
  WHERE id=?;
  `;
  db.query(sql,[id],callback);
};
export const changePass=(id,hashedPassword,callback)=>{
const sql=`UPDATE users SET password=? WHERE id=?`;
db.query(sql,[hashedPassword,id],callback);
};
export const getAdminData = (id, callback) => {
  const sql = "SELECT id, name, email FROM users WHERE id = ? AND role = 'admin'";
  db.query(sql, [id], callback);
};