library assets;

import 'dart:async';
import 'dart:html';

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
}