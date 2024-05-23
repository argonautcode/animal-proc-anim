// Bloopy lil dude
class Fish {
  Chain spine;

  color bodyColor = color(58, 124, 165);
  color finColor = color(129, 195, 215);

  // Width of the fish at each vertabra
  float[] bodyWidth = {68, 81, 84, 83, 77, 64, 51, 38, 32, 19};

  Fish(PVector origin) {
    // 12 segments, first 10 for body, last 2 for caudal fin
    spine = new Chain(origin, 12, 64, PI/8);
  }

  void resolve() {
    PVector headPos = spine.joints.get(0);
    PVector mousePos = new PVector(mouseX, mouseY);
    PVector targetPos = PVector.add(headPos, PVector.sub(mousePos, headPos).setMag(16));
    spine.resolve(targetPos);
  }

  void display() {
    strokeWeight(4);
    stroke(255);
    fill(finColor);

    // Alternate labels for shorter lines of code
    ArrayList<PVector> j = spine.joints;
    ArrayList<Float> a = spine.angles;

    // Relative angle differences are used in some hacky computation for the dorsal fin
    float headToMid1 = relativeAngleDiff(a.get(0), a.get(6));
    float headToMid2 = relativeAngleDiff(a.get(0), a.get(7));

    // For the caudal fin, we need to compute the relative angle difference from the head to the tail, but given
    // a joint count of 12 and angle constraint of PI/8, the maximum difference between head and tail is 11PI/8,
    // which is >PI. This complicates the relative angle calculation (flips the sign when curving too tightly).
    // A quick workaround is to compute the angle difference from the head to the middle of the fish, and then
    // from the middle of the fish to the tail.
    float headToTail = headToMid1 + relativeAngleDiff(a.get(6), a.get(11));

    // === START PECTORAL FINS ===
    pushMatrix();
    translate(getPosX(3, PI/3, 0), getPosY(3, PI/3, 0));
    rotate(a.get(2) - PI/4);
    ellipse(0, 0, 160, 64); // Right
    popMatrix();
    pushMatrix();
    translate(getPosX(3, -PI/3, 0), getPosY(3, -PI/3, 0));
    rotate(a.get(2) + PI/4);
    ellipse(0, 0, 160, 64); // Left
    popMatrix();
    // === END PECTORAL FINS ===

    // === START VENTRAL FINS ===
    pushMatrix();
    translate(getPosX(7, PI/2, 0), getPosY(7, PI/2, 0));
    rotate(a.get(6) - PI/4);
    ellipse(0, 0, 96, 32); // Right
    popMatrix();
    pushMatrix();
    translate(getPosX(7, -PI/2, 0), getPosY(7, -PI/2, 0));
    rotate(a.get(6) + PI/4);
    ellipse(0, 0, 96, 32); // Left
    popMatrix();
    // === END VENTRAL FINS ===

    // === START CAUDAL FINS ===
    beginShape();
    // "Bottom" of the fish
    for (int i = 8; i < 12; i++) {
      float tailWidth = 1.5 * headToTail * (i - 8) * (i - 8);
      curveVertex(j.get(i).x + cos(a.get(i) - PI/2) * tailWidth, j.get(i).y + sin(a.get(i) - PI/2) * tailWidth);
    }

    // "Top" of the fish
    for (int i = 11; i >= 8; i--) {
      float tailWidth = max(-13, min(13, headToTail * 6));
      curveVertex(j.get(i).x + cos(a.get(i) + PI/2) * tailWidth, j.get(i).y + sin(a.get(i) + PI/2) * tailWidth);
    }
    endShape(CLOSE);
    // === END CAUDAL FINS ===

    fill(bodyColor);

    // === START BODY ===
    beginShape();

    // Right half of the fish
    for (int i = 0; i < 10; i++) {
      curveVertex(getPosX(i, PI/2, 0), getPosY(i, PI/2, 0));
    }

    // Bottom of the fish
    curveVertex(getPosX(9, PI, 0), getPosY(9, PI, 0));

    // Left half of the fish
    for (int i = 9; i >= 0; i--) {
      curveVertex(getPosX(i, -PI/2, 0), getPosY(i, -PI/2, 0));
    }


    // Top of the head (completes the loop)
    curveVertex(getPosX(0, -PI/6, 0), getPosY(0, -PI/6, 0));
    curveVertex(getPosX(0, 0, 4), getPosY(0, 0, 4));
    curveVertex(getPosX(0, PI/6, 0), getPosY(0, PI/6, 0));

    // Some overlap needed because curveVertex requires extra vertices that are not rendered
    curveVertex(getPosX(0, PI/2, 0), getPosY(0, PI/2, 0));
    curveVertex(getPosX(1, PI/2, 0), getPosY(1, PI/2, 0));
    curveVertex(getPosX(2, PI/2, 0), getPosY(2, PI/2, 0));

    endShape(CLOSE);
    // === END BODY ===

    fill(finColor);

    // === START DORSAL FIN ===
    beginShape();
    vertex(j.get(4).x, j.get(4).y);
    bezierVertex(j.get(5).x, j.get(5).y, j.get(6).x, j.get(6).y, j.get(7).x, j.get(7).y);
    bezierVertex(j.get(6).x + cos(a.get(6) + PI/2) * headToMid2 * 16, j.get(6).y + sin(a.get(6) + PI/2) * headToMid2 * 16, j.get(5).x + cos(a.get(5) + PI/2) * headToMid1 * 16, j.get(5).y + sin(a.get(5) + PI/2) * headToMid1 * 16, j.get(4).x, j.get(4).y);
    endShape();
    // === END DORSAL FIN ===

    // === START EYES ===
    fill(255);
    ellipse(getPosX(0, PI/2, -18), getPosY(0, PI/2, -18), 24, 24);
    ellipse(getPosX(0, -PI/2, -18), getPosY(0, -PI/2, -18), 24, 24);
    // === END EYES ===
  }

  void debugDisplay() {
    spine.display();
  }

  // Various helpers to shorten lines

  float getPosX(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).x + cos(spine.angles.get(i) + angleOffset) * (bodyWidth[i] + lengthOffset);
  }

  float getPosY(int i, float angleOffset, float lengthOffset) {
    return spine.joints.get(i).y + sin(spine.angles.get(i) + angleOffset) * (bodyWidth[i] + lengthOffset);
  }
}
