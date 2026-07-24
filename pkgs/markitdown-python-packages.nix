{ ffmpeg-headless, python3Packages }:

python3Packages.overrideScope (final: prev: {
  pydub = prev.pydub.override {
    ffmpeg-full = ffmpeg-headless;
  };
  pypdfium2 = prev.pypdfium2.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      sed -i -E \
        's#/nix/store/[a-z0-9]{32}-apple-sdk-[^/]+/#/#g' \
        "$out/${final.python.sitePackages}/pypdfium2_raw/bindings.py"
    '';
  });
})
