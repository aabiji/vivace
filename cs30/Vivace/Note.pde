import java.util.Comparator;

// Custom comparator that puts white keys ahead of black keys
// This way, the black keys are drawn on top of the black keys
class NoteComparator implements Comparator<Note> {
  public int compare(Note a, Note b) {
    if (!a.isBlackKey && b.isBlackKey) return -1;
    if (a.isBlackKey && !b.isBlackKey) return 1;
    return 0;
  }
}

class Note {
  int value;
  boolean isBlackKey;
  PVector size;
  int baseHeight;
  PVector position;
  color c;

  Note(int value) {
    int octave = floor(value / 12); // There are 12 notes in an octave
    int n = value % 12; // Get the note in its octave
    // Check if it's C sharp, D sharp, F sharp, G sharp or A sharp
    isBlackKey =  n == 1 || n == 3 || n == 6 || n == 8 || n == 10;

    this.value = value;
    c = isBlackKey ? color(0, 0, 0) : color(255, 255, 255);

    // X offsets for the white and black keys in the octave
    float[] offsets = { 0, 0.75, 1, 1.75, 2, 3, 3.75, 4, 4.75, 5, 5.75, 6 };

    float w = width / 75.0; // Midi defines 128 notes, 75 of those are white keys
    baseHeight = 100;
    int h = isBlackKey ? baseHeight - 45 : baseHeight;
    size = new PVector(isBlackKey ? w / 2 : w, h);

    float octaveX = octave * w * 7; // The width comes from the 7 white keys
    position = new PVector(octaveX + w * offsets[n], 0);
  }

  void draw() {
    fill(c);
    rect(position.x, position.y, size.x, size.y);
  }

  void update() {}
}

class UpcomingNote extends Note {
  float fallSpeed;

  // value is the note value
  // start is the time at which the note starts playing in milliseconds
  // duration is how long the note is pressed down in milliseconds
  UpcomingNote(int value, float start, float duration) {
    super(value);

    // Vertical distance that's travelled every frame
    float pixelsPerSecond = 200;
    fallSpeed = pixelsPerSecond / frameRate;

    // Set the height of the note based on its duration
    float durationInSeconds = duration / 1000;
    size.y = pixelsPerSecond * durationInSeconds;

    // Set the initial y position based on when the note is played
    float startInSeconds = start / 1000;
    int startY = height - baseHeight; // Y position of the keyboard notes
    position.y = startY - startInSeconds * pixelsPerSecond;
    position.y -= size.y;

    getColor();
  }

  private void getColor() {
    float x = map(position.x, 0, width, 0, 255);
    float y = map(position.y, 0, width, 0, 255);
    c = color(128, y, x);
  }

  boolean hidden() {
    return position.y >= height - baseHeight;
  }

  void update() {
    position.y += fallSpeed;
  }
}

class KeyboardNote extends Note {
   KeyboardNote(int value) {
     super(value);
     position.y = height - baseHeight;
   }
}
