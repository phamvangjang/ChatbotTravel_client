
class AuthService{
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return email == 'giang@gmail.com' && password == '123456';
  }
}