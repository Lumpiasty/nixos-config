{ bun2nix, fetchFromGitHub, fetchurl, fetchzip, runCommand, python3, pkgs, stdenv, ... }:

# NOTE: This derivation works around two open bun2nix bugs. Remove the
# workarounds and simplify once they are fixed upstream.
#
# Bug 1 — missing .npm manifest cache files
# https://github.com/nix-community/bun2nix/issues/77
#
#   bun's install cache requires two kinds of entries per package:
#     - the extracted package directory (e.g. handlebars@4.7.9@@@1/)
#     - a hashed .npm manifest file (e.g. 02dd05ab1686ff3a.npm)
#   bun2nix only provides the former. bun therefore fetches the manifest from
#   the registry during the "Resolving" phase, which fails in the Nix sandbox.
#
#   Workaround: pass --offline to bun install. This tells bun to skip manifest
#   fetches and trust the lockfile for resolution instead.
#
# Bug 2 — catalog: specifiers still trigger network resolution with --offline
# https://github.com/nix-community/bun2nix/issues/77 (same thread)
#
#   bun2nix's bunResolveCatalogRefs rewrites "catalog:" specifiers in
#   package.json to the version *range* from the catalog table (e.g. "^1.3.14")
#   rather than the exact pinned version from bun.lock's packages section.
#   Even with --offline, bun reads the catalog table from bun.lock and tries to
#   resolve those ranges, hitting the network.
#
#   Workaround: the Python script below pre-processes the source before the
#   build. It pins every dep in every workspace package.json to the exact
#   version from bun.lock's packages section (so no ranges remain for bun to
#   resolve), and strips the catalog/catalogs keys from bun.lock entirely.
#
#   bun.lock is JSONC (trailing-comma JSON) so we parse it with Python's stdlib
#   json after stripping trailing commas with a regex.
#
# Additionally, oh-my-pi's bun.lock was generated with bun >=1.3.14 which uses
# a different Wyhash seed for cache keys than nixpkgs's bun 1.3.13. Bumping bun
# globally breaks other packages (e.g. opencode), so instead we patch the
# generated wrapper script in postInstall to reference bun 1.3.14 directly.
# Hashes from https://github.com/NixOS/nixpkgs/pull/519796

