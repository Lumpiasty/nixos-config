{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "opencode-claude-auth";
  version = "1.5.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/opencode-claude-auth/-/opencode-claude-auth-1.5.0.tgz";
    hash = "sha512-5NSL+x++VTe2ZrFSznXKv7imiKObIBz0QXPuL+g1NAXAcdTGcbEbQBvvHZeIaSBNjmwpY2MR67Yez1f3LlPl7w==";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./ $out/
  '';
}
