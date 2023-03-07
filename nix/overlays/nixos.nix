# overlay for the nixos input to this flake

final: prev:

{
  step-ca = prev.step-ca.overrideAttrs (old: {
    checkFlags = (old.checkFlags or [ ]) ++ [ "-p 1" ];
  });
}
