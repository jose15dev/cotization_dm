import 'package:flutter/material.dart';

class BodyPage extends StatelessWidget {
  final Widget? child;
  const BodyPage({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}

class HeadingPage extends StatelessWidget {
  final String title, desc;
  final Widget logo;
  final Widget? banner;
  final double height;
  const HeadingPage({
    super.key,
    required this.title,
    required this.desc,
    required this.logo,
    this.height = 200,
    this.banner,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 50.0;
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  logo,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headline2,
                          maxLines: 2,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          desc,
                          style: Theme.of(context).textTheme.bodyText2,
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FooterPage extends StatelessWidget {
  final Widget? child;
  const FooterPage({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20.0), child: child);
  }
}
