t: rec {
  utils = import ./utils.nix;
  lib = import <nixpkgs/lib>;
  background = 0.05;
  ambientLight = 0.1;
  camera = with utils; rec {
    position = Point 1.5 0 1.0;
    angle = [(0) 0 0];

    # distance between camera and viewplane
    focalLength = 0.2;
    # dimensions of the viewplane (rays are cast from camera.position through
    # this plane and into the scene; it corresponds to the rendered image)
    width = 0.5;
    height = width * 0.5;
    # number of pixels to render along each axis; rays are cast from the center
    # of each pixel/cell in the viewplane
    resolution = {
      x = 120;
      y = builtins.floor (resolution.x * 0.25); # scale to match typical terminal character dimensions
    };
    # if Unicode shape-matching is used for rendering, we can downsample from a
    # higher resolution to produce higher-resolution edges; otherwise, the
    # pixels are just averaged (can be used for antialiasing)
    resample = {
      x = 2;
      y = 2;
    };
    # number of rays to cast per pixel (only improves image quality if
    # stochastic rendering/lighting modes are used)
    samples = 1;
    # filter to apply to each pixel after rendering
    postprocess = lib.id;

    # if `true`, the color palette will be automatically scaled/translated to
    # match the range of brightness values in the image
    remapColors = true;
    # raw pixel value/color range to be mapped onto the character set; only
    # used if remapColors is disabled
    colorRange.low = 0.0;
    colorRange.high = 0.1;
    # charset = lib.stringToCharacters "░▒▓█";
    charset = [" " "░" "▒" "▓" "█"];
    # charset = lib.stringToCharacters "0123456789";
    useANSI = true;

    shading = "phong";
  };
  objects = with utils; [
    {
      # geometry.faces = map (i: ) [0 1 2];
      # TODO: why does string concatenation fail with index error when this cube is moved...?
      # TODO: clean up interface for rotating objects (and other method-like functions)
      geometry = let c = Cube (Point 1.5 2.2 0) 1.5; a = pi / 4; b = [0 0 (t * 0.1)]; in rotate [0.7 0 0.6] c;
      # geometry = Cube (Point 1.5 3.0 0) 1.5;
      # geometry = Cube (Point 0 0 0) 1;

      material.reflectiveness = 0.5;
      material.diffusion = 0.5;
      material.opacity = 1.0;
      material.phong = {
        specular = 0.5;
        diffuse = 0.5;
        ambient = 0.1;
        shininess = 60;
      };
      type = "mesh";

      # test = UnitSquare;
      # test = addPoints (Point 1 2 3) (Point 4 5 6);
      test = cross (Point 0.7 0 0) (Point 1 1 0);
      test2 = dot (Point 1 1 2) (Point 2 2 2);
      # visibleFromCamera
    }
    rec {
      # position = Point 5 (-3) 0;
      # position = Point 1 (-1) 1;
      position = camera.position;
      radius = 0.1;
      # TODO: automatically promote values to floats where needed
      brightness = 1.0;
      type = "light";

      phong.specular = 0.5;
      phong.diffuse = 0.6;
    }
  ];
}
