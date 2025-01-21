import java.util.ArrayList;
import java.util.HashMap;

class App {
  private File file;
  private MidiPlayer player;
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

  private PFont titleFont;
  private PFont uiFont;

  App() {
    PShape[] icons = { loadShape("back.svg") };
    backButton = new Button(icons, 15, 15, 20, 20);

    PShape[] toggleIcons = { loadShape("play.svg"), loadShape("pause.svg") };
    toggleButton = new Button(toggleIcons, 50, 15, 20, 20);

    positionSlider = new Slider(95, 15, 750, 0, 0);
    instrumentDropdown = new Dropdown(870, 10, 110, 25, Instrument.Names);

    loadButton = new Button("Load song", width / 2 - 100, height / 1.75, 150, 45);
    resumeButton = new Button("Resume song", width / 2 + 100, height / 1.75, 150, 45);

    titleFont = createFont("title.ttf", 128);
    uiFont = createFont("ui.ttf", 128);

    drawingMenu = true;
    createKeyboard();
  }

  void loadState() {
    JSONObject json = loadJSONObject("data/state.json");
    if (json == null) {
      errorMessage = "Have no previous state. Must load a new song.";
      return;
    }

    File previous = new File(json.getString("file"));
    float position = json.getFloat("position");
    Instrument instrument = Instrument.valueOf(json.getString("instrument"));
    initialize(previous, instrument, position);
  }

  // Save info about the currently playing song to a json file
  void saveState() {
    if (player == null || player.getInstrument() == null) return;
    JSONObject json = new JSONObject();
    json.setString("instrument", player.getInstrument().name());
    json.setFloat("position", player.getPosition());
    json.setString("file", file.getAbsolutePath());
    saveJSONObject(json, "data/state.json");
  }

  // Load the midi file. To load previous state, set file to null
  void initialize(File input, Instrument instrument, float position) {
    file = input;
    if (!validMidiFile(file)) {
      errorMessage = "Input file must be a midi file";
      return;
    }

    player = new MidiPlayer();
    errorMessage = player.load(file);
    if (errorMessage != null) return;
    if (player.getDuration() == 0) {
      errorMessage = "Empty midi file";
      return;
    }

    notes = player.getNotes();
    player.setPosition(position);
    positionSlider.updateEnd(player.getDuration());
    positionSlider.setValue(position);

    player.setInstrument(instrument);
    instrumentDropdown.setOption(instrument.toString());

    updateNotes(true);
    cursor(ARROW);
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

  private void updateNotes(boolean forceUpdate) {
    // Draw lines separating the octaves
    stroke(color(25, 25, 25));
    float octaveWidth = keyboard.get(0).size.x * 7;
    float x = 0;
    while (x < width) {
      line(x, 0, x, height);
      x += octaveWidth;
    }

    // Map a note to whether it's been pressed or not. The boolean
    // doesn't really matter, since we're just using the hashmap for lookup.
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

  // Update the playback position and the positions of the upcoming notes
  // based on the the value of the position slider
  private void changePosition(boolean updatePlayer) {
    float seconds = positionSlider.getValue();
    if (updatePlayer)
      player.setPosition(seconds);
    for (UpcomingNote note : notes) {
      note.updatePosition(seconds * 1000);
    }
  }

  // Draw the slider that controls the playback position and
  // handle updating the positions of the upcoming notes when it's dragged
  private void updatePositionSlider() {
    String position = formatTime(positionSlider.getValue());
    String duration = formatTime(player.getDuration());
    String label = String.format("%s / %s - %s", position, duration, file.getName());

    if (mousePressed && positionSlider.handleDrag()) {
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

  void drawMainMenu() {
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
      drawText(errorMessage, width / 2, height / 1.5, 20);
    }
  }

  void draw() {
    background(color(15, 15, 15));
    if (drawingMenu) {
      drawMainMenu();
    } else {
      updateNotes(false);
      drawControlPanel();
    }
  }

  // Do various things when the ui elements are clicked
  void handleClick() {
    if (loadButton.handleClick()) {
      File selected = openFileDialog();
      if (selected != null)
        initialize(selected, Instrument.Piano, 0.0);
    }

    if (resumeButton.handleClick())
      loadState();

    // Go back to the main menu
    if (backButton.handleClick()) {
      drawingMenu = true;
      if (!player.isPaused())
        player.togglePause();
      saveState();
      toggleButton.reset();
    }

    if (toggleButton.handleClick())
      player.togglePause();

    // Actually change the position when we've released the mouse
    if (positionSlider.handleDrag())
      changePosition(true);

    if (instrumentDropdown.handleClick()) {
      Instrument i = Instrument.valueOf(instrumentDropdown.currentOption());
      player.setInstrument(i);
    }
  }
}