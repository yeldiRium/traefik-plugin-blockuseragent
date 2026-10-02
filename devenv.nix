{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  go = pkgs.go-bin.fromGoMod ./go.mod;
  golangci-lint = go.tools.golangci-lint.latest;
in
{
  overlays = [
    inputs.go-overlay.overlays.default
  ];

  packages = with pkgs; [
    (go.withTools [
      "gopls"
      "golangci-lint"
      "delve"
    ])
    gotestsum
    go-mod-upgrade
    yaegi
  ];

  enterTest = # bash
    with pkgs; ''
      ${lib.getExe gotestsum} -- ./...
      ${lib.getExe yaegi} test -v .
    '';

  git-hooks.hooks = {
    check-merge-conflicts.enable = true;

    # go
    gofmt.enable = true;
    golangci-lint = {
      enable = true;
      package = golangci-lint;
    };
    gomodtidy = {
      enable = true;
      name = "go mod tidy";
      entry = "${lib.getExe go} mod tidy";
      files = "\\.go$";
      pass_filenames = false;
    };
    govendor = {
      enable = true;
      name = "go vendor";
      entry = "${lib.getExe go} mod vendor";
      always_run = true;
      pass_filenames = false;
    };

    # nix
    nixfmt.enable = true;

    # yaml
    check-yaml.enable = true;
  };
}
