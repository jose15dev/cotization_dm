import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/primary_button.component.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlockScreenPage extends StatelessWidget {
  const BlockScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    SetupPropertiesCubit setupBloc = BlocProvider.of(context);
    return OrientationBuilder(builder: (context, orientation) {
      var vertOrient = orientation == Orientation.portrait;
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: BlocBuilder<SetupPropertiesCubit, SetupPropertiesState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: const FractionalOffset(0.5, 0.3),
                      child: Icon(
                          state is SetupPropertiesAppReady
                              ? Icons.check
                              : Icons.room_preferences_outlined,
                          size: 60,
                          color: ColorPalete.primary),
                    ),
                    Align(
                      alignment: FractionalOffset(0.5, vertOrient ? 0.4 : 0.5),
                      child: Text(
                        state is SetupPropertiesAppReady
                            ? "Ahora puedes usar la aplicacion"
                            : "Antes de empezar debes configurar algunas propiedades.",
                        style: TextStyle(
                          color: ColorPalete.primary,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    state is SetupPropertiesAppReady
                        ? Align(
                            alignment:
                                FractionalOffset(0.5, vertOrient ? 0.7 : 0.8),
                            child: SizedBox(
                              height: 60,
                              width: 300,
                              child: PrimaryButton(
                                "Iniciar",
                                onTap: () => Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                        "/", (route) => false),
                              ),
                            ),
                          )
                        : Align(
                            alignment:
                                FractionalOffset(0.5, vertOrient ? 0.7 : 0.8),
                            child: SizedBox(
                              height: 60,
                              width: 300,
                              child: PrimaryButton(
                                "Ir a preferencias",
                                bordered: true,
                                textOnly: true,
                                onTap: setupBloc.navigateToPreferences,
                              ),
                            ),
                          )
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
