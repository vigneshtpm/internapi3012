import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class CognitoService {
  late CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  String? username;
  CognitoService() {
    _userPool = CognitoUserPool(
      dotenv.env['USER_POOL_ID']!,
      dotenv.env['CLIENT_ID']!,
    );
    _cognitoUser = CognitoUser(null, _userPool);
  }

  Future<CognitoUser> signUp(String email, String password,
      {String? phoneNumber}) async {
    final userAttributes = <AttributeArg>[];
    userAttributes.add(AttributeArg(name: 'email', value: email));
    if (phoneNumber != null) {
      userAttributes
          .add(AttributeArg(name: 'phone_number', value: phoneNumber));
    }

    var uuid = const Uuid();
    //final String userName = email;  //uuid.v4();
    username=uuid.v4();
    final CognitoUserPoolData userPoolData = await _userPool
        .signUp(username!, password, userAttributes: userAttributes);
    return userPoolData.user;
  }

  Future<CognitoUserSession?> signIn(String email, String password) async {
    //final cognitoUser = CognitoUser(email, _userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    return  _cognitoUser?.authenticateUser(authDetails);
  }

  Future<void> signOut(CognitoUser user) async {
    return user.signOut();
  }

  Future<CognitoUser?> getCurrentUser() async {
    return await _userPool.getCurrentUser();
  }

  Future<CognitoUserSession?> getSession(CognitoUser user) async {
    return await user.getSession();
  }

  Future<String> confirmUser( String verificationCode) async {
    if (verificationCode.isEmpty) {
      throw Exception('Verification code cannot be empty');
    }

    //final cognitoUser =  CognitoUser(email, _userPool);

    _cognitoUser = CognitoUser(username, _userPool);

    try {
      await  _cognitoUser?.confirmRegistration(verificationCode);
      return "User confirmed successfully.";
    } catch (e) {
      return "Error confirming user: ${e.toString()}";
    }

  }

  Future<String> resendVerificationCode(String email) async {
    print('Resending code for phone number: $email');

    try {
      // Create a Cognito user with the phone number
      final cognitoUser = CognitoUser(email, _userPool);

      // Resend the confirmation code
      print('Attempting to resend confirmation code...');
      await cognitoUser.resendConfirmationCode();
      print('Confirmation code resent successfully');
      return "Verification code resent successfully via SMS.";
    } catch (e) {
      // Log and return any errors encountered
      print('Error in resending verification code: ${e.toString()}');
      return "Error in resending verification code: ${e.toString()}";
    }
  }


  Future<void> forgotPassword(String email) async {
    final cognitoUser = CognitoUser(email, _userPool);
    await cognitoUser.forgotPassword();
  }

  Future<void> confirmPassword(
      String email, String newPassword, String verificationCode) async {
    final cognitoUser = CognitoUser(email, _userPool);
    await cognitoUser.confirmPassword(verificationCode, newPassword);
  }

  Future<String> verifyUser(String email, String verificationCode) async {
    try {
      final cognitoUser = CognitoUser(email, _userPool);
      await cognitoUser.confirmRegistration(verificationCode);
      return "User confirmed successfully.";
    } catch (e) {
      return "Error confirming user: ${e.toString()}";
    }
  }

  CognitoUserPool get cognitoUserPool => _userPool;
}
