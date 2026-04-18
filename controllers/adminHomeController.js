import { addNewDrug,getAllDrugs,updateDrugPriceFromBranch,deleteDrugFromBranch,searchDrugDetailed } from "../model/drugsModel.js";
import db from "../config/data.js";
export const getAllDrugsController=(req,res,next)=>{
  getAllDrugs((err,results)=>{
    if(err){
      console.error("Error ",err.message);
      return res.status(500).json({
        status:'error',
        message:'Server Error'
      });
    }
    if(results.length===0){
      return res.status(404).json({
        status:'success',
        message:'No Drugs found'
      });
    }
    res.status(200).json({
      status:'success',
      results:results.length,
      data:{
        drugs:results
      }
    });
  });
};
export const addNewDrugController=(req,res,next)=>{
  const {name,expDate,price,branchId,quantity}=req.body;
  addNewDrug(name,expDate,branchId,price,quantity,(err,results)=>{
    if(err) return res.status(500).json({message:err.message});
    res.status(201).json({
      status:'success',
      message:'Drug added successfully'
    })
  })};
  export const updateDrugController=(req,res,next)=>{
    const {newPrice,quantity}=req.body;
    const {drugId,branchId}=req.params;
    if(!drugId||!branchId){
      return res.status(400).json({
        message:'Please provide branch id and drug id'
      });
    }
    updateDrugPriceFromBranch(branchId,drugId,newPrice,quantity,(err,result)=>{
      if(err) return res.status(500).json({message:err.message});
      if(result.affectedRows === 0){
        return res.status(404).json({
          status:'fail',
          message:'Update failed. Drug not found in this branch'
        })
      }
      res.status(200).
      json(
        {
          message:"Drug updated successfully",
          data:result
        });
    });
  }
  export const deleteDrugController=(req,res,next)=>{
   const {drugId,branchId}=req.params;
    if(!drugId||!branchId){
      return res.status(400).json({
        message:'Please provide branch id and drug id'})
  }
  deleteDrugFromBranch(branchId,drugId,(err,result)=>{
    if(err) return res.status(500).json({message:err.message});
    res.status(204).json({
      message:'Drug delete successfully'
    });
  });
}
export const searchDrugController=(req,res,next)=>{
  const key=req.params.key;
  searchDrugDetailed(key,(err,result)=>{
    if(err) return res.status(500).json({message:err.message});
    res.status(200).json({
      data:result
    });
  });
}
export default{getAllDrugs,addNewDrug,updateDrugPriceFromBranch,deleteDrugFromBranch,searchDrugDetailed};