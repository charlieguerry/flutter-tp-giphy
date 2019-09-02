import 'package:flutter/material.dart';

class PopupTipsPage extends StatefulWidget {
  @override
  _PopupTipsPageState createState() => _PopupTipsPageState();
}

class _PopupTipsPageState extends State<PopupTipsPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.all(50),
          color: Color.fromRGBO(0, 0, 0, 0.8),
          child: Center(
            child: Text(
              "Tips:\n\n" +
                  "- Long-press sur un Gif pour le copier\n\n" +
                  "- Swipe vers le bas pour rafraichir la page\n\n" +
                  "- Lancer le téléphone du toit d'un immeuble pour quitter l'appli.\n\n" +
                  "Enjoy :D",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
