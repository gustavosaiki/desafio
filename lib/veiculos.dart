
import 'package:supabase/supabase.dart';

class ServicoVeiculos {

  // CADASTRAR VEÍCULO
  static Future<Map<String, dynamic>> cadastrarVeiculo(
    SupabaseClient cliente, {
    required String marca,
    required String modelo,
    required int ano,
    required double valor,
    required int quilometragem,
  }) async {
    final response = await cliente
        .from('veiculos')
        .insert({
          'marca': marca,
          'modelo': modelo,
          'ano': ano,
          'valor': valor,
          'quilometragem': quilometragem,
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // LISTAR VEÍCULOS
  static Future<List<Map<String, dynamic>>> listarVeiculos(
    SupabaseClient cliente,
  ) async {
    final response = await cliente
        .from('veiculos')
        .select()
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // ATUALIZAR VEÍCULO
  static Future<Map<String, dynamic>?> atualizarVeiculo(
    SupabaseClient cliente, {
    required int id,
    required String marca,
    required String modelo,
    required int ano,
    required double valor,
    required int quilometragem,
  }) async {
    final response = await cliente
        .from('veiculos')
        .update({
          'marca': marca,
          'modelo': modelo,
          'ano': ano,
          'valor': valor,
          'quilometragem': quilometragem,
        })
        .eq('id', id)
        .select();

    if (response.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(response.first);
  }

  // EXCLUIR VEÍCULO
  static Future<Map<String, dynamic>?> excluirVeiculo(
    SupabaseClient cliente,
    int id,
  ) async {
    final response = await cliente
        .from('veiculos')
        .delete()
        .eq('id', id)
        .select();

    if (response.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(response.first);
  }
}
