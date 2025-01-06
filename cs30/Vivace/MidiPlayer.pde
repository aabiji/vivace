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
  boolean isPaused;
  Instrument instrument;
  int playbackPosition; // TODO: ???
  String file;
  int tempo; // In beats per minute
  
  private Sequencer sequencer;

  MidiPlayer(String _file) {
    isPaused = true;
    playbackPosition = 0;
    instrument = Instrument.GrandPiano;
    file = _file;
    tempo = 50;
    loadMidiFile();
  }

  private void loadMidiFile() { 
  }

  // Go through the midi events defined in the file to extract info from it
  private void scanMidiFile() {
     
  }

  void togglePlayback() {
    
  }

  void setPosition(int position) { }
}
