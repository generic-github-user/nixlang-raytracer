with builtins; rec {
  lib = import <nixpkgs/lib>;

  # setAt = i: x: xs: 
  # insertAt :: Int -> a -> [a] -> [a]
  # insert the element `x` at index `i`, shifting the remaining elements of `xs`
  insertAt = i: x: xs: (lib.take i xs) ++ [x] ++ (lib.drop i xs);

  rot90 = { x, y }: { x = -y; y = x; };
  # rot90About 

  # PointType = Type { x = Number; y = Number; z = Number; }
  Point = a: b: c: { x = a; y = b; z = c; };
  Ray = o: d: { origin' = o; dir = d; };
  rayFrom = a: b: { origin' = a; dir = subPoints b a; };
  origin = Point 0 0 0;

  # liftPoint :: Int -> Number -> Point2D -> Point3D
  liftPoint = axis: w: p: listToPoint (insertAt axis w (pointToList p));

  # TODO: make this a specific case of a more general shape class
  # UnitSquare :: Shape
  UnitSquare = let d = {x = 0.5; y = 0.5;}; in
    # map (addPoints d) (lib.take 4 (iterate rot90 d));
    map (addPoints d) (iterate rot90 4 d);
  # Square = pos: size: (translate pos) (scale size) UnitSquare;

  Triangle = xs: listToAttrs (map ({fst, snd}: {name = fst; value = snd;})
    (lib.zipLists ["a" "b" "c"] xs));

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
  UnitCube = Cube origin 1.0;
  Sphere = pos: radius: { pos = pos; radius = radius; };

  # isPoint =
  pointToList = attrValues;
  listToPoint = xs: listToAttrs (map ({fst, snd}: {name = fst; value = snd;})
    (lib.zipLists ["x" "y" "z"] xs));

  # makeArrayOp = f: a: b: f [a b];
  # pointBinOp :: (Number -> Number -> Number) -> (Point3D -> Point3D -> Point3D)
  # generates an binary operation on points from the corresponding operation on numbers
  pointBinOp = f: a: b: lib.zipAttrsWith
    (_: x: f (elemAt x 0) (elemAt x 1)) [a b];
  addPoints = pointBinOp add;
  subPoints = pointBinOp sub;
  mulPoints = pointBinOp mul;
  scalePoint = s: p: mapAttrs (_: mul s) p;

  # mapPoints :: (Point3D -> Point3D) -> Geometry -> Geometry
  mapPoints = f: object: object // {
    faces = map (map f) object.faces;
  };
  # translate = delta: object: { };
  translate = delta: mapPoints (addPoints delta);
  scale = s: mapPoints (scalePoint s);
  # rotate = theta: mapPoints (rotatePoint theta);
  # extrude =

  Ok = x: { ok = true; value = x; };
  Error = err: { ok = false; error = err; };

  Some = x: { some = true; value = x; };
  None = { some = false; };
  Maybe = {
    zipWith = f: a: b: if a.some && b.some then Some (f a.value b.value) else Maybe.or_ a b;
    or_ = a: b: if a.some then a else b;
    unwrap = a: a.value;
  };

  # iterate = f: x: [x] ++ (iterate f (f x));
  iterate = f: n: x: if n == 0 then [] else [x] ++ (iterate f (n - 1) (f x));

  compose = f: g: x: f (g x);
  # TODO: add "methods" to individual objects

  cross = a: b: Point (a.y*b.z - a.z*b.y) (a.z*b.x - a.x*b.z) (a.x*b.y - a.y*b.x);
  dot = a: b: foldl' add 0
    (lib.zipListsWith mul (pointToList a) (pointToList b));
  # coplanar = points: if length points <= 3 then true else;

  # triangulateShape :: Shape -> [Shape]
  triangulateShape = s: if length s <= 3 then [s] else
    genList (i: [(let h = head s; in seq h h)] ++ (lib.sublist (i+1) 2 s)) (length s - 2);
  # triangulate :: Geometry -> Geometry
  triangulate = mesh: mesh // { faces = concatMap triangulateShape mesh.faces; };

  foldl1 = op: list: foldl' op (head list) (tail list);
  minBy = f: foldl1 (x: y: if f(y) >= f(x) then y else x);
  sum = foldl' add 0;

  # TODO: find a better name for this...
  foldl1-2D = op: compose (foldl1 op) (map (foldl1 op));
  min2D = foldl1-2D lib.min;
  max2D = foldl1-2D lib.max;

  mapRange = a1: a2: b1: b2: x: (x - a1) * (b2 - b1) / (a2 - a1) + b1;
  map2D = f: map (map f);
  epsilon = 0.00000001;
  clip = low: high: x: lib.max low (lib.min high x);
}
