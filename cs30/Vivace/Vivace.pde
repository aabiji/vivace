
MidiPlayer player;
ArrayList<UpcomingNote> notes;
ArrayList<KeyboardNote> keyboard;

ArrayList<KeyboardNote> createKeyboard() {
  // Midi defines 128 keys
  ArrayList<KeyboardNote> keys = new ArrayList<KeyboardNote>();
  for (int i = 0; i < 128; i++) {
      keys.add(new KeyboardNote(i));
  }
  keys.sort(new NoteComparator());
  return keys;
}

void setup() {
  size(1000, 600);

  String piece = "winter_wind.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);

  player = new MidiPlayer();
  String error = player.load(path);
  if (error != null) {
    println("ERROR", error);
  }

  notes = player.getNotes();
  keyboard = createKeyboard();
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void drawNotes() {
  // Draw the first ten for now
  for (int i = notes.size() - 1; i >= 0; i--) {
    UpcomingNote note = notes.get(i);
    if (!player.isPaused()) {
      note.updatePosition(player.getPosition() * 1000.0);
      if (note.hidden()) {
        notes.remove(i);
        continue;
      }
    }
    note.draw();
  }

  for (KeyboardNote key : keyboard) {
    key.draw();
  }
}

void draw() {
  background(20);
  drawNotes();
}
