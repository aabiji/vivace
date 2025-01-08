

class Note {
  int value;
  PVector size;
  PVector position;

  Note() {
    value = 0;
    size = new PVector(15, 30);
    position = new PVector(0, 0);
  }

  void draw() {
    fill(255);
    rect(position.x, position.y, size.x, size.y);
  }

  void update() {}
}

class UpcomingNote extends Note {
  long startTimestamp;
  float duration;
  int fallSpeed;

  UpcomingNote(int value, long start, float duration) {
    super();
    fallSpeed = 0;
    startTimestamp = start;
    this.value = value;
    this.duration = duration;
  }

  void update() {
    position.y -= fallSpeed; // TODO: consider delta time
  }
}
