# nixlang-raytracer

A simple raytracer written in the [Nix configuration language](https://nixos.org/manual/nix/stable/language/index.html) using the standard library (`builtins` and `lib`). It renders to the terminal in ASCII or Unicode, but I plan to adapt it to generate actual images[^1]. Optional resampling to a lower resolution can be enabled to render edges more precisely using non-block Unicode characters. Currently, the renderer can handle scenes containing spheres, convex meshes (which are triangulated at render time), and point light sources. Möller–Trumbore is used for ray-triangle intersection when rendering meshes. Color output is not currently supported.

## Usage

An example scene description (lighting, camera, objects, rendering settings) is given in `scene.nix`, with the renderer itself in `renderer.nix` and `utils.nix` (miscellaneous helper functions and geometry tools). Most of the settings should be self-evident, but those that may not be are (hopefully) commented. No particular units are imposed on geometry/focal length/other distances.

## Benchmarks

TODO

[^1] ...so I have an excuse to play with performance optimizations instead of updating my resume
