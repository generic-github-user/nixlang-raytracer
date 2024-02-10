{ scene', sceneParams ? {} , ... } :
# scene':
with builtins // (import ./utils.nix) ; let
  lib = import <nixpkgs/lib>;
  scene = (import scene') sceneParams;
  # adapted from https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm#C++_implementation
  # intersects :: Ray -> Shape -> Maybe Number
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

  intersectsObject = ray: object: any (f: (intersects ray f).some) object.geometry.faces;
  intersectsAny = ray: any (intersectsObject ray) meshes;

  # could also flatten objects into a set of triangles + their associated
  # materials, this seemed slightly cleaner/more efficient; this should be
  # equivalent to a filter for intersections followed by a minimum over the
  # resulting list
  # firstIntersectionWith :: Ray -> Object -> Maybe Number
  firstIntersectionWith = ray: obj: foldl1 (Maybe.zipWith (minBy' (x: x.t)))
  (map (face: Maybe.map_ (t: { inherit t face; }) (intersects ray face)) obj.geometry.faces);
  # TODO: find a cleaner way to get the surface normal out of the
  # lower-level functions...

  # intersections :: Ray -> [Intersection]
  intersections = ray: filter (x: x.some) (map (o: Maybe.zipWith' lib.mergeAttrs
  (Some { obj = o; }) (firstIntersectionWith ray o)) meshes);

  # TODO: come up with a better way to lift information about operations on
  # `Maybe`s in attrsets to operations on the objects themselves (also clean up
  # the below)
  firstIntersection = ray: let intersections' = intersections ray;
  in if intersections' == [] then None
  else Some (minBy (x: x.value.t) intersections').value;

  lights = filter (x: x.type == "light") scene.objects;
  meshes = map (o: o // { geometry = o.geometry.triangulation; })
    (filter (o: o.type == "mesh" && !(o.hidden or false)) scene.objects);

  # trace :: Ray -> Int -> Number
  trace = ray: depth: let I = (firstIntersection ray); shading = scene.camera.shading; in
  if !I.some then scene.background else
  let p = addPoints ray.origin' (scalePoint I.value.t ray.dir);
    material = I.value.obj.material;
    df = if settings.assertions.unit then dotUnit else dot;
    # snormal = normal I.value.face; in
    snormal = I.value.obj.geometry.normalTo I.value.face; in
    # snormal = normalOut (meanPoint I.value.obj.geometry) I.value.face; in
  if shading == "default" then sum (map (l: let lray = rayFrom p l.position;
    in if intersectsAny lray then 0.0 else
    material.reflectiveness * l.brightness * (df (normalized lray.dir) snormal)) lights)
  else if shading == "phong" then let ph = material.phong; in
    ph.ambient * scene.ambientLight + (sum (map (l: let
    lray = rayFrom' p l.position;
    reflection = vectorReflection lray.dir snormal; in # is this normalized?
    # TODO: this is almost definitely not lazily evaluated, needs fixing
    if intersectsAny lray then 0.0 else
    ph.diffuse * (df lray.dir snormal) * l.phong.diffuse + ph.specular * (power
    (lib.max 0 (df reflection (normalized (subPoints scene.camera.position p)))) ph.shininess)
    * l.phong.specular) lights))
  # else if shading == "none" then 1.0
  else throw "invalid shading mode";

  camera = scene.camera;
  frame = let c = camera; in lib.reverseList (genMatrix (x: y:
  let p = rotatePointAbout c.angle c.position (Point
    (c.position.x - c.width / 2 + (x + 0.5) * (c.width / c.resolution.x))
    c.focalLength
    (c.position.z - c.height / 2 + (y + 0.5) * (c.height / c.resolution.y)));
    in trace (Ray p (subPoints p c.position)) c.depth) c.resolution.x c.resolution.y);
    
  # getChar :: Number -> Number -> Number -> String
  getChar = min': max': v: let l = length camera.charset - 1.0; in
  if camera.useANSI then let i = floor (mapRange min' max' 232 255 v); in "\\033[38;5;${toString i}m█\\033[0m"
  else elemAt camera.charset (floor (clip 0.0 l (mapRange min' max' 0.0 l v)));

in let c = camera; in
  # builtins.trace (let x = frame; in deepSeq x x)
  lib.concatStringsSep "\n" (map lib.concatStrings
  (map2D (compose (if c.remapColors then (getChar (min2D frame) (max2D frame)) else
  (getChar c.colorRange.low c.colorRange.high)) c.postprocess) frame))
