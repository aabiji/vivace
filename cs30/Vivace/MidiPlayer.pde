import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.BufferedInputStream;

import javax.sound.midi.*;

import java.util.ArrayList;
import java.util.HashMap;

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
  private ArrayList<UpcomingNote> notes;
  private ArrayList<ShortMessage> instrumentChanges;

  MidiPlayer() {
    instrumentChanges = new ArrayList<ShortMessage>();
    notes = new ArrayList<UpcomingNote>();
  }

  private void scanSequence(Sequence sequence) {
    // Map the key (ex: middle C) to its timestamp (in midi ticks)
    HashMap<Integer, Long> noteEvents = new HashMap<Integer, Long>();

    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        long timestamp = event.getTick();

        MidiMessage message = event.getMessage();
        if (!(message instanceof ShortMessage)) continue;
        ShortMessage sm = (ShortMessage) message;

        // The PROGRAM_CHANGE event changes the isntrument used
        // We'll store references to those events so that we can
        // edit them when changing instruments
        if (sm.getCommand() == ShortMessage.PROGRAM_CHANGE) {
          instrumentChanges.add(sm); 
        }

        // Get the notes that will be played
        int key = sm.getData1();
        int velocity = sm.getData2();
        boolean on = sm.getCommand() == ShortMessage.NOTE_ON;

        if (on) {
          // Store when the note is turned on
          noteEvents.put(key, timestamp);
        } else if ((on && velocity == 0) || sm.getCommand() == ShortMessage.NOTE_OFF) {
          // Add a new upcoming note when the note is turned off
          long whenTurnedOn = noteEvents.get(key);
          long duration = timestamp - whenTurnedOn;
          UpcomingNote note = new UpcomingNote(key, whenTurnedOn, duration);
          notes.add(note);
          noteEvents.remove(key);
        }
      }
    }
  }

  // Load the midi file. Return a string containing the error
  // message on error, and null otherwise
  String load(String path) {
    try {
      sequencer = MidiSystem.getSequencer();
      sequencer.open();

      InputStream stream = new BufferedInputStream(new FileInputStream(new File(path)));
      Sequence sequence = MidiSystem.getSequence(stream);

      int ticksPerQuarterNote = sequence.getResolution();
      println("Ticks per quarter note", ticksPerQuarterNote);

      sequencer.setSequence(sequence);
      scanSequence(sequence);
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
  
  ArrayList<UpcomingNote> getNotes() {
    return notes; 
  }
}
