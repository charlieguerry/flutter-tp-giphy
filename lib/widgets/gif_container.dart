import 'package:flutter/material.dart';
import 'package:tp_giphy/screens/fullscreen_gif_page.dart';
import 'package:tp_giphy/util/functions.dart';
import 'package:tp_giphy/util/transitions.dart';

import 'gif.dart';

class GifContainer extends StatefulWidget {
  /// Un GifContainer contient un Gif original, un Gif basse qualité et un Gif basse qualité figé.
  ///
  /// L'HomePage va afficher une liste de GifContainer qui eux même vont afficher un GIF basse qualité (figé ou en mouvement).
  ///
  /// Lors du clic sur un GifContainer, ça va lancer une page qui va afficher le GIF orginal.
  const GifContainer({
    @required this.key,
    this.id,
    this.gifId,
    this.isStill,
    this.originalGif,
    this.mediumStillGif,
    this.mediumMovingGif,
    this.urlToShare,
  });

  /// Cette clé me permet d'accéder à l'état du Widget en dehors de la classe
  ///
  /// Grâce à ça je peux notifier depuis l'HomePage chaque GifContainer pour leur dire d'afficher un GIF figé ou un GIF en mouvement.
  final GlobalKey<_GifContainerState> key;
  final int id;
  final String gifId;
  final bool isStill;
  final Gif originalGif;
  final Gif mediumStillGif;
  final Gif mediumMovingGif;
  final String urlToShare;

  @override
  _GifContainerState createState() => _GifContainerState();
}

class _GifContainerState extends State<GifContainer> {
  /**
   * Utilisé pour afficher un filtre sombre lors de la selection d'un GIF.
   */
  bool _isSelecting = false;
  /**
   * True => GIF figé
   * 
   * False => GIF en mouvement
   */
  bool _isStill;

  void setIsStill(bool isStill) {
    setState(() {
      _isStill = isStill;
    });
  }

  @override
  void initState() {
    super.initState();
    _isStill = widget.isStill;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, FadeRoute(page: FullScreenGifPage(selectedGif: widget)));
        },
        //Le LongPress permet de copié l'url du gif.
        onLongPress: () {
          copyGif(context: context, selectedGif: widget);
        },
        onTapDown: (pressDetail) {
          setState(() {
            _isSelecting = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _isSelecting = false;
          });
        },
        onTapUp: (pressDetail) {
          setState(() {
            _isSelecting = false;
          });
        },
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.8),
          child: Opacity(
            opacity: _isSelecting ? 0.5 : 1,
            child: _isStill ? widget.mediumStillGif : widget.mediumMovingGif,
          ),
        ),
      ),
    );
  }
}
