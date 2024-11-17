import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/start/login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController biografiaController = TextEditingController();
  final TextEditingController nomeArtisticoController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  String? _selectCity;
  String? _selectType;
  final bool ativo = true;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final String defaultProfileImageUrl =
      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      await supabase.storage
          .from('wavekeeper/users_images')
          .upload(fileName, image);
      final urlResponse = supabase.storage
          .from('wavekeeper/users_images')
          .getPublicUrl(fileName);
      return urlResponse;
    } catch (e) {
      print('Erro durante o upload da imagem: $e');
      return null;
    }
  }

  Future<void> registerUser() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        String? imageUrl = defaultProfileImageUrl;

        if (_selectedImage != null) {
          final uploadedImageUrl = await _uploadImage(_selectedImage!);
          if (uploadedImageUrl != null) {
            imageUrl = uploadedImageUrl;
          }
        }

      print("Cidade selecionada: $_selectCity");
      print("Tipo selecionado: $_selectType");
      String city = _selectCity ?? 'Vitória';  
      String type = _selectType ?? 'Produtor Musical'; 

        await createUserInDatabase(
          response.user!.id,
          nomeController.text,
          emailController.text,
          biografiaController.text,
          imageUrl,
          nomeArtisticoController.text,
          cpfController.text,
          telefoneController.text,
          city,
          type,
        );
      } else {
        print('Falha ao registrar usuário.');
      }
    } catch (e) {
      print('Erro ao registrar usuário: $e');
    }
  }

     

  Future<void> createUserInDatabase(
    String userId,
    String nome,
    String email,
    String? biografia,
    String? fotoPerfil,
    String nomeArtistico,
    String cpf,
    String telefone,
    city,
    type,
  ) async {
    try {
      await Supabase.instance.client.from('usuario').insert({
        'id': userId,
        'nome': nome,
        'email': email,
        'biografia': biografia,
        'foto_perfil': fotoPerfil,
        'ativo': true,
        'nome_artistico': nomeArtistico,
        'CPF': cpf,
        'telefone': telefone,
        'cidade': city, 
        'tipo': type,
      });

      print('Usuário registrado com sucesso no banco de dados!');
    } catch (e) {
      print('Erro ao registrar usuário: $e');
    }
  }

  String? _selectedCity = 'Vitória'; 
  String? _selectedType = 'Artista'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 25.0),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Wave Keeper',
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : NetworkImage(defaultProfileImageUrl) as ImageProvider,
                    backgroundColor: Colors.grey[300],
                    child: _selectedImage == null
                        ? Icon(Icons.add_a_photo, color: Colors.black, size: 40)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(' Nome', nomeController, TextInputType.name,
                  'Digite seu nome'),
              SizedBox(height: 10),
              _buildTextField(' E-mail', emailController,
                  TextInputType.emailAddress, 'Digite um e-mail válido'),
              SizedBox(height: 10),
              _buildPasswordField(' Senha', passwordController),
              SizedBox(height: 10),
              _buildPasswordField(' Confirmar Senha', confirmPasswordController,
                  validator: (value) {
                if (value != passwordController.text) {
                  return 'As senhas não correspondem';
                }
                return null;
              }),
              SizedBox(height: 10),
              _buildTextField(' Biografia', biografiaController,
                  TextInputType.text, 'Adicione uma biografia'),
              SizedBox(height: 10),
              _buildTextField(' Nome Artístico', nomeArtisticoController,
                  TextInputType.text, 'Adicione um nome artístico'),
              SizedBox(height: 10),
              _buildTextField(' CPF', cpfController, TextInputType.number,
                  'Adicione seu CPF'),
              SizedBox(height: 10),
              _buildTextField('Telefone', telefoneController,
                  TextInputType.phone, 'Adicione seu telefone'),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue!;
                  });
                },
                items: [
                  'Vitória',
                  'Vila Velha',
                  'Serra',
                  'Cariacica',
                  'Viana',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.purple),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                items: [
                  'Artista',
                  'Músico',
                  'Beatmaker',
                  'Produtor de conteúdo',
                  'Youtuber',
                  'Produtor musical',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.purple),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType type, String validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color.fromARGB(255, 85, 85, 85)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            validator: (value) =>
                value == null || value.isEmpty ? validationMessage : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color.fromARGB(255, 85, 85, 85)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: true,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(174, 82, 200, 1.0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        child: Text('Registrar-se',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            await registerUser();

            await Future.delayed(Duration(seconds: 1));

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(
                        userIdCallback: (int) {},
                      )),
            );
          } else {
            print("Formulário inválido");
          }
        },
      ),
    );
  }
}
