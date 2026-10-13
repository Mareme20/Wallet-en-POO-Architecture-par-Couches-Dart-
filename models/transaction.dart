// ============================================================================
// COUCHE MODÈLE (models)
// ----------------------------------------------------------------------------
// Entité Transaction : représente une opération (Dépôt, Retrait ou Frais)
// enregistrée dans l'historique.
// ============================================================================

/// Enum (Dart moderne) listant les types de transactions possibles.
/// Utiliser un enum plutôt qu'une String évite les fautes de frappe
/// et les valeurs "magiques" dans le code.
enum TypeTransaction {
  depot,
  retrait,
  frais;

  /// Libellé lisible pour l'affichage console.
  String get libelle => switch (this) {
        TypeTransaction.depot => "Dépôt",
        TypeTransaction.retrait => "Retrait",
        TypeTransaction.frais => "Frais",
      };
}

class Transaction {
  final String telephone;
  final TypeTransaction type;
  final double montant;
  final DateTime date;

  Transaction({
    required this.telephone,
    required this.type,
    required this.montant,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @override
  String toString() {
    return "[$date] $telephone | ${type.libelle} | $montant";
  }
}
