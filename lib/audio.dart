import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';


typedef void CallbackValue(dynamic value);

class AudioRecordingScreen extends StatefulWidget {
  final CallbackValue callbackFile;

  AudioRecordingScreen({this.callbackFile});

  @override
  State<StatefulWidget> createState() {
    return AudioRecordingState();
  }
}

class AudioRecordingState extends State<AudioRecordingScreen> {
  bool _isRecording = false;
  var dir;
  String audioUrl;
  Future<bool> checkPermission() async {
    print('Checking permissions.....');
    if (!await Permission.microphone.isGranted) {
      PermissionStatus statusMicrophone = await Permission.microphone.request();
      if (statusMicrophone != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _startAudioRecording() async {
    bool hasPermission = await checkPermission();
    try {
      if (hasPermission) {
        dir = await getExternalStorageDirectory();

        var fileName =
            'AUD_${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}';
        await AudioRecorder.start(
            path: dir.path + fileName.toString(),
            audioOutputFormat: AudioOutputFormat.AAC);

        print(
            '*********************************custom recording path is : ${dir.path + fileName}*********************************');

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          //_recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopAudioRecording() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    setState(() {//_recording = recording;
      _isRecording = isRecording;
    });
    uploadAudioFile(File(recording.path));
    //Navigator.pop(context,'${recording.path}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Reacord Audio'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(child: Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.blueAccent : Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.mic_off,
                    size: 50,
                    color: _isRecording ? Colors.red : Colors.black38,
                  )
                ],
              ),
            ),
          ),
            onTap: _isRecording ? _stopAudioRecording : _startAudioRecording,),
          Text(_isRecording ? 'Recording...': 'Tap to Start recording.')
        ],
      ),
    );
  }


  Future uploadAudioFile(File audio) async {
    Fluttertoast.showToast(msg: 'Please wait.');
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String storageId = (millSeconds.toString());

    StorageReference ref = FirebaseStorage.instance.ref().child(storageId);
    StorageUploadTask uploadTask =
    ref.putFile(audio, StorageMetadata(contentType: 'audio/mp3'));

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      audioUrl = downloadUrl;
      widget.callbackFile(audioUrl);
      }, onError: (err) {

      Fluttertoast.showToast(msg: 'This file is not an Audio');
    });
    Navigator.pop(context);
  }
}
