
class App {
  MidiPlayer player;

  private ArrayList<UpcomingNote> notes;
  private ArrayList<KeyboardNote> keyboard;

  private Slider positionSlider;
  private Button toggleButton;
  private Dropdown instrumentDropdown;

  App() {
    createKeyboard();
    // TODO: don't hardcode positions
    PShape[] icons = { loadShape("play.svg"), loadShape("pause.svg") };
    toggleButton = new Button(icons, 25, 15, 20, 20);
    positionSlider = new Slider(55, 15, 785, 0, 0);
    instrumentDropdown = new Dropdown(850, 10, 130, 25, Instrument.Names);
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

  private void createKeyboard() {
    // Define all 128 midi keys
    keyboard = new ArrayList<KeyboardNote>();
    for (int i = 0; i < 128; i++) {
        keyboard.add(new KeyboardNote(i));
    }
    keyboard.sort(new NoteComparator());
  }

  private void drawNotes() {
    // Draw lines separating the octaves
    stroke(color(25, 25, 25));
    float octaveWidth = keyboard.get(0).size.x * 7;
    float x = 0;
    while (x < width) {
      line(x, 0, x, height);
      x += octaveWidth;
    }

    // Draw all the notes
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

  private void updateControls() {
    noStroke();
    fill(color(31, 31, 31));
    rect(0, 0, width, 45);

    toggleButton.draw();
    instrumentDropdown.draw();

    positionSlider.setValue(player.getPosition());
    positionSlider.setLabel(player.getPositionStr());
    positionSlider.draw();
    if (positionSlider.handleDrag())
      player.setPosition(positionSlider.getValue());
  }

  void draw() {
    background(color(15, 15, 15));
    drawNotes();
    updateControls();
  }

  void handleClick() {
    if (instrumentDropdown.handleClick()) {
      Instrument i = Instrument.valueOf(instrumentDropdown.enumOption());
      player.setInstrument(i);
    }

    if (toggleButton.handleClick())
      player.togglePause();
  }
}
