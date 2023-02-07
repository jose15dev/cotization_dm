import 'package:cotizacion_dm/ui/components/select_menu.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectImageMenu extends StatelessWidget {
  const SelectImageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectMenu(children: [
      MenuAction(
          icon: FontAwesomeIcons.image,
          text: "Seleccionar imagen",
          onTap: () {
            PickImageUtility.pickImage().then((value) {
              Navigator.of(context).pop(ResultImagePicker(
                image: value,
              ));
            });
          }),
      MenuAction(
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
      MenuAction(
        icon: FontAwesomeIcons.trash,
        text: "Quitar imagen",
        onTap: () {
          Navigator.of(context).pop(ResultImagePicker(remove: true));
        },
      ),
    ]);
  }
}

class ResultImagePicker {
  final bool remove;
  final Uint8List? image;
  ResultImagePicker({this.remove = false, this.image});
}
