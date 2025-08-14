import 'package:enderase/enderase.dart';
import 'package:flutter/material.dart';

import 'config/storage_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigPreference.init();
  runApp(const Enderase());
}
