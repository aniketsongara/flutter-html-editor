import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

/*
 * Created by riyadi rb on 2/5/2020.
 * link  : https://github.com/xrb21/flutter-html-editor
 */

typedef void CallbackValue(dynamic value);
class PickVideo extends StatelessWidget {
  final CallbackValue callbackFile;
  final Color color;

  PickVideo({this.callbackFile, this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 80,
                    child: FlatButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {
                        getImage(true);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Icon(
                              Icons.linked_camera,
                              color: color ?? Colors.black45,
                              size: 44,
                            ),
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(color: color ?? Colors.black45),
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
                        getImage(false);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Icon(
                              Icons.image,
                              color: color ?? Colors.black45,
                              size: 44,
                            ),
                          ),
                          Text(
                            "Galery",
                            style: TextStyle(color: color ?? Colors.black45),
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

  Future getImage(bool isKamera) async {
    var image = await ImagePicker.pickVideo(
      source: isKamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image != null) {
      uploadVideoFile(image);
    }
  }


  Future uploadVideoFile(File image) async {
    String videoUrl;
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String storageId = (millSeconds.toString());

    StorageReference ref = FirebaseStorage.instance.ref().child(storageId);
    StorageUploadTask uploadTask =
    ref.putFile(image, StorageMetadata(contentType: 'video/mp4'));
    Fluttertoast.showToast(msg: 'Please wait.');
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      videoUrl = downloadUrl;
      Fluttertoast.showToast(msg: videoUrl);
      callbackFile(videoUrl);
    }, onError: (err) {
      Fluttertoast.showToast(msg: 'This file is not an video');
    });

  }
}



/*
               String base64Image = "<video width=\"320\" height=\"240\" controls> <source src=\"$url\" type=\"video/mp4\"></video>";
                String txt =
                    "\$('.note-editable').append( '" + base64Image + "');";
                _controller.evaluateJavascript(txt);
*/