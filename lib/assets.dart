library assets;

import 'dart:async';
import 'dart:html';

import 'gamemodel.dart';

class AssetLibrary {
  static Map assets = {};
  Future _downloadsComplete;

  Future downloadAssets() {
    var assetNames = [ 'ant', 'beetle', 'grasshopper', 'queen', 'spider' ];
    var futures = [];
    for (var assetName in assetNames) {
      var image = new ImageElement(src: 'images/${assetName}.png');
      futures.add(image.onLoad.first);
      AssetLibrary.assets[assetName] = image;
    }
    return Future.wait(futures);
  }
  
  static ImageElement imageForBug(Bug bug) {
    switch (bug) {
      case Bug.SPIDER: return assets['spider'];
      case Bug.ANT: return assets['ant'];
      case Bug.BEETLE: return assets['beetle'];
      case Bug.GRASSHOPPER: return assets['grasshopper'];
      case Bug.QUEEN: return assets['queen'];
    }
    throw new Exception("Unknown bug: " + bug.toString());
  }
}