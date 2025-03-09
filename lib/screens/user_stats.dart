import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../storage.dart';

class UserStats extends StatefulWidget {
  Storage storage;

  UserStats({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats> {
  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  Future<void> asyncInitState() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
