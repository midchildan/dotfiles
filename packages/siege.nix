{ siege, fetchpatch }:

siege.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # fixes a deadlock issue: https://github.com/JoeDog/siege/pull/180
    (fetchpatch {
      url = "https://github.com/midchildan/siege/commit/cf6d1376f610fb60e583cc8a40776ed8ce24069b.patch";
      sha256 = "sha256-7ZTo6ubdVp4vYic8wkku+A/RX65nfv3fhC8BBVQgHbs=";
    })
  ];
})
