import mysql from "mysql2";
import dotenv from "dotenv";
dotenv.config({path:'config.env'});
const host=process.env.HOST;
const dbPort=process.env.DBPORT;
const user=process.env.USER;
const password=process.env.PASSWORD;
const db=mysql.createConnection({
  host:host,
  port:dbPort,
  user:user,
  password:password,
  database: process.env.DATABASE
});
db.connect((err)=>{
if(!err){
  console.log('✅ DB connection successful')}
  else{
    console.log('❌ DB connection error:',err)
  }
});
export default db;