// ============================================================================
// COUCHE SERVICE (services)
// ----------------------------------------------------------------------------
// C'est ICI que vivent toutes les Règles de Gestion (RG). Le Service :
//   - orchestre les appels aux Repositories (couche en dessous),
//   - applique les validations métier,
//   - ne connaît RIEN de la console (aucun `print`, aucun `stdin`) :
//     il retourne un OperationResult que la couche Présentation utilisera.
//
// C'est le cœur de l'architecture en couches : Présentation -> Service ->
// Repository -> "Base de données". Chaque couche ne parle qu'à la couche
// immédiatement voisine.
// ============================================================================

import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/operation_result.dart';
import '../extensions/formateur_monnaie.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/transaction_repository.dart';

class WalletService {
  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  // Constantes métier propres au service (RG 3.2).
  static const double _tauxFrais = 0.01; // 1%
  static const double _plafondFrais = 5000.0; // CFA

  // Injection de dépendances simple : le service reçoit ses repositories
  // en paramètre plutôt que de les créer lui-même. Cela facilite les tests
  // (on pourrait injecter un faux repository en mémoire pour tester).
  WalletService({
    required WalletRepository walletRepository,
    required TransactionRepository transactionRepository,
  })  : _walletRepository = walletRepository,
        _transactionRepository = transactionRepository;

  /// Calcule les frais de retrait (RG 3.2 : 1%, plafonnés à 5000 CFA).
  double _calculerFrais(double montant) {
    final double frais = montant * _tauxFrais;
    return frais > _plafondFrais ? _plafondFrais : frais;
  }

  /// RG 1.1 / RG 1.2 : création d'un wallet.
  Future<OperationResult> creerWallet({
    required String telephone,
    required String nom,
    required double solde,
    required String code,
  }) async {
    // RG 1.1 : champs obligatoires.
    if (telephone.isEmpty || nom.isEmpty || code.isEmpty) {
      return const OperationResult.echec(
        "❌ Tous les champs (téléphone, nom, code) sont obligatoires.",
      );
    }

    // RG 1.1 : solde initial >= 0.
    if (solde < 0) {
      return const OperationResult.echec(
        "❌ Le solde initial doit être supérieur ou égal à 0.",
      );
    }

    // RG 1.2 : unicité du téléphone.
    final walletExistant = await _walletRepository.trouverParTelephone(telephone);
    if (walletExistant != null) {
      return const OperationResult.echec(
        "❌ Ce numéro de téléphone est déjà associé à un wallet.",
      );
    }

    // RG 1.2 : unicité du code secret.
    final codeExiste = await _walletRepository.codeExiste(code);
    if (codeExiste) {
      return const OperationResult.echec(
        "❌ Ce code secret est déjà utilisé par un autre client.",
      );
    }

    // Toutes les règles passent : on délègue la persistance au repository.
    final wallet = Wallet(telephone: telephone, nom: nom, solde: solde, code: code);
    await _walletRepository.sauvegarder(wallet);

    return OperationResult.succes(
      "✅ Wallet créé avec succès pour $nom (Solde initial : ${solde.enCfa}).",
    );
  }

  /// RG 2.1 : dépôt d'argent.
  Future<OperationResult> deposer({
    required String telephone,
    required double montant,
  }) async {
    final wallet = await _walletRepository.trouverParTelephone(telephone);
    if (wallet == null) {
      return OperationResult.echec("❌ Aucun wallet trouvé pour le numéro $telephone.");
    }

    if (montant <= 0) {
      return const OperationResult.echec(
        "❌ Le montant du dépôt doit être strictement positif.",
      );
    }

    // Mise à jour du solde (le repository stocke l'instance Wallet, donc
    // muter `solde` ici se répercute directement dans la "base").
    wallet.solde += montant;

    await _transactionRepository.ajouter(
      Transaction(telephone: telephone, type: TypeTransaction.depot, montant: montant),
    );

    return OperationResult.succes(
      "✅ Dépôt de ${montant.enCfa} effectué. Nouveau solde : ${wallet.solde.enCfa}.",
    );
  }

  /// RG 3.1 / RG 3.2 : retrait d'argent avec frais.
  Future<OperationResult> retirer({
    required String telephone,
    required String code,
    required double montant,
  }) async {
    final wallet = await _walletRepository.trouverParTelephone(telephone);
    if (wallet == null) {
      return OperationResult.echec("❌ Aucun wallet trouvé pour le numéro $telephone.");
    }

    // RG 3.1 : validation du code secret.
    if (wallet.code != code) {
      return const OperationResult.echec("❌ Code secret incorrect.");
    }

    // RG 3.1 : montant strictement positif.
    if (montant <= 0) {
      return const OperationResult.echec(
        "❌ Le montant du retrait doit être strictement positif.",
      );
    }

    // RG 3.2 : calcul des frais plafonnés.
    final double frais = _calculerFrais(montant);
    final double montantTotal = montant + frais;

    // RG 3.1 : solde suffisant pour couvrir montant + frais.
    if (wallet.solde < montantTotal) {
      return OperationResult.echec(
        "❌ Solde insuffisant. Solde actuel : ${wallet.solde.enCfa}, "
        "requis : ${montantTotal.enCfa} (dont ${frais.enCfa} de frais).",
      );
    }

    // Mise à jour du solde.
    wallet.solde -= montantTotal;

    // Historisation : une transaction "Retrait" + une transaction "Frais",
    // conformément à RG 4.1 (l'historique doit inclure les frais).
    await _transactionRepository.ajouter(
      Transaction(telephone: telephone, type: TypeTransaction.retrait, montant: montant),
    );
    await _transactionRepository.ajouter(
      Transaction(telephone: telephone, type: TypeTransaction.frais, montant: frais),
    );

    return OperationResult.succes(
      "✅ Retrait de ${montant.enCfa} effectué (frais : ${frais.enCfa}). "
      "Nouveau solde : ${wallet.solde.enCfa}.",
    );
  }

  /// RG 4.1 : liste l'historique complet ou filtré par téléphone.
  Future<List<Transaction>> listerTransactions({String? telephone}) {
    return _transactionRepository.lister(telephone: telephone);
  }
}
