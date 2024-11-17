import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
    final String userId;

  const AboutAppPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
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
          'Sobre o Wave Keeper',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white,
            fontSize: 20.0,
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
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wave Keeper: A Plataforma para Pequenos Produtores Musicais',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Sobre o App: O Wave Keeper é uma plataforma móvel externa para compra e venda de músicas, criada para pequenos e médios produtores independentes. Seu objetivo é eliminar intermediários e permitir que os músicos tenham controle total sobre suas receitas, ao mesmo tempo que facilitam a descoberta de novos artistas pelos consumidores.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Visão: O Wave Keeper surge para resolver os desafios enfrentados pelos músicos independentes, como baixa visibilidade e divisão desigual de lucros, e oferece uma maneira acessível de divulgar e comercializar músicas diretamente com os consumidores.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Tecnologia:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    const Text(
                      'Back-end: Desenvolvido em Java.\nFront-end: Construído com Flutter, garantindo responsividade e usabilidade.\nAutenticação e Banco de Dados: Integração com Supabase.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Futuro do Projeto: O aplicativo pode ser expandido com novas funcionalidades, como recomendações personalizadas de músicas, versão web e novos testes para aprimorar a experiência do usuário.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Introdução:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    const Text(
                      'O mercado musical tem crescido significativamente, especialmente com o aumento das plataformas de streaming, mas pequenos produtores ainda enfrentam dificuldades. O Wave Keeper é uma solução para dar mais autonomia aos músicos independentes, permitindo a venda direta de suas obras, sem intermediários, promovendo maior controle financeiro e visibilidade.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Metodologia:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    const Text(
                      'O Wave Keeper foi desenvolvido com o foco em artistas e produções musicais. Durante seu desenvolvimento, foram realizados protótipos e levantamentos de requisitos com base no feedback dos usuários, além de testes práticos para garantir a melhor experiência possível.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Resultados e Considerações Finais:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    const Text(
                      'O Wave Keeper oferece uma plataforma segura e transparente para que pequenos artistas comercializem suas músicas diretamente com os consumidores, promovendo autonomia e visibilidade. Com infraestrutura escalável e recursos para licenciamento e vendas, o app democratiza o acesso ao mercado musical e facilita o apoio aos músicos independentes.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Conclusão:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    const Text(
                      'Com o Wave Keeper, pequenos e médios produtores têm uma solução prática e eficiente para gerenciar suas músicas e aumentar suas fontes de renda. O aplicativo promove uma nova forma de consumo musical, onde o controle e a transparência são fundamentais para o crescimento dos músicos independentes.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Readex Pro',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
