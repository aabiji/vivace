import java.util.ArrayList;
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
  int startY;
  PVector position;
  color c;
  boolean drawOutline;

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
    startY = height - 100;
    int h = isBlackKey ? 65 : 100;
    size = new PVector(isBlackKey ? w / 2 : w, h);

    float octaveX = octave * w * 7; // The width comes from the 7 white keys
    position = new PVector(octaveX + w * offsets[n], 0);
  }

  void draw() {
    fill(c);
    if (drawOutline) {
      strokeWeight(1);
      stroke(128);
    }
    rect(position.x, position.y, size.x, size.y);
  }
}

class UpcomingNote extends Note {
  // Time when the note is first pressed down, In milliseconds
  private float start;
  // Vertical distance travelled every second
  private final int pixelsPerSecond = 200;

  UpcomingNote(int value, float start, float duration) {
    super(value);
    this.start = start;
    drawOutline = false;

    // Adjust the height based on the duration of the note
    size.y = (duration / 1000.0) * pixelsPerSecond;

    updatePosition(0);
    getColor();
  }

  private void getColor() {
    float x = map(position.x, 0, width, 0, 255);
    float y = map(position.y, 0, width, 0, 255);
    c = color(128, y, x);
  }

  // Set the y position of the note based on how far
  // along we are in playback. The bottom of the note should
  // hit the top edge of the keyboard at the exact moment the
  // note is played in the music. currentTime is the playback
  // position in milliseconds
  void updatePosition(float currentTime) {
    float timeUntilPlayed = (start - currentTime) / 1000.0;
    position.y = startY - timeUntilPlayed * pixelsPerSecond - size.y;
  }
}

class KeyboardNote extends Note {
   KeyboardNote(int value) {
     super(value);
     position.y = startY;
     drawOutline = true;
   }
}
