import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/profile/aboutApp.dart';
import 'package:wavekeeper/screens/profile/account.dart';
import 'package:wavekeeper/screens/profile/favorites.dart';
import 'package:wavekeeper/screens/profile/privacy.dart';
import 'package:wavekeeper/screens/profile/chatbot.dart';
import 'package:wavekeeper/screens/profile/sales.dart';
import 'package:wavekeeper/screens/profile/viewProfile.dart';
import 'package:wavekeeper/screens/profile/yourMusic.dart';
import 'package:wavekeeper/screens/start/login.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  const ProfileView({super.key, required this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? photoUrl;
  String userName = '';
  String artistName = '';
  String biografia = '';

  final String defaultProfileImageUrl =
      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png';

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
          .select('nome, nome_artistico, biografia, foto_perfil')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userName = response['nome'];
        artistName = response['nome_artistico'];
        biografia = response['biografia'];
        photoUrl = response['foto_perfil'];
      });
        } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(135.0),
  child: AppBar(
    backgroundColor: Colors.black,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.black],
          stops: [0.0, 0.9],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 100.0,
              height: 100.0,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: photoUrl != null
                  ? Image.network(photoUrl!, fit: BoxFit.cover)
                  : Image.network(defaultProfileImageUrl, fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.topLeft, 
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 40.0),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FavoritosPage(userId: widget.userId),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight, 
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 40.0),
              child: IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewProfile(userId: widget.userId),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ),
)
,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter Tight',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.purple, Colors.white],
                      ).createShader(bounds),
                      child: Text(
                        artistName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        biografia,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildBottomProfileSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildBottomProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10.0,
              color: Colors.purple,
              offset: Offset(0.0, 2.0),
            ),
          ],
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Colors.purple, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                'Perfil',
                style: TextStyle(
                  fontFamily: 'Inter Tight',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            buildProfileOption(
              icon: Icons.library_music,
              text: 'Suas músicas',
              onTap: () =>
                  _navigateToPage(context, MyMusicPage(userId: widget.userId)),
            ),
            const SizedBox(height: 10.0),
            buildProfileOption(
              icon: Icons.monetization_on,
              text: 'Vendas e Compras',
              onTap: () => _navigateToPage(context, SalesPage(userId: widget.userId)),
            ),
            const SizedBox(height: 10.0),
            buildProfileOption(
              icon: Icons.account_circle,
              text: 'Conta',
              onTap: () =>
                  _navigateToPage(context, AccountPage(userId: widget.userId)),
            ),
            const SizedBox(height: 10.0),
            buildProfileOption(
              icon: Icons.comment_sharp,
              text: 'Principais dúvidas',
              onTap: () => _navigateToPage(context, const ChatBotPage()),
            ),
            const SizedBox(height: 10.0),
            buildProfileOption(
              icon: Icons.privacy_tip,
              text: 'Privacidade',
              onTap: () =>
                  _navigateToPage(context, PrivacyPage(userId: widget.userId)),
            ),
            const SizedBox(height: 10.0),
            buildProfileOption(
              icon: Icons.more_sharp,
              text: 'Sobre o App',
              onTap: () => _navigateToPage(context, AboutAppPage(userId: widget.userId)),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(userIdCallback: (id) {}),
                      ),
                    );
                  } catch (e) {
                    print("Erro ao fazer logout: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao fazer logout: $e')),
                    );
                  }
                },
                icon: const Icon(
                  Icons.logout_sharp,
                  size: 15.0,
                ),
                label: const Text('Sair'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40.0),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildProfileOption(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}
