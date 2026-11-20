{
  description = "probe-merge-queue: a throwaway repository that probes the merge queue.";

  inputs.nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-26.05&rev=b349185bb79c7cf7ad8ea8c097931730bf473c71&shallow=1";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Two pull requests that each pass alone but fail together: one adds
      # conflict/left, the other conflict/right.
      conflict = builtins.pathExists ./conflict/left && builtins.pathExists ./conflict/right;
    in
    {
      checks = nixpkgs.lib.genAttrs systems (system: {
        probe = nixpkgs.legacyPackages.${system}.runCommand "probe" { } (
          if conflict then
            ''
              echo "conflict/left and conflict/right must not both exist" >&2
              exit 1
            ''
          else
            ''
              sleep 30
              touch $out
            ''
        );
      });
    };
}
