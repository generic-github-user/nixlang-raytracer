rec {
  utils = import ./utils.nix;
  background = 0.2;
  camera = with utils; {
    position = Point 0.5 0 0.5;
    focalLength = 0.1;
    width = 0.5;
    height = 0.2;
    resolution = {
      x = 80;
      y = 20;
    };
    resample = {
      x = 2;
      y = 2;
    };
    samples = 1;
  };
  objects = with utils; [
    {
      # geometry.faces = map (i: ) [0 1 2];
      geometry = Cube (Point 1 1 0) 1.5;
      # geometry = Cube (Point 0 0 0) 1;

      material.reflectiveness = 0.8;
      material.diffusion = 0.5;
      material.opacity = 1.0;
      type = "object";

      # test = UnitSquare;
      # test = addPoints (Point 1 2 3) (Point 4 5 6);
      test = cross (Point 0.7 0 0) (Point 1 1 0);
      test2 = dot (Point 1 1 2) (Point 2 2 2);
      # visibleFromCamera
    }
    {
      position = Point 2 2 3;
      radius = 0.1;
      brightness = 1;
      type = "light";
    }
  ];
}
