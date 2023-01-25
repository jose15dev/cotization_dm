import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:flutter/material.dart';

import 'components.dart';

class Header extends StatelessWidget {
  final Function()? onTap;
  const Header({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Row(children: [
        const ArchitechIcon(size: 150),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Empezemos por planificar una obra.',
                style: Theme.of(context).textTheme.headline1,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              PrimaryButton(
                "Cotizar",
                onTap: onTap,
              )
            ],
          ),
        )
      ]),
    );
  }
}
