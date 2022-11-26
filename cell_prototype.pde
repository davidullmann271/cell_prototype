Cell cell;

void setup() {
  size(1200,800, P2D);
  cell = new Cell();
}

void draw() {
  colorMode(HSB,360,100,100,1);
  background(220,80,80);
  cell.run();
}
