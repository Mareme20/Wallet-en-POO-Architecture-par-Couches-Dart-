// ============================================================================
// POINT D'ENTRÉE (main.dart)
// ----------------------------------------------------------------------------
// C'est ici que l'on "câble" les couches entre elles (composition root) :
//   Repositories  --injectés dans-->  Service  --injecté dans-->  UI (MenuCli)
//
// Aucune couche ne crée elle-même ses dépendances : elle les reçoit en
// paramètre (injection de dépendances). Cela rend chaque couche testable
// indépendamment des autres.
//
// Lancer avec : dart run main.dart
// ============================================================================

import 'repositories/wallet_repository.dart';
import 'repositories/transaction_repository.dart';
import 'services/wallet_service.dart';
import 'ui/menu_cli.dart';

Future<void> main() async {
  // 1. Couche Repository : instanciation des "accès aux données".
  final walletRepository = WalletRepository();
  final transactionRepository = TransactionRepository();

  // 2. Couche Service : reçoit les repositories dont elle a besoin.
  final walletService = WalletService(
    walletRepository: walletRepository,
    transactionRepository: transactionRepository,
  );

  // 3. Couche Présentation : reçoit le service dont elle a besoin.
  final menu = MenuCli(walletService: walletService);

  // 4. Lancement de la boucle interactive.
  await menu.demarrer();
}
