import db from "../config/data.js";

export const addNewDrug=(name,exp_date,branch_id,price,quantity,callback)=>{
  const sqlDrug="INSERT INTO drugs(name,exp_date) VALUES(?,?)";
  db.query(sqlDrug,[name,exp_date],(err,result)=>{
    if(err) return callback(err);
    const newDrugId=result.insertId;
    const sqlPrice=`INSERT INTO branch_drugs (branch_id, drug_id, price, quantity)
    VALUES(?,?,?,?);`
    db.query(sqlPrice,[branch_id,newDrugId,price,quantity],(err,res)=>{
      if (err) return callback(err);
      callback(null,res);
    })
  });
};
export const getDrugsCount=(callback)=>{
  const sql=`SELECT COUNT(*) AS total FROM branch_drugs`;
  db.query(sql,(err,result)=>{
    if(err)
      return callback(err);
    callback(null,result[0].total);
  });
};
export const getAllDrugs=(offset,callback)=>{
  const sql= `SELECT
p.name AS pharmacy_name,
b.id AS branchId,
b.address AS branch_address,
d.name AS drug_name,
d.id AS drugId,
bd.price AS price,
d.exp_date AS exp_date
FROM 
branch_drugs bd
JOIN 
branches b ON bd.branch_id=b.id
JOIN
drugs d ON bd.drug_id =d.id
JOIN 
pharmacies p ON b.pharmacy_id = p.id
LIMIT 10 OFFSET ?
; `;
db.query(sql,[offset],callback)
};

export const updateDrugPriceFromBranch=(branchId,drugId,newPrice,quantity,callback)=>{
const sql=`UPDATE branch_drugs
SET price=?,quantity=?
WHERE branch_id=? AND drug_id=?
`;
db.query(sql,[newPrice, quantity, branchId, drugId],callback);
};

export const deleteDrugFromBranch=(branchId, drugId, callback) => {
  const sql = `DELETE FROM 
  branch_drugs
   WHERE branch_id = ? AND drug_id = ?`;
  db.query(sql, [branchId, drugId], callback);
};

export const searchDrugDetailed=(searchWord,callback)=>{
  const sql=`SELECT p.name AS pharmacy_name, b.address AS branch_address, d.name AS drug_name , bd.price ,d.id AS drugId ,b.id AS branchId
  FROM branch_drugs bd
  JOIN drugs d ON bd.drug_id=d.id
  JOIN branches b ON bd.branch_id=b.id
  JOIN pharmacies p ON b.pharmacy_id=p.id
  WHERE d.name LIKE ?
  `
  db.query(sql,[`%${searchWord}%`],callback);
};
export const getTotalStock=(callback)=>{
  const sql=`SELECT SUM(quantity) AS Total_Stock
FROM branch_drugs;
`
db.query(sql,callback);
};
export const getLowStockCount=(callback)=>{
  const sql=`SELECT COUNT(quantity) AS Low_Stock 
FROM branch_drugs
WHERE quantity<20;`
db.query(sql,callback);
};