import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/loading_indicator.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchLiquidationList extends StatefulWidget {
  const FetchLiquidationList({super.key});

  @override
  State<FetchLiquidationList> createState() => _FetchLiquidationListState();
}

class _FetchLiquidationListState extends State<FetchLiquidationList> {
  FetchLiquidationsCubit get bloc => BlocProvider.of(context);
  @override
  void initState() {
    super.initState();

    bloc.fetchLiquidations();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<FetchLiquidationsCubit, FetchLiquidationsState>(
        builder: (context, state) {
          if (state is FetchLiquidationOnLoading) {
            return const Center(
              child: LoadingIndicator(),
            );
          }
          if (state is FetchLiquidationOnSuccess) {
            return Stack(
              children: [
                Positioned(
                  height: constraints.maxHeight * 0.5,
                  left: 0,
                  right: 0,
                  bottom: -constraints.maxHeight * 0.2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalete.black.withOpacity(0.5),
                          blurRadius: 90,
                          spreadRadius: 50,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: PerspectiveListView(
                      visualizedItems: 8,
                      initialIndex: state.liquidations.length - 1,
                      itemExtent: constraints.maxHeight * .4,
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * .05,
                          vertical: constraints.maxHeight * .03),
                      children: state.liquidations
                          .asMap()
                          .entries
                          .map((e) => AnimatedLiquidationCard(
                                liquidation: e.value,
                                colors: Colors.primaries
                                    .getRange(e.key, e.key + 2)
                                    .toList(),
                              ))
                          .toList()),
                ),
              ],
            );
          }
          if (state is FetchLiquidationOnEmpty) {
            return const Center(
              child: Text("No hay liquidaciones"),
            );
          }
          return const SizedBox.shrink();
        },
      );
    });
  }
}
