import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static const String _key = 'fina';

  static String encryptConnection(String connectionKey) {
    final key = encrypt.Key.fromUtf8(md5.convert(utf8.encode(_key)).toString());
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
    return encrypter.encrypt(connectionKey).base64;
  }
}
