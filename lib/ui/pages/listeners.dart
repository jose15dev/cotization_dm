part of 'app.dart';

class AppListener extends StatefulWidget {
  final Widget? child;
  const AppListener({super.key, this.child});

  @override
  State<AppListener> createState() => _AppListenerState();
}

class _AppListenerState extends State<AppListener> {
  SetupPropertiesCubit get setupBloc => BlocProvider.of(context);
  FetchCotizationCubit get cotizationBloc => BlocProvider.of(context);
  FetchEmployeeCubit get employeeBloc => BlocProvider.of(context);
  FetchLiquidationsCubit get liquidationBloc => BlocProvider.of(context);

  // Services
  SnackbarBloc get snackbarBloc => BlocProvider.of(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupBloc.getProperties();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SetupPropertiesCubit, SetupPropertiesState>(
            listener: ((context, state) {
          if (state is SetupPropertiesBlockScreen) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: ((context) => const BlockScreenPage())));
          }

          if (state is SetupPropertiesIsOnPreferences) {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: ((context) => const PreferencesPage())))
                .then((value) {
              BlocProvider.of<SetupPropertiesCubit>(context).getProperties();
            });
          }
        })),
        BlocListener<SnackbarBloc, SnackbarState>(
          listener: (context, state) async {
            if (state is ShowSnackbarState) {
              var snackbar = SnackbarUtility.snackbar(state);
              messagerKey.currentState
                ?..removeCurrentSnackBar()
                ..showSnackBar(snackbar);
            }

            if (state is ShowBannerState) {
              messagerKey.currentState
                ?..removeCurrentMaterialBanner()
                ..showMaterialBanner(BannerUtility.banner(state));
            }

            if (state is SnackbarInitial) {
              messagerKey.currentState?.clearSnackBars();
            }
          },
        ),
        BlocListener<FetchCotizationCubit, FetchCotizationState>(
          listener: (context, state) {
            if (state is OnEditCotization) {
              Navigator.of(context)
                  .push(
                    fadeTransition(
                      CreateCotizationPage(
                        cotization: state.cotization,
                        onCopy: state.onCopy,
                        onlyShow: false,
                      ),
                    ),
                  )
                  .then(_popOnSave);
            }
            if (state is OnCreateCotization) {
              Navigator.of(context)
                  .push(
                    fadeTransition(const CreateCotizationPage(
                      onCopy: false,
                      onlyShow: false,
                    )),
                  )
                  .then(_popOnSave);
            }

            if (state is OnActionCotizationFailed) {
              snackbarBloc.add(ErrorSnackbarEvent(state.message));
            }

            if (state is FetchCotizationInitial ||
                state is OnActionCotizationSuccess) {
              cotizationBloc.fetchCotizations();
            }
          },
        ),
        BlocListener<FetchEmployeeCubit, FetchEmployeeState>(
          listener: (context, state) {
            if (state is FetchEmployeeFailed) {
              snackbarBloc.add(ErrorSnackbarEvent(state.message));
            }

            if (state is OnActionEmployeeSuccess ||
                state is FetchEmployeeInitial) {
              employeeBloc.fetchEmployees();
            }
          },
        ),
        BlocListener<FetchLiquidationsCubit, FetchLiquidationsState>(
          listener: (context, state) {
            if (state is FetchLiquidationFailed) {
              snackbarBloc.add(ErrorSnackbarEvent(state.message));
            }
            if (state is FetchLiquidationOnCreateSuccess) {
              liquidationBloc.fetchLiquidations();
            }
            if (state is FetchLiquidationOnCreate) {
              Navigator.of(context)
                  .push(fadeTransition<Liquidation>(
                      const CreateLiquidationPage()))
                  .then((value) {
                if (value is Liquidation) {
                  liquidationBloc.saveLiquidation(value);
                } else {
                  liquidationBloc.resetState();
                }
              });
            }
          },
          child: Container(),
        )
      ],
      child: widget.child ?? Container(),
    );
  }

  void _popOnSave(value) {
    if (value is Cotization) {
      cotizationBloc.saveCotization(value);
    } else {
      cotizationBloc.resetState();
    }
  }
}
