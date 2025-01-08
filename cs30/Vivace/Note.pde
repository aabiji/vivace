import java.util.Comparator;

class Note {
  int value;
  PVector size;
  PVector position;
  color c;
  boolean isBlackKey;

  Note(int value) {
    int octave = floor(value / 12); // There are 12 notes in an octave
    int n = value % 12; // Get the note in its octave
    // Check if it's C sharp, D sharp, F sharp, G sharp or A sharp
    isBlackKey =  n == 1 || n == 3 || n == 6 || n == 8 || n == 10;

    this.value = value;
    c = isBlackKey ? color(0, 0, 0) : color(255, 255, 255);

    // X offsets for the white and black keys in the octave
    float[] offsets = { 0, 0.75, 1, 1.75, 2, 3, 3.75, 4, 4.75, 5, 5.75, 6 };

    int w = 20;
    int h = isBlackKey ? 65 : 100;
    size = new PVector(isBlackKey ? w / 2 : w, h);

    int octaveX = octave * w * 7; // The width comes from the 7 white keys
    position = new PVector(octaveX + w * offsets[n], 0);
  }

  void draw() {
    fill(c);
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

class KeyboardNote extends Note {
   KeyboardNote(int value) {
     super(value);
     position.y = height - 100;
   }
}
