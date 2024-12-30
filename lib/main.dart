import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:intershiptask/service.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognito App',
      home: const CognitoUserActions(),
    );
  }
}

class CognitoUserActions extends StatefulWidget {
  const CognitoUserActions({Key? key}) : super(key: key);

  @override
  State<CognitoUserActions> createState() => _CognitoUserActionsState();
}

class _CognitoUserActionsState extends State<CognitoUserActions> {
  final CognitoService _cognitoService = CognitoService();
  String _logMessage = "";
  CognitoUser? _currentUser;
  CognitoUserSession? _currentSession;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final verificationCodeController = TextEditingController();
  late final CognitoUserPool _userPool;

  @override
  void initState() {
    super.initState();
    _userPool = CognitoUserPool(
      dotenv.env['COGNITO_USER_POOL_ID'] ?? 'us-east-1_7awD35IlT',
      dotenv.env['COGNITO_CLIENT_ID'] ?? '78qalg4fnf3f2bvot1prrr34ck',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkCurrentUser();
    });
  }

  Future<void> _checkCurrentUser() async {
    final cognitoUser = await _cognitoService.getCurrentUser();

    if (cognitoUser != null) {
      _setCurrentUser(cognitoUser);
      final session = await _cognitoService.getSession(cognitoUser);
      if (session != null) {
        _setCurrentSession(session);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    verificationCodeController.dispose();
    super.dispose();
  }

  void _setLogMessage(String message) {
    setState(() {
      _logMessage = message;
    });
  }

  void _setCurrentUser(CognitoUser? user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _setCurrentSession(CognitoUserSession? session) {
    setState(() {
      _currentSession = session;
    });
  }

  Future<void> _signUp() async {
    try {
      CognitoUser user = await _cognitoService.signUp(
        emailController.text,
        passwordController.text,
        phoneNumber: phoneController.text,
      );
      _setLogMessage("User ${user.username} signed up. Please confirm the user.");
    } catch (e) {
      _setLogMessage("Error in signing up user. ${e.toString()}");
    }
  }

  Future<void> _signIn() async {
    try {
      CognitoUserSession? session = await _cognitoService.signIn(emailController.text, passwordController.text);
      if(session != null){
        _setCurrentSession(session);
        final currentUser = await _cognitoService.getCurrentUser();
        if(currentUser != null){
          _setCurrentUser(currentUser);
          _setLogMessage("User ${currentUser.username} signed in. Token: ${session.accessToken?.jwtToken}");
        }
      }
    } catch (e) {
      _setLogMessage("Error in sign in user. ${e.toString()}");
    }
  }


  Future<void> _resendVerificationCode() async {
    try{
      await _cognitoService.resendVerificationCode(phoneController.text);
      _setLogMessage("Verification code resent successfully..");
    }
    catch(e){
      _setLogMessage("Error resending confirmation code. ${e.toString()}");
    }
  }

  Future<void> _verifyEmail() async {
    String verificationCode = verificationCodeController.text;

    if (verificationCode.isEmpty) {
      _setLogMessage("Please enter a valid verification code.");
      return;
    }
    try{
      String message = await _cognitoService.confirmUser( verificationCode);//(emailController.text, verificationCode);
      _setLogMessage(message);
    } on CognitoClientException catch (e){
      if(e.code == "CodeMismatchException"){
        _setLogMessage("Error confirming user: Invalid code, please try again.");
        _setLogMessage("Error confirming user: Invalid code, please try again. Do you want to resend code?");
        await _showResendCodeDialog(emailController.text);
      } else {
        _setLogMessage("Error in confirming user. ${e.toString()}");
      }
    }
    catch(e){
      _setLogMessage("Error in confirming user. ${e.toString()}");
    }
  }

  Future<void> _showResendCodeDialog(String email) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Resend Code?"),
              content: const Text("Do you want to resend the code?"),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      try{
                        await  _cognitoService.resendVerificationCode(emailController.text);
                        _setLogMessage("Confirmation code resent. Please confirm again.");
                        Navigator.pop(context);
                      }
                      catch(e){
                        _setLogMessage("Error resending confirmation code. ${e.toString()}");
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Yes")
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")
                )
              ]
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognito User Actions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter an Email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a Phone Number (Optional)',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a Password',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: verificationCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Verification Code',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final phoneNumber = emailController.text; // User's phone number in E.164 format
                  final response = await _cognitoService.resendVerificationCode(phoneNumber);
                  _setLogMessage(response);
                },
                child: const Text('Resend SMS Verification Code'),
              ),
              ElevatedButton(
                onPressed: _verifyEmail,
                child: const Text('Verify Email'),
              ),
              const SizedBox(height: 20),
              Text(_logMessage),
            ],
          ),
        ),
      ),
    );
  }
}