{ stdenv, fetchurl, runCommand, bun, bun2nix }:

# opencode-antigravity-auth ships only `dist/` in its npm tarball and relies on
# runtime `dependencies` (@opencode-ai/plugin, @openauthjs/openauth, zod, ...).
# opencode loads it via a file:// path and does NOT install those deps, so the
# tarball-only approach fails at load time with "Cannot find module
# '@opencode-ai/plugin'". We therefore vendor node_modules with bun2nix.
#
# bun.lock and bun.nix are generated on the fly rather than committed.
#
# The tarball ships no lockfile, so we synthesize one with `bun install
# --lockfile-only`. Resolving npm version ranges (e.g. "^4.1.4") into exact
# versions requires registry access, and Nix only permits network inside a
# fixed-output derivation — hence `lockfileHash` below. This is the single
# unavoidable hash for the dep graph: it pins the resolved lockfile, which in
# turn (via bun2nix -> fetchBunDeps) pins every transitive dependency, each
# fetched as its own hash-checked FOD. bun.nix itself stays uncommitted and
# is derived deterministically from the pinned lockfile.
#
# Bump `version`, `hash`, and `lockfileHash` together. To refresh lockfileHash,
# set it to lib.fakeHash, build, and copy the "got:" value from the error.

let
  version = "1.6.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/opencode-antigravity-auth/-/opencode-antigravity-auth-${version}.tgz";
    hash = "sha256-bLoDjJHuHczxKbslyZSm4zKg5FhdRLdUteKXFmqVlHQ=";
  };

  # Fixed-output derivation: network-enabled, produces only the resolved
  # bun.lock. Determinism is enforced by lockfileHash.
  bunLock = stdenv.mkDerivation {
    name = "opencode-antigravity-auth-bun.lock";
    inherit src;
    sourceRoot = "package";
    nativeBuildInputs = [ bun ];

    buildPhase = ''
      export HOME="$TMPDIR"
      bun install --lockfile-only --no-progress
    '';
    installPhase = "cp bun.lock $out";

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "sha256-H+m181VozFyEEQVrOZTienj15Bgn1UXTG/G/B9gy1UE=";
  };

  # Derive a source tree containing the resolved bun.lock and a bun.nix
  # generated from it. Fully offline — no network needed here.
  srcWithBunNix = runCommand "opencode-antigravity-auth-src" {
    nativeBuildInputs = [ bun2nix ];
  } ''
    mkdir -p $out
    # The npm tarball unpacks to a top-level `package/` directory.
    tar xzf ${src} --strip-components=1 -C $out
    chmod -R u+w $out

    cp ${bunLock} $out/bun.lock
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
