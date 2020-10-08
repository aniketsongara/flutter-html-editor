import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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
    return /*Scaffold(
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
    )*/
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
                child: _isRecording ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    SizedBox(
                      width: 160,
                      child: FlatButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          _stopAudioRecording();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Icon(
                                Icons.mic,
                                color: Colors.green,
                                size: 44,
                              ),
                            ),
                            Text(
                             _isRecording ? "Recording...\n Tap to stop Recording " : "Tap to start Recording",
                              style: TextStyle(color:  Colors.black45),
                            ),
                          ],
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ) : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 80,
                      child: FlatButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          setState(() {
                            _startAudioRecording();
                            _isRecording = true;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Icon(
                                Icons.record_voice_over,
                                color:  Colors.black45,
                                size: 44,
                              ),
                            ),
                            Text(
                              "Record",
                              style: TextStyle(color:  Colors.black45),
                            ),
                          ],
                        ),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: FlatButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () {
                          _openFileExplorer();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Icon(
                                Icons.library_music,
                                color: Colors.black45,
                                size: 44,
                              ),
                            ),
                            Text(
                              "Galery",
                              style: TextStyle(color:  Colors.black45),
                            ),
                          ],
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _openFileExplorer() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if(result != null) {
        File file = File(result.files.single.path);
        uploadAudioFile(file);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
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
