
class Note {
  int value;
  PVector size;
  PVector position;
  color c;

  Note(int value) {
    this.value = value;
    c = isBlackKey() ? color(0, 0, 0) : color(255, 255, 255);

    float step = width / 128.0; // MIDI defines 128 different notes
    position = new PVector(value * step, 0);
    size = new PVector(step, step * 8);
  }

  // Determine whether it's a white key (ex: C) or a black key (ex: C sharp)
  protected boolean isBlackKey() {
    // Get the note in its octave (an octave contains 12 notes)
    int n = value % 12;
    // Check if it's C sharp, D sharp, F sharp, G sharp or A sharp
    return n == 1 || n == 3 || n == 6 || n == 8 || n == 10;
  }

  void draw() {
    fill(c);
    // TODO: how to draw the black keys properly
    rect(position.x, position.y, size.x, size.y);
  }

  void update() {}
}

class UpcomingNote extends Note {
  long startTimestamp;
  float duration;
  int fallSpeed;

  UpcomingNote(int value, long start, float duration) {
    super(value);

    fallSpeed = 0;
    startTimestamp = start;
    this.duration = duration;
    getColor();
  }

  private void getColor() {
    float r = map(position.x, 0, width, 0, 255);
    float b = map(position.y, 0, width, 0, 255);
    c = color(r, 128, b);
  }

  void update() {
    position.y -= fallSpeed; // TODO: consider delta time
  }
}
