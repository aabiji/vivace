
App app;

void setup() {
  size(1000, 700);

  String piece = "winter_wind.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);
  app = new App();
  app.init(path); // TODO: handle possible error
}

void mouseClicked() {
  app.handleClick();
}

void draw() {
  app.draw();
}
