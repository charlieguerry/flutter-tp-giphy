import 'package:flutter/material.dart';

class Gif extends StatefulWidget {
  const Gif({this.key, this.url}) : super(key: key);

  /**
   * Cette clé a une utilisation bien différente de celle du GifContainer.

   * Elle permet à Flutter de différencier 2 instances de Gif lors du setState() du parent GifContainer.
   *
   * Lorsque je demande au GifContainer de passer d'un GIF figé à un GIF en mouvement, à l'exécution du setState() du GifContainer, Flutter va
   *comparer le précédent Widget tree au nouveau Widget tree..
   *
   * Il va voir que je remplace un Gif par un autre Gif.
   *Si une clé de Gif est spécifiée, il va comparer les clés et va voir que ce n'est pas le même Widget.
   *Sinon il va juste comparer le type et voir que le widget est toujours le même et va laisser le GIF figé.
   * 
   * Explication par Google : https://www.youtube.com/watch?v=kn0EOS-ZiIc
   */
  final GlobalKey<GifState> key;
  final String url;

  @override
  State<StatefulWidget> createState() {
    return GifState();
  }
}

class GifState extends State<Gif> {
  Image _gif;
  bool _isLoading = true;
  ImageConfiguration _imageConfiguration = ImageConfiguration();

  ImageStreamListener setIsLoading() {
    return ImageStreamListener((_, __) {
      setState(() {
        _isLoading = false;
        //Ce removeListener ne fonctionne pas, quand l'état se dispose(),
        //le listener continue de marcher et tente de faire un setState() sur un State qui n'existe plus.
        //Ca ne fait pas buger l'appli mais ce n'est pas propre.
        //Du coup j'ai overridé le setState()...
        _gif.image.resolve(_imageConfiguration).removeListener(setIsLoading());
      });
    });
  }

  @override
  void setState(fn) {
    //Le If(mounted) permet de savoir si l'état est monté dans le Widget tree.
    //Si ce n'est pas le cas il ne fait rien.
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _gif = Image.network(widget.url);
    _gif.image.resolve(_imageConfiguration).addListener(setIsLoading());
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        : _gif;
  }
}
