import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:donm/main_simple.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DonM E2E Integration Tests', () {
    testWidgets('Complete user journey from registration to order completion', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Étape 1: Vérifier que la page de connexion s'affiche
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Pas encore de compte ? Inscrivez-vous'), findsOneWidget);

      // Étape 2: Navigation vers l'inscription
      await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
      await tester.pumpAndSettle();

      expect(find.text('Inscription'), findsOneWidget);

      // Étape 3: Remplir le formulaire d'inscription
      await tester.enterText(find.byKey(const Key('email_field')), 'test.user@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('first_name_field')), 'Test');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'User');
      await tester.enterText(find.byKey(const Key('phone_field')), '+2250770000000');
      await tester.enterText(find.byKey(const Key('username_field')), 'testuser');

      // Sélectionner le rôle
      await tester.tap(find.byKey(const Key('role_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Client').last);
      await tester.pumpAndSettle();

      // Soumettre l'inscription
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Étape 4: Vérifier la redirection vers la sélection de rôle
      expect(find.text('Choisissez votre rôle'), findsOneWidget);
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Vendeur'), findsOneWidget);
      expect(find.text('Livreur'), findsOneWidget);

      // Étape 5: Sélectionner le rôle Client
      await tester.tap(find.text('Client'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Étape 6: Vérifier l'accès au dashboard client
      expect(find.text('Dashboard Client'), findsOneWidget);
      expect(find.text('Commander une livraison'), findsOneWidget);

      // Étape 7: Navigation vers le formulaire de commande
      await tester.tap(find.text('Commander une livraison'));
      await tester.pumpAndSettle();

      expect(find.text('Commander une livraison'), findsOneWidget);
      expect(find.byKey(const Key('pickup_address_field')), findsOneWidget);
      expect(find.byKey(const Key('delivery_address_field')), findsOneWidget);

      // Étape 8: Remplir le formulaire de commande
      await tester.enterText(
        find.byKey(const Key('pickup_address_field')),
        'Abidjan, Cocody, Zone 4, Boutique A'
      );
      await tester.enterText(
        find.byKey(const Key('delivery_address_field')),
        'Abidjan, Yopougon, Zone 1, Résidence B'
      );
      await tester.pumpAndSettle();

      // Étape 9: Soumettre la commande
      await tester.tap(find.byKey(const Key('submit_order_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Étape 10: Vérifier la redirection vers la page de paiement
      expect(find.text('Paiement'), findsOneWidget);
      expect(find.text('Résumé de la commande'), findsOneWidget);

      // Étape 11: Sélectionner le mode de paiement Mobile Money
      await tester.tap(find.byKey(const Key('mobile_money_radio')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('operator_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);

      // Étape 12: Sélectionner l'opérateur Orange
      await tester.tap(find.byKey(const Key('operator_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Orange Money'));
      await tester.pumpAndSettle();

      // Étape 13: Entrer le numéro de téléphone
      await tester.enterText(
        find.byKey(const Key('phone_field')),
        '+2250770000000'
      );
      await tester.pumpAndSettle();

      // Étape 14: Confirmer le paiement
      await tester.tap(find.byKey(const Key('confirm_payment_button')));
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Étape 15: Vérifier la confirmation de paiement
      expect(find.text('Paiement réussi !'), findsOneWidget);
      expect(find.text('Suivre ma commande'), findsOneWidget);

      // Étape 16: Navigation vers le suivi de commande
      await tester.tap(find.text('Suivre ma commande'));
      await tester.pumpAndSettle();

      expect(find.text('Suivi de commande'), findsOneWidget);
      expect(find.byKey(const Key('tracking_code')), findsOneWidget);
      expect(find.byKey(const Key('order_status')), findsOneWidget);

      // Étape 17: Retour au dashboard
      await tester.tap(find.byKey(const Key('back_to_dashboard')));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Client'), findsOneWidget);

      // Étape 18: Vérifier l'historique des commandes
      expect(find.text('Mes commandes'), findsOneWidget);
      await tester.tap(find.text('Mes commandes'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Vendor workflow: registration to product management', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Navigation vers l'inscription
      await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
      await tester.pumpAndSettle();

      // Remplir le formulaire d'inscription vendeur
      await tester.enterText(find.byKey(const Key('email_field')), 'vendor.test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('first_name_field')), 'Vendor');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Test');
      await tester.enterText(find.byKey(const Key('phone_field')), '+2250770000001');
      await tester.enterText(find.byKey(const Key('username_field')), 'vendoruser');
      await tester.enterText(find.byKey(const Key('shop_name_field')), 'Boutique Test');

      // Sélectionner le rôle Vendeur
      await tester.tap(find.byKey(const Key('role_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vendeur').last);
      await tester.pumpAndSettle();

      // Soumettre l'inscription
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Sélectionner le rôle Vendeur
      await tester.tap(find.text('Vendeur'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Vérifier l'accès au dashboard vendeur
      expect(find.text('Dashboard Vendeur'), findsOneWidget);
      expect(find.text('Mes produits'), findsOneWidget);

      // Navigation vers la gestion des produits
      await tester.tap(find.text('Mes produits'));
      await tester.pumpAndSettle();

      expect(find.text('Gestion des produits'), findsOneWidget);
      expect(find.text('Ajouter un produit'), findsOneWidget);

      // Ajouter un nouveau produit
      await tester.tap(find.text('Ajouter un produit'));
      await tester.pumpAndSettle();

      expect(find.text('Ajouter un produit'), findsOneWidget);

      // Remplir le formulaire du produit
      await tester.enterText(find.byKey(const Key('product_name_field')), 'Attiéké spécial');
      await tester.enterText(find.byKey(const Key('product_description_field')), 'Attiéké avec poisson fumé et légumes');
      await tester.enterText(find.byKey(const Key('product_price_field')), '2500');
      
      await tester.tap(find.byKey(const Key('product_category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plats chauds'));
      await tester.pumpAndSettle();

      // Soumettre le produit
      await tester.tap(find.byKey(const Key('submit_product_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Vérifier que le produit a été ajouté
      expect(find.text('Attiéké spécial'), findsOneWidget);
      expect(find.text('2500 FCFA'), findsOneWidget);
    });

    testWidgets('Delivery person workflow: registration to order management', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Navigation vers l'inscription
      await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
      await tester.pumpAndSettle();

      // Remplir le formulaire d'inscription livreur
      await tester.enterText(find.byKey(const Key('email_field')), 'delivery.test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('first_name_field')), 'Delivery');
      await tester.enterText(find.byKey(const Key('last_name_field')), 'Test');
      await tester.enterText(find.byKey(const Key('phone_field')), '+2250770000002');
      await tester.enterText(find.byKey(const Key('username_field')), 'deliveryuser');

      // Sélectionner le rôle Livreur
      await tester.tap(find.byKey(const Key('role_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Livreur').last);
      await tester.pumpAndSettle();

      // Sélectionner le type de véhicule
      await tester.tap(find.byKey(const Key('vehicle_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moto'));
      await tester.pumpAndSettle();

      // Soumettre l'inscription
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Sélectionner le rôle Livreur
      await tester.tap(find.text('Livreur'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Vérifier l'accès au dashboard livreur
      expect(find.text('Dashboard Livreur'), findsOneWidget);
      expect(find.text('Commandes disponibles'), findsOneWidget);

      // Navigation vers les commandes disponibles
      await tester.tap(find.text('Commandes disponibles'));
      await tester.pumpAndSettle();

      expect(find.text('Commandes disponibles'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Simuler l'acceptation d'une commande
      if (find.byKey(const Key('accept_order_button')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('accept_order_button')).first);
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Vérifier que la commande est en cours
        expect(find.text('Commande en cours'), findsOneWidget);
        expect(find.text('Mettre à jour la position'), findsOneWidget);
      }
    });

    testWidgets('Error handling and validation', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Test validation du formulaire de connexion
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);

      // Test email invalide
      await tester.enterText(find.byKey(const Key('email_field')), 'email-invalide');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer un email valide'), findsOneWidget);

      // Navigation vers l'inscription
      await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
      await tester.pumpAndSettle();

      // Test validation du formulaire d'inscription
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);

      // Test mot de passe trop court
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      expect(find.text('Le mot de passe doit contenir au moins 6 caractères'), findsOneWidget);
    });

    testWidgets('Performance and responsiveness', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Mesurer le temps de rendu initial
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Le rendu initial devrait prendre moins de 2 secondes
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Test de navigation rapide
      await tester.tap(find.text('Pas encore de compte ? Inscrivez-vous'));
      await tester.pumpAndSettle();

      // La navigation devrait être fluide
      expect(find.text('Inscription'), findsOneWidget);

      // Test de scroll sur de longues listes
      await tester.tap(find.text('Connexion')); // Retour
      await tester.pumpAndSettle();

      // Simuler une connexion pour accéder aux listes
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Sélectionner un rôle
      await tester.tap(find.text('Client'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Accéder à une liste de produits
      await tester.tap(find.text('Explorer les produits'));
      await tester.pumpAndSettle();

      // Test de scroll fluide
      await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // Vérifier qu'il n'y a pas d'erreurs de rendu
      expect(tester.takeException(), isNull);
    });

    testWidgets('Accessibility compliance', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Vérifier les labels sémantiques
      expect(find.bySemanticsLabel('Champ email'), findsOneWidget);
      expect(find.bySemanticsLabel('Champ mot de passe'), findsOneWidget);
      expect(find.bySemanticsLabel('Bouton de connexion'), findsOneWidget);

      // Test navigation au clavier
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Le focus devrait se déplacer correctement
      // Note: Ceci dépend de l'implémentation du focus management

      // Test de contraste (simulé)
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final widget in textWidgets) {
        expect(widget.style?.fontSize, greaterThan(12)); // Taille de police minimale
      }
    });

    testWidgets('Network connectivity handling', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Simuler une tentative de connexion sans réseau
      // Note: Ceci nécessiterait un mock du service réseau

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Vérifier le message d'erreur réseau
      // expect(find.text('Erreur de connexion'), findsOneWidget);
      // Note: Dépend de l'implémentation de la gestion d'erreur
    });

    testWidgets('Data persistence and offline mode', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Test de persistance des données utilisateur
      await tester.enterText(find.byKey(const Key('email_field')), 'persistent@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      // Simuler une connexion réussie
      // Note: Dépend de l'implémentation du stockage local

      // Redémarrer l'application et vérifier la persistance
      // app.main();
      // await tester.pumpAndSettle();
      
      // Vérifier que l'utilisateur est toujours connecté
      // expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('Multi-language support', (WidgetTester tester) async {
      // Lancer l'application
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les textes sont en français par défaut
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Inscription'), findsOneWidget);

      // Test de changement de langue (si implémenté)
      // await tester.tap(find.byKey(const Key('language_selector')));
      // await tester.pumpAndSettle();
      // await tester.tap(find.text('English'));
      // await tester.pumpAndSettle();
      
      // expect(find.text('Login'), findsOneWidget);
      // expect(find.text('Register'), findsOneWidget);
    });
  });
}

// Extension pour faciliter les tests
extension WidgetTesterX on WidgetTester {
  Future<void> pumpAndSettle([Duration? duration]) async {
    await pump(duration ?? Duration.zero);
    await pump(Duration(seconds: 1));
  }
}
