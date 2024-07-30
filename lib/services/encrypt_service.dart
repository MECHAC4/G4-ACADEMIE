import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  final _encrypter = encrypt.Encrypter(encrypt.AES(
    encrypt.Key.fromLength(32),
    mode: encrypt.AESMode.cbc,
  ));
  final _iv = encrypt.IV.fromLength(16);

  String encryptPassword(String password) {
    return _encrypter.encrypt(password, iv: _iv).base64;
  }

  String decryptPassword(String encryptedPassword) {
    return _encrypter.decrypt64(encryptedPassword, iv: _iv);
  }
}
