import processing.net.*;
//server
int n = 5;
class Player {
  int id;
  float cx, cy, angle, step, cBx, cBy, cBt;
  boolean [] shots = new boolean[n];
  float [] sx = new float[n];
  float [] sy = new float[n];
  float [] sAngle = new float[n];
  boolean heal;
  boolean cB;
  int hp, sn, time, cBtime;

  Player(int id, int n) {
    this.id = id;
    this.cx = random(width);
    this.cy = random(height);
    this.angle = random(TWO_PI);
    this.hp = 5;
    for (int i = 0; i<n; i++) {
      this.shots[i] = false;
    }
    this.heal = false;
    this.cB = false;
    this.sn = n;
    this.step = 1.0;
    this.time = 0;
    this.cBt = 0;
  }

  void forward() {
    float x = step * cos(this.angle) + this.cx;
    float y = step * sin(this.angle) + this.cy;
    this.cx = x;
    if (this.cx > width) {
      this.cx -= width;
    }
    if (this.cx < 0) {
      this.cx += width;
    }
    this.cy = y;
    if (this.cy > height) {
      this.cy -= height;
    }
    if (this.cy < 0) {
      this.cy += height;
    }
  }
  void shot(int i) {
    this.shots[i] = true;
    sx[i] = 20*cos(this.angle)+this.cx;
    sy[i] = 20*sin(this.angle)+this.cy;
    sAngle[i] = this.angle;
  }
  void sStepAndHit(float step) {
    for (int i = 0; i<n; i++) {
      if (this.shots[i]) {
        float x = step * cos(sAngle[i]);
        float y = step * sin(sAngle[i]);
        sx[i] += x;
        sy[i] += y;
        if (sx[i] > width || sx[i] < 0) {
          this.shots[i] = false;
        }
        if (sy[i] > height || sy[i] < 0) {
          this.shots[i] = false;
        }
        for (Player player : players.values()) {
          if (player.id != this.id) {

            int size = 20;
            float x1 = size * cos(player.angle) + player.cx;
            float y1 = size * sin(player.angle) + player.cy;
            float x2 = size * cos(player.angle + radians(150)) + player.cx;
            float y2 = size * sin(player.angle + radians(150)) + player.cy;
            float x3 = size * cos(player.angle - radians(150)) + player.cx;
            float y3 = size * sin(player.angle - radians(150)) + player.cy;

            //float x1, y1, x2, y2, x3, y3 = init(this.angle, this.cx, this.cy);
            if ((judge(x1, y1, x2, y2, sx[i], sy[i], 15) && min(x1, x2) < sx[i] && max(x1, x2) > sx[i] && min(y1, y2) < sy[i] && max(y1, y2) > sy[i])
              || (judge(x2, y2, x3, y3, sx[i], sy[i], 15)&& min(x3, x2) < sx[i] && max(x3, x2) > sx[i] && min(y3, y2) < sy[i] && max(y3, y2) > sy[i])
              || (judge(x1, y1, x3, y3, sx[i], sy[i], 15)&& min(x1, x3) < sx[i] && max(x1, x3) > sx[i] && min(y1, y3) < sy[i] && max(y1, y3) > sy[i])) {
              this.shots[i] = false;
              player.hp -= 1;
            }
          }
        }
      }
    }
  }
  /*float init(float angle, float cx, float cy) {
   float x1 = size * cos(angle) + cx;
   float y1 = size * sin(angle) + cy;
   float x2 = size * cos(angle + radians(150)) + cx;
   float y2 = size * sin(angle + radians(150)) + cy;
   float x3 = size * cos(angle - radians(150)) + cx;
   float y3 = size * sin(angle - radians(150)) + cy;
   return x1, y1, x2, y2, x3, y3;
   }*/
  void Heal() {
    if (this.heal) {
      this.hp = this.hp+1;
      this.heal = false;
      time = 0;
    }
  }
  void circleBalls() {
    this.cB = true;
    this.cBtime = this.time;
  }
  void cBHit() {
    if (cB) {
      int size = 20;
      float bx1 = size * cos(this.angle) + this.cx;
      float by1 = size * sin(this.angle) + this.cy;
      float bx2 = size * cos(this.angle + radians(150)) + this.cx;
      float by2 = size * sin(this.angle + radians(150)) + this.cy;
      float bx3 = size * cos(this.angle - radians(150)) + this.cx;
      float by3 = size * sin(this.angle - radians(150)) + this.cy;
      this.cBx = (bx1+bx2+bx3)/3+60*cos(this.cBt);
      this.cBy = (by1+by2+by3)/3+60*sin(this.cBt);
      for (Player player : players.values()) {

        float x1 = size * cos(player.angle) + player.cx;
        float y1 = size * sin(player.angle) + player.cy;
        float x2 = size * cos(player.angle + radians(150)) + player.cx;
        float y2 = size * sin(player.angle + radians(150)) + player.cy;
        float x3 = size * cos(player.angle - radians(150)) + player.cx;
        float y3 = size * sin(player.angle - radians(150)) + player.cy;

        if ((judge(x1, y1, x2, y2, this.cBx, this.cBy, 15) && min(x1, x2) < this.cBx && max(x1, x2) > this.cBx && min(y1, y2) < this.cBy && max(y1, y2) > this.cBy)
          || (judge(x2, y2, x3, y3, this.cBx, this.cBy, 15)&& min(x3, x2) < this.cBx && max(x3, x2) > this.cBx && min(y3, y2) < this.cBy && max(y3, y2) > this.cBy)
          || (judge(x1, y1, x3, y3, this.cBx, this.cBy, 15)&& min(x1, x3) < this.cBx && max(x1, x3) > this.cBx && min(y1, y3) < this.cBy && max(y1, y3) > this.cBy)) {
          player.hp -= 1;
        }
      }
      if (this.time/60-this.cBtime/60 > 10) {
        this.cB = false;
        time = 0;
      }
    }
  }
  boolean judge(float ax, float ay, float bx, float by, float mx, float my, float r) {
    float a = (by-ay);
    float b = (ax-bx);
    float c = -a*ax-b*ay;
    float d = abs((a*mx+b*my+c)/mag(a, b));
    if (d <= r/2) {
      return true;
    }
    return false;
  }
  boolean stopConnect() {
    if (this.hp < 1) {
      return true;
    }
    return false;
  }
}



