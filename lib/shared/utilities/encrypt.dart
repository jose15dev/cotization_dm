import 'dart:convert';
import 'dart:io';

String encryptString(String text) {
  final enCodedJson = utf8.encode(text);
  final gZipJson = gzip.encode(enCodedJson);
  final base64Json = base64.encode(gZipJson);
  return base64Json;
}

String decryptString(String text) {
  final decodeBase64Json = base64.decode(text);
  final decodegZipJson = gzip.decode(decodeBase64Json);
  final originalJson = utf8.decode(decodegZipJson);
  return originalJson;
}
