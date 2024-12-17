This is not necessary any more. `openscad-unstable` in nixos is already build with `manifold`. At least since 24.11 but
maybe even earlier, I am not sure.

The option is a little hidden, you can find it in

    Edit / Preferences / Advanced / 3D Rendering / Backend Dropdown / Select Manifold (new/fast)
    

Build with

```
nix build .#openscad
```

then run like

```
./result/bin/openscad
```

Activate manifold
=================
Edit -> Preferences -> Features -> manifold
