import 'package:cotizacion_dm/ui/pages/pages.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';

class ContactBanner extends StatefulWidget {
  final Function() onCall, onChat;
  final double height;
  const ContactBanner(
      {super.key,
      required this.height,
      required this.onCall,
      required this.onChat});

  @override
  State<ContactBanner> createState() => _ContactBannerState();
}

class _ContactBannerState extends State<ContactBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: widget.height,
        color: ColorPalete.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contacto",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(children: [
                  Expanded(
                    child: ContactButton(
                      label: "Whatsapp",
                      icon: Icons.whatsapp,
                      onTap: widget.onChat,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ContactButton(
                      label: "Llamar",
                      icon: Icons.call,
                      onTap: widget.onCall,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ));
  }
}
