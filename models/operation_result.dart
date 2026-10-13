// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Petite classe "DTO" (Data Transfer Object) utilisée pour faire remonter
// le résultat d'une opération métier depuis la couche Service vers la
// couche Présentation (succès ou échec + message).
//
// C'est l'équivalent orienté-objet du Record (bool, String) utilisé dans
// la version procédurale : ici on préfère une classe nommée, plus lisible
// et plus facile à faire évoluer (on pourrait y ajouter un champ "code
// erreur" plus tard sans casser les appels existants).
// ============================================================================

class OperationResult {
  final bool success;
  final String message;

  const OperationResult.succes(this.message) : success = true;
  const OperationResult.echec(this.message) : success = false;

  @override
  String toString() => message;
}
