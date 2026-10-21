import 'package:cloud_firestore/cloud_firestore.dart';

/// Elimina en lotes acotados sin saltarse documentos al paginar una eliminación.
Future<void> deleteQuery(
  FirebaseFirestore firestore,
  Query<Map<String, dynamic>> query,
) async {
  while (true) {
    final snapshot = await query.limit(450).get();
    if (snapshot.docs.isEmpty) return;
    final batch = firestore.batch();
    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }
}
