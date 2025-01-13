import java.util.ArrayList;
import java.util.HashMap;

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

  private void updateNotes() {
    // Draw lines separating the octaves
    stroke(color(25, 25, 25));
    float octaveWidth = keyboard.get(0).size.x * 7;
    float x = 0;
    while (x < width) {
      line(x, 0, x, height);
      x += octaveWidth;
    }

    HashMap<Integer, Boolean> pressedNotes = new HashMap<Integer, Boolean>();

    // Draw all the notes
    for (int i = notes.size() - 1; i >= 0; i--) {
      UpcomingNote note = notes.get(i);
      if (note.hidden()) continue;
      if (!player.isPaused())
        note.updatePosition(player.getPosition() * 1000.0);
      if (note.hittingKeyboard())
        pressedNotes.put(note.value, true);
      note.draw();
    }

    for (KeyboardNote note : keyboard) {
      boolean highlighted = pressedNotes.get(note.value) != null;
      note.draw(highlighted);
    }
  }

  private void updatePositionSlider() {
    positionSlider.setValue(player.getPosition());
    positionSlider.setLabel(player.getPositionStr());
    positionSlider.draw();

    if (positionSlider.handleDrag()) {
      float seconds = positionSlider.getValue();
      player.setPosition(seconds);
      for (UpcomingNote note : notes) {
        note.updatePosition(seconds * 1000);
      }
    }
  }

  void draw() {
    background(color(15, 15, 15));
    updateNotes();

    // Draw the control panel
    noStroke();
    fill(color(31, 31, 31));
    rect(0, 0, width, 45);

    toggleButton.draw();
    instrumentDropdown.draw();
    updatePositionSlider();
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
