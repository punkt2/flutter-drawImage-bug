import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() => runApp(new DrawApp());

class DrawApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DrawAppState();
}

class DrawAppState extends State<DrawApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Canvas drawImage bug',
        home: Container(
            decoration: new BoxDecoration(color: Colors.grey),
            child: Column(
              children: <Widget>[
                Text('Image with drawImage'),
                SizedBox(
                    height: 200.0,
                    child: FutureBuilder<ByteData>(
                        future: imageWithDraw(),
                        builder: (BuildContext context,
                            AsyncSnapshot<ByteData> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Image.memory(
                                snapshot.data.buffer.asUint8List());
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading');
                          }
                          return null;
                        })),
                Text('Image without drawImage'),
                SizedBox(
                    height: 200.0,
                    child: FutureBuilder<ByteData>(
                        future: imageWithoutDraw(),
                        builder: (BuildContext context,
                            AsyncSnapshot<ByteData> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Image.memory(
                                snapshot.data.buffer.asUint8List());
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading');
                          }
                          return null;
                        }))
              ],
            )));
  }

  Future<ByteData> imageWithDraw() async {
    final ByteData data = await getAssetImage();
    var image = await loadImage(data);
    image = draw(image);
    return image.toByteData(format: ui.ImageByteFormat.png);
  }

  Future<ByteData> imageWithoutDraw() async {
    final ByteData data = await getAssetImage();
    var image = await loadImage(data);
    return image.toByteData(format: ui.ImageByteFormat.png);
  }

  Future<ByteData> getAssetImage() async {
    var assetImage = ExactAssetImage('images/flutter.jpg');
    var key = await assetImage.obtainKey(ImageConfiguration());
    final ByteData data = await key.bundle.load(key.name);
    return data;
  }

  Future<ui.Image> loadImage(ByteData data) async {
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  ui.Image draw(ui.Image image) {
    ui.Size size = ui.Size(image.width.toDouble(), image.height.toDouble());
    var rect = ui.Offset.zero & size;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, rect);
    var paint = ui.Paint()..color = Colors.blue;

    canvas.drawImage(image, ui.Offset.zero, paint);
    canvas.drawRect(ui.Rect.fromLTRB(0.0, 0.0, 100.0, 100.0), paint);

    final picture = recorder.endRecording();
    image = picture.toImage(size.width.toInt(), size.height.toInt());
    return image;
  }
}
