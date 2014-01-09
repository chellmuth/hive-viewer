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
    context.rect(left, top, width, height + 1);
    context.fill();
    context.stroke();

    var fontSize = 45;
    context.font = '${fontSize}px Futura';
    context.fillStyle = '#000';

    var verticalMargin = 10;
    {
      var metrics = context.measureText(player1);
      var textWidth = metrics.width;
      context.fillText(player1, left + width / 4 - textWidth / 2, top + fontSize + verticalMargin);
    }
    {
      var metrics = context.measureText(player2);
      var textWidth = metrics.width;
      context.fillText(player2, left + width * 3 / 4 - textWidth / 2, top + fontSize + verticalMargin);
    }
  }
}
