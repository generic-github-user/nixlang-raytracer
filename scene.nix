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
}
