import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/auth/auth_controller.dart';
import 'package:library_app/features/auth/google_auth_gateway.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

class FakeGateway implements GoogleAuthGateway {
  final tokens = StreamController<String?>.broadcast();
  Future<String?>? restored = Future.value(null);
  String? interactiveToken;
  int signOuts = 0;

  @override
  Future<void> initialize() async {}

  @override
  Stream<String?> get idTokens => tokens.stream;

  @override
  Future<String?>? restore() => restored;

  @override
  bool get supportsSignInCall => true;

  @override
  Future<String?> signIn() async => interactiveToken;

  @override
  Future<void> signOut() async => signOuts++;
}

void main() {
  late FakeGateway gateway;
  late FakeApi api;
  late ProviderContainer container;

  final me = MeResponse(
    id: 1,
    email: 'owner@example.com',
    libraries: [LibrarySummary(id: 10, name: 'Ma bibliothèque', role: Role.OWNER)],
  );

  ProviderContainer start() {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [googleAuthGatewayProvider.overrideWithValue(gateway), api.override],
    );
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, _) {});
    return container;
  }

  Future<AuthState> settled() async {
    for (var i = 0; i < 20 && container.read(authControllerProvider) is AuthStarting; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    await Future<void>.delayed(Duration.zero);
    return container.read(authControllerProvider);
  }

  void meAnswers(Object answer) {
    when(() => api.me.getMe(headers: any(named: 'headers'))).thenAnswer(
      (_) => answer is MeResponse ? Future.value(ok(answer)) : Future.error(answer),
    );
  }

  setUp(() {
    gateway = FakeGateway();
    api = FakeApi();
  });

  test('restores a member with the token sent to /api/me', () async {
    gateway.restored = Future.value('token-1');
    meAnswers(me);
    start();

    final state = await settled();

    expect(state, isA<AuthSignedIn>());
    expect(state.idToken, 'token-1');
    expect((state as AuthSignedIn).me.email, 'owner@example.com');
    verify(() => api.me.getMe(headers: {'Authorization': 'Bearer token-1'})).called(1);
  });

  test('shows the sign-in screen when no session is restored', () async {
    start();
    expect(await settled(), isA<AuthSignedOut>());
    verifyNever(() => api.me.getMe(headers: any(named: 'headers')));
  });

  test('shows the sign-in screen while the web platform answers later', () async {
    gateway.restored = null;
    meAnswers(me);
    start();
    expect(await settled(), isA<AuthSignedOut>());

    gateway.tokens.add('web-token');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider), isA<AuthSignedIn>());
  });

  test('refuses a Google account that is not invited', () async {
    gateway.restored = Future.value('stranger');
    meAnswers(httpError(403));
    start();

    final state = await settled();

    expect(state, isA<AuthSignedOut>());
    expect((state as AuthSignedOut).message, AuthController.notInvited);
    expect(gateway.signOuts, 1);
  });

  test('explains an unreachable server', () async {
    gateway.restored = Future.value('token-1');
    meAnswers(httpError(500, detail: 'Base indisponible'));
    start();

    expect(((await settled()) as AuthSignedOut).message, 'Base indisponible');
  });

  test('signs in interactively and ignores the same token arriving twice', () async {
    gateway.interactiveToken = 'token-2';
    meAnswers(me);
    start();
    await settled();

    await container.read(authControllerProvider.notifier).signIn();
    gateway.tokens.add('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).idToken, 'token-2');
    verify(() => api.me.getMe(headers: any(named: 'headers'))).called(1);
  });

  test('signs out when the API rejects an expired token', () async {
    gateway.restored = Future.value('token-1');
    meAnswers(me);
    start();
    await settled();

    container.read(authControllerProvider.notifier).sessionExpired();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(authControllerProvider);
    expect((state as AuthSignedOut).message, AuthController.expired);
    expect(gateway.signOuts, 1);
  });

  test('signs out on request', () async {
    gateway.restored = Future.value('token-1');
    meAnswers(me);
    start();
    await settled();

    await container.read(authControllerProvider.notifier).signOut();

    expect(container.read(authControllerProvider), isA<AuthSignedOut>());
    expect(container.read(authControllerProvider).idToken, isNull);
  });
}
