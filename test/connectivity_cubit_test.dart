import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto_desctop/core/cubits/connectivity_cubit.dart';
import 'package:flutter_test/flutter_test.dart';


class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> _result = [ConnectivityResult.wifi];
  Exception? _error;

  void setResult(List<ConnectivityResult> result) {
    _result = result;
  }

  void setError(Exception error) {
    _error = error;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (_error != null) throw _error!;
    return _result;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.empty();
}

void main() {
  group('ConnectivityCubit', () {
    // setUp
    late FakeConnectivity fakeConnectivity;
    late ConnectivityCubit connectivityCubit;

    setUp(() {
      // fake connectivity
      fakeConnectivity = FakeConnectivity();
      connectivityCubit = ConnectivityCubit(connectivity: fakeConnectivity);
    });

    // tearDown
    tearDown(() {

      connectivityCubit.close();
    });

    // test 1 INIT State
    test('init state - ConnectivityOnline', () {
      // init this Connectivity ture
      expect(connectivityCubit.state, isA<ConnectivityOnline>());
    });

    // test 2 getter is true if `connectivityCubit.isOnline`
    test('getter isOnline возвращает true когда Online', () {
      // should be true
      expect(connectivityCubit.isOnline, true);
    });

    // test3 lost internet connection
    test('Cubit Offline when ConnectivityResult.none', () async {
      // ConnectivityResult.none
      fakeConnectivity.setResult([ConnectivityResult.none]);

      // new cubit with ConnectivityResult.none
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state, isA<ConnectivityOffline>());

      cubit.close();
    });

    // test4 getter false when ConnectivityResult.none
    test('getter isOnline false when Offline', () async {
      fakeConnectivity.setResult([ConnectivityResult.none]);

      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      await Future.delayed(const Duration(milliseconds: 100));


      expect(cubit.isOnline, false);

      cubit.close();
    });

    // test5 wifi
    test('Online If WiFi connection', () async {
      // `wifi` by default
      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      await Future.delayed(const Duration(milliseconds: 100));

      // WiFi = Online
      expect(cubit.state, isA<ConnectivityOnline>());
      expect(cubit.isOnline, true);

      cubit.close();
    });

    // test6 fail-open check
    test('if err checkConnectivity still true', () async {
      // get an err
      fakeConnectivity.setError(Exception('No internet connection'));

      final cubit = ConnectivityCubit(connectivity: fakeConnectivity);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.isOnline, true);

      cubit.close();
    });
  });
}

