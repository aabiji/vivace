
MidiPlayer player;
ArrayList<UpcomingNote> notes;
ArrayList<KeyboardNote> piano;

void setup() {
  size(1000, 600);

  String piece = "fantaisie_impromptu.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);

  player = new MidiPlayer();
  String error = player.load(path);
  if (error != null) {
    println("ERROR", error);
  }
  notes = player.getNotes();

  // Create the piano keyboard, adding all the white keys first,
  // then the black keys. This way, the black keys are drawn on top of the white keys
  piano = new ArrayList<KeyboardNote>();
  ArrayList<KeyboardNote> blackKeys = new ArrayList<KeyboardNote>();
  for (int i = 0; i < 128; i++) {
    KeyboardNote n = new KeyboardNote(i);
    if (n.isBlackKey)
      blackKeys.add(n);
    else
      piano.add(n);
  }
  piano.addAll(blackKeys);
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void draw() {
  background(20);

  for (KeyboardNote note : piano) {
    note.draw();
  }

  // Draw the first ten for now
  for (int i = 0; i < 10; i++) {
    notes.get(i).draw();
  }
}
