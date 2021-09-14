import 'package:androcid/screens/tabs/submitscreen.dart';
import 'package:androcid/screens/tabs/viewscreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Androcid"),
        bottom: TabBar(controller: _tabController, tabs: [
          Tab(
            text: "Submit",
          ),
          Tab(
            text: "View",
          )
        ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [SubmitScreen(), ViewScreen()],
      ),
    );
  }
}
