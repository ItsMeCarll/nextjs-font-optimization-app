import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  Map<String, dynamic>? _platformTokens;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    _loadPlatformTokens();
  }

  Future<void> _loadPlatformTokens() async {
    try {
      final tokensJson = await _storage.read(key: 'platform_tokens');
      if (tokensJson != null) {
        _platformTokens = Map<String, dynamic>.from(
          json.decode(tokensJson),
        );
      }
    } catch (e) {
      _platformTokens = {};
    }
  }

  Future<void> _savePlatformTokens() async {
    if (_platformTokens != null) {
      await _storage.write(
        key: 'platform_tokens',
        value: json.encode(_platformTokens),
      );
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Guardar token para YouTube
      if (googleAuth.accessToken != null) {
        _platformTokens ??= {};
        _platformTokens!['youtube'] = {
          'access_token': googleAuth.accessToken,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await _savePlatformTokens();
      }

      return userCredential;
    } catch (e) {
      print('Error en inicio de sesión con Google: $e');
      return null;
    }
  }

  // Facebook Sign In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile', 'user_videos'],
      );

      if (result.status != LoginStatus.success) return null;

      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.token);

      final userCredential = await _auth.signInWithCredential(credential);

      // Guardar token para Facebook
      _platformTokens ??= {};
      _platformTokens!['facebook'] = {
        'access_token': result.accessToken!.token,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _savePlatformTokens();

      return userCredential;
    } catch (e) {
      print('Error en inicio de sesión con Facebook: $e');
      return null;
    }
  }

  // Twitter Sign In
  Future<UserCredential?> signInWithTwitter() async {
    try {
      final twitterProvider = TwitterAuthProvider();
      final userCredential = await _auth.signInWithProvider(twitterProvider);

      // Guardar token para Twitter
      if (userCredential.credential?.accessToken != null) {
        _platformTokens ??= {};
        _platformTokens!['twitter'] = {
          'access_token': userCredential.credential!.accessToken,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await _savePlatformTokens();
      }

      return userCredential;
    } catch (e) {
      print('Error en inicio de sesión con Twitter: $e');
      return null;
    }
  }

  // Obtener token de acceso para una plataforma específica
  Future<String?> getPlatformToken(String platform) async {
    if (_platformTokens == null) return null;
    
    final tokenInfo = _platformTokens![platform];
    if (tokenInfo == null) return null;

    // Verificar si el token ha expirado (1 hora)
    final timestamp = DateTime.parse(tokenInfo['timestamp']);
    if (DateTime.now().difference(timestamp).inHours > 1) {
      // Token expirado, necesita renovación
      await _refreshPlatformToken(platform);
    }

    return _platformTokens![platform]['access_token'];
  }

  Future<void> _refreshPlatformToken(String platform) async {
    switch (platform) {
      case 'youtube':
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          _platformTokens!['youtube'] = {
            'access_token': googleAuth.accessToken,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
        break;
      case 'facebook':
        final accessToken = await _facebookAuth.accessToken;
        if (accessToken != null) {
          _platformTokens!['facebook'] = {
            'access_token': accessToken.token,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
        break;
      // Agregar más plataformas según sea necesario
    }
    await _savePlatformTokens();
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      _platformTokens = {};
      await _storage.delete(key: 'platform_tokens');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Verificar si tiene acceso a una plataforma específica
  bool hasPlatformAccess(String platform) {
    return _platformTokens?.containsKey(platform) ?? false;
  }

  // Obtener información del usuario actual
  Map<String, dynamic> getCurrentUserInfo() {
    if (_user == null) return {};

    return {
      'uid': _user!.uid,
      'email': _user!.email,
      'displayName': _user!.displayName,
      'photoURL': _user!.photoURL,
      'connectedPlatforms': _platformTokens?.keys.toList() ?? [],
    };
  }
}
