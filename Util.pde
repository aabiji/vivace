import java.awt.FileDialog;
import java.awt.Frame;

// Allow the user to select a file using the OS's file dialog.
// Technique taken from here:
// https://www.javatpoint.com/filedialog-java
File openFileDialog() {
  Frame frame = new Frame("File Dialog");
  FileDialog dialog = new FileDialog(frame, "Pick a song", FileDialog.LOAD);

  dialog.setFile("*.mid");
  dialog.setDirectory(sketchPath() + "/music");
  dialog.setVisible(true);

  String file = dialog.getFile();
  return file != null ? new File(dialog.getDirectory() + file) : null;
}

// Return true if the file is a valid MIDI file
boolean validMidiFile(File file) {
  if (!file.exists() || file.isDirectory())
    return false;

  String extension = "";
  String path = file.getAbsolutePath();
  int i = path.lastIndexOf(".");
  if (i > 0)
    extension = path.substring(i + 1);
  return extension.equals("mid");
}

// Format seconds into a string containing minutes and seconds
String formatTime(float seconds) {
  int minutes = seconds > 0 ? floor(seconds / 60) : 0;
  seconds = seconds > 0 ? seconds - minutes * 60 : 0;
  return String.format("%02d:%02d", minutes, (int)seconds);
}

void drawText(String str, float x, float y, int size) {
  textSize(size);
  float w = textWidth(str);
  text(str, x - w / 2, y + size / 2);
}

// Convert HSL to RGB where Hue is between 0 and 360,
// Saturation is between 0 and 1 and Brightness is between 0 and 1
// Algorithm for converting HSL to RGB taken from here:
// https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
color hslToRGB(float h, float s, float l) {
  float[] values = { 0.0, 0.0, 0.0 };
  float[] params = { 0.0, 8.0, 4.0 };

  float a = s * min(l, 1 - l);
  for (int i = 0; i < 3; i++) {
    float n = params[i];
    float k = (n + h / 30.0) % 12.0;
    values[i] = l - a * max(min(k - 3.0, 9.0 - k, 1.0), -1.0);
    values[i] *= 255.0;
  }

  return color(values[0], values[1], values[2]);
}

// Convert a list of bytes into a long. Conversion is in big endian.
// Technique taken from here:
// https://stackoverflow.com/questions/1026761/how-to-convert-a-byte-array-to-its-numeric-value-java
private long bytesToLong(byte[] data) {
  long value = 0;
  for (int i = 0; i < data.length; i++) {
    value = (value << 8) + (data[i] & 0xff);
  }
  return value;
}
