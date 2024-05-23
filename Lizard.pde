// Glitchy lil dude
class Lizard {
  Chain spine;
  Chain[] arms;
  PVector[] armDesired;

  // Width of the lizard at each vertabra
  float[] bodyWidth = {52, 58, 40, 60, 68, 71, 65, 50, 28, 15, 11, 9, 7, 7};

  Lizard(PVector origin) {
    spine = new Chain(origin, 14, 64, PI/8);
    arms = new Chain[4];
    armDesired = new PVector[4];
    for (int i = 0; i < arms.length; i++) {
      arms[i] = new Chain(origin, 3, i < 2 ? 52 : 36);
      armDesired[i] = new PVector(0, 0);
    }
  }

  void resolve() {
    PVector headPos = spine.joints.get(0);
    PVector mousePos = new PVector(mouseX, mouseY);
    PVector targetPos = PVector.add(headPos, PVector.sub(mousePos, headPos).setMag(12));
    spine.resolve(targetPos);

    for (int i = 0; i < arms.length; i++) {
      int side = i % 2 == 0 ? 1 : -1;
      int bodyIndex = i < 2 ? 3 : 7;
      float angle = i < 2 ? PI/4 : PI/3;
      PVector desiredPos = new PVector(getPosX(bodyIndex, angle * side, 80), getPosY(bodyIndex, angle * side, 80));
      if (PVector.dist(desiredPos, armDesired[i]) > 200) {
        armDesired[i] = desiredPos;
      }

      arms[i].fabrikResolve(PVector.lerp(arms[i].joints.get(0), armDesired[i], 0.4), new PVector(getPosX(bodyIndex, PI/2 * side, -20), getPosY(bodyIndex, PI/2 * side, -20)));
    }
  }

  void display() {
    // === START ARMS ===
    noFill();
    for (int i = 0; i < arms.length; i++) {
      PVector shoulder = arms[i].joints.get(2);
      PVector foot = arms[i].joints.get(0);
      PVector elbow = arms[i].joints.get(1);
      // Doing a hacky thing to correct the back legs to be more physically accurate
      PVector para = PVector.sub(foot, shoulder);
      PVector perp = new PVector(-para.y, para.x).setMag(30);
      if (i == 2) {
        elbow = PVector.sub(elbow, perp);
      } else if (i == 3) {
        elbow = PVector.add(elbow, perp);
      }
      strokeWeight(40);
      stroke(255);
      bezier(shoulder.x, shoulder.y, elbow.x, elbow.y, elbow.x, elbow.y, foot.x, foot.y);
      strokeWeight(32);
      stroke(82, 121, 111);
      bezier(shoulder.x, shoulder.y, elbow.x, elbow.y, elbow.x, elbow.y, foot.x, foot.y);
    }
    // === END ARMS ===

    strokeWeight(4);
    stroke(255);
    fill(82, 121, 111);

    // === START BODY ===
    beginShape();

    // Right half of the lizard
    for (int i = 0; i < spine.joints.size(); i++) {
      curveVertex(getPosX(i, PI/2, 0), getPosY(i, PI/2, 0));
    }

    // Left half of the lizard
    for (int i = spine.joints.size() - 1; i >= 0; i--) {
      curveVertex(getPosX(i, -PI/2, 0), getPosY(i, -PI/2, 0));
    }


    // Top of the head (completes the loop)
    curveVertex(getPosX(0, -PI/6, -8), getPosY(0, -PI/6, -10));
    curveVertex(getPosX(0, 0, -6), getPosY(0, 0, -4));
    curveVertex(getPosX(0, PI/6, -8), getPosY(0, PI/6, -10));

    // Some overlap needed because curveVertex requires extra vertices that are not rendered
    curveVertex(getPosX(0, PI/2, 0), getPosY(0, PI/2, 0));
    curveVertex(getPosX(1, PI/2, 0), getPosY(1, PI/2, 0));
    curveVertex(getPosX(2, PI/2, 0), getPosY(2, PI/2, 0));

    endShape(CLOSE);
    // === END BODY ===

    // === START EYES ===
    fill(255);
    ellipse(getPosX(0, 3*PI/5, -7), getPosY(0, 3*PI/5, -7), 24, 24);
    ellipse(getPosX(0, -3*PI/5, -7), getPosY(0, -3*PI/5, -7), 24, 24);
    // === END EYES ===
  }

  void debugDisplay() {
    spine.display();
  }

  float getPosX(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).x + cos(spine.angles.get(i) + angleOffset) * (bodyWidth[i] + lengthOffset);
  }

  float getPosY(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).y + sin(spine.angles.get(i) + angleOffset) * (bodyWidth[i] + lengthOffset);
  }
}