Server server;
int idOffset = 0;
HashMap<Client, Player> players = new HashMap();

void setup() {
  size(800, 800);
  server = new Server(this, 5204);
}

void draw() {
  float step = 1;
  for (Player player : players.values()) {
    player.forward();
    player.sStepAndHit(step*2.0);
    player.Heal();
    player.cBHit();
    player.time += 1;
    player.cBt += 0.1;
    //println(player.time/60);
  }
  for (Client client : players.keySet()) {
    if (players.get(client).stopConnect()) {
      players.remove(client);
      break;
    }
  }
  JSONObject message = playerInfo();
  server.write(message.toString());
  server.write('\0');
}

void clientEvent(Client client) {
  int dAngle = 20;
  String payload = client.readStringUntil('\0');
  if (payload != null) {
    JSONObject message = parseJSONObject(payload.substring(0, payload.length() - 1));
    String direction = message.getString("direction");
    String action = message.getString("action");
    if (direction != null) {
      if (direction.equals("left")) {
        players.get(client).angle += radians(-dAngle);
      } else if (direction.equals("right")) {
        players.get(client).angle += radians(dAngle);
      }
    } else if (action != null) {
      for (int i = 0; i<n; i++) {
        if (action.equals("shot"+i) && !players.get(client).shots[i]) {
          players.get(client).shot(i);
        }
      }
      if (action.equals("speed-up")) {
        players.get(client).step = 2.5;
      } else if (action.equals("speed-reset")) {
        players.get(client).step = 1.0;
      } else if (action.equals("heal")) {
        players.get(client).heal = true;
      } else if (action.equals("cB")) {
        players.get(client).circleBalls();
      }
    }
  }
}




void serverEvent(Server server, Client client) {
  Player player = new Player(idOffset++, n);
  players.put(client, player);
}

void disconnectEvent(Client client) {
  players.remove(client);
}

JSONObject playerInfo() {
  JSONArray playerArray = new JSONArray();
  for (Player player : players.values()) {
    JSONObject item = new JSONObject();
    item.setInt("id", player.id);
    item.setFloat("x", player.cx);
    item.setFloat("y", player.cy);
    item.setFloat("angle", player.angle);
    item.setFloat("cBt", player.cBt);
    item.setInt("hp", player.hp);
    item.setInt("n", player.sn);
    item.setBoolean("heal", player.heal);
    item.setBoolean("cB", player.cB);
    item.setInt("playTime", player.time/60);
    for (int i = 0; i<n; i++) {
      item.setBoolean("shot"+i, player.shots[i]);
      item.setFloat("sx"+i, player.sx[i]);
      item.setFloat("sy"+i, player.sy[i]);
      item.setFloat("sAngle"+i, player.sAngle[i]);
    }
    playerArray.append(item);
  }
  JSONObject message = new JSONObject();
  message.setJSONArray("players", playerArray);
  return message;
}
