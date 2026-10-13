// ============================================================================
// COUCHE REPOSITORY (repositories)
// ----------------------------------------------------------------------------
// Gère le "stockage" de l'historique des transactions.
// Comme WalletRepository, aucune règle de gestion ici : uniquement du
// stockage / de la recherche.
// ============================================================================

import '../models/transaction.dart';

class TransactionRepository {
  final List<Transaction> _transactions = <Transaction>[];

  /// Enregistre une transaction dans l'historique.
  Future<void> ajouter(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 500)); // latence simulée
    _transactions.add(transaction);
  }

  /// Retourne toutes les transactions, éventuellement filtrées par
  /// numéro de téléphone (RG 4.1).
  Future<List<Transaction>> lister({String? telephone}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // latence simulée
    if (telephone == null || telephone.isEmpty) {
      return List.unmodifiable(_transactions);
    }
    return _transactions.where((t) => t.telephone == telephone).toList();
  }
}
