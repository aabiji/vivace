/*
Ressources:
https://docs.oracle.com/en/java/javase/11/docs/api/java.desktop/javax/sound/midi/package-summary.html
https://reintech.io/blog/java-midi-programming-creating-manipulating-midi-data
https://docs.oracle.com/javase/tutorial/sound/SPI-providing-MIDI.html
https://www.geeksforgeeks.org/java-midi/
https://en.wikipedia.org/wiki/General_MIDI
https://www.javatpoint.com/filedialog-java
*/

App app;

void setup() {
  size(1000, 650);
  app = new App();
}

void mouseClicked() {
  app.handleClick();
}

void exit() {
  app.saveState();
  super.exit();
}

void draw() {
  app.draw();
}
