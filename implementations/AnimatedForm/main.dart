import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_form.dart';
import 'form_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => FormProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: AnimatedForm())),
    );
  }
}
