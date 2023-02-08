import 'package:cotizacion_dm/ui/components/components.dart';
import 'package:cotizacion_dm/ui/pages/employee_page/bloc/form_employee_bloc/contact.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectContactDialog extends StatefulWidget {
  final List<CustomContact> contacts;
  const SelectContactDialog({super.key, required this.contacts});

  @override
  State<SelectContactDialog> createState() => _SelectContactDialogState();
}

class _SelectContactDialogState extends State<SelectContactDialog> {
  String searchWord = "";
  List<CustomContact> filtered = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _filterContacts(searchWord);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var foreground =
        filtered.isNotEmpty ? ColorPalete.primary : ColorPalete.white;
    var background =
        filtered.isNotEmpty ? ColorPalete.secondary : ColorPalete.error;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: SizedBox(
          width: size.width * 0.8,
          height: size.height / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  color: background,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 60.0, color: foreground),
                      CustomTextfield(
                        label: "Buscar contacto",
                        fontSize: 30,
                        foreground: foreground,
                        onChanged: _filterContacts,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    color: ColorPalete.white,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: ((context, index) {
                        var contact = filtered[index];
                        return ContactItem(
                          contact: contact,
                          onTap: () => _save(contact),
                        );
                      }),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _filterContacts(String value) {
    setState(() {
      searchWord = value;
      if (searchWord.isEmpty) {
        filtered = widget.contacts
            .where((element) => element.phone.isNotEmpty)
            .toList();
      } else {
        filtered = widget.contacts.where((element) {
          var thereRecords =
              element.name.toLowerCase().contains(searchWord.toLowerCase());
          return thereRecords
              ? thereRecords
              : (element.phone.contains(searchWord));
        }).toList();
      }
    });
  }

  _save(CustomContact contact) {
    Navigator.of(context).pop(
      ContactResponse(contact: contact, result: ContactDialogResult.success),
    );
  }
}

class ContactItem extends StatelessWidget {
  final Function()? onTap;
  const ContactItem({
    Key? key,
    this.onTap,
    required this.contact,
  }) : super(key: key);

  final CustomContact contact;

  Widget _title(context) {
    return Text(
      contact.name,
    );
  }

  Widget _phone(context) {
    return Text(
      contact.phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _avatar(),
      title: _title(context),
      subtitle: _phone(context),
      onTap: onTap,
    );
  }

  Widget _avatar() {
    var avatar = contact.avatar is Uint8List && contact.avatar!.isNotEmpty
        ? contact.avatar
        : null;
    var icon = !PhoneNumberUtility.isNumberPhone(contact.name)
        ? Text(contact.name[0].toUpperCase())
        : const Icon(Icons.person);
    return CircleAvatar(
      child: avatar is Uint8List
          ? ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.memory(
                avatar,
                fit: BoxFit.cover,
              ))
          : icon,
    );
  }
}

enum ContactDialogResult {
  success,
  failed,
  empty,
}

class ContactResponse {
  final CustomContact? contact;
  final ContactDialogResult result;

  ContactResponse({this.contact, required this.result})
      : assert(
          contact != null || result != ContactDialogResult.success,
        );
}
