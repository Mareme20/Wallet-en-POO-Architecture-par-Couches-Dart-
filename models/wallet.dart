// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Un "modèle" représente une entité métier sous forme de classe.
// Ici : le Wallet (portefeuille) d'un client.
// Cette couche ne contient AUCUNE logique métier ni accès aux données :
// uniquement la structure des données et des méthodes très simples
// (getters, toString, etc.).
// ============================================================================

class Wallet {
  final String telephone;
  final String nom;
  double solde; // mutable : le solde évolue lors des dépôts/retraits
  final String code;

  Wallet({
    required this.telephone,
    required this.nom,
    required this.solde,
    required this.code,
  });

  @override
  String toString() {
    return "Wallet(telephone: $telephone, nom: $nom, solde: $solde)";
  }
}
