import 'package:flutter/material.dart';

class ArchitechIcon extends StatelessWidget {
  final double size;
  const ArchitechIcon({super.key, this.size = 254});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/arquitecto.png',
      width: size,
      height: size,
    );
  }
}

class FinanceIcon extends StatelessWidget {
  final double size;
  const FinanceIcon({super.key, this.size = 254});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/finanzas.png',
      width: size,
      height: size,
    );
  }
}

class PayIcon extends StatelessWidget {
  final double size;
  const PayIcon({super.key, this.size = 254});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/pago.png',
      width: size,
      height: size,
    );
  }
}

class PlaneIcon extends StatelessWidget {
  final double size;
  const PlaneIcon({super.key, this.size = 254});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/plano.png',
      width: size,
      height: size,
    );
  }
}

class WorkerIcon extends StatelessWidget {
  final double size;
  const WorkerIcon({super.key, this.size = 254});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/obrero.png',
      width: size,
      height: size,
    );
  }
}
