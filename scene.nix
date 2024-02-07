rec {
  utils = import ./utils.nix;
  background = 0.05;
  camera = with utils; rec {
    position = Point 1.5 0 0.5;
    focalLength = 0.2;
    width = 0.5;
    height = width * 0.5;
    resolution = {
      x = 120;
      y = builtins.floor (resolution.x * 0.25);
    };
    resample = {
      x = 2;
      y = 2;
    };
    samples = 1;

    remapColors = false;
    colorRange.low = 0.0;
    colorRange.high = 0.2;
    # charset = lib.stringToCharacters "░▒▓█";
    charset = [" " "░" "▒" "▓" "█"];
    # charset = lib.stringToCharacters "0123456789";
  };
  objects = with utils; [
    {
      # geometry.faces = map (i: ) [0 1 2];
      # TODO: why does string concatenation fail with index error when this cube is moved...?
      # TODO: clean up interface for rotating objects (and other method-like functions)
      geometry = let c = Cube (Point 1.0 2.0 0) 1.5; in rotateAbout [0 (pi / 4) (pi / 4)] (meanPoint c) c;
      # geometry = Cube (Point 0 0 0) 1;

      material.reflectiveness = 0.5;
      material.diffusion = 0.5;
      material.opacity = 1.0;
      type = "mesh";

      # test = UnitSquare;
      # test = addPoints (Point 1 2 3) (Point 4 5 6);
      test = cross (Point 0.7 0 0) (Point 1 1 0);
      test2 = dot (Point 1 1 2) (Point 2 2 2);
      # visibleFromCamera
    }
    {
      position = Point 0 0 2;
      # position = Point 0 0 0;
      radius = 0.1;
      # TODO: automatically promote values to floats where needed
      brightness = 10.0;
      type = "light";
    }
  ];
}
