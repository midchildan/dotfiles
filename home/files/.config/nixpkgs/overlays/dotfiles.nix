let
  maybeOverlay = builtins.tryEval (import <dotfiles>).overlay;
  emptyOverlay = final: prev: { };
in
if maybeOverlay.success then maybeOverlay.value else emptyOverlay
