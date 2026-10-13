// ============================================================================
// COUCHE REPOSITORY (repositories)
// ----------------------------------------------------------------------------
// Rôle : c'est la SEULE couche autorisée à manipuler le "stockage" des
// wallets (ici une simple List en mémoire, mais dans une vraie application
// ce serait une base de données SQL/NoSQL).
//
// Le Repository ne connaît AUCUNE règle de gestion (RG). Il sait uniquement
// "sauvegarder", "chercher", "lister". Toute la logique métier (validations,
// calculs de frais, etc.) est déléguée à la couche Service.
//
// C'est asynchrone (Future) pour simuler une vraie latence réseau/BDD.
// ============================================================================

import '../models/wallet.dart';

class WalletRepository {
  // "Base de données" en mémoire, privée à la couche repository.
  final List<Wallet> _wallets = <Wallet>[];

  /// Enregistre un nouveau wallet.
  Future<void> sauvegarder(Wallet wallet) async {
    await Future.delayed(const Duration(seconds: 1)); // latence simulée
    _wallets.add(wallet);
  }

  /// Recherche un wallet par numéro de téléphone. Retourne `null` si absent.
  Future<Wallet?> trouverParTelephone(String telephone) async {
    await Future.delayed(const Duration(seconds: 1)); // latence simulée
    for (final w in _wallets) {
      if (w.telephone == telephone) return w;
    }
    return null;
  }

  /// Vérifie si un code secret est déjà utilisé par un wallet existant.
  Future<bool> codeExiste(String code) async {
    await Future.delayed(const Duration(seconds: 1)); // latence simulée
    return _wallets.any((w) => w.code == code);
  }

  /// Retourne la liste complète des wallets (copie défensive).
  Future<List<Wallet>> lister() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_wallets);
  }
}
