import bcrypt from 'bcrypt';
import { createUser, findUser, verifyUserEmail, updatePassword } from '../model/userModel.js';
import jwt from 'jsonwebtoken';
import {promisify} from 'util'
import { validatePassword, validateConfirmPassword } from '../utills/validators.js';
import { generateOTP, saveOTP, verifyOTP } from '../utills/otp.js';
import db from '../config/data.js';

const signToken = id => {
  return jwt.sign({ id }, process.env.ACCESSTOKEN, {
    expiresIn: process.env.JWT_EXPIRESIN
  });
};

const createSendToken = (user, statusCode, res) => {
  const token = signToken(user.id);

  const cookieOptions = {
    expires: new Date(Date.now() + Number(process.env.JWT_COOKIE_EXPIRES) * 24 * 60 * 60 * 1000),
    httpOnly: true,
  };

  if (process.env.NODE_ENV === 'production')
    cookieOptions.secure = true;

  res.cookie('jwt', token, cookieOptions);
  user.password = undefined;
  res.status(statusCode).json({
    status: 'success',
    token,
    data: { user }
  });
};

export const registerUser = async (req, res) => {
  const { name, email, password, confirmPassword, phone } = req.body;

  if (!validatePassword(password))
    return res.status(400).json({ message: "Password must be at least 8 characters and include uppercase, lowercase, number, and special character" });
  if (!validateConfirmPassword(password, confirmPassword))
    return res.status(400).json({ message: "Passwords do not match" });

  findUser(email, (err, result) => {
    if (err) return res.status(500).json({ message: err.message });
    if (result.length > 0)
      return res.status(400).json({ message: "Email already in use" });

    bcrypt.hash(password, 10, (err, hashedPassword) => {
      if (err) return res.status(500).json({ message: err.message });

      createUser(name, email, phone, hashedPassword, "customer", (err, result) => {
        if (err) return res.status(500).json({ message: err.message });

        const otp = generateOTP();
        saveOTP(email, name, otp, 'sendOTP', (err) => {
          if (err) return res.status(500).json({ message: err.message });
          res.status(201).json({ message: "Registration successful. OTP sent to your email." });
        });
      });
    });
  });
};

export const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "Please provide email and password" });

  findUser(email, (err, result) => {
    if (err) return res.status(500).json({ message: err.message });
    if (result.length === 0)
      return res.status(401).json({ message: "Invalid email or password" });

    const user = result[0];
    if (!user.is_verified)
      return res.status(403).json({ message: 'Please verify your email first' });

    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err || !isMatch)
        return res.status(401).json({ message: "Invalid email or password" });
      createSendToken(user, 200, res);
    });
  });
};

export const requestOTP = async (req, res) => {
  const { email } = req.body;
  if (!email)
    return res.status(400).json({ message: 'Please provide email' });

  findUser(email, (err, result) => {
    if (err) return res.status(500).json({ message: err.message });
    if (result.length === 0)
      return res.status(404).json({ message: 'No account found with this email' });

    const user = result[0];
    const otp = generateOTP();
    saveOTP(email, user.name, otp, 'sendOTP', (err) => {
      if (err) return res.status(500).json({ message: err.message });
      res.status(200).json({ message: 'OTP sent to your email' });
    });
  });
};

export const verifyEmail = (req, res) => {
  const { otp } = req.body;
  if (!otp)
    return res.status(400).json({ message: "Please provide OTP" });

  db.query(
    'SELECT * FROM otps WHERE otp = ? AND expires_at > NOW() AND is_used = FALSE',
    [otp],
    (err, result) => {
      if (err) return res.status(500).json({ message: err.message });
      if (result.length === 0)
        return res.status(400).json({ message: "Invalid or expired OTP" });

      const email = result[0].email;
      db.query('UPDATE otps SET is_used = TRUE WHERE otp = ?', [otp], (err) => {
        if (err) return res.status(500).json({ message: err.message });

        verifyUserEmail(email, (err) => {
          if (err) return res.status(500).json({ message: err.message });

          findUser(email, (err, result) => {
            if (err) return res.status(500).json({ message: err.message });
            createSendToken(result[0], 200, res);
          });
        });
      });
    }
  );
};

