import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get/get.dart';
import 'package:unimp_sdk_plugin_example/page/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QueryClient.initialize(cachePrefix: 'fl_query_example');
  runApp(const App());
}


class App extends HookWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
   return QueryClientProvider(
      child: MaterialApp(
        title: 'Fl-Query Example App',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Home()
        ),
      ),
    );
  }

}
