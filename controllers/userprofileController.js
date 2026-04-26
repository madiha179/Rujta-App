import { getUserData,updateUserName,updatePhone,getPass, updatePassword, changePass,getAdminData } from "../model/userModel.js";
import bcrypt from 'bcrypt';
export const getUserDataController=(req,res,next)=>{
  const id=req.user.id;
getUserData(id,(err,result)=>{
  if(err) return res.status(500).json({message:err.message});
  res.status(200).json({
    data:{
      result
    }
  });
});
};

export const updateUserNameController=(req,res,next)=>{
  const id=req.user.id;
  const {name}=req.body;
  updateUserName(name,id,(err,result)=>{
    if(err) return res.status(500).json({message:err.message});
    res.status(200).json({
      data:{
        result
      }
    });
  });
};

export const updatePhoneController=(req,res,next)=>{
  const id=req.user.id;
  const {phone}=req.body;
  updatePhone(phone,id,(err,result)=>{
     if(err) return res.status(500).json({message:err.message});
     res.status(200).json({
      data:{
        result
      }
     });
  });
};

export const updatePasswordController=(req,res,next)=>{
   const id=req.user.id;
   const {currentPassword,newPassword,confirmNewPassword}=req.body;
   if(!currentPassword||!newPassword||!confirmNewPassword)
    return res.status(400).json({message:'please enter current Password,new Password,confirm New Password'});
  if(newPassword!=confirmNewPassword){
    return res.status(400).json({
      message:'new password and confirm password are not match'
    })
  }
 getPass(id,async(err,result)=>{
     if(err) return res.status(500).json({message:err.message});
     if(result.length===0) return res.status(404).json({message:'user not found'});
     const hashedOldPass=result[0].password;
     try{
      const isMatch=await bcrypt.compare(currentPassword,hashedOldPass);
      if(!isMatch){
        return res.status(400).json({message:'password are not correct'});
      }
      const salt=await bcrypt.genSalt(10);
      const newHashedPassword=await bcrypt.hash(newPassword,salt);
      changePass(id,newHashedPassword,(err,updateResult)=>{
        if(err) return res.status(500).json({message:err.message});
        res.status(200).json({message:'password updated successfully'});
      });
     }
     catch(err){
       res.status(500).json({message:err.message});
     }
  });
}
export const getAdminIdController = (req, res) => {
  const id = req.user.id; 
  getAdminData(id, (err, result) => {
    if (err) return res.status(500).json({ message: err.message });
     res.status(200).json({
      adminId: result[0].id
    });
  });
};