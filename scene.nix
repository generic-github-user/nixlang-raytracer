{ t ? 0 }: rec {
  utils = import ./utils.nix;
  lib = import <nixpkgs/lib>;
  background = 0.05;
  ambientLight = 0.1;
  camera = with utils; rec {
    position = Point 1.5 0 2.3;
    angle = [(-0.7) 0 0];

    # distance between camera and viewplane
    focalLength = 0.18;
    # dimensions of the viewplane (rays are cast from camera.position through
    # this plane and into the scene; it corresponds to the rendered image)
    width = 0.4;
    height = width * 0.5;
    # number of pixels to render along each axis; rays are cast from the center
    # of each pixel/cell in the viewplane
    resolution = {
      x = 100;
      # scale to match typical terminal character dimensions
      y = builtins.floor (resolution.x * 0.25);
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
    remapColors = false;
    # raw pixel value/color range to be mapped onto the character set; only
    # used if remapColors is disabled
    colorRange.low = 0.0;
    colorRange.high = 0.25;
    charset = [" " "░" "▒" "▓" "█"];
    # charset = lib.stringToCharacters "0123456789";
    useANSI = true;

    shading = "phong";
    recursive = true;
    depth = 5;
  };
  objects = with utils; let material1 = {
      reflectiveness = 0.5;
      diffusion = 0.5;
      opacity = 1.0;
      phong = {
        specular = 1.8;
        diffuse = 0.5;
        ambient = 0.1;
        shininess = 100;
      };
  }; in [
    {
      geometry = let c = Cube (Point 1.0 1.6 0) 1.5; a = pi / 4; b = [0 0 (t * 0.1)];
        in rotate b c;
      material = material1;
      hidden = true;
      type = "mesh";
    }
    {
      geometry = rotate [0 0 (t * 2 * pi / 60)] (scale 0.5 (union (map (p: Cube
      (addPoints p (Point 1.3 2.4 0)) 1.0) (builtins.filter (p: lib.mod
      (p.x+p.y+p.z) 2 == 0) (let w = [0 1 2]; in lib.cartesianProductOfSets { x
      = w; y = w; z = w; })))));
      material = material1;
      type = "mesh";
    }
    rec {
      position = Point 3 (-1) 2.5;
      radius = 0.1;
      brightness = 3.0;
      type = "light";

      phong.specular = 1.0;
      phong.diffuse = 0.6;
    }
  ];
}
