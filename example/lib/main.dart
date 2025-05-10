import 'dart:math';

import 'package:flutter/material.dart';
import 'package:macos_tabbar/macos_tabbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacOS Tabbar Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String? selectedTabId;
  late List<MacosTabData> tabs;

  @override
  void initState() {
    super.initState();
    tabs = List.generate(
      5,
      (index) => MacosTabData(
        id: 'tab_$index',
        title: 'Tab ${index + 1}',
      ),
    );
    selectedTabId = tabs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: tabs.isEmpty
          ? null
          : MacosTabbar(
              tabs: tabs,
              selectedTabId: selectedTabId,
              onTabSelected: (newTabId) {
                setState(() {
                  selectedTabId = newTabId;
                });
              },
              onTabDeleted: (tabId) {
                setState(() {
                  tabs.removeWhere((tab) => tab.id == tabId);
                  if (tabs.isEmpty) {
                    selectedTabId = null;
                  } else if (tabId == selectedTabId) {
                    selectedTabId = tabs.first.id;
                  }
                });
              },
            ),
      body: Center(
        child: Text(
          'Selected Tab: ${selectedTabId == null ? 'No tabs' : tabs.firstWhere((tab) => tab.id == selectedTabId).title}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            final newIndex = tabs.length;
            final newTab = MacosTabData(
              id: Random().nextInt(1000000).toString(),
              title: 'Tab ${newIndex + 1}',
            );
            tabs.add(newTab);
            selectedTabId = newTab.id;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
