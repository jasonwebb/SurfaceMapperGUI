// An utility class to calculate framerate more accurately.
class Chronometer {
  int fcount;
  int lastmillis;
  int interval;
  float fps;
  float time;
  boolean updated;

  Chronometer() {
    lastmillis = 0;
    fcount = 0;
    interval = 5;
    updated = false;
  }

  Chronometer(int t) {
    lastmillis = 0;
    fcount = 0;
    interval = t;
    updated = false;
  }

  void update() {
    fcount++;
    int t = millis();
    if (t - lastmillis > interval * 1000) {
      fps = (float) (fcount) / interval;
      time = (float) (t) / 1000;
      fcount = 0;
      lastmillis = t;
      updated = true;
    } else
      updated = false;
  }

  void printFps() {
    if (updated)
      PApplet.println("FPS: " + fps);
  }
}

