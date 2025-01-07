import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.BufferedInputStream;

import javax.sound.midi.*;

enum Instrument {
  GrandPiano(0), ElectricPiano(4), Guitar(25), Xylophone(13), Violin(40);

  // Instrument indexes are taken from the
  // General Midi standard: https://en.wikipedia.org/wiki/General_MIDI
  int index;
  Instrument(int index) {
    this.index = index;
  }
}

class MidiPlayer {
  private Sequencer sequencer;

  // Load the midi file. Return a string containing the error
  // message on error, and null otherwise
  String load(String path) {
    try {
      sequencer = MidiSystem.getSequencer();
      sequencer.open();

      InputStream stream = new BufferedInputStream(new FileInputStream(new File(path)));
      Sequence sequence = MidiSystem.getSequence(stream);
      sequencer.setSequence(sequence);

      Synthesizer synthesizer = MidiSystem.getSynthesizer();
      channels = synthesizer.getChannels();

    } catch (Exception exception) {
      return exception.getMessage();
    }
    return null;
  }

  boolean isPaused() {
    return sequencer.isRunning();
  }

  void togglePause() {
    if (sequencer.isRunning()) {
      sequencer.stop();
    } else {
      float tempo = sequencer.getTempoInBPM();
      sequencer.start();
      sequencer.setTempoInBPM(tempo);
    }
  }

  float getTempo() {
    return sequencer.getTempoInBPM();
  }

  void setTempo(float tempo) {
    sequencer.setTempoInBPM(tempo);
  }

  float getPosition() {
    float microseconds = sequencer.getMicrosecondPosition();
    return microseconds / 1000000; // In seconds
  }

  void setPosition(float positionInSeconds) {
    long microseconds = (long)(positionInSeconds * 1000000);
    sequencer.setMicrosecondPosition(microseconds);
  }

  float getDuration() {
    return sequencer.getMicrosecondLength() / 1000000; // In seconds
  }
}
