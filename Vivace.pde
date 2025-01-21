/*
Vivace
------
Abigail Adegbiji
January 20, 2025

Vivace is an app that visualizes piano songs, showing
the notes falling down the screen as the song plays. There
are no keybindings or anything like that, just load a midi
file, interact with the ui and watch the visualization.

I hope you enjoy this as much as I enjoyed creating it.
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
