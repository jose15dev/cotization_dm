import 'package:cotizacion_dm/ui/pages/liquidation_page/bloc/fetch_liquidations/fetch_liquidations_cubit.dart';
import 'package:cotizacion_dm/ui/styled/styled.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchLiquidationPage extends StatefulWidget {
  const FetchLiquidationPage({super.key});

  @override
  State<FetchLiquidationPage> createState() => _FetchLiquidationPageState();
}

class _FetchLiquidationPageState extends State<FetchLiquidationPage> {
  FetchLiquidationsCubit get bloc => BlocProvider.of(context);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc.fetchLiquidations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: bloc.onCreate,
        label: const Text("Nuevo Pago"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  RefreshIndicator _buildBody() {
    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            bottom: AppBar(
              title: const Text("Pagos"),
              automaticallyImplyLeading: false,
            ),
          ),
          _items()
        ],
      ),
    );
  }

  BlocBuilder<FetchLiquidationsCubit, FetchLiquidationsState> _items() {
    return BlocBuilder<FetchLiquidationsCubit, FetchLiquidationsState>(
      builder: (context, state) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        if (state is FetchLiquidationOnLoading) {
          return SliverToBoxAdapter(
            child: SizedBox(
              width: width,
              height: height / 1.5,
              child: const LoadingIndicator(),
            ),
          );
        }
        if (state is FetchLiquidationOnEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              width: width,
              height: height / 1.5,
              child: const MessageInfo("No hay pagos"),
            ),
          );
        }

        return StreamBuilder(
          stream: bloc.liquidationStream,
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return SliverList(
                  delegate: SliverChildBuilderDelegate(
                ((context, index) {
                  var liquidation = snapshot.data![index];
                  return ListTile(
                    title: Text(liquidation.employee.firstname),
                    subtitle: Text(CurrencyUtility.doubleToCurrency(
                        liquidation.realPrice)),
                    trailing:
                        Text(TimeAgoUtility.toTimeAgo(liquidation.createdAt)),
                  );
                }),
                childCount: snapshot.data!.length,
              ));
            }
            return const SliverToBoxAdapter();
          },
        );
      },
    );
  }
}
