// Solo para análisis y pruebas aisladas en CI; nunca conecta con un backend real.
const fs = require('node:fs');
const source = `import 'package:firebase_core/firebase_core.dart';
class DefaultFirebaseOptions {
  static const android = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:000000000000:android:ci',
    messagingSenderId: '000000000000',
    projectId: 'demo-petreminder-ci',
  );
  static const web = android;
  static FirebaseOptions get currentPlatform => android;
}
`;
for (const file of ['lib/firebase_options.dart', 'petreminder_admin/lib/firebase_options.dart']) {
  if (fs.existsSync(file)) throw new Error(`No se sobrescribe configuración existente: ${file}`);
  fs.writeFileSync(file, source);
}
