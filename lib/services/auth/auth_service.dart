
class AuthService{
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return email == 'test@example.com' && password == '123456';
  }
}