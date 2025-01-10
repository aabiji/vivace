
// Slider UI component
class Slider {
  private String name;
  private int x, y, lineWidth;
  private float value, rangeStart, rangeEnd;

  Slider(String id, int xpos, int ypos, int dragWidth, float start, float end) {
    x = xpos;
    y = ypos;
    lineWidth = dragWidth;
    rangeStart = start;
    rangeEnd = end;
    value = 0;
    name = id;
  }

  void updateEnd(float end) {
    rangeEnd = end;
  }

  float getValue() {
    return value;
  }

  void setValue(float value) {
    this.value = value;
  }

  void draw(color sliderColor, color handleColor) {
    int textHeight = 20;
    stroke(sliderColor);
    fill(handleColor);
    textSize(textHeight);
    strokeWeight(4);

    // Draw the labels and the slider line
    String str = String.format("%f", value);
    text(str, x - textWidth(str) * 1.5, y + textHeight / 3);
    text(name, x + lineWidth - textWidth(name), y - textHeight);
    line(x, y, x + lineWidth, y);

    // Draw the slider drag handle
    noStroke();
    float handleX = map(value, rangeStart, rangeEnd, 0, lineWidth);
    ellipse(x + handleX, y, 10, 10);
    strokeWeight(2);
  }

  // Return true if the slider was dragged
  boolean handleDrag() {
    int padding = 30;
    boolean onSlider = mouseY > y - padding / 2 && mouseY < y + padding / 2;
    if (!mousePressed || !onSlider) return false;

    int xpos = max(x, min(mouseX, x + lineWidth)); // Clamp to the slider bounds
    value = map(xpos - x, 0, lineWidth, rangeStart, rangeEnd);
    return true;
  }
}

class Button {
  private PVector size;
  private PVector position;
  private color c;

  Button(int x, int y, int w, int h, color c) {
    size = new PVector(w, h);
    position = new PVector(x, y);
    this.c = c;
  }

  boolean mouseInside() {
    return
      (mouseX >= position.x && mouseX <= position.x + size.x) &&
      (mouseY >= position.y && mouseY <= position.y + size.y);
  }
  
  void draw() {
    color _c = mousePressed && mouseInside() ? color(128, 255, 0) : c;
    fill(_c);
    rect(position.x, position.y, size.x, size.y);
  }
}
