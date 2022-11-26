class Cell {
  Flock insides;
  QTree qtree;
  Flow membrane;
  
  float maxspeed = 0.9;
  int R = 200;
  float t = 0.0;
  
  Cell(){
    insides = new Flock();
    for (int i = 0; i < 1000; i++) {
      PVector mid = new PVector(width/2, height/2);
      float dist = random(5,R);
      float angle = random(TWO_PI);
      
      float x = dist*cos(angle)+mid.x;
      float y = dist*sin(angle)+mid.y;
      
      
      Boid b = new Boid(x,y);
      insides.addBoid(b);
    }
    membrane = new Flow(R);
  }
  
  void run(){
    Rectangle boundary = new Rectangle(width/2,height/2, width, height);
    qtree = new QTree(boundary, 20);
    insides.run(qtree, R);
    insides.render(R);
    membrane.render();
  }
}
