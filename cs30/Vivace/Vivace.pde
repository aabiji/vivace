
MidiPlayer player = new MidiPlayer();

void setup() {
  size(400, 400);

  String piece = "fantaisie_impromptu.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);
  String error = player.load(path);
  if (error != null) {
    println("ERROR", error);
  }

  // FIXME: I think this is wrong but I can't prove it yet...
  println("Notes: ");
  ArrayList<UpcomingNote> notes = player.getNotes();
  for (int i = 0; i < 10; i++) {
    UpcomingNote n = notes.get(i);
    println(n.value, n.startTimestamp, n.duration);
  }
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void draw() {
  background(255);
}
