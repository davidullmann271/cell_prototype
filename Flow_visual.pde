class Flow{
  float t = 0;
  PVector pos, vel;
  int divisions = 200;
  int R;
  float[] r;
 
  
  Flow(int R){
    pos = new PVector(width/2, height/2);
    vel = new PVector(0,0);
    this.R = R;
    r = new float[divisions];
   
  }
  
  void update(PVector tpos){
    pos = tpos;
  }
  
  void render(){
    t += 0.01;
    pushMatrix();
    translate(pos.x, pos.y);
    stroke(0,0,60,0.6);
  //  stroke(5,80,80);
  //  fill(0,80,80);
    fill(0,0,58,0.7);
    strokeWeight(1);
    
    
    for(int n = 0; n < divisions; n++){
      float theta = map(n,0,divisions,0,TWO_PI);
    //  PVector p = new PVector(width/2, height/2);
      PVector p = new PVector(cos(theta), sin(theta));
      r[n] = getBlob(p.x, p.y, pos, t, R);
      p.mult(R+r[n]);
      
      PVector v = new PVector(cos(theta)*5, sin(theta)*5);
      for(int i = 0; i < 6; i++){
        float oldX = p.x;
        float oldY = p.y;
        PVector a = getFlow(p.x, p.y);
        
        v.x += a.x;
        v.y += a.y;
        p.x += v.x;
        p.y += v.y;
        
        line(oldX, oldY, p.x, p.y);
        if(i == 5) {
          ellipse(p.x,p.y,6,6);
          
        }
      }
    }
    beginShape();
    fill(150,0.1);
    for(int n = 0; n < divisions; n++){
      float theta = map(n,0,divisions,0,TWO_PI);
      PVector p = new PVector(cos(theta), sin(theta));
      r[n] = getBlob(p.x, p.y, pos, t, R);
      p.mult(R+r[n]);
      vertex(p.x, p.y);
    }
    endShape(CLOSE);
    beginShape();
    fill(150,0.1);
    for(int n = 0; n < divisions; n++){
      float theta = map(n,0,divisions,0,TWO_PI);
      PVector p = new PVector(cos(theta), sin(theta));
      r[n] = getBlob(p.x, p.y, pos, t, R);
      p.mult(R-5+r[n]);
      vertex(p.x, p.y);
    }
    endShape(CLOSE);
    
    popMatrix();
  }
  
  PVector getFlow(float x, float y) {
    float angle = noise(x/200.0 + pos.x/300.0 + t/6, y/200.0+pos.y/300.0 + t/7) * 6 * PI;
    return PVector.fromAngle(angle).setMag(1);
  }
  
  
}

float getBlob(float x, float y, PVector pos, float t, float R){
  float blob = noise(x/(R/100) + pos.x/300.0 + t/6, y/(R/100) + pos.y/300.0 + t/7);
  return map(blob,0,1,-R,R);
}
