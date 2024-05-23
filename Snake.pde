// Wiggly lil dude
class Snake {
  Chain spine;

  Snake(PVector origin) {
    spine = new Chain(origin, 48, 64, PI/8);
  }

  void resolve() {
    PVector headPos = spine.joints.get(0);
    PVector mousePos = new PVector(mouseX, mouseY);
    PVector targetPos = PVector.add(headPos, PVector.sub(mousePos, headPos).setMag(8));
    spine.resolve(targetPos);
  }

  void display() {
    strokeWeight(4);
    stroke(255);
    fill(172, 57, 49);

    // === START BODY ===
    beginShape();

    // Right half of the snake
    for (int i = 0; i < spine.joints.size(); i++) {
      curveVertex(getPosX(i, PI/2, 0), getPosY(i, PI/2, 0));
    }

    curveVertex(getPosX(47, PI, 0), getPosY(47, PI, 0));

    // Left half of the snake
    for (int i = spine.joints.size() - 1; i >= 0; i--) {
      curveVertex(getPosX(i, -PI/2, 0), getPosY(i, -PI/2, 0));
    }


    // Top of the head (completes the loop)
    curveVertex(getPosX(0, -PI/6, 0), getPosY(0, -PI/6, 0));
    curveVertex(getPosX(0, 0, 0), getPosY(0, 0, 0));
    curveVertex(getPosX(0, PI/6, 0), getPosY(0, PI/6, 0));

    // Some overlap needed because curveVertex requires extra vertices that are not rendered
    curveVertex(getPosX(0, PI/2, 0), getPosY(0, PI/2, 0));
    curveVertex(getPosX(1, PI/2, 0), getPosY(1, PI/2, 0));
    curveVertex(getPosX(2, PI/2, 0), getPosY(2, PI/2, 0));

    endShape(CLOSE);
    // === END BODY ===

    // === START EYES ===
    fill(255);
    ellipse(getPosX(0, PI/2, -18), getPosY(0, PI/2, -18), 24, 24);
    ellipse(getPosX(0, -PI/2, -18), getPosY(0, -PI/2, -18), 24, 24);
    // === END EYES ===
  }

  void debugDisplay() {
    spine.display();
  }

  float bodyWidth(int i) {
    switch(i) {
    case 0:
      return 76;
    case 1:
      return 80;
    default:
      return 64 - i;
    }
  }

  float getPosX(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).x + cos(spine.angles.get(i) + angleOffset) * (bodyWidth(i) + lengthOffset);
  }

  float getPosY(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).y + sin(spine.angles.get(i) + angleOffset) * (bodyWidth(i) + lengthOffset);
  }
}
