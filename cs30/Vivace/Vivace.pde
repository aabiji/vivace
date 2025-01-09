
MidiPlayer player;
ArrayList<UpcomingNote> notes;
ArrayList<KeyboardNote> keyboard;

void setup() {
  size(1000, 600);

  String piece = "un_sospiro.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);

  player = new MidiPlayer();
  String error = player.load(path);
  if (error != null) {
    println("ERROR", error);
  }

  notes = player.getNotes();
  notes.sort(new NoteComparator());

  // Create all the 128 notes midi defines
  keyboard = new ArrayList<KeyboardNote>();
  for (int i = 0; i < 128; i++) {
    keyboard.add(new KeyboardNote(i));
  }
  keyboard.sort(new NoteComparator());
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void draw() {
  background(20);

  // Draw the first ten for now
  for (int i = notes.size() - 1; i >= 0; i--) {
    UpcomingNote note = notes.get(i);
    note.draw();

    if (!player.isPaused()) {
      note.update();
      if (note.hidden())
        notes.remove(i);
    }
  }

  for (KeyboardNote key : keyboard) {
    key.draw();
  }
}
