# 📌 Séquence 2 : Wallet en POO — Architecture par Couches (Dart)

## 🎯 Objectif

Refaire le prototype du Menu Distributeur, mais cette fois en **Programmation
Orientée Objet (POO)** avec une **architecture en couches** (layered
architecture), au lieu du style procédural de la Séquence 1.
 
## 🧱 Les couches

```
main.dart                → Point d'entrée : assemble les couches (DI)
  │
  ├── ui/                → COUCHE PRÉSENTATION
  │     menu_cli.dart       Interaction console (stdin/stdout).
  │                         Ne connaît AUCUNE règle de gestion.
  │
  ├── services/           → COUCHE SERVICE (logique métier)
  │     wallet_service.dart  Contient toutes les Règles de Gestion (RG).
  │                          Orchestre les Repositories.
  │
  ├── repositories/        → COUCHE ACCÈS AUX DONNÉES
  │     wallet_repository.dart       "Persiste" les Wallets (liste en mémoire).
  │     transaction_repository.dart  "Persiste" les Transactions.
  │
  ├── models/              → COUCHE MODÈLE (entités)
  │     wallet.dart            Entité Wallet.
  │     transaction.dart       Entité Transaction + enum TypeTransaction.
  │     operation_result.dart  DTO représentant succès/échec + message.
  │
  └── extensions/          → UTILITAIRES
        formateur_monnaie.dart  Extension double.enCfa
```

## 🔑 Principe clé : séparation des responsabilités

- **UI (Présentation)** → parle uniquement au **Service**.
- **Service** → parle uniquement aux **Repositories**.
- **Repository** → parle uniquement aux **Modèles**.
- Aucune couche ne "saute" une couche (ex: l'UI n'accède jamais directement
  à un Repository).
- L'**injection de dépendances** se fait dans `main.dart` : chaque classe
  reçoit ses dépendances via son constructeur plutôt que de les créer
  elle-même. Cela facilite grandement les tests unitaires (on peut injecter
  de faux repositories).

## ▶️ Exécution

```bash
dart run main.dart
```

## ✅ Règles de gestion respectées (identiques à la Séquence 1)

- RG 1.1 / RG 1.2 : création de wallet (champs obligatoires, solde ≥ 0,
  unicité téléphone + code).
- RG 2.1 : dépôt (montant > 0).
- RG 3.1 / RG 3.2 : retrait (code valide, montant > 0, frais 1% plafonnés
  à 5000 CFA, solde suffisant).
- RG 4.1 : historique complet ou filtré par téléphone.

Toute cette logique vit désormais dans `services/wallet_service.dart`,
et non plus éparpillée dans la boucle `main()` comme en Séquence 1.
