import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import 'profile_repository.dart';

class FirebaseAccounts {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Firebase requires email-shaped credentials. Keep the contact email private.
  String _credential(String id) => '${id.toLowerCase()}@planit-id.invalid';

  FirebaseProfileRepository _repository(User user) => FirebaseProfileRepository(
    FirebaseFirestore.instance.collection('profiles').doc(user.uid),
  );

  Future<ProfileRepository> register({
    required String id,
    required String email,
    required String password,
    required String nickname,
    Uint8List? photo,
  }) async {
    final credential = _credential(id);
    User user;
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: credential,
        password: password,
      );
      user = result.user!;
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') rethrow;
      // A previous attempt may have created the account before saving its profile.
      try {
        final result = await _auth.signInWithEmailAndPassword(
          email: credential,
          password: password,
        );
        user = result.user!;
      } on FirebaseAuthException catch (signInError) {
        if (const {
          'invalid-credential',
          'wrong-password',
          'user-not-found',
        }.contains(signInError.code)) {
          throw const AccountException('이미 사용 중인 아이디입니다.');
        }
        rethrow;
      }
    }

    try {
      final repository = _repository(user);
      await repository.create(
        UserProfile(
          userId: user.uid,
          loginId: id,
          email: email,
          nickname: nickname,
          photoBytes: photo,
        ),
      );
      return repository;
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<ProfileRepository> signIn(String id, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: _credential(id),
      password: password,
    );
    return _repository(result.user!);
  }

  Future<void> signOut() => _auth.signOut();
}

class AccountException implements Exception {
  const AccountException(this.message);
  final String message;
}

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository(this._document);

  static const photoLimit = 750 * 1024;
  final DocumentReference<Map<String, dynamic>> _document;

  @override
  Future<UserProfile> load() async {
    final data = (await _document.get()).data();
    if (data == null) {
      throw const AccountException('프로필이 저장되지 않았어요. 회원가입을 완료해 주세요.');
    }
    final preferences = data['preferences'] as Map<String, dynamic>? ?? {};
    return UserProfile(
      userId: _document.id,
      loginId: data['loginId'] as String,
      email: data['email'] as String,
      nickname: data['nickname'] as String,
      homeAddress: data['homeAddress'] as String? ?? '',
      photoBytes: (data['photo'] as Blob?)?.bytes,
      preferences: BasicPreferences(
        gender: preferences['gender'] as String?,
        birthDate: DateTime.tryParse(preferences['birthDate'] as String? ?? ''),
        mbti: preferences['mbti'] as String?,
        activityPreference: ActivityPreference.values
            .where((item) => item.name == preferences['activityPreference'])
            .firstOrNull,
        drinkingEnjoyment: preferences['drinkingEnjoyment'] as int?,
        livingArea: preferences['livingArea'] as String? ?? '',
        hasCar: preferences['hasCar'] as bool?,
      ),
    );
  }

  Map<String, Object?> _editableFields(UserProfile profile) {
    final preferences = profile.preferences;
    final photo = profile.photoBytes;
    return {
      'nickname': profile.nickname,
      'homeAddress': profile.homeAddress,
      'photo': photo == null ? null : Blob(photo),
      'preferences': {
        'gender': preferences.gender,
        'birthDate': preferences.birthDate?.toIso8601String(),
        'mbti': preferences.mbti,
        'activityPreference': preferences.activityPreference?.name,
        'drinkingEnjoyment': preferences.drinkingEnjoyment,
        'livingArea': preferences.livingArea,
        'hasCar': preferences.hasCar,
      },
    };
  }

  Future<void> create(UserProfile profile) =>
      _document.firestore.runTransaction((transaction) async {
        if ((await transaction.get(_document)).exists) {
          throw const AccountException('이미 사용 중인 아이디입니다. 로그인해 주세요.');
        }
        transaction.set(_document, {
          'loginId': profile.loginId,
          'email': profile.email,
          ..._editableFields(profile),
        });
      });

  @override
  Future<void> save(UserProfile profile) {
    if (profile.userId != _document.id) {
      throw ArgumentError('Cannot save a different user in this repository.');
    }
    return _document.update(_editableFields(profile));
  }
}
