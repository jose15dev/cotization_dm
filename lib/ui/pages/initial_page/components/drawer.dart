import 'package:cotizacion_dm/globals.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: ColorPalete.primary,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorPalete.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const ArchitechIcon(
                        size: 60,
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      titleApp,
                      style: TextStyle(
                        fontSize: 20,
                        color: ColorPalete.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  DrawerBasicOption(
                    title: "Principal",
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context, "/", (route) => false),
                    active: ModalRoute.of(context)?.settings.name == "/",
                  ),
                  DrawerBasicOption(
                    title: "Nuevo Trabajador",
                    icon: Icons.person_add_outlined,
                    activeIcon: Icons.home,
                    onTap: () => BlocProvider.of<FetchEmployeeCubit>(context)
                        .onCreateEmployee(),
                  ),
                ],
              )
            ],
          ),
          Column(
            children: [
              DrawerBasicOption(
                title: "Preferencias de la app",
                icon: Icons.room_preferences_outlined,
                activeIcon: Icons.room_preferences,
                onTap: () => Navigator.push(
                    context, fadeTransition(const PreferencesPage())),
                active: ModalRoute.of(context)?.settings.name == "/preferences",
              ),
              DrawerBasicOption(
                title: "Configuracion",
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    fadeTransition(const SettingPage()), (route) => false),
                active: ModalRoute.of(context)?.settings.name == "/settings",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerBasicOption extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  const DrawerBasicOption({
    Key? key,
    required this.title,
    this.onTap,
    required this.icon,
    required this.activeIcon,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = active ? ColorPalete.primary : Colors.grey.shade600;
    return ListTile(
      selected: active,
      selectedColor: color,
      selectedTileColor: ColorPalete.secondary,
      onTap: onTap,
      leading: Icon(
        active ? activeIcon : icon,
      ),
      horizontalTitleGap: 0,
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
