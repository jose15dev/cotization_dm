import 'package:cotizacion_dm/ui/components/primary_button.component.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class CardPaymentEmployeeInfo extends StatelessWidget {
  const CardPaymentEmployeeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    const padding = 16.0;
    const radius = 20.0;
    var headline12 = Theme.of(context).textTheme.headline1;
    var subtitle22 = Theme.of(context).textTheme.subtitle2;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(bottom: padding),
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: ColorPalete.black,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            // Employee info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rodrigo Andres De avila Moreno", style: headline12),
                      _spacer,
                      Text("Sueldo \$60.000/dia", style: subtitle22),
                      Text("Lleva 5 dias trabajados", style: subtitle22),
                      _spacer,
                      _spacer,
                      Text(
                        "Trabajo hoy?",
                        style: subtitle22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _spacer,
            // Action-Card buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                // PrimaryButton(
                //   "Si",
                // ),
                // PrimaryButton(
                //   "Asistio medio dia",
                // ),
                // PrimaryButton(
                //   "No",
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _spacer => const SizedBox(
        height: 10.0,
      );
}
