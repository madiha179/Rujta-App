import express from "express";
import dotenv from "dotenv";
import db from './config/data.js';
import swaggerDOC from "./swagger/swaggerDOC.js";
import authRout from "./routes/authRout.js";
dotenv.config({path:'config.env'});
const app=express();
const port=process.env.PORT||3000;
app.use(express.json());
swaggerDOC(app);
app.use('/api/v1/users',authRout);
app.listen(port,()=>{
  console.log(`app working on ${port} ✅`)
});