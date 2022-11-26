class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids  

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }
  void render(float R) {
    for (Boid b : boids) {
       b.render(R);
    }
  }
  
  void run(QTree qtree, int R) {
    for (int i = 0; i < boids.size(); i++) {
      Boid boid = boids.get(i);
      Particle point = new Particle(boid.position.x, boid.position.y, boid);
      qtree.insert(point); 
    }
    for (Boid b : boids) {
      ArrayList<Boid> closeBoids = new ArrayList<Boid>();
      closeBoids.clear();
      ArrayList<Particle> points = new ArrayList<Particle>();
      points.clear();
      Circle range = new Circle(b.position.x,b.position.y, 100);
      points = qtree.query(range, null);
    
      for (Particle p : points) {
        Boid ud = p.userData;
        if(ud != b) closeBoids.add(ud);
        
      }
      
      b.run(closeBoids, R);
    
     }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  
  float record = 100000.0;
  int random = floor(random(6));
  float t = 0;

  Boid(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(0,0);
    position = new PVector(x,y);
    r = 3.0;
    maxspeed = 1;
    maxforce = 0.03;
   
  }

  void run(ArrayList<Boid> boids, int R) {
    flock(boids, R);
    update();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids, int R) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector cir = circleEdge(R);
 
    
    sep.mult(3.5);
    ali.mult(3.0);
    coh.mult(1.2);
    cir.mult(10.0);
    
    applyForce(sep);
    applyForce(coh);
    applyForce(cir);
  }
  
  

  
  void update() {
    
    velocity.add(acceleration);
    
    position.add(velocity);
    acceleration.mult(0);
    
    t += 0.01;
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,position);  // A vector pointing from the position to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  void render(float tr) {
    float R;
    stroke(0,0,49,0.7);
    if(random == 0 || random == 1 || random == 4 || random == 5){
      fill(115,68,80,0.5); 
      R = 8;
    } else if(random == 2) {
      fill(0,0,80,0.5); 
      R = 10;
    }
    else {
      fill(10,60,70,0.5);
      R = 5;
    }
    
   
    ellipse(position.x, position.y, R,R);
  }
  
 


  
  void neighbors(ArrayList<Boid> boids){
    record = 1000000.0;
    for(Boid b : boids){
      float d = pow(b.position.x-position.x,2)+pow(b.position.y-position.y,2);
      /*if(d < 30*30 && d > 15*15){
        stroke(120,80);
        line(b.position.x,b.position.y,position.x,position.y);
      }*/
      if(d < record*record && d != 0 ) {
        record = sqrt(d);
      }
    }
  }
  
  PVector edges(){
    PVector desired = new PVector(0,0);
    int d = 50;

    if (position.x < d) {
      desired.set(maxspeed, velocity.y);
    } else if (position.x > width - d) {
      desired.set(-maxspeed, velocity.y);
    }
    if (position.y < d) {
      desired.set(velocity.x, maxspeed);
    } else if (position.y > height - d) {
      desired.set(velocity.x, -maxspeed);
    } 
    return useDesired(desired);
    
  }
  
  PVector circleEdge(float tr){
    PVector origin = new PVector(width/2, height/2);
    float xdif = origin.x-position.x;
    float ydif = origin.y-position.y;
    PVector angle_vec = new PVector(-xdif, -ydif);
    float theta = angle_vec.heading();
    PVector p = new PVector(cos(theta), sin(theta));
    float rdif = getBlob(p.x, p.y, origin, t, tr);
    float r = tr + rdif - 10;
    float rSq = r*r;
    PVector desired = new PVector(0,0);
    if (xdif*xdif+ydif*ydif < rSq){
      desired.set(0,0);
    } else {
      desired.set(xdif,ydif);
    }
    return useDesired2(desired);
  }
  
  PVector useDesired(PVector desired){
    if (desired.x != 0 || desired.y != 0) {
      desired.normalize();
      desired.mult(this.maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(this.maxforce*2);
      return steer;
    } else return new PVector(0,0);
  }
  
  PVector useDesired2(PVector desired){
    if (desired.x != 0 || desired.y != 0) {
      desired.normalize();
      desired.mult(this.maxspeed*3);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(this.maxforce*3);
      return steer;
    } else return new PVector(0,0);
  }
  
  
  
  
  

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float dseparation = 16.0f;
    if(random == 3) dseparation = 25.0f;
    
    float desiredseparation = dseparation*dseparation;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = pow(other.position.x-position.x,2)+pow(other.position.y-position.y,2);
      if ((d < desiredseparation)) {
        
        PVector diff = PVector.sub(position,other.position);
        diff.normalize();
        diff.div(sqrt(d));        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
      
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
        sum.add(other.velocity);
        count++;
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
        sum.add(other.position); // Add position
        count++;
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0,0);
    }
  }
}
