import 'dart:developer';
import 'dart:ui';

import 'package:cotizacion_dm/core/domain/domain.dart';
import 'package:cotizacion_dm/shared/utilities/utilities.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/bloc/fetch_cotization_bloc/fetch_cotization_cubit.dart';
import 'package:cotizacion_dm/ui/pages/cotization_page/pages/pages.dart';
import 'package:cotizacion_dm/ui/transitions/custom_transtion.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScannerView extends StatefulWidget {
  const QrCodeScannerView({super.key});

  @override
  State<QrCodeScannerView> createState() => _QrCodeScannerViewState();
}

class _QrCodeScannerViewState extends State<QrCodeScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Cotization? _cotization;

  var _flashOn = false;
  var _isFailed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = size.width * 0.8;
    final scannerTopPosition = (size.height / 2) - (scannerSize / 2);
    final paddingOffsetDy =
        (scannerTopPosition - size.height * .1) / size.height;
    const iconSize = 30.0;
    final elementColor = ColorPalete.primary;
    final secondaryElementColor = ColorPalete.white;
    final primaryTextColor = ColorPalete.white;
    final background = ColorPalete.black.withOpacity(0.7);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: const [BarcodeFormat.qrcode],
              overlay: QrScannerOverlayShape(
                cutOutSize: scannerSize,
                borderColor: elementColor,
                borderRadius: 20.0,
                borderLength: 40.0,
                borderWidth: 10.0,
                overlayColor: background,
              ),
            ),
          ),
          Positioned(
              top: 20.0,
              left: 0.0,
              right: 20.0,
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: secondaryElementColor,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        child: Icon(
                          FontAwesomeIcons.cameraRotate,
                          color: secondaryElementColor,
                          size: iconSize,
                        ),
                        onTap: () async {
                          await controller!.flipCamera();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          color: secondaryElementColor,
                          size: iconSize,
                        ),
                        onTap: () async {
                          await controller!.toggleFlash();
                          setState(() {
                            _flashOn = !_flashOn;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )),

          // Top Actions
          Align(
            alignment: FractionalOffset(.5, paddingOffsetDy),
            child: Text(
              "Coloca el codigo QR dentro del recuadro",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ),

          // Notification Message
          if (_cotization != null)
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.bounceOut,
              duration: const Duration(seconds: 1),
              builder: ((context, value, child) {
                var translateY = MediaQuery.of(context).size.height * .1;
                return Transform.translate(
                  offset:
                      Offset(0.0, lerpDouble(translateY, -translateY, value)!),
                  child: child,
                );
              }),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<FetchCotizationCubit>(context)
                          .onEditCotization(_cotization!, true);
                      setState(() {
                        _cotization = null;
                      });
                    },
                    child: Container(
                      width: size.width * .6,
                      decoration: BoxDecoration(
                        color: elementColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        "La informacion ha sido cargada",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ),

          if (_isFailed)
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.bounceOut,
              duration: const Duration(seconds: 1),
              builder: ((context, value, child) {
                var translateY = MediaQuery.of(context).size.height * .1;
                return Transform.translate(
                  offset:
                      Offset(0.0, lerpDouble(translateY, -translateY, value)!),
                  child: child,
                );
              }),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFailed = false;
                      });
                    },
                    child: Container(
                      width: size.width * .6,
                      decoration: BoxDecoration(
                        color: ColorPalete.error,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        "Ocurrio un error al cargar la informacion",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      try {
        var cotization = cotizationFromJson(scanData.code!);
        _cotization = cotization;
      } catch (e) {
        _isFailed = true;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
