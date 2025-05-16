
class AuthService{
  bool? _isLoggedIn;

  Future<bool?> isLoggedIn() async{
    await Future.delayed(Duration(seconds: 2));
    return _isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'giang@gmail.com' && password == '123456') {
      _isLoggedIn = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
  }
}