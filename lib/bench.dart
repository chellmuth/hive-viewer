part of view;

class Bench {
  static num height = 260;

  List<Bug> expansionBugs;
  String player1, player2;
  Bench(this.expansionBugs, this.player1, this.player2);

  List<Bug> get bugs {
    var baseBugs = [ Bug.ANT, Bug.GRASSHOPPER, Bug.SPIDER, Bug.BEETLE, Bug.QUEEN ];
    baseBugs.addAll(this.expansionBugs);
    return baseBugs;
  }

  void draw(CanvasRenderingContext2D context, CanvasElement canvas, GameState gamestate) {
    context.save();

    context.lineWidth = 2;
    context.strokeStyle = '#4A4A4A';
    context.fillStyle = 'rgba(236, 217, 176, .95)';
    var widthRatio = .5;

    var extraWidth = expansionBugs.length * 260;

    var left = canvas.width * (1 - widthRatio) / 2 - extraWidth / 2;
    var top = canvas.height - height;
    var width = canvas.width * widthRatio + extraWidth;
    context.beginPath();
    context.rect(left, top, width, height + 1);
    context.fill();
    context.stroke();

    _drawPlayerInRect(context, gamestate, new Rectangle(left, top, width / 2, height), Player.WHITE);
    _drawPlayerInRect(context, gamestate, new Rectangle(left + width / 2, top, width / 2, height), Player.BLACK);

    context.restore();
  }

  void _drawPlayerInRect(CanvasRenderingContext2D context, GameState gamestate, Rectangle bounds, Player player) {
    context.save();

    var name = player == Player.WHITE ? player1 : player2;

    var fontSize = 45;
    context.font = '${fontSize}px Futura';
    context.fillStyle = '#000';

    var verticalMargin = 10;
    var metrics = context.measureText(name);
    var textWidth = metrics.width;
    context.fillText(name, bounds.left + bounds.width / 2 - textWidth / 2, bounds.top + fontSize + verticalMargin);

    Map<Bug, int> benchPieces = gamestate.benchPieces(player);

    var totalBugWidth = 0;
    var assetRatio = 3/4;
    for (var bug in bugs) {
      ImageElement asset = AssetLibrary.imageForPiece(new Piece(player, bug, 0));
      totalBugWidth += asset.naturalWidth * assetRatio;
    }
    var xOrigin = (bounds.width - totalBugWidth) / 2 + bounds.left;
    for (var i = 0; i < bugs.length; i++) {
      var count = benchPieces[bugs[i]];
      if (count == 0) { continue; }
      ImageElement asset = AssetLibrary.imageForPiece(new Piece(player, bugs[i], 0));
      var width = asset.naturalWidth * assetRatio;
      var height = asset.naturalHeight * assetRatio;
      context.drawImageScaledFromSource(asset, 0, 0, asset.naturalWidth, asset.naturalHeight, xOrigin + width * i, bounds.bottom - height - verticalMargin, width, height);

      var diameter = 30;
      var bugCountRect = new Rectangle(xOrigin + width * (i + .7), bounds.bottom - (height * .97) - verticalMargin, diameter, diameter);
      _drawBugCount(context, bugCountRect, player, count);
    }

    context.restore();
  }

  void _drawBugCount(CanvasRenderingContext2D context, Rectangle bounds, Player player, int count) {
    context.save();
    context.fillStyle = player == Player.WHITE ? Color.BlackTile : Color.WhiteTile;

    context.beginPath();
    context.arc(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2, bounds.width / 2, 0, PI * 2, true);
    context.closePath();
    context.fill();

    var fontSize = 14;
    context.font = '${fontSize}pt Futura';
    context.fillStyle = player == Player.WHITE ? Color.WhiteTile : Color.BlackTile;
    var metrics = context.measureText(count.toString());
    context.fillText(count.toString(), bounds.left + bounds.width / 2 - metrics.width / 2, bounds.top + bounds.height / 2 + fontSize / 2);
    context.restore();
  }
}
