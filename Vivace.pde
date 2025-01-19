/*
Ressources:
https://docs.oracle.com/en/java/javase/11/docs/api/java.desktop/javax/sound/midi/package-summary.html
https://reintech.io/blog/java-midi-programming-creating-manipulating-midi-data
https://docs.oracle.com/javase/tutorial/sound/SPI-providing-MIDI.html
https://www.geeksforgeeks.org/java-midi/
https://en.wikipedia.org/wiki/General_MIDI
https://www.javatpoint.com/filedialog-java
*/

// TODO: create a readme and finish documentation

/*
User feedback:
The purpose of the program was confusing, the main menu should make it more obvious.
“Wasn’t sure if it was a game or teaching you the song”


The main menu and  the ui elements should look nicer

The user should be able to choose different colors for the notes

The user should be able to control the tempo
*/

App app;

void setup() {
  size(1000, 650);
  app = new App();
}

void mouseReleased() {
  app.handleClick();
}

void exit() {
  app.saveState();
  super.exit();
}

void draw() {
  app.draw();
}
