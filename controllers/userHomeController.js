import { findAllDrugsByLocation ,searchDrugNameByLocation} from "../model/drugs-userModel.js";
import db from "../config/data.js";
export const getAllDrugsByLocationController=(req,res,next)=>{
  const userLat=parseFloat(req.params.lat);
  const userLang=parseFloat(req.params.lng);
  if(!userLat||!userLang)
  {
    return res.status(400).json({
      message:'User location(lat,lng) is required'
    });
  }
  findAllDrugsByLocation(userLang,userLat,(err,result)=>{
    if(err)
      return res.status(500).json({
    message:err.message});
    const protocol=req.protocol;
    const host=req.get('host');
    const updatedResult=result.map(drug=>({
      ...drug,
      image_url:drug.image_url ? `${protocol}://${host}/${drug.image_url}`:null
    }))
    res.status(200).json({
      status:'success',
      results:result.length,
      data:{
        data:updatedResult
      }
    });
  });
};

export const searchDrugByLocationController=(req,res,next)=>{
  const userLat=parseFloat(req.params.lat);
  const userLang=parseFloat(req.params.lng);
  const key=req.params.key;
  if(!userLat||!userLang)
  {
    return res.status(400).json({
      message:'User location(lat,lng) is required'
    });
  }
  searchDrugNameByLocation(key,userLang,userLat,(err,result)=>{
    if(err)
      return res.status(500).json({
    message:err.message
      });
      if(result.length===0){
        return res.status(400).json({
          message:'This drug is out of stock'
        });
      }
      const protocol=req.protocol;
    const host=req.get('host');
    const updatedResult=result.map(drug=>({
      ...drug,
      image_url:drug.image_url ? `${protocol}://${host}/${drug.image_url}`:null
    }))
      res.status(200).json({
        status:'success',
        result:result.length,
        data:{
          data:updatedResult
        }
      });
  });
};