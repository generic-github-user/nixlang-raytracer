scene:
let
  lib = import <nixpkgs/lib>;
  utils = import ./utils.nix;
  # adapted from https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm#C++_implementation
  intersects = with utils; ray@{ origin', dir }: triangle:
    let tri = Triangle triangle;
        e1 = subPoints tri.b tri.a;
        e2 = subPoints tri.c tri.a;
        ray_x_e2 = cross dir e2;
        det = dot e1 ray_x_e2;
        epsilon = 0.00000001; in
        if det > -epsilon && det < epsilon then None else

        let det' = 1.0 / det;
        s = subPoints origin' tri.a;
        u = det' * (dot s ray_x_e2); in
        if u < 0 || u > 1 then None else

        let s_x_e1 = cross s e1;
        v = det' * (dot dir s_x_e1); in
        if v < 0 || u + v > 1 then None else
        
        let t = det' * (dot e2 s_x_e1); in
        if t > epsilon then Some (addPoints origin' (scalePoint t dir))
          else None;
  test1 = with utils; intersects { origin' = origin; dir = Point 1 1 1; }
    [(Point 5 0 0) (Point 0 5 0) (Point 0 0 5)];
  test2 = with utils; triangulate UnitCube;
  in test2
