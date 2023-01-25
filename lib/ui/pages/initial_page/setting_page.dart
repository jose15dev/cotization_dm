import 'package:cotizacion_dm/core/infrastructure/infrastructure.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/initial_page/components/drawer.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          bottom: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Configuracion"),
          ),
        ),
        customPadding(heading("Restablecer datos", () {
          AppSetup.reset().then((value) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (route) => false);
          });
        }, "Resetear"))
      ],
    );
  }

  Widget _buildBottomBar() {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (orientation == Orientation.landscape) {
          return Container();
        }
        return const BottomBar();
      },
    );
  }
}
