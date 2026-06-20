{ stdenv, fetchurl, runCommand, bun2nix }:

# opencode-antigravity-auth ships only `dist/` in its npm tarball and relies on
# runtime `dependencies` (@opencode-ai/plugin, @openauthjs/openauth, zod, ...).
# opencode loads it via a file:// path and does NOT install those deps, so the
# tarball-only approach fails at load time with "Cannot find module
# '@opencode-ai/plugin'". We therefore vendor node_modules with bun2nix.
#
# Since the NPM tarball doesn't ship a lockfile, we commit a generated bun.lock
# into the NixOS configuration repository to ensure fully deterministic builds.
# To update dependencies, run `bun install --lockfile-only` manually on the unpacked tarball.

let
  version = "1.6.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/opencode-antigravity-auth/-/opencode-antigravity-auth-${version}.tgz";
    hash = "sha256-bLoDjJHuHczxKbslyZSm4zKg5FhdRLdUteKXFmqVlHQ=";
  };

  # Derive a source tree containing the committed bun.lock and a bun.nix
  # generated from it. Fully offline — no network needed here.
  srcWithBunNix = runCommand "opencode-antigravity-auth-src" {
    nativeBuildInputs = [ bun2nix ];
  } ''
    mkdir -p $out
    # The npm tarball unpacks to a top-level `package/` directory.
    tar xzf ${src} --strip-components=1 -C $out
    chmod -R u+w $out

    cp ${./bun.lock} $out/bun.lock
    bun2nix --lock-file $out/bun.lock --output-file $out/bun.nix
  '';
in
stdenv.mkDerivation {
  pname = "opencode-antigravity-auth";
  inherit version;

  src = srcWithBunNix;

  nativeBuildInputs = [ bun2nix.hook ];

  # The bun cache (symlink farm) built from the generated bun.nix. The hook
  # copies this into a writable BUN_INSTALL_CACHE_DIR and runs `bun install
  # --offline` against it to materialize node_modules with no network.
  bunDeps = bun2nix.fetchBunDeps {
    bunNix = "${srcWithBunNix}/bun.nix";
  };

  # This is a plugin (a library directory), not an app: skip bun build/check.
  dontUseBunBuild = true;
  dontUseBunCheck = true;
  dontRunLifecycleScripts = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist package.json node_modules $out/
    [ -f README.md ] && cp README.md $out/ || true
    [ -f LICENSE ] && cp LICENSE $out/ || true

    runHook postInstall
  '';

  dontFixup = true;
}
