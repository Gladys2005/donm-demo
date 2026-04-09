import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/app_config.dart';

class CameraService {
  static final ImagePicker _imagePicker = ImagePicker();
  static CameraController? _cameraController;
  static List<CameraDescription>? _cameras;
  static int _currentCameraIndex = 0;
  
  // Initialize cameras
  static Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      throw Exception('Failed to initialize cameras: $e');
    }
  }
  
  // Get available cameras
  static List<CameraDescription> getCameras() {
    return _cameras ?? [];
  }
  
  // Initialize camera controller
  static Future<void> initializeCameraController({
    int cameraIndex = 0,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
  }) async {
    try {
      if (_cameras == null || _cameras!.isEmpty) {
        await initializeCameras();
      }
      
      if (_cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
      
      _currentCameraIndex = cameraIndex.clamp(0, _cameras!.length - 1);
      
      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      
    } catch (e) {
      throw Exception('Failed to initialize camera controller: $e');
    }
  }
  
  // Get camera controller
  static CameraController? getCameraController() {
    return _cameraController;
  }
  
  // Switch camera
  static Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      return;
    }
    
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    
    await initializeCameraController(cameraIndex: _currentCameraIndex);
  }
  
  // Take picture
  static Future<String?> takePicture() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized');
      }
      
      final XFile picture = await _cameraController!.takePicture();
      return picture.path;
      
    } catch (e) {
      throw Exception('Failed to take picture: $e');
    }
  }
  
  // Dispose camera controller
  static Future<void> disposeCameraController() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
  
  // Pick image from gallery
  static Future<String?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final hasPermission = await _checkPhotoPermission();
      if (!hasPermission) {
        throw Exception('Photo permission denied');
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      return image?.path;
      
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }
  
  // Pick image from camera
  static Future<String?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      return image?.path;
      
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }
  
  // Pick multiple images from gallery
  static Future<List<String>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final hasPermission = await _checkPhotoPermission();
      if (!hasPermission) {
        throw Exception('Photo permission denied');
      }
      
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      return images.map((image) => image.path).toList();
      
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }
  
  // Pick video from gallery
  static Future<String?> pickVideoFromGallery({
    Duration? maxDuration,
  }) async {
    try {
      final hasPermission = await _checkPhotoPermission();
      if (!hasPermission) {
        throw Exception('Photo permission denied');
      }
      
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );
      
      return video?.path;
      
    } catch (e) {
      throw Exception('Failed to pick video from gallery: $e');
    }
  }
  
  // Record video from camera
  static Future<String?> recordVideoFromCamera({
    Duration? maxDuration,
  }) async {
    try {
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );
      
      return video?.path;
      
    } catch (e) {
      throw Exception('Failed to record video: $e');
    }
  }
  
  // Compress image
  static Future<String> compressImage(
    String imagePath, {
    int quality = 80,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // This would use an image compression library
      // For now, just return the original path
      return imagePath;
      
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
  
  // Resize image
  static Future<String> resizeImage(
    String imagePath, {
    required int width,
    required int height,
  }) async {
    try {
      final File imageFile = File(imagePath);
      
      // This would use an image processing library
      // For now, just return the original path
      return imagePath;
      
    } catch (e) {
      throw Exception('Failed to resize image: $e');
    }
  }
  
  // Get image info
  static Future<Map<String, dynamic>> getImageInfo(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final stat = await imageFile.stat();
      
      return {
        'path': imagePath,
        'size': stat.size,
        'lastModified': stat.modified,
        'name': path.basename(imagePath),
        'extension': path.extension(imagePath),
      };
      
    } catch (e) {
      throw Exception('Failed to get image info: $e');
    }
  }
  
  // Validate image
  static bool validateImage(String imagePath) {
    try {
      final File imageFile = File(imagePath);
      
      // Check if file exists
      if (!imageFile.existsSync()) {
        return false;
      }
      
      // Check file size
      final fileSize = imageFile.lengthSync();
      if (fileSize > AppConfig.maxImageSize) {
        return false;
      }
      
      // Check file extension
      final extension = path.extension(imagePath).toLowerCase();
      if (!AppConfig.supportedImageFormats.contains(extension.substring(1))) {
        return false;
      }
      
      return true;
      
    } catch (e) {
      return false;
    }
  }
  
  // Save image to app directory
  static Future<String> saveImageToAppDirectory(
    String imagePath, {
    String? customName,
  }) async {
    try {
      final File originalFile = File(imagePath);
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images'));
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = customName ??
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final savedPath = path.join(imagesDir.path, fileName);
      
      await originalFile.copy(savedPath);
      
      return savedPath;
      
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }
  
  // Delete image
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      
      return false;
      
    } catch (e) {
      return false;
    }
  }
  
  // Check camera permission
  static Future<bool> _checkCameraPermission() async {
    try {
      final permission = await Permission.camera.request();
      return permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;
    } catch (e) {
      return false;
    }
  }
  
  // Check photo permission
  static Future<bool> _checkPhotoPermission() async {
    try {
      final permission = await Permission.photos.request();
      return permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;
    } catch (e) {
      return false;
    }
  }
  
  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  // Get image preview
  static Widget getImagePreview(
    String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        );
      },
    );
  }
  
  // Get camera preview widget
  static Widget getCameraPreview({
    double? aspectRatio,
  }) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return CameraPreview(
      _cameraController!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AspectRatio(
            aspectRatio: aspectRatio ?? _cameraController!.value.aspectRatio,
            child: Container(),
          );
        },
      ),
    );
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  // Dispose resources
  static Future<void> dispose() async {
    await disposeCameraController();
    _cameras = null;
  }
}
