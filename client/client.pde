import processing.net.*;
//client
int n;
int playTime;
int x = 2;
int playId = 0;
int buf = 0;
int playIdcount = 0;

class Player {
  int id;
  float cx, cy, angle, cBt;
  boolean [] shots;
  float [] sx;
  float [] sy;
  float [] sAngle;
  int hp;
  boolean heal;
  boolean cB;
  int time;

  Player(int id, float cx, float cy, float angle, boolean [] shots, float [] sx, float [] sy, float [] sAngle, int hp, int time, boolean heal, boolean cB, float cBt) {
    this.id = id;
    this.cx = cx;
    this.cy = cy;
    this.angle = angle;
    this.shots = shots;
    this.sx = sx;
    this.sy = sy;
    this.sAngle = sAngle;
    this.hp = hp;
    this.heal = heal;
    this.cB = cB;
    this.time = time;
    n = sx.length;
    this.cBt = cBt;
  }

  void draw() {
    int size = 20;
    noStroke();
    fill(0);
    float x1 = size * cos(this.angle) + cx;
    float y1 = size * sin(this.angle) + cy;
    float x2 = size * cos(this.angle + radians(150)) + cx;
    float y2 = size * sin(this.angle + radians(150)) + cy;
    float x3 = size * cos(this.angle - radians(150)) + cx;
    float y3 = size * sin(this.angle - radians(150)) + cy;
    triangle(x1, y1, x2, y2, x3, y3);
    text("HP:"+hp, max(x1, x2, x3), max(y1, y2, y3));
    if (playIdcount == 0) {
      if (playId != buf) {
        playId = buf;
      }
      playIdcount++;
    }

    if (this.id == playId) {
      playTime = time;
      text("GAGE:", 50, 50);
      if (5*playTime/x > 50) {
        fill(255, 0, 0);
        rect(50, 50, 100, 10);
      } else {
        rect(50, 50, 5*playTime, 10);
      }
    }
    fill(0);
    for (int i = 0; i<shots.length; i++) {
      if (shots[i]) {
        ellipse(sx[i], sy[i], 15, 15);
      }
    }
    if (cB) {
      float zx = (x1+x2+x3)/3;
      float zy = (y1+y2+y3)/3;
      ellipse(zx+60*cos(this.cBt), zy+60*sin(this.cBt), 15, 15);
    }
  }
}

Client client;
ArrayList<Player> players = new ArrayList();
int count = 0;

void setup() {
  size(800, 800);
  client = new Client(this, "127.0.0.1", 5204);
}

void draw() {
  background(255);

  synchronized(players) {
    for (Player player : players) {
      if (buf < player.id ) {
        buf = player.id;
      }
    }
    for (Player player : players) {
      player.draw();
    }
  }
  println(playId);
}

void keyPressed() {
  if (key == CODED) {
    JSONObject message = null;
    if (keyCode == RIGHT) {
      message = new JSONObject();
      message.setString("direction", "right");
    } else if (keyCode == LEFT) {
      message = new JSONObject();
      message.setString("direction", "left");
    } else if (keyCode == CONTROL) {
      message = new JSONObject();
      message.setString("action", "shot"+count);
      count++;
      if (count%n==0) {
        count = 0;
      }
    } else if (keyCode == SHIFT) {
      message = new JSONObject();
      message.setString("action", "speed-up");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
  if (5*playTime/x > 50) {
    JSONObject message = null;
    if (key == 'a') {
      message = new JSONObject();
      message.setString("action", "heal");
    } else if (key == 's') {
      message = new JSONObject();
      message.setString("action", "cB");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    JSONObject message = null;
    if (keyCode == SHIFT) {
      message = new JSONObject();
      message.setString("action", "speed-reset");
    }
    if (message != null) {
      client.write(message.toString());
      client.write('\0');
    }
  }
}

void clientEvent(Client client) {
  String payload = client.readStringUntil('\0');
  if (payload != null) {
    JSONObject message = parseJSONObject(payload.substring(0, payload.length() - 1));
    JSONArray playerArray = message.getJSONArray("players");
    //println(playerArray);
    synchronized(players) {
      players.clear();
      for (int i = 0; i < playerArray.size(); ++i) {
        JSONObject item = playerArray.getJSONObject(i);
        int id = item.getInt("id");
        float x = item.getFloat("x");
        float y = item.getFloat("y");
        float angle = item.getFloat("angle");
        float cBt = item.getFloat("cBt");
        int hp = item.getInt("hp");
        int nx = item.getInt("n");
        int playTime = item.getInt("playTime");
        boolean heal = item.getBoolean("heal");
        boolean cB = item.getBoolean("cB");
        boolean [] shots = new boolean[nx];
        float [] sx = new float[nx];
        float [] sy = new float[nx];
        float [] sAngle = new float[nx];
        for (int j = 0; j<sx.length; j++) {
          shots[j] = item.getBoolean("shot"+j);
          sx[j] = item.getFloat("sx"+j);
          sy[j] = item.getFloat("sy"+j);
          sAngle[j] = item.getFloat("sAngle"+j);
        }

        Player player = new Player(id, x, y, angle, shots, sx, sy, sAngle, hp, playTime, heal, cB, cBt);
        players.add(player);
      }
    }
  }
}
