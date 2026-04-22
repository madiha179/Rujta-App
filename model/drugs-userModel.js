import db from "../config/data.js";
export const findAllDrugsByLocation=(userlang,userlatt,callback)=>{
  const sql=`SELECT 
  d.name AS drug_name,
  p.name AS pharmacy_name,
  d.imgae_url AS image_url,
  bd.price AS drug_price,
  (ST_Distance_Sphere(
  point(b.longitude, b.latitude),
  point(?,?)
  )/1000) AS distance_km
  FROM branch_drugs bd
  JOIN branches b ON bd.branch_id=b.id
  JOIN drugs d ON bd.drug_id =d.id
  JOIN 
pharmacies p ON b.pharmacy_id = p.id
  ORDER BY distance_km ASC
 ;
  `
  db.query(sql,[userlang,userlatt],callback);
};

export const searchDrugNameByLocation=(word,userlang,userlatt,callback)=>{
 const sql=`
 SELECT d.name AS drug_name,
 bd.price AS drug_price,
 d.imgae_url AS image_url,
 p.name AS pharmacy_name,
 (ST_Distance_sphere(
 point(b.longitude,b.latitude),
 point(?,?)
 )/1000) AS distance_km
 FROM branch_drugs bd
 JOIN branches b ON bd.branch_id=b.id
 JOIN drugs d ON bd.drug_id=d.id
 JOIN pharmacies p ON b.pharmacy_id=p.id
  WHERE d.name LIKE ?
 ORDER BY distance_km ASC;
 `
 db.query(sql,[userlang,userlatt,`%${word}%`],callback);
};