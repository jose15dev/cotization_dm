import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/bloc/snackbar/snackbar_bloc.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwipeCotizationScroll extends StatefulWidget {
  const SwipeCotizationScroll({
    Key? key,
  }) : super(key: key);

  @override
  State<SwipeCotizationScroll> createState() => _SwipeCotizationScrollState();
}

class _SwipeCotizationScrollState extends State<SwipeCotizationScroll> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCotizationCubit.fetchCotizations();
  }

  FetchCotizationCubit get fetchCotizationCubit => BlocProvider.of(context);
  SnackbarBloc get snackbarBloc => BlocProvider.of(context);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const height = 200.0;

    return BlocConsumer<FetchCotizationCubit, FetchCotizationState>(
      listener: (context, state) {
        if (state is OnActionCotizationFailed) {
          snackbarBloc.add(ErrorSnackbarEvent(state.message));
        }
      },
      builder: (context, state) {
        if (state is OnFetchCotizationLoading) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(
              child: LoadingIndicator(),
            ),
          );
        }
        if (state is OnFetchCotizationEmpty) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(
                child: MessageInfo(
              "No hay operaciones",
              enableIcon: false,
            )),
          );
        }
        return SizedBox(
          height: height,
          width: width,
          child: StreamBuilder<List<Cotization>>(
              stream: fetchCotizationCubit.cotizationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var cotizations =
                      snapshot.data!.where((e) => !e.finished).take(5).toList();
                  if (cotizations.isEmpty) {
                    return SizedBox(
                      height: height,
                      width: width,
                      child: const Center(
                          child: MessageInfo(
                        "No hay operaciones",
                        enableIcon: false,
                      )),
                    );
                  }
                  return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 1.05,
                        mainAxisExtent: 250,
                      ),
                      itemCount: cotizations.length,
                      itemBuilder: ((context, index) {
                        return CardCotization(cotizations[index]);
                      }));
                }
                return Container();
              }),
        );
      },
    );
  }
}
