import 'package:contacts_service/contacts_service.dart';
import 'package:cotizacion_dm/ui/utilities/utilities.dart';
import 'package:flutter/foundation.dart';

class CustomContact {
  final String phone;
  final String name;
  final Uint8List? avatar;

  CustomContact(this.phone, this.name, this.avatar);

  factory CustomContact.fromContactService(Contact contact) {
    return CustomContact(
      PhoneNumberUtility.toAppNumber(contact.phones!.first.value!),
      contact.displayName ?? "",
      contact.avatar,
    );
  }
}
