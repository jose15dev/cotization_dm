import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/bloc/bloc.dart';
import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimatedCotizationList extends StatefulWidget {
  const AnimatedCotizationList({super.key});

  @override
  State<AnimatedCotizationList> createState() => _AnimatedCotizationListState();
}

class _AnimatedCotizationListState extends State<AnimatedCotizationList> {
  final _cardScrollController = PageController(viewportFraction: 0.25);
  final _typeScrollController = PageController();
  var _currentCard = 0.0;
  final _duration = const Duration(milliseconds: 1000);
  FetchCotizationCubit get bloc => BlocProvider.of(context);

  @override
  void initState() {
    super.initState();
    bloc.fetchCotizations();
    _cardScrollController.addListener(() {
      setState(() {
        _currentCard = _cardScrollController.page ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Cotization>>(
        stream: bloc.cotizationStream,
        initialData: const [],
        builder: (context, snapshot) {
          return Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                color: ColorPalete.primary,
              ),
              Align(
                  alignment: const FractionalOffset(0.5, 0.1),
                  child: SizedBox(
                    height: 50,
                    child: PageView(
                      controller: _typeScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      children: ['COTIZACION', 'CUENTA DE COBRO']
                          .map((e) => Center(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: ColorPalete.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: PageView.builder(
                    controller: _cardScrollController,
                    onPageChanged: (value) {
                      if (value < snapshot.data!.length) {
                        var type = snapshot.data![value].isAccount;
                        _changeType(type);
                      } else {
                        _cardScrollController.animateToPage(value - 1,
                            duration: _duration, curve: Curves.easeOut);
                      }
                    },
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, index) {
                      if (snapshot.data!.isEmpty || index == 0) {
                        return const SizedBox.shrink();
                      }
                      var item = snapshot.data![index - 1];
                      var result = _currentCard - (index + 1);
                      var value = -0.4 * result + 1;
                      var opacity = value.clamp(0, 1).toDouble();
                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            100 * (1 - value).abs(),
                            0.0,
                          )
                          ..scale(value),
                        child: Opacity(
                          opacity: opacity,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: AnimatedCardCotization(item),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          );
        });
  }

  void _changeType(bool type) {
    var page = type ? 1 : 0;
    _typeScrollController.animateToPage(
      page,
      duration: _duration,
      curve: Curves.bounceOut,
    );
  }
}

class AnimatedCardCotization extends StatefulWidget {
  const AnimatedCardCotization(
    this.item, {
    Key? key,
  }) : super(key: key);

  final Cotization item;

  @override
  State<AnimatedCardCotization> createState() => _AnimatedCardCotizationState();
}

class _AnimatedCardCotizationState extends State<AnimatedCardCotization> {
  FetchCotizationCubit get _bloc => BlocProvider.of(context);

  Color get _foreground => BgFgColorUtility.getFgForBg(widget.item.color);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _bloc.onShowCotization(widget.item),
      child: Container(
        decoration: BoxDecoration(
          color: Color(widget.item.color),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 30.0,
          horizontal: 20.0,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.item.name,
            style: TextStyle(
              color: _foreground,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.item.description,
            style: TextStyle(
              color: _foreground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ),
    );
  }
}

class CotizationHistoryPage extends StatefulWidget {
  const CotizationHistoryPage({super.key});

  @override
  State<CotizationHistoryPage> createState() => _CotizationHistoryPageState();
}

class _CotizationHistoryPageState extends State<CotizationHistoryPage> {
  FetchCotizationCubit get bloc => BlocProvider.of(context);
  SnackbarBloc get snackbarBloc => BlocProvider.of(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc.fetchCotizations();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return BlocListener<FetchCotizationCubit, FetchCotizationState>(
      listener: (context, state) {},
      child: Scaffold(
        backgroundColor: ColorPalete.white,
        body: _buildBody(orientation),
        bottomNavigationBar: _buildButtonBar(),
        floatingActionButtonLocation: _buildFloatingLocation(),
        floatingActionButton: _buildFloatingButton(),
      ),
    );
  }

  Widget? _buildButtonBar() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return null;
    }
    return const BottomBar();
  }

  FloatingActionButtonLocation _buildFloatingLocation() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return FloatingActionButtonLocation.endFloat;
    }
    return FloatingActionButtonLocation.centerDocked;
  }

  FloatingActionButton _buildFloatingButton() {
    return FloatingActionButton.extended(
      label: const Text(
        "Nueva cotization",
      ),
      icon: const Icon(
        Icons.add,
      ),
      onPressed: bloc.onCreateCotization,
    );
  }

  Widget _buildBody(Orientation orientation) {
    return LayoutBuilder(builder: ((p0, p1) {
      return RefreshIndicator(
        onRefresh: _reloadCotizations,
        child: CustomScrollView(
          slivers: [
            _appbar,
            _spacer(),
            _items,
          ],
        ),
      );
    }));
  }

  Future<void> _reloadCotizations() async {
    await DelayUtility.delay();
    bloc.reloadCotization();
  }

  SliverToBoxAdapter _spacer() {
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 30,
      ),
    );
  }

  SliverAppBar get _appbar {
    return SliverAppBar(
      pinned: true,
      bottom: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Historial de cotizationes",
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget get _items {
    var size = MediaQuery.of(context).size;
    return BlocConsumer<FetchCotizationCubit, FetchCotizationState>(
      listener: ((context, state) {
        if (state is FetchCotizationFailed) {
          snackbarBloc.add(ErrorSnackbarEvent(state.message));
        }
      }),
      builder: ((context, state) {
        if (state is OnFetchCotizationLoading) {
          return SliverToBoxAdapter(
            child: SizedBox(
              width: size.width,
              height: size.height / 1.5,
              child: const LoadingIndicator(),
            ),
          );
        }
        if (state is OnFetchCotizationEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              width: size.width,
              height: size.height / 1.5,
              child: MessageInfo(
                "No hay cotizaciones",
                onTap: bloc.fetchCotizations,
              ),
            ),
          );
        }
        return StreamBuilder<List<Cotization>>(
            stream: bloc.cotizationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var items = snapshot.data!.map((e) {
                  return CardCotization(e);
                }).toList();
                var count =
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 3
                        : 2;
                return SliverGrid(
                  delegate: SliverChildListDelegate(items),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                  ),
                );
              }
              return const SliverToBoxAdapter();
            });
      }),
    );
  }
}
