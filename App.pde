import java.awt.FileDialog;
import java.awt.Frame;

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

  private JSONObject state;
  private String file;
  private String filename;

  PFont titleFont;
  PFont uiFont;

  App() {
    createKeyboard();
    // TODO: don't hardcode positions
    PShape[] icons = { loadShape("back.svg") };
    backButton = new Button(icons, 15, 15, 20, 20);

    PShape[] toggleIcons = { loadShape("play.svg"), loadShape("pause.svg") };
    toggleButton = new Button(toggleIcons, 50, 15, 20, 20);

    positionSlider = new Slider(95, 15, 750, 0, 0);
    instrumentDropdown = new Dropdown(870, 10, 110, 25, Instrument.Names);

    loadButton = new Button("Load song", width / 2 - 100, height / 1.75, 150, 45);
    resumeButton = new Button("Resume playback", width / 2 + 100, height / 1.75, 150, 45);

    titleFont = createFont("title.ttf", 128);
    uiFont = createFont("ui.ttf", 128);

    drawingMenu = true;
    state = new JSONObject();
  }

  // Load the midi file. To load previous state, set file to null
  void init(String path) {
    float position = 0;
    Instrument instrument = Instrument.Piano;
    file = path;

    // Load previously stored state
    if (path == null) {
      state = loadJSONObject("data/state.json");
      if (state == null) {
        errorMessage = "Have no previous state. Must load a new song.";
        return;
      }

      file = state.getString("file");
      if (file.length() == 0) {
        errorMessage = "You don't have a save file to load from";
        return;
      }
      
      position = state.getFloat("position");
      instrument = Instrument.valueOf(state.getString("instrument"));
    }

    String extension = "";
    int i = file.lastIndexOf(".");
    if (i > 0) extension = file.substring(i + 1);
    if (!extension.equals("mid")) {
      errorMessage = "Input file must be a midi file";
      return;
    }
    filename = new File(file).getName();

    player = new MidiPlayer();
    errorMessage = player.load(file);
    if (errorMessage != null) return;

    notes = player.getNotes();
    player.setInstrument(instrument);
    player.setPosition(position);
    instrumentDropdown.setOption(instrument.toString());

    positionSlider.updateEnd(player.getDuration());
    positionSlider.setValue(position);

    updateNotes(true);
    drawingMenu = false;
    cursor(ARROW);
  }

  void saveState() {
    if (file == null) return; // Not loaded
    state.setString("instrument", player.getInstrument().name());
    state.setFloat("position", player.getPosition());
    state.setString("file", file);
    saveJSONObject(state, "data/state.json");
  }

  private void createKeyboard() {
    // Define all 128 midi keys
    keyboard = new ArrayList<KeyboardNote>();
    for (int i = 0; i < 128; i++) {
      keyboard.add(new KeyboardNote(i));
    }
    keyboard.sort(new NoteComparator());
  }

  private void updateNotes(boolean forceUpdate) {
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
      if (!player.isPaused() || forceUpdate)
        note.updatePosition(positionSlider.getValue() * 1000.0);
      if (note.hittingKeyboard())
        pressedNotes.put(note.value, true);
      note.draw();
    }

    for (KeyboardNote note : keyboard) {
      boolean highlighted = pressedNotes.get(note.value) != null;
      note.draw(highlighted);
    }
  }

  private void changePosition(boolean updatePlayer) {
    float seconds = positionSlider.getValue();
    if (updatePlayer)
      player.setPosition(seconds);
    for (UpcomingNote note : notes) {
      note.updatePosition(seconds * 1000);
    }
  }

  private void updatePositionSlider() {
    String position = formatTime(positionSlider.getValue());
    String duration = formatTime(player.getDuration());
    String label = String.format("%s / %s - %s", position, duration, filename);

    if (mousePressed) {
      positionSlider.handleDrag();
      changePosition(false);
    } else {
      positionSlider.setValue(player.getPosition());
    }

    positionSlider.setLabel(label);
    positionSlider.draw();
  }

  void drawControlPanel() {
    noStroke();
    fill(color(31, 31, 31));
    rect(0, 0, width, 45);

    boolean done = floor(player.getPosition()) == floor(player.getDuration());
    if (done) toggleButton.reset();
    toggleButton.draw();

    backButton.draw();
    instrumentDropdown.draw();
    updatePositionSlider();
  }

  void draw() {
    background(color(15, 15, 15));

    if (drawingMenu) {
      fill(255);
      textFont(titleFont);
      drawText("Vivace", width / 2, height / 3, 80);
      textFont(uiFont);

      drawText("Visualize piano songs!", width / 2, height / 2.15, 18);
      drawText("(C) Abigail Adegbiji, 2025", width / 2, height - 50, 14);

      loadButton.draw();
      resumeButton.draw();

      if (errorMessage != null) {
        fill(color(255, 0, 0));
        drawText(errorMessage, width / 2, 400, 20);
      }
      return;
    }

    updateNotes(false);
    drawControlPanel();
  }

  // Technique taken from here:
  // https://www.javatpoint.com/filedialog-java
  String openFileDialog() {
    Frame frame = new Frame("File Dialog");
    FileDialog dialog = new FileDialog(frame, "Pick a song", FileDialog.LOAD);

    dialog.setFile("*.mid");
    dialog.setDirectory(sketchPath() + "/music");
    dialog.setVisible(true);

    String file = dialog.getFile();
    return file != null ? dialog.getDirectory() + file : null;
  }

  void handleClick() {
    if (loadButton.handleClick()) {
      String path = openFileDialog();
      if (path != null) init(path);
    }

    if (resumeButton.handleClick())
      init(null);

    if (backButton.handleClick()) {
      drawingMenu = true;
      if (!player.isPaused())
        player.togglePause();
      saveState();
      toggleButton.reset();
    }

    if (toggleButton.handleClick())
      player.togglePause();

    if (positionSlider.handleDrag())
      changePosition(true);

    if (instrumentDropdown.handleClick()) {
      Instrument i = Instrument.valueOf(instrumentDropdown.currentOption());
      player.setInstrument(i);
    }
  }
}
