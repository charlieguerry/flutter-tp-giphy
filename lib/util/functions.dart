import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:toast/toast.dart';
import 'package:tp_giphy/widgets/gif_container.dart';

void copyGif({BuildContext context, GifContainer selectedGif}) {
  Clipboard.setData(
    ClipboardData(text: selectedGif.urlToShare),
  );
  Toast.show(
    "Url du GIF copié dans le presse-papier",
    context,
    duration: Toast.LENGTH_LONG,
    gravity: Toast.BOTTOM,
  );
}
