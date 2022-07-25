let
  maybeOverlay = builtins.tryEval (import <dotfiles>).overlays.default;
  emptyOverlay = final: prev: { };
in
if maybeOverlay.success then maybeOverlay.value else emptyOverlay
