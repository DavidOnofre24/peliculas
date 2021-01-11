import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = 'bc3cff2412c196fec9db761aa20d0a08';
  String _url = 'api.themoviedb.org';
  String _lenguaje = 'es-ES';

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodeData = jsonDecode(resp.body);
    final peliculas = Peliculas.fromJsonList(decodeData['results']);

    return peliculas.items;
  }

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();
  final _popularesStreamController = new StreamController<
      List<
          Pelicula>>.broadcast(); // Stream sirve para manejar flujo de datos, broadcast sirve como si fuera un atributo publico

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      // sirve para organizar el url para recibir las peliculas

      'api_key': _apikey,
      'language': _lenguaje,
    });

    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      // sirve para organizar el url para recibir las peliculas

      'api_key': _apikey,
      'language': _lenguaje,
      'page': _popularesPage.toString()
    });
    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);
    popularesSink(_populares);

    _cargando = false;

    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key': _apikey,
      'language': _lenguaje,
    });

    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodeData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {
    final url = Uri.https(_url, '3/search/movie', {
      // sirve para organizar el url para recibir las peliculas

      'api_key': _apikey,
      'language': _lenguaje,
      'query': query
    });

    return await _procesarRespuesta(url);
  }
}
