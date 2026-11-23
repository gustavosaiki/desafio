
import 'dart:io';

import 'package:supabase/supabase.dart';

import '../lib/conexao.dart';
import '../lib/veiculos.dart';

Future<void> main() async {
  SupabaseClient? cliente;

  try {
    cliente = await conectar();

    print('Conectado ao Supabase com sucesso!');

    bool rodando = true;

    while (rodando) {
      print('\n========== CADASTRO DE VEÍCULOS ==========');
      print('1 - Cadastrar veículo');
      print('2 - Listar veículos');
      print('3 - Atualizar veículo');
      print('4 - Excluir veículo');
      print('0 - Sair');

      stdout.write('O que deseja fazer? ');

      String? opcao = stdin.readLineSync()?.trim();

      try {
        switch (opcao) {
          case '1':
            await tratarCadastro(cliente);
            break;

          case '2':
            await tratarListagem(cliente);
            break;

          case '3':
            await tratarAtualizacao(cliente);
            break;

          case '4':
            await tratarExclusao(cliente);
            break;

          case '0':
            print('Sistema encerrado.');
            rodando = false;
            break;

          default:
            print('Opção inválida. Tente novamente.');
        }
      } on FormatException catch (e) {
        print(e.message);
      } catch (e) {
        print('Ocorreu um erro durante a operação: $e');
      }
    }
  } catch (e) {
    print('Erro ao conectar com o Supabase: $e');
  } finally {
    if (cliente != null) {
      await cliente.dispose();
    }
  }
}

// ==========================================
// CADASTRAR VEÍCULO
// ==========================================

Future<void> tratarCadastro(SupabaseClient cliente) async {
  print('\n========== CADASTRAR VEÍCULO ==========');

  String marca = lerTexto('Marca: ', 50);
  String modelo = lerTexto('Modelo: ', 100);
  int ano = lerAno();
  double valor = lerValor();
  int quilometragem = lerQuilometragem();

  final resultado = await ServicoVeiculos.cadastrarVeiculo(
    cliente,
    marca: marca,
    modelo: modelo,
    ano: ano,
    valor: valor,
    quilometragem: quilometragem,
  );

  print('\nVeículo cadastrado!');

  final valorFormatado =
      (resultado['valor'] as num).toStringAsFixed(2);

  print(
    'ID: ${resultado['id']} | '
    '${resultado['marca']} ${resultado['modelo']} | '
    'Ano: ${resultado['ano']} | '
    'Valor: R\$ $valorFormatado | '
    'Quilometragem: ${resultado['quilometragem']} km',
  );
}

// ==========================================
// LISTAR VEÍCULOS
// ==========================================

Future<void> tratarListagem(SupabaseClient cliente) async {
  print('\n========== LISTA DE VEÍCULOS ==========');

  final veiculos = await ServicoVeiculos.listarVeiculos(cliente);

  if (veiculos.isEmpty) {
    print('Nenhum veículo cadastrado.');
    return;
  }

  for (final veiculo in veiculos) {
    final valor =
        (veiculo['valor'] as num).toStringAsFixed(2);

    print(
      '\nID: ${veiculo['id']} | '
      'Marca: ${veiculo['marca']} | '
      'Modelo: ${veiculo['modelo']} | '
      'Ano: ${veiculo['ano']} | '
      'Valor: R\$ $valor | '
      'Quilometragem: ${veiculo['quilometragem']} km',
    );
  }
}

// ==========================================
// ATUALIZAR VEÍCULO
// ==========================================

Future<void> tratarAtualizacao(SupabaseClient cliente) async {
  print('\n========== ATUALIZAR VEÍCULO ==========');

  int id = lerId('ID do veículo: ');

  String marca = lerTexto('Nova marca: ', 50);
  String modelo = lerTexto('Novo modelo: ', 100);
  int ano = lerAno();
  double valor = lerValor();
  int quilometragem = lerQuilometragem();

  final resultado = await ServicoVeiculos.atualizarVeiculo(
    cliente,
    id: id,
    marca: marca,
    modelo: modelo,
    ano: ano,
    valor: valor,
    quilometragem: quilometragem,
  );

  if (resultado == null) {
    print('Nenhum veículo encontrado com o ID $id.');
    return;
  }

  print('\nVeículo atualizado!');

  final valorFormatado =
      (resultado['valor'] as num).toStringAsFixed(2);

  print(
    'ID: ${resultado['id']} | '
    '${resultado['marca']} ${resultado['modelo']} | '
    'Ano: ${resultado['ano']} | '
    'Valor: R\$ $valorFormatado | '
    'Quilometragem: ${resultado['quilometragem']} km',
  );
}

