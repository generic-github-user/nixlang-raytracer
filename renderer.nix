scene':
with builtins // (import ./utils.nix); let
  lib = import <nixpkgs/lib>;
  scene = import scene';
  # adapted from https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm#C++_implementation
  # intersects :: Ray -> Triangle -> Maybe Number
  intersects = ray@{ origin', dir }: triangle:
    let tri = Triangle triangle;
        e1 = subPoints tri.b tri.a;
        e2 = subPoints tri.c tri.a;
        ray_x_e2 = cross dir e2;
        det = dot e1 ray_x_e2; in
        if det > -epsilon && det < epsilon then None else

        let det' = 1.0 / det;
        s = subPoints origin' tri.a;
        u = det' * (dot s ray_x_e2); in
        if u < 0 || u > 1 then None else

        let s_x_e1 = cross s e1;
        v = det' * (dot dir s_x_e1); in
        if v < 0 || u + v > 1 then None else
        
        let t = det' * (dot e2 s_x_e1); in
        # if t > epsilon then Some (addPoints origin' (scalePoint t dir))
        if t > epsilon then Some t
        else None;

  # could also flatten objects into a set of triangles + their associated
  # materials, this seemed slightly cleaner/more efficient; this should be
  # equivalent to a filter for intersections followed by a minimum over the
  # resulting list
  # firstIntersectionWith :: Ray -> Object -> Maybe Number
  firstIntersectionWith = ray: obj: foldl1 (Maybe.zipWith lib.min)
  (map (intersects ray) obj.geometry.faces);
  # TODO: clean this up
  intersections = ray: (builtins.filter (x: x.t.some) (map (o: (let o' = o // { geometry = triangulate o.geometry; }; in { obj = o'; t = firstIntersectionWith ray o'; })) (builtins.filter (o: o.type == "mesh") scene.objects)));
  firstIntersection = ray: let intersections' = intersections ray;
  in if intersections' == [] then None
  # TODO: come up with a better way to lift information about operations on
  # `Maybe`s in attrsets to operations on the objects themselves
  else Some (minBy (x: x.t.value) intersections');
  lights = builtins.filter (x: x.type == "light") scene.objects;

  # trace :: Ray -> Int -> Number
  trace = ray: depth: let I = firstIntersection ray; in if !I.some then scene.background else
  let p = addPoints ray.origin' (scalePoint I.value.t.value ray.dir); in
  I.value.obj.material.reflectiveness * (sum (map (l: let lray = rayFrom p l.position;
  in if (firstIntersection lray).some then 0 else l.brightness * (dot lray.dir ray.dir)) lights));

  camera = scene.camera;
  frame = let c = camera; in lib.reverseList (genMatrix (x: y:
  let p = Point
    (c.position.x - c.width / 2 + (x + 0.5) * (c.width / c.resolution.x))
    c.focalLength
    (c.position.z - c.height / 2 + (y + 0.5) * (c.height / c.resolution.y));
    in trace (Ray p (subPoints p c.position)) 5) c.resolution.x c.resolution.y);
    
  getChar = min': max': v: let l = length camera.charset - 1.0; in
    elemAt camera.charset (floor (clip 0.0 l (mapRange min' max' 0.0 l v)));

  test1 = intersects { origin' = origin; dir = Point 1 1 1; }
    [(Point 5 0 0) (Point 0 5 0) (Point 0 0 5)];
  test2 = triangulate UnitCube;
  test3 = foldl1 builtins.add [1 2 3];
  test4 = intersections { origin' = origin; dir = Point 1 1 1.1; };
in let c = camera; in
  lib.concatStringsSep "\n" (map lib.concatStrings
  (map2D (if c.remapColors then (getChar (min2D frame) (max2D frame)) else
  (getChar c.colorRange.low c.colorRange.high)) frame))
