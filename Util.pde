
// Convert a list of bytes into a long
// Conversion is in big endian
private long bytesToLong(byte[] data) {
  long value = 0;
  for (int i = 0; i < data.length; i++) {
    value = (value << 8) + (data[i] & 0xff);
  }
  return value;
}

// Format seconds into a string containing minutes and seconds
String formatTime(float seconds) {
  int minutes = seconds > 0 ? floor(seconds / 60) : 0;
  seconds = seconds > 0 ? seconds - minutes * 60 : 0;
  return String.format("%02d:%02d", minutes, (int)seconds);
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
