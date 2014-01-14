library assets;

import 'dart:async';
import 'dart:html';

import 'gamemodel.dart';

class AssetLibrary {
  static Map assets = {};
  Future _downloadsComplete;

  Future downloadAssets() {
    var assetNames = [
        'ant-white@2x', 'grasshopper-white@2x', 'queen-white@2x', 'spider-white@2x', 'beetle-white@2x', 'mosquito-white@2x',
        'ant-black@2x', 'grasshopper-black@2x', 'queen-black@2x', 'spider-black@2x', 'beetle-black@2x', 'mosquito-black@2x',
        'move-tile@2x'
    ];
    var futures = [];
    for (var assetName in assetNames) {
      var image = new ImageElement(src: 'images/${assetName}.png');
      futures.add(image.onLoad.first);
      AssetLibrary.assets[assetName] = image;
    }
    return Future.wait(futures);
  }

  static ImageElement imageNamed(String name) {
    return assets["${name}@2x"];
  }

  static ImageElement imageForPiece(Piece piece) {
    var color = piece.player == Player.WHITE ? 'white' : 'black';
    switch (piece.bug) {
      case Bug.SPIDER: return assets['spider-${color}@2x'];
      case Bug.ANT: return assets['ant-${color}@2x'];
      case Bug.BEETLE: return assets['beetle-${color}@2x'];
      case Bug.GRASSHOPPER: return assets['grasshopper-${color}@2x'];
      case Bug.QUEEN: return assets['queen-${color}@2x'];
      case Bug.MOSQUITO: return assets['mosquito-${color}@2x'];
    }
    throw new Exception("Unknown bug: " + piece.bug.toString());
  }
}