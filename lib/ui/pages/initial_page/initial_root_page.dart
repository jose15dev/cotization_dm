import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class CustomStackPage {
  final String title;
  final Widget page;

  CustomStackPage(this.title, this.page);
}

final initialPages = [
  CustomStackPage(
    "Empleados",
    const FetchEmployeeList(),
  ),
  CustomStackPage(
    "Cotizaciones",
    const AnimatedCotizationList(),
  ),
  CustomStackPage(
    "Pagos",
    Container(
      child: Center(
        child: Text("Pays"),
      ),
    ),
  ),
];

class InitialRootPage extends StatefulWidget {
  const InitialRootPage({super.key});

  @override
  State<InitialRootPage> createState() => _InitialRootPageState();
}

class _InitialRootPageState extends State<InitialRootPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: initialPages.length, vsync: this, initialIndex: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(titleApp),
        bottom: TabBar(
          onTap: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          controller: _tabController,
          labelColor: ColorPalete.black,
          isScrollable: true,
          indicator: DotIndicator(),
          labelStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          tabs: initialPages
              .map(
                (e) => Tab(
                  text: e.title,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: initialPages.map((e) => e.page).toList(),
      ),
    );
  }
}
