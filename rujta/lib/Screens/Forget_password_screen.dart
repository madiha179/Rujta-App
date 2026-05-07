import 'package:Rujta/core/constants.dart';
import 'package:Rujta/view_model/Forget_password_view_model.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _nameState();
}

class _nameState extends State<ForgetPasswordScreen> {
  final ForgetPasswordViewModel viewModel=ForgetPasswordViewModel();

  void _goBackToLogin(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/login');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBackToLogin(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top:64,left: 20,right: 20 ),
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
        SizedBox(height:64 ),
            Center(
              child: Text('Forgot Password',
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
                      
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(child: 
            Text('Enter your email account to reset your password',
            style: TextStyle(color: Colors.grey),),
            )
            ,SizedBox(height: 64,),
            TextField(controller: viewModel.emailController,
                decoration: InputDecoration(
    labelText: "Email",
   // border: OutlineInputBorder(),
  ),
            ),
            SizedBox(height: 42,),
  GestureDetector(
  onTap: (){
    viewModel.resetPassword(context);
  },
    child: Container(
    
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: kMainColor),
    child: Center(child: Text('Reset Password',
    style: TextStyle(color: Colors.white),)),),
  )
       ] ),
      ),
    );
  }
}