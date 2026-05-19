{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "opencode-claude-auth";
  version = "1.5.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/opencode-claude-auth/-/opencode-claude-auth-1.5.4.tgz";
    hash = "sha256-9iByuNTg/MTD3VGeqpBaBCBaooXm97BuvP0fPXDoPGc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./ $out/
  '';
}
