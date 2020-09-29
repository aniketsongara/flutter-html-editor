import 'package:flutter/material.dart';
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

    String url = "https://firebasestorage.googleapis.com/v0/b/tbbchat-d6f52.appspot.com/o/1601288130853?alt=media&token=4abe7d2d-066d-4519-8258-a1bff425dc32";
    if (image != null) {
      callbackFile(url);
    }
  }
}



/*
               String base64Image = "<video width=\"320\" height=\"240\" controls> <source src=\"$url\" type=\"video/mp4\"></video>";
                String txt =
                    "\$('.note-editable').append( '" + base64Image + "');";
                _controller.evaluateJavascript(txt);
*/