class Chain {
  ArrayList<PVector> joints;
  int linkSize; // Space between joints

  // Only used in non-FABRIK resolution
  ArrayList<Float> angles;
  float angleConstraint; // Max angle diff between two adjacent joints, higher = loose, lower = rigid

  Chain(PVector origin, int jointCount, int linkSize) {
    this(origin, jointCount, linkSize, TWO_PI);
  }

  Chain(PVector origin, int jointCount, int linkSize, float angleConstraint) {
    this.linkSize = linkSize;
    this.angleConstraint = angleConstraint;
    joints = new ArrayList<>(); // Assumed to be >= 2, otherwise it wouldn't be much of a chain
    angles = new ArrayList<>();
    joints.add(origin.copy());
    angles.add(0f);
    for (int i = 1; i < jointCount; i++) {
      joints.add(PVector.add(joints.get(i - 1), new PVector(0, this.linkSize)));
      angles.add(0f);
    }
  }

  void resolve(PVector pos) {
    angles.set(0, PVector.sub(pos, joints.get(0)).heading());
    joints.set(0, pos);
    for (int i = 1; i < joints.size(); i++) {
      float curAngle = PVector.sub(joints.get(i - 1), joints.get(i)).heading();
      angles.set(i, constrainAngle(curAngle, angles.get(i - 1), angleConstraint));
      joints.set(i, PVector.sub(joints.get(i - 1), PVector.fromAngle(angles.get(i)).setMag(linkSize)));
    }
  }

  void fabrikResolve(PVector pos, PVector anchor) {
    // Forward pass
    joints.set(0, pos);
    for (int i = 1; i < joints.size(); i++) {
      joints.set(i, constrainDistance(joints.get(i), joints.get(i-1), linkSize));
    }

    // Backward pass
    joints.set(joints.size() - 1, anchor);
    for (int i = joints.size() - 2; i >= 0; i--) {
      joints.set(i, constrainDistance(joints.get(i), joints.get(i+1), linkSize));
    }
  }

  void display() {
    strokeWeight(8);
    stroke(255);
    for (int i = 0; i < joints.size() - 1; i++) {
      PVector startJoint = joints.get(i);
      PVector endJoint = joints.get(i + 1);
      line(startJoint.x, startJoint.y, endJoint.x, endJoint.y);
    }

    fill(42, 44, 53);
    for (PVector joint : joints) {
      ellipse(joint.x, joint.y, 32, 32);
    }
  }
}
