rec {
  lib = import <nixpkgs/lib>;

  # setAt = i: x: xs: 
  # insertAt :: Int -> a -> [a] -> [a]
  # insert the element `x` at index `i`, shifting the remaining elements of `xs`
  insertAt = i: x: xs: (lib.take i xs) ++ [x] ++ (lib.drop i xs);

  rot90 = { x, y }: { x = -y; y = x; };
  # rot90About 

  # PointType = Type { x = Number; y = Number; z = Number; }
  Point = a: b: c: { x = a; y = b; z = c; };
  origin = Point 0 0 0;

  # liftPoint :: Int -> Number -> Point2D -> Point3D
  liftPoint = axis: w: p: listToPoint (insertAt axis w (pointToList p));

  # TODO: make this a specific case of a more general shape class
  # UnitSquare :: Shape
  UnitSquare = let d = {x = 0.5; y = 0.5;}; in
    # map (addPoints d) (lib.take 4 (iterate rot90 d));
    map (addPoints d) (iterate rot90 4 d);
  # Square = pos: size: (translate pos) (scale size) UnitSquare;

  # Cube :: Point3D -> Number -> Geometry
  Cube = pos: size: compose (translate pos) (scale size) {
    # faces = map (mapPoints (liftPoint) (Square pos size)) [0 1 2];
    position = origin;
    faces = map ({i, j}: map (liftPoint i j) UnitSquare)
      (lib.cartesianProductOfSets {i = [0 1 2]; j = [0 1];});
    # faces = [UnitSquare];
    # faces = [[origin]];

    # volume = 
  };
  Sphere = pos: radius: { pos = pos; radius = radius; };
}
