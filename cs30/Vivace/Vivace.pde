/*
Experimenting with midi files

Ressources:
https://docs.oracle.com/javase/tutorial/sound/overview-MIDI.html
https://examples.javacodegeeks.com/java-development/desktop-java/sound/play-midi-audio/
https://en.wikipedia.org/wiki/General_MIDI
https://docs.oracle.com/en/java/javase/11/docs/api/java.desktop/javax/sound/midi/package-summary.html
https://docs.oracle.com/javase/tutorial/sound/MIDI-seq-adv.html

Java MIDI implementation structure:
- Sequencer:   A device that responsible for playing back sequences of midi events.
             It sends the midi events to the synthesizer.
- Synthesizer: A device responsible for generating sound. It'll parse the event
             and dispatch the corresponding command (ex: noteOn, noteOff) to one of the
             16 MidiChannel objects it controls.
- MidiChannel: Responsible for creating the sound. It takes the note values from the Synthesizer
             and instructions for how to generate audio signals for each note from an Instrument.
- Instrument:  Emulates a real world instrument. Either comes built into the synthesizer, or is loaded
             from a soundbank file.
- Soundbank:   A collection of different instruments.
- Transmitter: Sends midi events
- Receiver:    Receives midi events
- Sequence:    Holds a bunch of different tracks
- Track:       Holds a bunch of different midi events
- MidiEvent:   An instruction that tells the synthesizer device what to do
All the other classes should be pretty straight forwards.

The default java synthesizer already ships with a bunch of different instruments.
TODO: check if it's the same for windows
*/
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.BufferedInputStream;

import javax.sound.midi.*;

void playMidi(String path) {
  try {
      // Use the default sequencer
      Sequencer sequencer = MidiSystem.getSequencer();
      sequencer.open();

      // Read the midi flie
      InputStream stream = new BufferedInputStream(new FileInputStream(new File(path)));
      Sequence sequence = MidiSystem.getSequence(stream);

      // Sequence division type is PPQ. TODO: use getDivisionType() just to be sure
      int ticksPerQuarterNote = sequence.getResolution();

      float duration = sequence.getMicrosecondLength() / 1000000 / 60; // Get in minutes
      println(duration);

      // Make the synthesizer use an instrument from our default soundbank:
      // Edit all the ProgramChange events in the midi file. Instead of changing
      // to whatever instrument the midi file defines, we change to our own choice of instrument
      int instrumentIndex = 40;
      for (Track track : sequence.getTracks()) {
          for (int i = 0; i < track.size(); i++) {
              MidiMessage message = track.get(i).getMessage();

              // The PROGRAM_CHANGE event changes the isntrument used
              // So we'll force the instrument to be our own instrument
              if (message instanceof ShortMessage) {
                ShortMessage sm = (ShortMessage) message;
                if (sm.getCommand() != ShortMessage.PROGRAM_CHANGE) continue;
                sm.setMessage(ShortMessage.PROGRAM_CHANGE, sm.getChannel(), instrumentIndex, 0);
              }

              // TODO: what to do with the fact that we have multiple tempos???????
              // Extract all the tempo meta messages to get the tempo of the piece
              if (message instanceof MetaMessage) {
                MetaMessage mm = (MetaMessage) message;
                if (mm.getType() != 81) continue;
                byte[] data = mm.getData();
                // The microseconds per quarter note
                int quarterNote = ((data[0] & 0xFF) << 16) | ((data[1] & 0xFF) << 8) | (data[2] & 0xFF);
                // There are 60,000,000 microseconds per second, so to get the number
                // of beats per minute (aka tempo) we need to divide 60,000,000 by the
                // amount of microseconds each quarter note takes up
                int tempo = Math.round(60000000f / quarterNote);
                println("Tempo", tempo);
              }
          }
      }

      sequencer.setSequence(sequence);

      //sequencer.setTempoInBPM(65);

      sequencer.start();

      // while (sequencer.isRunning()) {}
      // sequencer.close();
  } catch (IOException | InvalidMidiDataException | MidiUnavailableException e) {
      println(e.getMessage());
  }
}

void setup() {
  size(400, 400);

  String piece = "alla_marcia.mid";
  String path = String.format("%s/music/%s", sketchPath(), piece);
  playMidi(path);
}

void draw() {
  background(255);
}
