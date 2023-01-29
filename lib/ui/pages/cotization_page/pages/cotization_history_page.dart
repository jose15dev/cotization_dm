import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimatedCotizationList extends StatefulWidget {
  const AnimatedCotizationList({super.key});

  @override
  State<AnimatedCotizationList> createState() => _AnimatedCotizationListState();
}

class _AnimatedCotizationListState extends State<AnimatedCotizationList> {
  FetchCotizationCubit get bloc => BlocProvider.of(context);
  @override
  void initState() {
    super.initState();
    bloc.fetchCotizations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCotizationCubit, FetchCotizationState>(
      builder: (context, state) {
        if (state is OnFetchCotizationSuccess) {
          return Stack(
            fit: StackFit.expand,
            children: [
              PerspectiveListView(
                onTapFrontItem: (value) {
                  Navigator.of(context)
                      .push(fadeTransition(
                          DetailsCotizationPage(state.cotizations[value!])))
                      .then(
                    (value) {
                      if (value is Cotization) {
                        bloc.deleteCotization(value);
                      } else {
                        bloc.resetState();
                      }
                    },
                  );
                },
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                itemExtent: MediaQuery.of(context).size.height * 0.3,
                visualizedItems: 8,
                initialIndex: state.cotizations.length - 1,
                children: state.cotizations
                    .map(
                      (e) => Hero(
                        tag: "cotization-${e.id}",
                        child: AnimatedCardCotization(e),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
