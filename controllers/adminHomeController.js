import { addNewDrug,getAllDrugs,updateDrugPriceFromBranch,deleteDrugFromBranch,searchDrugDetailed,getDrugsCount,getTotalStock,getLowStockCount } from "../model/drugsModel.js";
import db from "../config/data.js";
export const getAllDrugsController=(req,res,next)=>{
  const page=parseInt(req.query.page)||1;
  if(page<1) page=1;
  const limit=10;
  const offset=(page-1)*limit;
getDrugsCount((err,totalCount)=>{
  if(err){
    return res.status(500).json({
      status:'error',
      message:err.message
    });
  }
  getAllDrugs(offset,(err,results)=>{
    if(err){
      console.error("Error ",err.message);
      return res.status(500).json({
        status:'error',
        message:'Server Error'
      });
    }
    const totalPages=Math.ceil(totalCount/limit);
    if(results.length===0){
      return res.status(404).json({
        status:'success',
        message:'No Drugs found'
      });
    }
    res.status(200).json({
      status:'success',
      currentPage:page,
      totalPages:totalPages,
      totalItems:totalCount,
      results:results.length,
      data:{
        drugs:results
      }
    });
  });
}) 
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
export const getTotalStockController=(req,res,next)=>{
getTotalStock((err,result)=>{
  if(err) return res.status(500).json({message:err.message});
  res.status(200).json({
    data:result
  });
});
}
export const getLowStockController=(req,res,next)=>{
  getLowStockCount((err,result)=>{
    if(err) return res.status(500).json({message:err.message});
    res.status(200).json({
      data:result
    });
  });
}
export default{getAllDrugs,addNewDrug,updateDrugPriceFromBranch,deleteDrugFromBranch,searchDrugDetailed};