import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/transitions.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class LiquidationsSection extends StatefulWidget {
  final ScrollController controller;
  final Future<void> Function() onRefresh;
  final Stream<List<Liquidation>> liquidations;
  const LiquidationsSection(
      {super.key,
      required this.controller,
      required this.liquidations,
      required this.onRefresh});

  @override
  State<LiquidationsSection> createState() => _LiquidationsSectionState();
}

class _LiquidationsSectionState extends State<LiquidationsSection> {
  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(
      top: Radius.circular(30),
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorPalete.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              controller: widget.controller,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TopDraggableSection(),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  sliver: StreamBuilder<List<Liquidation>>(
                    stream: widget.liquidations,
                    initialData: const [],
                    builder: (BuildContext context, snapshot) {
                      return SliverList(
                          delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          var item = snapshot.data![index];
                          return LiquidationDetailsItem(liquidation: item);
                        },
                        childCount: snapshot.data!.length,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidationDetailsItem extends StatelessWidget {
  const LiquidationDetailsItem({
    Key? key,
    required this.liquidation,
  }) : super(key: key);

  final Liquidation liquidation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      leading: Icon(
        Icons.monetization_on,
        size: 30,
        color: ColorPalete.primary,
      ),
      title: Text(
        CurrencyUtility.doubleToCurrency(liquidation.realPrice),
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey.shade700,
        ),
      ),
      subtitle: Text(
        TimeAgoUtility.toTimeAgo(liquidation.createdAt),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sunny),
          const SizedBox(width: 5),
          Text(
            "${liquidation.days} días",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class TopDraggableSection extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalete.white,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 50,
            height: 5,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PAGOS",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(fadeTransition(const InitialLiquidationPage())),
                    child: Text(
                      "Ver todos",
                      style: TextStyle(
                        color: ColorPalete.primary,
                        fontSize: 18,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 100;

  @override
  // TODO: implement minExtent
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }
}