let
  version = "15.2.1";

  # bun 1.3.14 — needed for correct cache key hashes; scoped to this package.
  bun_1_3_14 = pkgs.bun.overrideAttrs (_: {
    version = "1.3.14";
    src =
      let
        sources = {
          "aarch64-darwin" = fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-darwin-aarch64.zip";
            hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
          };
          "aarch64-linux" = fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-aarch64.zip";
            hash = "sha256-on/7Y6gxA3WDbg1vZorhf6jY0YuIw3yCHGUzGXOhmjs=";
          };
          "x86_64-darwin" = fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-darwin-x64-baseline.zip";
            hash = "sha256-PjWtb1OXGpg0v55nhuKt9ytfGSHMmpxf3gc9KXKUQHY=";
          };
          "x86_64-linux" = fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip";
            hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
          };
        };
      in
      sources.${stdenv.hostPlatform.system} or (throw "bun 1.3.14 not available for ${stdenv.hostPlatform.system}");
  });

  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    rev = "v${version}";
    hash = "sha256-fztQJrhDG5ZbTlgqoHA96eCgwYm5WIna3mAPlCDWYLM=";
  };

  # The workspace source for @oh-my-pi/pi-natives has no pre-built .node
  # binaries — those only exist in the npm tarball. Fetch it so we can copy
  # the platform binaries into packages/natives/native/ before the build.
  piNativesTarball = fetchzip {
    url = "https://registry.npmjs.org/@oh-my-pi/pi-natives/-/pi-natives-${version}.tgz";
    hash = "sha256-mEEnvTNxWFVSs1An61K83sSjUJ5bz4yrluwZvz1+6fg=";
    stripRoot = false;
  };

  srcWithBunNix = runCommand "oh-my-pi-src" {
    nativeBuildInputs = [ bun2nix bun_1_3_14 python3 ];
  } ''
    cp -r ${src} $out
    chmod -R u+w $out

    # Copy pre-built .node binaries from the npm tarball into the workspace
    # source so the runtime can load the native addon without building Rust.
    cp ${piNativesTarball}/package/native/*.node $out/packages/natives/native/

    bun2nix --lock-file $out/bun.lock --output-file $out/bun.nix

    python3 - "$out" << 'EOF'
import sys, re, json, os

root = sys.argv[1]
lock_path = os.path.join(root, "bun.lock")

raw = open(lock_path).read()
lock = json.loads(re.sub(r',(\s*[}\]])', r'\1', raw))

packages = lock.get("packages", {})
catalog  = lock.get("catalog", {})
catalogs = lock.get("catalogs", {})

# Build name -> exact resolved version from the packages section.
resolved = {}
for name, entry in packages.items():
    if isinstance(entry, list) and entry and isinstance(entry[0], str):
        spec = entry[0]
        if spec.startswith(name + "@"):
            resolved[name] = spec[len(name) + 1:]

def pin(name, spec):
    """Pin a dep specifier to its exact resolved version from bun.lock."""
    if not isinstance(spec, str):
        return spec
    # catalog: specifiers — resolve via catalog table then pinned version.
    if spec.startswith("catalog:"):
        cname = spec[len("catalog:"):]
        table = catalog if cname == "" else catalogs.get(cname, {})
        rv = resolved.get(name)
        cv = table.get(name)
        if isinstance(rv, str) and rv.startswith("workspace:"):
            return "workspace:*"
        if isinstance(rv, str):
            return rv
        if isinstance(cv, str):
            return cv
        return spec
    # Any npm version range — pin to exact resolved version.
    if not spec.startswith(("workspace:", "file:", "link:", "git", "http", "/")):
        rv = resolved.get(name)
        if isinstance(rv, str) and rv.startswith("workspace:"):
            return "workspace:*"
        if isinstance(rv, str):
            return rv
    return spec

sections = ["dependencies", "devDependencies", "peerDependencies", "optionalDependencies"]

def rewrite(holder):
    for sec in sections:
        deps = holder.get(sec)
        if isinstance(deps, dict):
            for name in list(deps):
                deps[name] = pin(name, deps[name])

# Rewrite bun.lock workspaces and drop the catalog tables.
for ws in lock.get("workspaces", {}).values():
    rewrite(ws)
lock.pop("catalog", None)
lock.pop("catalogs", None)
open(lock_path, "w").write(json.dumps(lock, indent=2) + "\n")

# Rewrite each workspace package.json (root "" included).
for ws_dir in lock.get("workspaces", {}):
    pkg_path = os.path.join(root, ws_dir, "package.json")
    if not os.path.exists(pkg_path):
        continue
    pkg = json.loads(open(pkg_path).read())
    rewrite(pkg)
    open(pkg_path, "w").write(json.dumps(pkg, indent=2) + "\n")
EOF
  '';
in

(bun2nix.writeBunApplication {
  pname = "omp";
  inherit version;

  src = srcWithBunNix;

  # oh-my-pi requires bun >=1.3.14 at runtime. writeBunApplication prepends
  # pkgs.bun (1.3.13) to PATH in the startup script, so we use an absolute
  # path to bun 1.3.14 instead of relying on PATH resolution.
  #
  # writeBunApplication's installPhase does `cd $out/share/$pname` before
  # exec, so $PWD is always the store path. OLDPWD is set by bash's cd to the
  # user's original directory. We cd back so omp's process.cwd() is correct,
  # and use an absolute path to the entry point so bun resolves modules from
  # the store regardless of cwd.
  # At this point the wrapper has already done `cd $out/share/omp`, so $PWD
  # is the store package dir and OLDPWD is the user's original directory.
  # Capture the store dir, cd back to the user's dir so omp's process.cwd()
  # is correct, then exec bun with an absolute path so module resolution
  # still works from the store.
  startScript = ''
    _omp_pkg="$PWD"
    cd "''${OLDPWD:-$PWD}"
    exec ${bun_1_3_14}/bin/bun run "$_omp_pkg/packages/coding-agent/src/cli.ts" "$@"
  '';

  dontUseBunBuild = true;
  dontUseBunCheck = true;

  # --offline: workaround for Bug 1 above (missing .npm manifest cache files).
  bunInstallFlags = [ "--offline" "--linker=isolated" "--ignore-scripts" ];

  # Generate the docs index embedded into the binary at build time.
  # The prepack script reads docs/**/*.md and emits docs-index.generated.ts.
  postBunNodeModulesInstallPhase = ''
    ${bun_1_3_14}/bin/bun run packages/coding-agent/scripts/generate-docs-index.ts
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = "${srcWithBunNix}/bun.nix";
  };

  meta = {
    description = "AI coding agent for the terminal — batteries included";
    homepage = "https://omp.sh";
    mainProgram = "omp";
  };
})
