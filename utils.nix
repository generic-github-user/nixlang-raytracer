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

}
