
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
    boolean yOnSlider = mouseY > y - padding / 2 && mouseY < y + padding / 2;
    boolean xOnSlider = mouseX >= x && mouseX <= x + lineWidth;
    if (!mousePressed || !xOnSlider || !yOnSlider) return false;

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

class Dropdown {
  private PVector position;
  private PVector menuSize; // TODO: find the largest possible size then just center the text inside the rect
  private String[] options;
  private boolean menuOpened;

  Dropdown(int x, int y, String[] options) {
    this.options = options;
    position = new PVector(x, y);
    menuSize = new PVector(50, 30);
    menuOpened = false;
  }

  void draw() {
    stroke(0);
    textSize(15);

    // Draw the options
    int length = menuOpened ? options.length : 1;
    for (int i = 0; i < length; i++) {
      fill(255);
      rect(position.x, position.y + menuSize.y * i, menuSize.x, menuSize.y);
      fill(0);
      text(options[i], position.x, position.y + menuSize.y * (i + 1));
    }
  }

  // Return the index of the option that was clicked, return -1 if not clicking the dropdown
  int hoveredOption() {
    float h = menuOpened ? options.length * menuSize.y : menuSize.y;
    float y = floor((mouseY - position.y) / menuSize.y);
    boolean inside =
      (mouseX >= position.x && mouseX <= position.x + menuSize.x) &&
      (mouseY >= position.y && mouseY <= position.y + h);
    return inside ? (int)y : -1;
  }

  void handleClick() {
    int index = hoveredOption();
    if (index == -1) return;

    menuOpened = !menuOpened;
    // Swap the currently selection option that's set at index 0
    if (index > 0) {
      String previous = options[0];
      options[0] = options[index];
      options[index] = previous;
    }
  }
}
