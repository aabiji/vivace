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

  static String[] getNames() {
    String[] names = { "Grand piano", "Electric piano", "Guitar", "Xylophone", "Violin" };
    return names;
  }
}

private class TempoChange {
  long tick; // When it changed
  float millisecondsPerTick; // New milliseconds per tick

  TempoChange(long tick, float millisecondsPerTick) {
    this.tick = tick;
    this.millisecondsPerTick = millisecondsPerTick;
  }
}

private long bytesToLong(byte[] data) {
  long value = 0;
  for (int i = 0; i < data.length; i++) {
    value = (value << 8) + (data[i] & 0xff);
  }
  return value;
}

class MidiPlayer {
  private Sequencer sequencer;

  private ArrayList<UpcomingNote> notes;
  private ArrayList<TempoChange> tempoChanges;
  private ArrayList<ShortMessage> instrumentChanges;

  private float ticksPerQuarterNote;
  // To account for potential lag from
  // the audio processing java's doing in milliseconds
  private final float audioLatency = 0.05;

  MidiPlayer() {
    instrumentChanges = new ArrayList<ShortMessage>();
    tempoChanges = new ArrayList<TempoChange>();
    notes = new ArrayList<UpcomingNote>();
    ticksPerQuarterNote = 0.0;
  }

  // Store changes in tempo and in instrument choice
  private void getChanges(Sequence sequence) {
    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        long timestamp = event.getTick();
        MidiMessage message = event.getMessage();

        // Store tempo change events
        if (message instanceof MetaMessage) {
          MetaMessage mm = (MetaMessage) message;
          if (mm.getType() == 0x51) { // Tempo change message
            long microsecondsPerQuarterNote = bytesToLong(mm.getData());
            float beatsPerMinute = 60000000.0 / (float)microsecondsPerQuarterNote;
            float millisecondsPerTick = 60000.0 / (beatsPerMinute * ticksPerQuarterNote);
            tempoChanges.add(new TempoChange(timestamp, millisecondsPerTick));
          }
        }

        // Store instrument change events
        if (message instanceof ShortMessage) {
          ShortMessage sm = (ShortMessage) message;
          if (sm.getCommand() == ShortMessage.PROGRAM_CHANGE) {
            instrumentChanges.add(sm);
          }
        }
      }
    }
  }

  private void extractNotes(Sequence sequence) {
    // The key is mapped to a stack of MIDI timestamps to handle
    // scenarios where the same note is played again while it's already
    // being held, as seen in musical examples like overlapping voices or chords
    HashMap<Integer, Stack<Long>> noteEvents = new HashMap<Integer, Stack<Long>>();

    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        long timestamp = event.getTick();

        MidiMessage message = event.getMessage();
        if (!(message instanceof ShortMessage)) continue;
        ShortMessage sm = (ShortMessage) message;

        boolean on = sm.getCommand() == ShortMessage.NOTE_ON;
        boolean off = sm.getCommand() == ShortMessage.NOTE_OFF;
        int value = sm.getData1();
        int velocity = sm.getData2();
        if (!on && !off) continue;

        // Keep track of when the note is turned on
        if (on && velocity > 0) {
          if (noteEvents.get(value) != null) {
            noteEvents.get(value).push(timestamp);
            continue;
          }

          Stack<Long> stack = new Stack<Long>();
          stack.push(timestamp);
          noteEvents.put(value, stack);
        }

        // Add a new upcoming note when the note is turned off
        if ((on && velocity == 0) || off) {
          long whenTurnedOn = noteEvents.get(value).pop();
          float start = ticksToMilliseconds(whenTurnedOn) + (audioLatency * 1000);
          float end = ticksToMilliseconds(timestamp) + (audioLatency * 1000);
          UpcomingNote note = new UpcomingNote(value, start, end - start);

          notes.add(note);
          if (noteEvents.get(value).empty())
            noteEvents.remove(value);
        }
      }
    }

    notes.sort(new NoteComparator());
  }

  private float ticksToMilliseconds(long tick) {
    if (tempoChanges.isEmpty()) return 0.0;

    long lastTick = 0;
    float totalMilliseconds = 0;
    float millisecondsPerTick = tempoChanges.get(0).millisecondsPerTick;

    // Accumulate the equivalent milliseconds for all the ticks
    // up to this point in time in the music. Tempo doesn't stay
    // the same throughout the entire song, so each segment between
    // tempo changes needs to be calculated separately at its own tempo.
    for (TempoChange change : tempoChanges) {
      if (change.tick >= tick) break;

      long tickDelta = change.tick - lastTick;
      totalMilliseconds += tickDelta * millisecondsPerTick;

      lastTick = change.tick;
      millisecondsPerTick = change.millisecondsPerTick;
    }

    long remainingTicks = Math.max(0, tick - lastTick);
    totalMilliseconds += remainingTicks * millisecondsPerTick;

    return totalMilliseconds;
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

      ticksPerQuarterNote = sequence.getResolution();
      getChanges(sequence);
      extractNotes(sequence);
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

  // Get the tempo in beats per minute
  float getTempo() {
    return sequencer.getTempoInBPM();
  }

  // Set the tempo in beats per minute
  void setTempo(float tempo) {
    sequencer.setTempoInBPM(tempo);
  }

  // Get the playback position in seconds
  float getPosition() {
    return (sequencer.getMicrosecondPosition() / 1000000.0) - audioLatency;
  }

  // Set the playback position of the music
  void setPosition(float positionInSeconds) {
    sequencer.setMicrosecondPosition((long)(positionInSeconds * 1000000.0));
  }

  // Get the duration of the music in seconds
  float getDuration() {
    return sequencer.getMicrosecondLength() / 1000000.0;
  }

  ArrayList<UpcomingNote> getNotes() {
    return notes;
  }
}
