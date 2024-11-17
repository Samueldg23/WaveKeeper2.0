import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/start/login.dart';

class PrivacyPage extends StatefulWidget {
  final String userId;

  const PrivacyPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<PrivacyPage> {
  bool isProfileVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    print("userId atual: ${widget.userId}");
    if (widget.userId.isEmpty ||
        !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.userId)) {
      print("Erro: userId inválido");
      return;
    }
    try {
      final response = await supabase
          .from('usuario')
          .select('ativo')
          .eq('id', widget.userId)
          .single();

      if (response['ativo'] != null) {
        setState(() {
          isProfileVisible = response['ativo']; 
        });
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('usuario').update({
        'ativo': isProfileVisible,
      }).eq('id', widget.userId);

      print('Perfil atualizado com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar o perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar o perfil.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('usuario').delete().eq('id', widget.userId);
      print('Conta excluída com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  userIdCallback: (int) {},
                )),
      );
    } catch (e) {
      print('Erro ao excluir a conta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir a conta.')),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
              'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Privacidade',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white,
            letterSpacing: 0.0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              stops: [0.2, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrivacidadeBody(
              isProfileVisible: isProfileVisible,
              onToggleVisibility: (newValue) {
                setState(() {
                  isProfileVisible = newValue;
                });
              },
              onSave: _updateUserProfile,
              onDeleteAccount: _confirmDeleteAccount,
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacidadeBody extends StatelessWidget {
  final bool isProfileVisible;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onSave;
  final VoidCallback onDeleteAccount;

  const PrivacidadeBody({
    Key? key,
    required this.isProfileVisible,
    required this.onToggleVisibility,
    required this.onSave,
    required this.onDeleteAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Controle quem pode ver o seu perfil no aplicativo.',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Colors.black,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SwitchListTile.adaptive(
          value: isProfileVisible,
          onChanged: onToggleVisibility,
          title: const Text(
            'Mostrar perfil para outros usuários',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Permite que outros usuários encontrem seu perfil no aplicativo.',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Colors.black.withOpacity(0.7),
              fontSize: 14.0,
            ),
          ),
          tileColor: Colors.white,
          activeColor: Colors.white,
          activeTrackColor: Colors.purple[200],
          dense: false,
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(170.0, 50.0),
            backgroundColor: Colors.purple,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text(
            'Salvar Alterações',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: onDeleteAccount,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(170.0, 50.0),
            backgroundColor: Colors.red,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text(
            'Excluir Conta',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
