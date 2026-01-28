import 'dart:io';
import 'package:crypto/crypto.dart';

class ChecksumService {
  Future<String> generateChecksum(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final checksum = sha256.convert(bytes);
      return checksum.toString();
    } catch (e) {
      print('Error generating checksum for ${file.path}: $e');
      rethrow;
    }
  }
}