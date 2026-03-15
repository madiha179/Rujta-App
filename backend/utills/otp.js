import db from '../config/data.js';
import Email from './sendEmail.js';

export const generateOTP=()=>{
  //4-digits
  return Math.floor(1000+Math.random()*9000).toString();
};

export const saveOTP=(email,name,otp,type = 'sendOTP',callback)=>{
  // delete any old otp for this email
  db.query('DELETE FROM otps WHERE email=? ',[email],(err)=>{
    if(err) return callback(err);
    const expiresAt=new Date(Date.now()+10*60*1000);// 10 min
    const sql='INSERT INTO otps (email,otp,expires_at) VALUES (?,?,?)';
    db.query(sql,[email,otp,expiresAt],async(err,result)=>{
      if(err) return callback(err);
      try{
        const user = { email, name };
        const emailInstance = new Email(user, otp);
        if (type === 'resetPassword')
          await emailInstance.sendResetPassword();
        else
          await emailInstance.sendOTP();
        callback(null, result);
      }catch(emailErr){
        callback(emailErr);
      }
    });
  });
};

//verify OTP
export const verifyOTP=(email,otp,callback)=>{
  const sql=`SELECT * FROM otps 
  WHERE email = ? AND otp = ?
  AND expires_at > NOW()
  AND is_used = FALSE
  `;
  db.query(sql,[email,otp],(err,result)=>{
    if(err) return callback(err);
    if(result.length===0) return callback(null,false);
    db.query('UPDATE otps SET is_used=TRUE WHERE email= ?',[email],(err)=>{
      if(err) return callback(err);
      callback(null,true)
    });
  });
};
