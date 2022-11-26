class Particle {
  float x, y;
  Boid userData;
  
  Particle(float x, float y, Boid Userdata) {
    this.x = x;
    this.y = y;
    this.userData = Userdata;
  }
}



//-------------------------------------------------------------------------------------------------------------------------------------------------------------



class Circle{
  float x;
  float y;
  float r;
  float rSquared;
  
  Circle(float x,float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.rSquared = this.r*this.r;
  }

  Boolean contains(Particle point) {
    float d = pow((point.x - this.x), 2) + pow((point.y - this.y), 2);
    return d <= this.rSquared;
  }

  Boolean intersects(Rectangle range) {

    float xDist = abs(range.x - this.x);
    float yDist = abs(range.y - this.y);

    // radius of the circle
    float r = this.r;

    float w = range.w;
    float h = range.h;

    float edges = pow((xDist - w), 2) + pow((yDist - h), 2);

    // no intersection
    if (xDist > (r + w) || yDist > (r + h))
      return false;

    // intersection within the circle
    if (xDist <= w || yDist <= h)
      return true;

    // intersection on the edge of the circle
    return edges <= this.rSquared;
  }
}



//-------------------------------------------------------------------------------------------------------------------------------------------------------------


class Rectangle {
  float x, y;
  float w, h;

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  Rectangle(Rectangle other) {
    this.x = other.x;
    this.y = other.y;
    this.w = other.w;
    this.h = other.h;
  }

  Boolean contains(Particle point) {
    return (
      point.x >= x - w &&
      point.x <= x + w &&
      point.y >= y - h &&
      point.y <= y + h);
  }
}


//-------------------------------------------------------------------------------------------------------------------------------------------------------------



class QTree {
  Rectangle boundary;
  ArrayList<Particle> particles;
  int capacity;
  Boolean isDivided;

  QTree northEast, northWest, southEast, southWest;

  QTree(Rectangle boundary, int n) {
    this.boundary = new Rectangle(boundary);
    this.capacity = n;
    this.particles = new ArrayList<Particle>();
    this.isDivided = false;
  }

  void subdivide() {
    float x = this.boundary.x;
    float y = this.boundary.y;
    float w = this.boundary.w * 0.5;
    float h = this.boundary.h * 0.5;

    Rectangle ne = new Rectangle(x + w, y - h, w, h);
    northEast = new QTree(ne, this.capacity);
    Rectangle nw = new Rectangle(x - w, y - h, w, h);
    northWest = new QTree(nw, this.capacity);
    Rectangle se = new Rectangle(x + w, y + h, w, h);
    southEast = new QTree(se, this.capacity);
    Rectangle sw = new Rectangle(x - w, y + h, w, h);
    southWest = new QTree(sw, this.capacity);
    isDivided = true;
  }

  Boolean insert(Particle point) {
    if (!this.boundary.contains(point)) {
      return false;
    }

    if (particles.size() < this.capacity) {
      particles.add(point);
      return true;
    } else {
      if (!isDivided) {
        subdivide();
      }
      if (this.northEast.insert(point)) {
        return true;
      } else if (this.northWest.insert(point)) {
        return true;
      } else if (this.southEast.insert(point)) {
        return true;
      } else if (this.southWest.insert(point)) {
        return true;
      }
    }
    return false;
  }

  ArrayList<Particle> query(Circle range, ArrayList<Particle> found) {
    if (found == null) {
      found = new ArrayList<Particle>();
    }
    if (range.intersects(this.boundary)) {

      for (Particle p : particles) {
        if (range.contains(p)) {
          found.add(p);
        }
      }
      if (isDivided) {
        northWest.query(range, found);
        northEast.query(range, found);
        southWest.query(range, found);
        southEast.query(range, found);
      }
    }
    return found;
  }

/*  void show() {
    stroke(255);
    strokeWeight(0.5);
    noFill();
    rectMode(CENTER);
    rect(boundary.x, boundary.y, boundary.w * 2, boundary.h * 2);
    if (isDivided) {
      this.northEast.show();
      this.northWest.show();
      this.southEast.show();
      this.southWest.show();
    }
    stroke(255, 0, 100);
    strokeWeight(2);
    for (Particle p : particles) {
      point(p.x, p.y);
    }
  } */
}
