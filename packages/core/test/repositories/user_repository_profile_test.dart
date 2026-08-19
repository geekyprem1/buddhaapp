import 'package:core/core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setPreferredLanguage does not rewind onboarding', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = UserRepository(firestore: firestore);
    await firestore.collection('users').doc('u1').set({
      'name': 'Prem',
      'language': 'en',
      'onboardingStep': 'complete',
    });

    await repo.setPreferredLanguage('u1', 'hi');
    final snap = await firestore.collection('users').doc('u1').get();
    expect(snap.data()!['language'], 'hi');
    expect(snap.data()!['onboardingStep'], 'complete');
  });

  test('addFcmToken unions the token onto the user doc', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = UserRepository(firestore: firestore);
    await firestore.collection('users').doc('u1').set({'fcmTokens': <String>[]});
    await repo.addFcmToken('u1', 'tok_a');
    final snap = await firestore.collection('users').doc('u1').get();
    expect(List<String>.from(snap.data()!['fcmTokens'] as List), ['tok_a']);
  });

  test('contact form writes uid subject and message', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = ContactRepository(firestore: firestore);
    await repo.submit(uid: 'u1', subject: 'Help', message: 'Alarm issue');
    final docs = await firestore.collection('contactMessages').get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.data()['uid'], 'u1');
    expect(docs.docs.first.data()['subject'], 'Help');
  });
}
