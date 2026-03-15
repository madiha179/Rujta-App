import express from "express";
import mysql from "mysql2";
import dotenv from "dotenv";
dotenv.config({path:'config.env'});
const app=express();
const host=process.env.HOST;
const dbPort=process.env.DBPORT;
const user=process.env.USER;
const password=process.env.PASSWORD;
const port=process.env.PORT;
app.use(express.json());
const connection=mysql.createConnection({
  host:host,
  port:dbPort,
  user:user,
  password:password
});
connection.connect((err)=>{
if(!err){
  console.log('✅ DB connection successful')}
  else{
    console.log('❌ DB connection error:',err)
  }
});
app.listen(port,()=>{
  console.log(`app working on ${port} ✅`)
});