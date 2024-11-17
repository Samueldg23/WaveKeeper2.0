import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  List<String> _currentOptions = [];
  bool _isFirstTime = true; // Controla se é a primeira vez no menu inicial
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _showInitialOptions();
  }

  void _showInitialOptions() {
    setState(() {
      _currentOptions = [
        'Sobre o Wave Keeper',
        'Cadastro e Login',
        'Vendas e Compras de Músicas',
        'Registro Autoral',
        'Contratar Músicos',
        'Outras Perguntas'
      ];
      if (_isFirstTime) {
        _addBotMessage(
            'Olá! Como posso te ajudar hoje? Selecione uma opção abaixo:');
        _isFirstTime = false;
      }
    });
  }

  void sendMessage(String text) {
    _addUserMessage(text);
    _handleUserSelection(text);
  }

  void _addUserMessage(String text) {
    _messages.add({'message': text, 'isUserMessage': true});
    _listKey.currentState?.insertItem(_messages.length - 1);
  }

  void _addBotMessage(String text) {
    _messages.add({'message': text, 'isUserMessage': false});
    _listKey.currentState?.insertItem(_messages.length - 1);
  }

  void _handleUserSelection(String userMessage) {
    switch (userMessage) {
      case 'Sobre o Wave Keeper':
        _showWaveKeeperOptions();
        break;
      case 'O que é o Wave Keeper?':
        _addBotMessage(
            'O Wave Keeper é uma plataforma que apoia pequenos artistas, '
            'facilitando a compra e venda de músicas, letras e beats, além de colaborar com a gestão de carreira.');
        _showBackOption();
        break;
      case 'Quais funcionalidades o Wave Keeper oferece?':
        _addBotMessage(
            'O Wave Keeper oferece controle de vendas, compras, registro autoral, e possibilita a contratação de músicos e produtores.');
        _showBackOption();
        break;
      case 'Como o Wave Keeper ajuda pequenos artistas?':
        _addBotMessage(
            'Oferecemos uma plataforma para que artistas emergentes possam vender suas criações e colaborar com outros músicos e produtores.');
        _showBackOption();
        break;
      case 'Cadastro e Login':
        _showCadastroLoginOptions();
        break;
      case 'Como faço para me cadastrar?':
        _addBotMessage(
            'Você pode se cadastrar no aplicativo acessando a página de login e clicando em "Criar conta".');
        _showBackOption();
        break;
      case 'Esqueci minha senha, o que fazer?':
        _addBotMessage(
            'Você pode recuperar sua senha clicando em "Esqueci minha senha" na tela de login e seguindo as instruções.');
        _showBackOption();
        break;
      case 'Vendas e Compras de Músicas':
        _showVendasComprasOptions();
        break;
      case 'Como vender minhas músicas?':
        _addBotMessage(
            'Para vender suas músicas, crie uma conta, faça o upload das músicas e defina o preço. O Wave Keeper cuidará das transações.');
        _showBackOption();
        break;
      case 'Como comprar músicas no Wave Keeper?':
        _addBotMessage(
            'Navegue pela nossa biblioteca de músicas, escolha a que deseja e siga as etapas para finalizar a compra.');
        _showBackOption();
        break;
      case 'Registro Autoral':
        _showRegistroAutoralOptions();
        break;
      case 'Como funciona o registro autoral no Wave Keeper?':
        _addBotMessage(
            'Nós facilitamos o processo de registro autoral para proteger suas músicas legalmente. Você pode iniciar o processo na plataforma.');
        _showBackOption();
        break;
      case 'Contratar Músicos':
        _showContratarMusicosOptions();
        break;
      case 'Como contratar músicos no Wave Keeper?':
        _addBotMessage(
            'Na nossa versão futura, você poderá encontrar músicos e contratar seus serviços para eventos, festivais, ou bandas.');
        _showBackOption();
        break;
      case 'Outras Perguntas':
        _showOutrasPerguntasOptions();
        break;
      case 'Há custos para usar o Wave Keeper?':
        _addBotMessage(
            'A inscrição no aplicativo é gratuita, mas há taxas associadas às transações de vendas e licenciamento de obras.');
        _showBackOption();
        break;
      case 'Voltar':
        _showInitialOptions();
        break;
      default:
        _addBotMessage(
            'Desculpe, não entendi. Por favor, selecione uma das opções.');
    }
  }

  void _showWaveKeeperOptions() {
    setState(() {
      _currentOptions = [
        'O que é o Wave Keeper?',
        'Quais funcionalidades o Wave Keeper oferece?',
        'Como o Wave Keeper ajuda pequenos artistas?'
      ];
    });
  }

  void _showCadastroLoginOptions() {
    setState(() {
      _currentOptions = [
        'Como faço para me cadastrar?',
        'Esqueci minha senha, o que fazer?'
      ];
    });
  }

  void _showVendasComprasOptions() {
    setState(() {
      _currentOptions = [
        'Como vender minhas músicas?',
        'Como comprar músicas no Wave Keeper?'
      ];
    });
  }

  void _showRegistroAutoralOptions() {
    setState(() {
      _currentOptions = ['Como funciona o registro autoral no Wave Keeper?'];
    });
  }

  void _showContratarMusicosOptions() {
    setState(() {
      _currentOptions = ['Como contratar músicos no Wave Keeper?'];
    });
  }

  void _showOutrasPerguntasOptions() {
    setState(() {
      _currentOptions = ['Há custos para usar o Wave Keeper?'];
    });
  }

  void _showBackOption() {
    setState(() {
      _currentOptions = ['Voltar'];
    });
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
          'Wave Keeper ChatBot',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: Container(
                    alignment: _messages[index]['isUserMessage']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _messages[index]['isUserMessage']
                            ? Colors.purple
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index]['message'],
                        style: TextStyle(
                          color: _messages[index]['isUserMessage']
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey<List<String>>(_currentOptions),
                children: _currentOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () => sendMessage(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(option),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
