import express from "express";
import dotenv from "dotenv";
import db from './config/data.js';
import swaggerDOC from "./swagger/swaggerDOC.js";
import authRout from "./routes/authRout.js";
import  {adminHomeRouter}  from "./routes/adminHomeRoute.js";
import { userHomeRouter } from "./routes/userHomeRoute.js";
dotenv.config({path:'config.env'});
const app=express();
const port=process.env.PORT||3000;
app.use(express.json());
app.use('/images',express.static('view/images'));
swaggerDOC(app);
app.use('/api/v1/users',authRout);
app.use('/api/v1/admin',adminHomeRouter);
app.use('/api/v1/users',userHomeRouter);
app.listen(port,()=>{
  console.log(`app working on ${port} ✅`)
});