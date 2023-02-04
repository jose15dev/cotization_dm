import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectImageMenu extends StatelessWidget {
  const SelectImageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .7,
      height: MediaQuery.of(context).size.height * .2,
      child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorPalete.white,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageMenuAction(
                    icon: FontAwesomeIcons.image,
                    text: "Seleccionar imagen",
                    onTap: () {
                      PickImageUtility.pickImage().then((value) {
                        Navigator.of(context).pop(ResultImagePicker(
                          image: value,
                        ));
                      });
                    }),
                ImageMenuAction(
                  icon: FontAwesomeIcons.camera,
                  text: "Tomar foto",
                  onTap: () {
                    PickImageUtility.takePhoto().then((value) {
                      Navigator.of(context).pop(ResultImagePicker(
                        image: value,
                      ));
                    });
                  },
                ),
                ImageMenuAction(
                  icon: FontAwesomeIcons.trash,
                  text: "Quitar imagen",
                  onTap: () {
                    Navigator.of(context).pop(ResultImagePicker(remove: true));
                  },
                ),
              ],
            ),
          )),
    );
  }
}

class ImageMenuAction extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String text;
  const ImageMenuAction({
    Key? key,
    this.onTap,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class ResultImagePicker {
  final bool remove;
  final Uint8List? image;
  ResultImagePicker({this.remove = false, this.image});
}
