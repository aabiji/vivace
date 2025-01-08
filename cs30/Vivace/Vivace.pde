
MidiPlayer player;
ArrayList<UpcomingNote> notes;
ArrayList<Note> piano;

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

  piano = new ArrayList<Note>();
  for (int i = 0; i < 128; i++) {
    piano.add(new Note(i));
  }
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void draw() {
  background(20);

  for (Note note : piano) {
    note.draw();
  }

  UpcomingNote upcoming = notes.get(0);
  upcoming.draw();
}
