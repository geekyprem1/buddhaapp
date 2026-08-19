import 'package:core/core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upsert then watch returns the alarm', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = AlarmRepository(firestore: firestore);
    const alarm = Alarm(
      id: 'a1',
      timeHour: 5,
      timeMinute: 15,
      prarthanaId: 'pr_001',
    );
    await repo.upsert('uid1', alarm);

    final items = await repo.watch('uid1').first;
    expect(items, hasLength(1));
    expect(items.single.timeHour, 5);
    expect(items.single.prarthanaId, 'pr_001');

    await repo.delete('uid1', 'a1');
    expect(await repo.watch('uid1').first, isEmpty);
  });
}
