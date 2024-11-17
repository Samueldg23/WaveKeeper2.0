import 'package:flutter/material.dart';
import 'package:wavekeeper/entity/user.dart';
import 'package:wavekeeper/navigation/botNavBar.dart';
import 'package:wavekeeper/screens/start/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String WaveKeeperUrl =
      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png';

  final Function(String) userIdCallback;

  LoginScreen({required this.userIdCallback});

  Future<User?> loginWithSupabase(String email, String password) async {
    final response =
        await supabase.Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null && response.user != null) {
      final userId = response.user!.id;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      return User(
        id: userId,
        nome: response.user!.userMetadata?['name'] ?? 'Usuário',
        email: email,
        biografia: "Descrição padrão",
        nomeArtistico: "Nome padrão",
        cpf: '',
        telefone: '',
        cidade: '',
        tipo: '',
      );
    } else {
      print('Erro no login: Login falhou.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple,
              Colors.black,
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: [
                const SizedBox(height: 20),
                Image.network(
                  WaveKeeperUrl,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                ),
                const Text(
                  'Wave Keeper',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(emailController, 'Digite seu e-mail', false),
                  const SizedBox(height: 30),
                  const Text(
                    'Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(passwordController, 'Digite sua senha', true),
                  const SizedBox(height: 50),
                  _buildLoginButton(context),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildForgotPasswordButton(),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: _buildRegisterButton(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo não pode estar vazio';
          }
          if (isPassword && value.length < 6) {
            return 'A senha deve ter pelo menos 6 caracteres';
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(174, 82, 200, 1.0),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: TextButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            String email = emailController.text;
            String password = passwordController.text;

            User? user = await loginWithSupabase(email, password);

            if (user != null) {
              userIdCallback(
                user.id ?? '',
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavBar(
                    userId: user.id ?? '',
                    initialIndex:
                        0,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Erro ao fazer login, verifique suas credenciais.',
                  ),
                ),
              );
            }
          }
        },
        child: const Text(
          'Entrar',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        'Esqueceu a senha?',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        );
      },
      child: const Text(
        'Inscreva-se',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
