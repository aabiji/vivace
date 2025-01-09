import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.BufferedInputStream;

import javax.sound.midi.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Stack;

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
  private float millisecondsPerTick;

  MidiPlayer() {
    instrumentChanges = new ArrayList<ShortMessage>();
    notes = new ArrayList<UpcomingNote>();
    millisecondsPerTick = 0;
  }

  private void scanSequence(Sequence sequence) {
    // Map the key (ex: middle C) to a list of potential
    // timestamps (in midi ticks). The reason why we're using a stack,
    // and not just a long, is that there's always the possibility
    // of having a note that's being already played, being pressed
    // down again. This isn't particularly uncommon in music.
    // Here: https://www.sheetmusicnow.com/products/cant-take-my-eyes-off-of-you-p119764
    // in the 3rd measure is an example. You have a chord being held down as one voice,
    // and a sequence comprised of mostly eight notes being played as another,
    // and one of the notes (G) in that sequence is being played
    // while G is already being played in the chord
    HashMap<Integer, Stack<Long>> noteEvents = new HashMap<Integer, Stack<Long>>();

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

        if (on && velocity > 0) {
          // Keep track of when the note is turned on
          if (noteEvents.get(key) != null) {
            noteEvents.get(key).push(timestamp);
            continue;
          }

          Stack<Long> stack = new Stack<Long>();
          stack.push(timestamp);
          noteEvents.put(key, stack);
        }

        // Add a new upcoming note when the note is turned off        
        if ((on && velocity == 0) || (sm.getCommand() == ShortMessage.NOTE_OFF)) {
          long whenTurnedOn = noteEvents.get(key).pop();
          float duration = (timestamp - whenTurnedOn) * millisecondsPerTick;
          float start = whenTurnedOn * millisecondsPerTick;
          UpcomingNote note = new UpcomingNote(key, start, duration);

          notes.add(note);
          if (noteEvents.get(key).empty())
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
      sequencer.setSequence(sequence);

      float ticksPerQuarterNote = sequence.getResolution();
      millisecondsPerTick = 60000.0 / (getTempo() * ticksPerQuarterNote);

      scanSequence(sequence);
    } catch (Exception exception) {
      return exception.getMessage();
    }
    return null;
  }

  boolean isPaused() {
    return !sequencer.isRunning();
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
