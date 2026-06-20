#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq bun nix-prefetch

set -euo pipefail

cd "$(dirname "$0")"

echo "Fetching latest version info from npm..."
LATEST_VERSION=$(curl -s "https://registry.npmjs.org/opencode-antigravity-auth/latest" | jq -r .version)
echo "Latest version is: $LATEST_VERSION"

URL="https://registry.npmjs.org/opencode-antigravity-auth/-/opencode-antigravity-auth-${LATEST_VERSION}.tgz"

echo "Fetching tarball to calculate hash..."
# nix-prefetch-url outputs base32 sha256; convert to SRI
HASH=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $URL 2>/dev/null))
echo "New tarball hash: $HASH"

echo "Updating default.nix..."
sed -i "s/version = \".*\";/version = \"$LATEST_VERSION\";/" default.nix
sed -i "s|hash = \"sha256-.*\";|hash = \"$HASH\";|" default.nix

echo "Generating new bun.lock..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -sL "$URL" | tar xz -C "$TMPDIR"
pushd "$TMPDIR/package" > /dev/null
bun install --lockfile-only --no-progress
popd > /dev/null

cp "$TMPDIR/package/bun.lock" ./bun.lock

echo "Update complete! Remember to commit the changes:"
echo "  git add default.nix bun.lock"