export const verifyUserOTP = (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp)
    return res.status(400).json({ message: 'Please provide email and OTP' });

  verifyOTP(email, otp, (err, isValid) => {
    if (err) return res.status(500).json({ message: err.message });
    if (!isValid)
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    res.status(200).json({ message: 'OTP verified successfully' });
  });
};

export const forgotPassword = (req, res) => {
  const { email } = req.body;
  if (!email)
    return res.status(400).json({ message: 'Please provide email' });

  findUser(email, (err, result) => {
    if (err) return res.status(500).json({ message: err.message });
    if (result.length === 0)
      return res.status(404).json({ message: 'No account found with this email' });

    const user = result[0];
    const otp = generateOTP();
    saveOTP(email, user.name, otp, 'resetPassword', (err) => {
      if (err) return res.status(500).json({ message: err.message });
      res.status(200).json({ message: 'OTP sent to your email' });
    });
  });
};

export const verifyResetOTP = (req, res) => {
  const { otp } = req.body;
  if (!otp)
    return res.status(400).json({ message: 'Please provide OTP' });

  db.query(
    'SELECT * FROM otps WHERE otp = ? AND expires_at > NOW() AND is_used = FALSE',
    [otp],
    (err, result) => {
      if (err) return res.status(500).json({ message: err.message });
      if (result.length === 0)
        return res.status(400).json({ message: 'Invalid or expired OTP' });

      const email = result[0].email;
      db.query('UPDATE otps SET is_used = TRUE WHERE otp = ?', [otp], (err) => {
        if (err) return res.status(500).json({ message: err.message });

        const resetToken = jwt.sign({ email }, process.env.ACCESSTOKEN, { expiresIn: '10m' });
        res.status(200).json({
          message: 'OTP verified successfully',
          token: resetToken
        });
      });
    }
  );
};

export const resetPassword = (req, res) => {
  const { token } = req.params;
  const { newPassword, confirmPassword } = req.body;

  if (!newPassword || !confirmPassword)
    return res.status(400).json({ message: 'Please provide all fields' });
  if (!validatePassword(newPassword))
    return res.status(400).json({ message: 'Password must be at least 8 characters and include uppercase, lowercase, number, and special character' });
  if (!validateConfirmPassword(newPassword, confirmPassword))
    return res.status(400).json({ message: 'Passwords do not match' });

  let email;
  try {
    const decoded = jwt.verify(token, process.env.ACCESSTOKEN);
    email = decoded.email;
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired session. Please try again.' });
  }

  bcrypt.hash(newPassword, 10, (err, hashedPassword) => {
    if (err) return res.status(500).json({ message: err.message });

    updatePassword(email, hashedPassword, (err) => {
      if (err) return res.status(500).json({ message: err.message });

      findUser(email, (err, result) => {
        if (err) return res.status(500).json({ message: err.message });
        createSendToken(result[0], 200, res);
      });
    });
  });
};
export const restrictTO=(...roles)=>{
 return (req,res,next)=>{
  if(!roles.includes(req.user.role)){
    return res.status(403).json({
      message:"You do not have permission to perform this action "
    });
  }
  next();
 };
};
export const protect=async (req,res,next)=>{
  let token;
  if(req.headers.authorization&&req.headers.authorization.startsWith('Bearer'))
    {
      token=req.headers.authorization.split(' ')[1];
  }
  if(!token){
    return res.status(401).json({
      message:"you're not logged in! please login again to get access"
    });
  }
  try{
  const decoded=await promisify(jwt.verify)(token,process.env.ACCESSTOKEN);
  db.query('SELECT * FROM users WHERE id=?',[decoded.id],(err,result)=>{
    if(err||result.length===0){
      return res.status(401).json({ message: 'User no longer exist' });
    }
    req.user = result[0];
    next();
  });

  }
  catch(err){
    return res.status(401).json({ message: 'Invalid token or expired. Please log in again.' });
  }
}
export default {registerUser,login,verifyEmail,forgotPassword,verifyResetOTP,resetPassword,protect,restrictTO};