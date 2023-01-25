import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';

import 'package:flutter/material.dart';

import 'ui/pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSetup.boot();
  runApp(const AppState());
}
