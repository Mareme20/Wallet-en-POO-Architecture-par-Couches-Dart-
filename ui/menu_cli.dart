// ============================================================================
// COUCHE PRÉSENTATION (ui)
// ----------------------------------------------------------------------------
// Cette classe gère UNIQUEMENT l'interaction avec l'utilisateur :
// affichage du menu, lecture des saisies (stdin), affichage des résultats.
//
// Elle ne contient AUCUNE règle de gestion : elle délègue tout au
// WalletService et se contente d'afficher le résultat (OperationResult).
// C'est le principe de séparation des responsabilités (Separation of
// Concerns) propre à l'architecture en couches.
// ============================================================================

import 'dart:io';

import '../models/transaction.dart';
import '../services/wallet_service.dart';

class MenuCli {
  final WalletService _walletService;

  MenuCli({required WalletService walletService}) : _walletService = walletService;

  /// Lance la boucle interactive principale.
  Future<void> demarrer() async {
    bool continuer = true;

    while (continuer) {
      _afficherMenu();
      final String? saisieChoix = stdin.readLineSync();

      // switch expression moderne (Dart 3) pour aiguiller vers l'action.
      switch (saisieChoix) {
        case "1":
          await _gererCreationWallet();
        case "2":
          await _gererDepot();
        case "3":
          await _gererRetrait();
        case "4":
          await _gererListeTransactions();
        case "0":
          print("👋 Merci d'avoir utilisé le distributeur. À bientôt !");
          continuer = false;
        default:
          print("⚠️  Choix invalide, veuillez réessayer.");
      }
    }
  }

  void _afficherMenu() {
    print("");
    print("** Menu Distributeur (Asynchrone - Architecture par couches) **");
    print("1 - Créer Wallet");
    print("2 - Faire Dépôt");
    print("3 - Faire Retrait");
    print("4 - Lister les Transactions");
    print("0 - Quitter");
    stdout.write("Votre choix : ");
  }

  Future<void> _gererCreationWallet() async {
    stdout.write("Numéro de téléphone : ");
    final String telephone = stdin.readLineSync() ?? "";

    stdout.write("Nom du client : ");
    final String nom = stdin.readLineSync() ?? "";

    stdout.write("Solde initial : ");
    final double solde = double.tryParse(stdin.readLineSync() ?? "") ?? -1;

    stdout.write("Code secret : ");
    final String code = stdin.readLineSync() ?? "";

    print("⏳ Création du wallet en cours...");
    // La couche UI appelle le Service (jamais directement le Repository).
    final resultat = await _walletService.creerWallet(
      telephone: telephone,
      nom: nom,
      solde: solde,
      code: code,
    );
    print(resultat.message);
  }

  Future<void> _gererDepot() async {
    stdout.write("Numéro de téléphone : ");
    final String telephone = stdin.readLineSync() ?? "";

    stdout.write("Montant à déposer : ");
    final double montant = double.tryParse(stdin.readLineSync() ?? "") ?? -1;

    print("⏳ Dépôt en cours...");
    final resultat = await _walletService.deposer(telephone: telephone, montant: montant);
    print(resultat.message);
  }

  Future<void> _gererRetrait() async {
    stdout.write("Numéro de téléphone : ");
    final String telephone = stdin.readLineSync() ?? "";

    stdout.write("Code secret : ");
    final String code = stdin.readLineSync() ?? "";

    stdout.write("Montant à retirer : ");
    final double montant = double.tryParse(stdin.readLineSync() ?? "") ?? -1;

    print("⏳ Retrait en cours...");
    final resultat = await _walletService.retirer(
      telephone: telephone,
      code: code,
      montant: montant,
    );
    print(resultat.message);
  }

  Future<void> _gererListeTransactions() async {
    stdout.write("Filtrer par numéro de téléphone (laisser vide pour tout afficher) : ");
    final String? filtre = stdin.readLineSync();

    final List<Transaction> resultats = await _walletService.listerTransactions(
      telephone: (filtre == null || filtre.isEmpty) ? null : filtre,
    );

    if (resultats.isEmpty) {
      print("ℹ️  Aucune transaction trouvée.");
      return;
    }

    print("\n--- Historique des transactions ---");
    for (final t in resultats) {
      print(t); // utilise Transaction.toString()
    }
  }
}
