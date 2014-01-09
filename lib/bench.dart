part of view;

class Bench {
  static num height = 260;

  String player1, player2;
  Bench(this.player1, this.player2);

  void draw(CanvasRenderingContext2D context, CanvasElement canvas) {
    context.save();

    context.lineWidth = 2;
    context.strokeStyle = '#4A4A4A';
    context.fillStyle = 'rgba(236, 217, 176, .95)';
    var widthRatio = .5;

    var left = canvas.width * (1 - widthRatio) / 2;
    var top = canvas.height - height;
    var width = canvas.width * widthRatio;
    context.beginPath();
    context.rect(left, top, width, height + 1);
    context.fill();
    context.stroke();

    _drawPlayerInRect(context, Player.WHITE, new Rectangle(left, top, width / 2, height));
    _drawPlayerInRect(context, Player.BLACK, new Rectangle(left + width / 2, top, width / 2, height));

    context.restore();
  }

  void _drawPlayerInRect(CanvasRenderingContext2D context, Player player, Rectangle bounds) {
    context.save();

    var name = player == Player.WHITE ? player1 : player2;

    var fontSize = 45;
    context.font = '${fontSize}px Futura';
    context.fillStyle = '#000';

    var verticalMargin = 10;
    var metrics = context.measureText(name);
    var textWidth = metrics.width;
    context.fillText(name, bounds.left + bounds.width / 2 - textWidth / 2, bounds.top + fontSize + verticalMargin);


    var totalBugWidth = 0;
    var assetRatio = 3/4;
    var bugs = [ Bug.ANT, Bug.GRASSHOPPER, Bug.SPIDER, Bug.BEETLE, Bug.QUEEN ];
    for (var bug in bugs) {
      ImageElement asset = AssetLibrary.imageForPiece(new Piece(player, bug, 0));
      totalBugWidth += asset.naturalWidth * assetRatio;
    }
    var xOrigin = (bounds.width - totalBugWidth) / 2 + bounds.left;
    for (var i = 0; i < 5; i++) {
      ImageElement asset = AssetLibrary.imageForPiece(new Piece(player, bugs[i], 0));
      var width = asset.naturalWidth * assetRatio;
      var height = asset.naturalHeight * assetRatio;
      context.drawImageScaledFromSource(asset, 0, 0, asset.naturalWidth, asset.naturalHeight, xOrigin + width * i, bounds.bottom - height - verticalMargin, width, height);
    }

    context.restore();
  }
}
