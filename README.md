# MacOS Tabbar

A Flutter package that provides a macOS-style tab bar widget.

<img width="880" alt="Screenshot 2025-05-10 at 6 54 50 PM" src="https://github.com/user-attachments/assets/c265af46-a2ae-4dd3-af14-4a688fa92bbd" />


https://github.com/user-attachments/assets/4944ba45-3b7b-4d41-99f9-60206a3d87e9

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  macos_tabbar: ^0.0.1
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:macos_tabbar/macos_tabbar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MacosTabData selectedTab;
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
    selectedTab = tabs.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: MacosTabbar(
        tabs: tabs,
        selectedTabId: selectedTab.id,
        onTabSelected: (newTabId) {
          setState(() {
            selectedTab = tabs.firstWhere((tab) => tab.id == newTabId);
          });
        },
        onTabDeleted: (tabId) {
          setState(() {
            tabs.removeWhere((tab) => tab.id == tabId);
          });
        },
      ),
    );
  }
}
```

## Example

Check out the `example` directory for a complete example of how to use this package.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
