import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceService{
  static const String baseUrl = 'YOUR_API_BASE_URL';
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Kiểm tra và yêu cầu quyền microphone
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  // Bắt đầu ghi âm
  Future<bool> startRecording() async {
    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Không có quyền truy cập microphone');
      }

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      return true;
    } catch (e) {
      throw Exception('Lỗi bắt đầu ghi âm: $e');
    }
  }

  // Dừng ghi âm và trả về đường dẫn file
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      throw Exception('Lỗi dừng ghi âm: $e');
    }
  }

  // Hủy ghi âm
  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();
    } catch (e) {
      throw Exception('Lỗi hủy ghi âm: $e');
    }
  }

  // Kiểm tra trạng thái ghi âm
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  // Lấy amplitude (độ lớn âm thanh) để tạo hiệu ứng waveform
  Stream<Amplitude> getAmplitudeStream() {
    return _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 200));
  }

  // Upload file âm thanh và chuyển đổi thành text
  Future<Map<String, dynamic>> uploadVoiceAndConvertToText(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File âm thanh không tồn tại');
      }

      //fix
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/voice/speech-to-text'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('audio', filePath),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        return {
          'text': result['text'] ?? '',
          'voice_url': result['voice_url'] ?? '',
          'confidence': result['confidence'] ?? 0.0,
        };
      } else {
        throw Exception('Lỗi chuyển đổi giọng nói: $responseBody');
      }
    } catch (e) {
      throw Exception('Lỗi upload file âm thanh: $e');
    }
  }

  // Xóa file tạm
  Future<void> deleteTemporaryFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      // Log error nhưng không throw exception
      print('Lỗi xóa file tạm: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _audioRecorder.dispose();
  }
}