import 'package:auto_size_text/auto_size_text.dart';
import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/utilities/dialog_employee.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomStackPage {
  final String title;
  final Widget page;
  final Function(TapDownDetails details, BuildContext context)? onTap;

  CustomStackPage(this.title, this.page, {this.onTap});
}

final initialPages = [
  CustomStackPage(
    "Empleados",
    const FetchEmployeeList(),
    onTap: (details, context) {
      dialogEmployeeForm(context, details, withImagePicker: true);
    },
  ),
  CustomStackPage("Cotizaciones", const AnimatedCotizationList(),
      onTap: (detils, context) {
    final cotizationBloc = BlocProvider.of<FetchCotizationCubit>(context);
    cotizationBloc.onCreateCotization();
  }),
  CustomStackPage(
    "Pagos",
    Center(),
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

  SetupPropertiesCubit get setupBloc => BlocProvider.of(context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(fadeTransition(const PreferencesPage()));
          },
          child: Icon(
            Icons.settings_outlined,
            color: ColorPalete.black,
          ),
        ),
        title: StreamBuilder<String?>(
            stream: setupBloc.businessNameStream,
            builder: (context, snapshot) {
              return LayoutBuilder(builder: (context, constraints) {
                return AutoSizeText(
                  snapshot.data ?? titleApp,
                  presetFontSizes: const [
                    30,
                    25,
                    20,
                  ],
                  maxLines: 1,
                );
              });
            }),
        actions: [
          if (initialPages[_currentPage].onTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTapDown: (details) {
                  initialPages[_currentPage].onTap?.call(details, context);
                },
                child: const Icon(FontAwesomeIcons.solidSquarePlus),
              ),
            ),
        ],
        bottom: TabBar(
          onTap: (value) {
            setState(() {
              _currentPage = value;
            });
          },
          controller: _tabController,
          labelColor: ColorPalete.black,
          isScrollable: true,
          indicator: const DotPlaneIndicator(),
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
