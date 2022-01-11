import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  late int _cameraIndex;
  bool _isRecording = false;
  late String _filePath;

  @override
  void initState() {
    super.initState();

    availableCameras().then((cameras) {
      _cameras = cameras;

      if (_cameras.length != 0) {
        _cameraIndex = 0;

        _initCamera(_cameras[_cameraIndex]);
      }
    });
  }

  _initCamera(CameraDescription camera) async {
    if (_controller != null) await _controller.dispose();

    _controller = CameraController(camera, ResolutionPreset.medium);

    _controller.addListener(() => this.setState(() {}));

    _controller.initialize();
  }

  Widget _buildCamera() {
    if (_controller == null || !_controller.value.isInitialized)
      return Center(child: Text('Loading...'));

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: CameraPreview(_controller),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(_getCameraIcon(_cameras[_cameraIndex].lensDirection)),
          onPressed: _onSwitchCamera,
        ),
        IconButton(
          icon: Icon(Icons.radio_button_checked),
          onPressed: _isRecording ? null : _onRecord,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: _isRecording ? _onStop : null,
        ),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: _isRecording ? null : _onPlay,
        ),
      ],
    );
  }

  void _onPlay() => OpenFile.open(_filePath);

  Future<void> _onStop() async {
    // var directory = await getTemporaryDirectory();
    // _filePath = directory.path + '/${DateTime.now()}.mp4';
    // await _controller.stopVideoRecording();

    if (_controller.value.isRecordingVideo) {
      XFile videoFile = await _controller.stopVideoRecording();
      print(videoFile.path); //and there is more in this XFile object
    }

    setState(() => _isRecording = false);
  }

  Future<void> _onRecord() async {
    // _controller.startVideoRecording(_filePath);

    setState(() {
      _isRecording = true;
      if (!_controller.value.isRecordingVideo) {
        _controller.startVideoRecording();
      }
    });
  }

  IconData _getCameraIcon(CameraLensDirection lensDirection) {
    return lensDirection == CameraLensDirection.back
        ? Icons.camera_front
        : Icons.camera_rear;
  }

  void _onSwitchCamera() {
    if (_cameras.length < 2) return;

    _cameraIndex = (_cameraIndex + 1) % 2;

    _initCamera(_cameras[_cameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video recording with Flutter')),
      body: Column(children: [
        Container(height: 500, child: Center(child: _buildCamera())),
        _buildControls(),
      ]),
    );
  }
}
