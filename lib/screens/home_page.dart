import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp_giphy/screens/popup_tips_page.dart';
import 'package:tp_giphy/util/transitions.dart';
import 'package:tp_giphy/widgets/gif.dart';
import 'package:tp_giphy/widgets/gif_container.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GifContainer> _gifs = new List<GifContainer>();
  final String _trendUrl = "http://api.giphy.com/v1/gifs/trending?";
  final String _searchUrl = "http://api.giphy.com/v1/gifs/search?";
  final String _apiKey = "hlRdW2NUBPJn01Vr1Fcw6oshlVWwKbGt";
  final TextEditingController _textFieldController =
      new TextEditingController();
  final String prefsProp = "IsAppOpenedForTheFirstTime?";

  //Paramètres de la requête HTTP
  String _url;
  int _initialNbGifs = 10;
  String _params;
  String _searchedText = "";
  String _tappingText = "";

  //GIF figé ? true : false
  bool _isStill = true;
  //True si la requête d'ajout des GIFs suivant est en cours sinon false
  bool _isAddMoreGifLoading = false;
  //True si la requête de recherche de GIF est en cours sinon false
  bool _isSearchRequestLoading = false;
  //True si la recherche a été validé via le bouton "enter" du clavier,
  //False si l'utilisateur fait un return
  bool _isSearchSubmitted = false;

  //Requête de recherche de GIFs
  Future search({int nbGifs}) async {
    setState(() {
      _isSearchRequestLoading = true;
    });
    return await getSearchedGifs(nbGifs: nbGifs).then((gifs) {
      setState(() {
        _gifs = gifs ?? _gifs;
        _isSearchRequestLoading = false;
      });
    });
  }

  //Requête d'ajouts des GIFs suivants
  void addMoreGifs(int nbGifsToAdd) async {
    int totalNbGifs = _gifs.length + nbGifsToAdd;
    setState(() => _isAddMoreGifLoading = true);
    return await getSearchedGifs(nbGifs: totalNbGifs).then((gifs) {
      setState(() {
        _gifs.addAll(
          (gifs ?? new List<GifContainer>())
              .getRange(totalNbGifs - nbGifsToAdd, totalNbGifs - 1),
        );
        _isAddMoreGifLoading = false;
      });
    });
  }

  /**
   * Change les paramètres de l'url et relance la requpête http
   */
  Future<List<GifContainer>> getSearchedGifs({int nbGifs}) async {
    bool ok = false;
    int _nbGifs = nbGifs ?? _initialNbGifs;
    if (_searchedText.length >= 2) {
      _params = "api_key=$_apiKey&q=$_searchedText&limit=$_nbGifs";
      _url = _searchUrl + _params;
      ok = true;
    } else if (_searchedText.length == 0) {
      _params = "api_key=$_apiKey&limit=$_nbGifs";
      _url = _trendUrl + _params;
      ok = true;
    }
    if (ok) {
      print(_url);
      return await getGifsFromServer();
    } else
      return null;
  }

  /**
   * Execution de la requête http vers GIPHY
   * 
   * Retourne une nouvelle liste de GIFs
   */
  Future<List<GifContainer>> getGifsFromServer() async {
    var response = await http.get(_url);
    int increment = 0;
    List<GifContainer> gifs = new List<GifContainer>();
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<dynamic> gifsFromJSON = jsonResponse['data'];
      gifsFromJSON.forEach((gif) {
        gifs.add(
          new GifContainer(
            key: GlobalKey(),
            id: increment++,
            originalGif:
                Gif(key: GlobalKey(), url: gif["images"]["original"]["url"]),
            mediumMovingGif:
                Gif(key: GlobalKey(), url: gif["images"]["fixed_width"]["url"]),
            mediumStillGif: Gif(
                key: GlobalKey(),
                url: gif["images"]["fixed_width_still"]["url"]),
            urlToShare: "https://media.giphy.com/media/${gif["id"]}/giphy.gif",
            isStill: _isStill,
          ),
        );
      });
    }
    return gifs;
  }

  /**
   * Méthode de rafraichissement de l'appli
   *  
   * Est appelé lors du swipe vers le bas
   */
  Future<void> _handledRefresh() async {
    return await search();
  }

  Widget searchBarPrefixIcon() {
    return _isSearchRequestLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
            ),
          )
        : Icon(
            Icons.search,
            color: Colors.purple,
          );
  }

  Widget searchBarSuffixIcon() {
    return _tappingText != "" || _searchedText != ""
        ? IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _searchedText = "";
                _tappingText = "";
                _textFieldController.clear();
              });
              search();
            },
          )
        : null;
  }

  Widget raisedButtonIcon() {
    return _isAddMoreGifLoading
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
        : Icon(
            Icons.add_circle_outline,
            size: 40,
            color: Colors.white,
          );
  }

  @override
  void initState() {
    super.initState();
    search();
    //Listener sur la fermeture du clavier pour remettre la recherche actuelle et enlever le focus sur le TextField.
    KeyboardVisibilityNotification().addNewListener(onHide: () {
      if (!_isSearchSubmitted) {
        setState(() {
          _textFieldController.text = _searchedText;
          _tappingText = _searchedText;
          FocusScope.of(context).requestFocus(new FocusNode());
        });
      }
    });

    //Show les tips si c'est la première fois que l'application s'ouvre
    SharedPreferences.getInstance().then((prefs) {
      bool isFirstTime = !prefs.containsKey(prefsProp);
      if (isFirstTime) {
        prefs.setBool(prefsProp, true);
        Navigator.of(context).push(FadeRoute(page: PopupTipsPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background de l'appli.
        // Je l'utilise dans ce Container pour que même l'AppBar laisse passer le background
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: [
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.red,
                Colors.purple,
                Colors.purple,
                Colors.indigo,
                Colors.blue,
                Colors.green,
              ],
              startAngle: 1,
            ),
          ),
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text("GIPHY"),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.help),
                onPressed: () {
                  Navigator.of(context).push(FadeRoute(page: PopupTipsPage()));
                },
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              //TextField de recherche de GIFs.
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _textFieldController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white54,
                        prefixIcon: searchBarPrefixIcon(),
                        suffixIcon: searchBarSuffixIcon()),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _tappingText = value;
                      });
                    },
                    onSubmitted: (_) {
                      setState(() {
                        _searchedText = _tappingText;
                        _isSearchSubmitted = false;
                      });
                      search();
                    },
                  ),
                ),
              ),
              //Liste de GIFs
              Expanded(
                flex: 10,
                //RefreshIndicator permet le Swipe vers le bas pour raffraichir la liste.
                child: RefreshIndicator(
                  onRefresh: () => _handledRefresh(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        //Liste de 2 columns au lieu d'un GridView pour gérer l'espace entre chaque GIF,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              //Column gauche : Les GIF à un emplacement pair de la liste
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: _gifs
                                    .where((gif) => gif.id.isEven)
                                    .toList(),
                              ),
                            ),
                            Expanded(
                              //Column droite : Les GIF à un enmplacement impair de la liste
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    _gifs.where((gif) => gif.id.isOdd).toList(),
                              ),
                            ),
                          ],
                        ),
                        RaisedButton(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: raisedButtonIcon(),
                          ),
                          onPressed: () {
                            addMoreGifs(10);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          //Bouton Play/Pause
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isStill = !_isStill;
              });
              _gifs.forEach((gif) => gif.key.currentState.setIsStill(_isStill));
            },
            child: Icon(_isStill ? Icons.play_arrow : Icons.pause),
          ),
        ),
      ],
    );
  }
}
