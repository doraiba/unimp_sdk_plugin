import 'package:dio/dio.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:unimp_sdk_plugin/unimp_sdk_plugin.dart';

class Home extends HookWidget {
  final dio = Dio();
  final unimpPlugin = UnimpSdkPlugin();

  Home({super.key}) {
    unimpPlugin.registerHandleReceive((args) async {
      return ({"hello": "world"});
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = useQuery<List<Map<String, dynamic>>, dynamic>(
      'fetch-uniapp',
      () async {
        var l = await dio
            .get("http://192.168.1.9:8080/uniapp/uniapp.json")
            .then((value) => value.data?.cast<Map<String, dynamic>>());
        return l;
      },
      initial: [],
      onData: (value) {
        debugPrint('onData: $value');
      },
      onError: (error) {
        debugPrint('onError: $error');
      },
    );

    if (query.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (query.hasError) {
      return Center(
        child: Text(query.error.toString()),
      );
    }
    return Center(
      child: ListView.builder(
        itemCount: query.data?.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = query.data?[index] ?? {};
          return GFListTile(
              onTap: () {
                unimpPlugin.openUniMP(item["url"]);
              },
              color: GFColors.DARK,
              title: Text(
                item["title"],
                style: const TextStyle(color: GFColors.WHITE),
              ),
              icon: const Icon(
                CupertinoIcons.forward,
                color: GFColors.SUCCESS,
              ));
        },
      ),
    );
  }
}
