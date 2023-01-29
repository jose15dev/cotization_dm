import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/transitions.dart';
import 'package:flutter/material.dart';

class InitialActions extends StatelessWidget {
  const InitialActions({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 200,
      width: width,
      child: Row(
        children: [
          Container(
            width: width / 3,
            padding: const EdgeInsets.all(8.0),
            child: OptionPage(
              label: "Pagos",
              icon: Icons.engineering_outlined,
              onTap: () => Navigator.of(context)
                  .push(fadeTransition(const InitialLiquidationPage())),
            ),
          ),
        ],
      ),
    );
  }
}
