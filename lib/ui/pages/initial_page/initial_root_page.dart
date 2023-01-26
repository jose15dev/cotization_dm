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
    Container(),
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

class DotIndicatorPainter extends BoxPainter {
  static double radius = 8.0;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final dx = configuration.size!.width / 2;
    final dy = configuration.size!.height + radius / 2;
    final c = offset + Offset(dx, dy);
    final paint = Paint()..color = ColorPalete.primary;
    canvas.drawCircle(c, radius, paint);
  }
}

class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return DotIndicatorPainter();
  }
}
