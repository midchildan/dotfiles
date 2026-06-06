{
  lib,
  writers,
  blockedYouTubeChannels ? [ ],
}:

let
  baseSettings = lib.importJSON ./base.json;

  ytTopRecommendOf = channel: "youtube.com##ytd-rich-item-renderer:has(a[href=\"/@${channel}\"])";
  youtubeFilters = map ytTopRecommendOf blockedYouTubeChannels;

  fullSettings = baseSettings // {
    cosmeticFilters = youtubeFilters;
  };

  drv = writers.writeJSON "ubol-settings.json" fullSettings;
in
drv.overrideAttrs (_: {
  passthru = {
    filters = youtubeFilters;

    # Script to obtain canonicalized YouTube channel names from channel URLs. The resulting names
    # can be fed into `blockedYouTubeChannels`.
    youtube =
      writers.writePython3Bin "canonicalize-youtube-channel" { }
        # python
        ''
          import fileinput
          from urllib import parse

          for line in fileinput.input(encoding="utf-8"):
              channel = line.strip().removeprefix("https://www.youtube.com/@")
              encoded = parse.quote(channel)
              print(encoded)
        '';
  };
})
