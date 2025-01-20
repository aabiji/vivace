// Slider UI component
class Slider {
  private float x, y, lineWidth;
  private float value, rangeStart, rangeEnd;
  private String label;

  Slider(float x, float y, float dragWidth, float start, float end) {
    this.x = x;
    this.y = y;
    lineWidth = dragWidth;
    rangeStart = start;
    rangeEnd = end;
    value = 0;
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

  void setLabel(String label) {
    this.label = label;
  }

  void draw() {
    fill(color(255, 255, 255));
    textSize(15);
    strokeWeight(4);

    // Draw the label and the slider line
    float endX = map(value, 0.0, rangeEnd, 0.0, lineWidth);
    stroke(color(133, 133, 133));
    line(x, y, x + lineWidth, y);
    stroke(color(6, 214, 159));
    line(x, y, x + endX, y);
    drawText(label, x + textWidth(label) / 2, y + 15, 15);

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
    if (!xOnSlider || !yOnSlider) return false;

    float xpos = max(x, min(mouseX, x + lineWidth)); // Clamp to the slider bounds
    value = map(xpos - x, 0, lineWidth, rangeStart, rangeEnd);
    return true;
  }
}

class Button {
  private PVector size;
  private PVector position;
  private String text;
  private PShape[] icons;
  private int iconIndex;
  private boolean hovering;

  Button(PShape[] icons, float x, float y, float w, float h) {
    size = new PVector(w, h);
    position = new PVector(x, y);
    this.icons = icons;
    iconIndex = 0;
    hovering = false;
  }

  Button(String text, float x, float y, float w, float h) {
    size = new PVector(w, h);
    position = new PVector(x - w / 2, y - h / 2);
    this.text = text;
  }

  private boolean mouseInside() {
    return
      (mouseX >= position.x && mouseX <= position.x + size.x) &&
      (mouseY >= position.y && mouseY <= position.y + size.y);
  }

  boolean handleClick() {
    if (!mouseInside()) return false;
    if (icons != null)
      iconIndex = (iconIndex + 1) % icons.length;
    return true;
  }

  void reset() {
    iconIndex = 0; 
  }

  // Make the cursor reflect whether the mouse is hovering the element
  void setCursor() {
    if (mouseInside() && !hovering) {
      cursor(HAND);
      hovering = true;
    } else if (hovering && !mouseInside()) {
      cursor(ARROW);
      hovering = false;
    }
  }

  void draw() {
    setCursor();
    if (text != null) {
      if (mouseInside()) {
        stroke(color(6, 214, 159));
        fill(color(41, 41, 41));
      } else {
        fill(color(31, 31, 31));
        stroke(color(31, 31, 31));
      }
      rect(position.x, position.y, size.x, size.y);
      fill(255);
      drawText(text, position.x + size.x / 2, position.y + size.y / 2, 15);
    } else {
      shape(icons[iconIndex], position.x, position.y, size.x, size.y);
    }
  }
}

class Dropdown {
  private PVector position;
  private PVector size;
  private String[] options;
  private boolean menuOpened;
  private boolean hovering;

  Dropdown(float x, float y, float w, float h, String[] options) {
    this.options = options;
    position = new PVector(x, y);
    size = new PVector(w, h);
    menuOpened = false;
    hovering = false;
  }

  // Return the index of the option that was clicked, return -1 if not clicking the dropdown
  private int hoveredOption() {
    float h = menuOpened ? options.length * size.y : size.y;
    float y = floor((mouseY - position.y) / size.y);
    boolean inside =
      (mouseX >= position.x && mouseX <= position.x + size.x) &&
      (mouseY >= position.y && mouseY <= position.y + h);
    return inside ? (int)y : -1;
  }

  // Swap the option at index with the current option (always at index 0)
  private void swapOption(int index) {
    String previous = options[0];
    options[0] = options[index];
    options[index] = previous;
  }

  // Make the cursor reflect whether the mouse is hovering the element
  private void setCursor() {
    if (hoveredOption() != -1 && !hovering) {
      cursor(HAND);
      hovering = true;
    } else if (hovering && hoveredOption() == -1) {
      cursor(ARROW);
      hovering = false;
    }
  }
  
  void draw() {
    setCursor();
    stroke(color(61, 61, 61));
    textSize(15);
    // Draw the options
    int count = menuOpened ? options.length : 1;
    for (int i = 0; i < count; i++) {
      fill(i == hoveredOption() ? color(51, 51, 51) : color(41, 41, 41));
      float y = position.y + size.y * i;
      rect(position.x, y, size.x, size.y);
      fill(255);
      drawText(options[i], position.x + size.x / 2, y + size.y / 2, 15);
    }
  }

  String currentOption() { return options[0]; }

  void setOption(String option) {
    int index = -1;
    for (int i = 0; i < options.length; i++) {
      if (options[i].equals(option)) {
        index = i;
        break;
      }
    }

    if (index == -1) return; // Option not found
    swapOption(index);
  }

  boolean handleClick() {
    int index = hoveredOption();
    if (index == -1) return false;

    menuOpened = !menuOpened;
    if (index == 0) return false; // Option hasn't changed

    // Swap the currently selection option that's set at index 0
    if (index > 0) swapOption(index);
    return true;
  }
}
