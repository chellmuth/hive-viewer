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

    _drawPlayerInRect(context, player1, new Rectangle(left, top, width / 2, height));
    _drawPlayerInRect(context, player2, new Rectangle(left + width / 2, top, width / 2, height));

    context.restore();
  }

  void _drawPlayerInRect(CanvasRenderingContext2D context, String player, Rectangle bounds) {
    context.save();

    var fontSize = 45;
    context.font = '${fontSize}px Futura';
    context.fillStyle = '#000';

    var verticalMargin = 10;
    var metrics = context.measureText(player);
    var textWidth = metrics.width;
    context.fillText(player, bounds.left + bounds.width / 2 - textWidth / 2, bounds.top + fontSize + verticalMargin);

    context.restore();
  }
}
