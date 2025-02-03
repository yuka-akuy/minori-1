import processing.video.*;

Capture cam;
PImage realTimeFrame, delay5SecFrame, delay10SecFrame;

// 遅延用のバッファ（5秒、10秒分のフレームを保持）
ArrayList<PImage> delayBuffer5Sec = new ArrayList<PImage>();
ArrayList<PImage> delayBuffer10Sec = new ArrayList<PImage>();

void setup() {
  size(100, 100);  // メインウィンドウは小さく設定
  frameRate(10);   // 1秒あたり10フレーム

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras available");
    exit();
  } else {
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  // リアルタイム、5秒、10秒遅延のウィンドウを生成
  PApplet.runSketch(new String[]{"RealTimeWindow"}, new RealTimeWindow());
  PApplet.runSketch(new String[]{"Delay5SecWindow"}, new Delay5SecWindow());
  PApplet.runSketch(new String[]{"Delay10SecWindow"}, new Delay10SecWindow());
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }

  // リアルタイムのフレームを取得し、サーモグラフィ風エフェクトを適用
  realTimeFrame = applyThermalEffect(cam.get());

  // 5秒遅延（50フレーム）
  if (delayBuffer5Sec.size() >= 50) {
    delay5SecFrame = delayBuffer5Sec.get(0);
    delayBuffer5Sec.remove(0);
  }

  // 10秒遅延（100フレーム）
  if (delayBuffer10Sec.size() >= 100) {
    delay10SecFrame = delayBuffer10Sec.get(0);
    delayBuffer10Sec.remove(0);
  }

  // バッファにサーモグラフィ風エフェクトのフレームを追加
  delayBuffer5Sec.add(realTimeFrame.copy());
  delayBuffer10Sec.add(realTimeFrame.copy());
}

// サーモグラフィ風エフェクトを適用する関数
PImage applyThermalEffect(PImage img) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    float brightnessValue = brightness(img.pixels[i]);
    img.pixels[i] = thermalColorMap(brightnessValue);
  }
  img.updatePixels();
  return img;
}

// 明るさに基づいて色をマップする関数
color thermalColorMap(float sabun) {
  if (sabun > 65.0) {  //65とかの数字を変えていくと色の割合が変わるよここら辺全部
    return color(255, 255, 255);       // 白（非常に高温）
  } else if (sabun > 38.0) {
    return color(255, 0, 0);           // 赤（高温）
  } else if (sabun > 30.0) {
    return color(255, 165, 0);         // オレンジ（中高温）
  } else if (sabun > 25.0) {
    return color(139, 255, 0);         // 黄色（中温）
  } else if (sabun > 18.0) {
    return color(0, 255, 0);           // 緑（低温）
  } else if (sabun > 10.0) {
    return color(0, 0, 255);           // 青（非常に低温）
  } else if (sabun > 5.0) {
    return color(0, 0, 139);           // 濃い青（極端に低温）
  } else {
    return color(0, 0, 0);             // 黒（極端に低温）
  }
}

// リアルタイム映像のウィンドウ
public class RealTimeWindow extends PApplet {
  public void settings() {
    size(640, 480);
  }
 
  public void draw() {
    if (realTimeFrame != null) {
      image(realTimeFrame, 0, 0);
    }
  }
}

// 5秒遅延映像のウィンドウ
public class Delay5SecWindow extends PApplet {
  public void settings() {
    size(640, 480);
  }
 
  public void draw() {
    if (delay5SecFrame != null) {
      image(delay5SecFrame, 0, 0);
    }
  }
}

// 10秒遅延映像のウィンドウ
public class Delay10SecWindow extends PApplet {
  public void settings() {
    size(640, 480);
  }
 
  public void draw() {
    if (delay10SecFrame != null) {
      image(delay10SecFrame, 0, 0);
    }
  }
}
