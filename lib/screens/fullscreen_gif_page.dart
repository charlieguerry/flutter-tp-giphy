import 'package:flutter/material.dart';
import 'package:tp_giphy/util/functions.dart';
import 'package:share/share.dart';
import 'package:tp_giphy/widgets/gif_container.dart';

class FullScreenGifPage extends StatefulWidget {
  const FullScreenGifPage({@required this.selectedGif});
  final GifContainer selectedGif;
  @override
  State<StatefulWidget> createState() {
    return FullScreenGifPageState();
  }
}

class FullScreenGifPageState extends State<FullScreenGifPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: widget.selectedGif.originalGif,
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  color: Color.fromRGBO(100, 0, 180, 0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.transparent,
                          child: Icon(
                            Icons.content_copy,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: () {
                            copyGif(
                                context: context,
                                selectedGif: widget.selectedGif);
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.transparent,
                          child: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: () {
                            Share.share(widget.selectedGif.urlToShare);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
