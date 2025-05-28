
class AuthService{
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return email == 'giang@gmail.com' && password == '123456';
  }

  Future<bool> register(String username ,String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return username == 'van giang' && email == 'giang@gmail.com' && password == '123456';
  }
}