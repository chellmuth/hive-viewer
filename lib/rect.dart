library rect;

import 'dart:math' show Rectangle;

Rectangle centerRect(Rectangle container, Rectangle target) =>
  new Rectangle(
    container.left + container.width / 2 - target.width / 2,
    container.top + container.height / 2 - target.height / 2,
    target.width,
    target.height
  );

Rectangle aspectFill(Rectangle container, Rectangle target) {
  var heightRatio = container.height / target.height;
  var widthRatio = container.width / target.width;
  
  if (heightRatio > widthRatio) {
    return centerRect(container, new Rectangle(0, 0, container.width, target.height * widthRatio));
  } else {
    return centerRect(container, new Rectangle(0, 0, target.width * heightRatio, container.height));  
  }
}