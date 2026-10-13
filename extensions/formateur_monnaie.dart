// ============================================================================
// COUCHE UTILITAIRE (extensions)
// ----------------------------------------------------------------------------
// Extension Dart 3 sur le type `double` pour formater un montant en CFA.
// Exemple : 15000.0.enCfa => "15000 CFA"
// ============================================================================

extension FormateurMonnaie on double {
  String get enCfa => "${toStringAsFixed(0)} CFA";
}
