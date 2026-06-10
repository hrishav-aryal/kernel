import '../models/models.dart';
import '../repositories/byte_repository.dart';

/// Service for managing byte operations
/// Uses repository pattern for data access
class ByteService {
  final ByteRepository _byteRepository = ByteRepository();

  /// Get all bytes
  Future<List<Byte>> getBytes() async {
    return await _byteRepository.getBytes();
  }

  /// Load byte content
  Future<List<Block>> loadByteContent(String contentUrl) async {
    return await _byteRepository.loadByteContent(contentUrl);
  }
}
