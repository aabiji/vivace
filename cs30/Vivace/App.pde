
class App {
  MidiPlayer player;

  private ArrayList<UpcomingNote> notes;
  private ArrayList<KeyboardNote> keyboard;

  private Slider positionSlider;
  private Button toggleButton;

  App() {
    createKeyboard();
    positionSlider = new Slider("Position", 20, 20, 100, 0, 0);
    toggleButton = new Button(0, 50, 50, 50, color(0, 0, 255));
  }

  private void createKeyboard() {
    // Define all 128 midi keys
    keyboard = new ArrayList<KeyboardNote>();
    for (int i = 0; i < 128; i++) {
        keyboard.add(new KeyboardNote(i));
    }
    keyboard.sort(new NoteComparator());
  }

  // Load the midi file, return null on error
  String init(String path) {
    player = new MidiPlayer();
    String error = player.load(path);
    if (error != null) return error;
    notes = player.getNotes();
    positionSlider.updateEnd(player.getDuration());
    return null;
  }

  private void drawNotes() {
    for (int i = notes.size() - 1; i >= 0; i--) {
      UpcomingNote note = notes.get(i);
      if (!player.isPaused())
        note.updatePosition(player.getPosition() * 1000.0);
      note.draw();
    }
  
    for (KeyboardNote key : keyboard) {
      key.draw();
    }
  }

  private void drawControls() {
    noStroke();
    fill(50);
    rect(0, 0, width, 100);
    toggleButton.draw();

    positionSlider.setValue(player.getPosition());
    positionSlider.draw(color(255, 0, 0), color(0, 255, 0));
    if (positionSlider.handleDrag())
      player.setPosition(positionSlider.getValue());
  }
  
  void draw() {
    background(20);
    drawNotes();
    drawControls();
  }

  void handleClick() {
    if (toggleButton.mouseInside())
      player.togglePause();
  }
}
