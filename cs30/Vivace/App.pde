import java.util.ArrayList;
import java.util.HashMap;

class App {
  MidiPlayer player;
  private ArrayList<UpcomingNote> notes;
  private ArrayList<KeyboardNote> keyboard;

  private Slider positionSlider;
  private Button toggleButton;
  private Dropdown instrumentDropdown;
  private Button backButton;

  private Button loadButton;
  private Button resumeButton;
  private String errorMessage;
  private boolean drawingMenu;

  App() {
    createKeyboard();
    // TODO: don't hardcode positions
    PShape[] icons = { loadShape("back.svg") };
    backButton = new Button(icons, 15, 15, 20, 20);

    PShape[] toggleIcons = { loadShape("play.svg"), loadShape("pause.svg") };
    toggleButton = new Button(toggleIcons, 50, 15, 20, 20);

    positionSlider = new Slider(95, 15, 750, 0, 0);
    instrumentDropdown = new Dropdown(870, 10, 110, 25, Instrument.Names);

    loadButton = new Button("Load song", width / 2, 260, 150, 45);
    resumeButton = new Button("Resume playback", width / 2, 340, 150, 45);

    drawingMenu = true;
  }

  // Load the midi file, return null on error
  void init(String path) {
    String extension = "";
    int i = path.lastIndexOf(".");
    if (i > 0) extension = path.substring(i + 1);
    if (!extension.equals("mid")) {
      errorMessage = "Input file must be a midi file";
      return;
    }

    player = new MidiPlayer();
    errorMessage = player.load(path);
    if (errorMessage != null) return;

    notes = player.getNotes();
    positionSlider.updateEnd(player.getDuration());
    drawingMenu = false;
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

  void drawControlPanel() {
    noStroke();
    fill(color(31, 31, 31));
    rect(0, 0, width, 45);

    backButton.draw();
    toggleButton.draw();
    instrumentDropdown.draw();
    updatePositionSlider();
  }

  void draw() {
    background(color(15, 15, 15));

    if (drawingMenu) {
      fill(255);
      drawText("Vivace", width / 2, height / 4, 35);

      loadButton.draw();
      resumeButton.draw();

      if (errorMessage != null) {
        fill(color(255, 0, 0));
        drawText(errorMessage, width / 2, 400, 20);
      }
      return;
    }

    updateNotes();
    drawControlPanel();
  }

  void handleClick() {
    if (backButton.handleClick()) {
      drawingMenu = true;
      if (!player.isPaused())
        player.togglePause();
    }

    if (loadButton.handleClick()) {
      selectInput("Select a midi file", "fileSelected");
    }

    if (instrumentDropdown.handleClick()) {
      Instrument i = Instrument.valueOf(instrumentDropdown.enumOption());
      player.setInstrument(i);
    }

    if (toggleButton.handleClick())
      player.togglePause();
  }
}
