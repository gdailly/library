import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/auth/auth_controller.dart';
import 'package:library_app/features/settings/settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

/// Signed in from the start, without Google.
class SignedIn extends AuthController {
  SignedIn(this.role);

  final Role role;

  @override
  AuthState build() => AuthSignedIn(
        token: 'token',
        me: MeResponse(
          id: 1,
          email: 'owner@example.com',
          name: 'Guillaume',
          libraries: [LibrarySummary(id: 10, name: 'Ma bibliothèque', role: role)],
        ),
      );
}

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() {
    api = FakeApi();
    when(() => api.categories.listCategories()).thenAnswer(
      (_) async => ok([
        CategoryResponse(id: 3, name: 'Classiques', color: '#3E6B48', bookCount: 42),
        CategoryResponse(id: 4, name: 'Policier', color: '#8C3B2E', bookCount: 1),
      ]),
    );
    when(() => api.members.listMembers()).thenAnswer(
      (_) async => ok([
        MemberResponse(userId: 1, email: 'owner@example.com', name: 'Guillaume', role: Role.OWNER),
        MemberResponse(userId: 2, email: 'claire@example.com', role: Role.MEMBER),
      ]),
    );
    when(() => api.members.inviteMember(memberRequest: any(named: 'memberRequest'))).thenAnswer(
      (_) async => ok(MemberResponse(userId: 3, email: 'paul@example.com', role: Role.MEMBER)),
    );
  });

  Future<void> pumpSettings(WidgetTester tester, Role role) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(
      tester,
      const SettingsScreen(),
      overrides: [api.override, authControllerProvider.overrideWith(() => SignedIn(role))],
    );
  }

  testWidgets('shows the profile, categories with their book counts and members', (tester) async {
    await pumpSettings(tester, Role.OWNER);

    expect(find.text('owner@example.com · Propriétaire'), findsOneWidget);
    expect(find.text('42 livres'), findsOneWidget);
    expect(find.text('1 livre'), findsOneWidget);
    expect(find.text('claire@example.com'), findsOneWidget);
    expect(find.text('Pas encore connecté'), findsOneWidget);
  });

  testWidgets('lets the owner invite and remove members, but not remove themselves', (tester) async {
    await pumpSettings(tester, Role.OWNER);

    expect(find.byTooltip('Retirer claire@example.com'), findsOneWidget);
    expect(find.byTooltip('Retirer Guillaume'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'E-mail Google à inviter'), ' paul@example.com ');
    await tester.tap(find.text('Inviter'));
    await tester.pumpAndSettle();

    final request = verify(
      () => api.members.inviteMember(memberRequest: captureAny(named: 'memberRequest')),
    ).captured.single as MemberRequest;
    expect(request.email, 'paul@example.com');
  });

  testWidgets('refuses an invitation without a valid e-mail', (tester) async {
    await pumpSettings(tester, Role.OWNER);

    await tester.enterText(find.widgetWithText(TextField, 'E-mail Google à inviter'), 'paul');
    await tester.tap(find.text('Inviter'));
    await tester.pumpAndSettle();

    expect(find.text('Saisis l\'adresse e-mail Google à inviter.'), findsOneWidget);
    verifyNever(() => api.members.inviteMember(memberRequest: any(named: 'memberRequest')));
  });

  testWidgets('hides member management from simple members', (tester) async {
    await pumpSettings(tester, Role.MEMBER);

    expect(find.text('Inviter'), findsNothing);
    expect(find.byTooltip('Retirer claire@example.com'), findsNothing);
  });

  testWidgets('creates a category', (tester) async {
    final created = Completer<void>();
    when(() => api.categories.createCategory(categoryRequest: any(named: 'categoryRequest'))).thenAnswer((_) async {
      created.complete();
      return ok(CategoryResponse(id: 5, name: 'Poésie', color: '#3E6B48'));
    });
    await pumpSettings(tester, Role.MEMBER);

    await tester.tap(find.text('Ajouter une catégorie'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Poésie');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(created.isCompleted, isTrue);
    expect(find.text('Nouvelle catégorie'), findsNothing);
  });
}
