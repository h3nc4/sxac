#!/bin/sh

# Prints the dev image .devcontainer.json pins. That file is the only place this repository
# names the image, so CI reads it from there rather than keeping a copy of its own. Renovate's
# devcontainer manager is what moves the pin, since nothing here publishes the image.

set -eu

cd "$(dirname "$0")/../"

ref="$(
  sed -n 's/^[[:space:]]*"image"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    .devcontainer.json | head -n 1
)"

if [ -z "${ref}" ]; then
  echo "no image key in .devcontainer.json" >&2
  exit 1
fi

# A reference with no tag pulls whatever latest happens to be, which is the opposite of a pin.
case "${ref##*/}" in
  *:?*) ;;
  *)
    echo "the image in .devcontainer.json is '${ref}', which carries no tag" >&2
    exit 1
    ;;
esac

printf '%s\n' "${ref}"
