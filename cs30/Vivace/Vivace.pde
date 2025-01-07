
MidiPlayer player = new MidiPlayer();

void setup() {
  size(400, 400);

  String piece = "alla_marcia.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);
  String error = player.load(path);
  if (error != null) {
    println("ERROR", error);
  }
}

void keyReleased() {
  if (key == ' ')
    player.togglePause();
}

void draw() {
  background(255);
}
