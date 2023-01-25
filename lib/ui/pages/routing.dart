part of 'app.dart';

class RouteAwareWidget extends StatefulWidget {
  final Widget child;
  const RouteAwareWidget({super.key, required this.child});

  @override
  State<RouteAwareWidget> createState() => _RouteAwareWidgetState();
}

class _RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  SetupPropertiesCubit get setupBloc => BlocProvider.of(context);
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // TODO: implement didPopNext
    super.didPopNext();
    setupBloc.getProperties();
  }

  @override
  void didPushNext() {
    // TODO: implement didPushNext
    super.didPushNext();
    setupBloc.getProperties();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
