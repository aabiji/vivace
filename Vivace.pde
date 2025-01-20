/*
User feedback:
The user should be able to control the tempo
*/

// TODO:
// Create github releases:
// Beta version 1 v1.0.0-beta -> b52946a79eae4f9747456919056ae2c94a5df47d
// Beta version 2 v2.0.0-beta -> c937c413e40664e1858961f2c45a0752033ea504
// Final version v1.0.0 ->

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