// ==========================================
// EXCLUIR VEÍCULO
// ==========================================

Future<void> tratarExclusao(SupabaseClient cliente) async {
  print('\n========== EXCLUIR VEÍCULO ==========');

  int id = lerId('ID do veículo: ');

  stdout.write('Confirma a exclusão? S/N: ');

  String? confirmacao =
      stdin.readLineSync()?.trim().toUpperCase();

  if (confirmacao == 'N') {
    print('Exclusão cancelada.');
    return;
  }

  if (confirmacao != 'S') {
    print('Resposta inválida. Exclusão rejeitada.');
    return;
  }

  final resultado =
      await ServicoVeiculos.excluirVeiculo(cliente, id);

  if (resultado == null) {
    print('Nenhum veículo encontrado com o ID $id.');
    return;
  }

  print('Veículo excluído!');

  print(
    'ID: ${resultado['id']} | '
    '${resultado['marca']} ${resultado['modelo']}',
  );
}

// ==========================================
// VALIDAR MARCA E MODELO
// ==========================================

String lerTexto(String mensagem, int limiteMaximo) {
  stdout.write(mensagem);

  String? entrada = stdin.readLineSync();

  if (entrada == null) {
    throw FormatException('Entrada inválida.');
  }

  String valor = entrada.trim();

  if (valor.isEmpty) {
    throw FormatException('O campo não pode ficar vazio.');
  }

  if (valor.length > limiteMaximo) {
    throw FormatException(
      'O campo deve ter no máximo $limiteMaximo caracteres.',
    );
  }

  return valor;
}

// ==========================================
// VALIDAR ANO
// ==========================================

int lerAno() {
  stdout.write('Ano: ');

  String? entrada = stdin.readLineSync();

  int? ano = int.tryParse(entrada ?? '');

  int anoAtual = DateTime.now().year;

  if (ano == null || ano < 1900 || ano > anoAtual) {
    throw FormatException(
      'Ano inválido. Digite um número inteiro entre 1900 e $anoAtual.',
    );
  }

  return ano;
}

// ==========================================
// VALIDAR VALOR
// ==========================================

double lerValor() {
  stdout.write('Valor: ');

  String? entrada = stdin.readLineSync();

  if (entrada == null) {
    throw FormatException('Valor inválido.');
  }

  String formatado = entrada.trim();

  // Aceita ponto ou vírgula, sem separador de milhar.
  final formatoValido =
      RegExp(r'^\d+([.,]\d{1,2})?$');

  if (!formatoValido.hasMatch(formatado)) {
    throw FormatException(
      'Valor inválido. Utilize até duas casas decimais.',
    );
  }

  formatado = formatado.replaceAll(',', '.');

  double? valor = double.tryParse(formatado);

  if (valor == null ||
      !valor.isFinite ||
      valor <= 0 ||
      valor >= 10000000000) {
    throw FormatException(
      'Valor inválido. Informe um número maior que zero e menor que 10000000000.',
    );
  }

  return valor;
}

// ==========================================
// VALIDAR QUILOMETRAGEM
// ==========================================

int lerQuilometragem() {
  stdout.write('Quilometragem: ');

  String? entrada = stdin.readLineSync();

  int? km = int.tryParse(entrada ?? '');

  if (km == null || km < 0) {
    throw FormatException(
      'Quilometragem inválida. Digite um inteiro maior ou igual a zero.',
    );
  }

  return km;
}

// ==========================================
// VALIDAR ID
// ==========================================

int lerId(String mensagem) {
  stdout.write(mensagem);

  String? entrada = stdin.readLineSync();

  int? id = int.tryParse(entrada ?? '');

  if (id == null || id <= 0) {
    throw FormatException(
      'ID inválido. Digite um número inteiro positivo.',
    );
  }

  return id;
}
