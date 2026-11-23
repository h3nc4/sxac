#!/bin/sh

# Builds sxac_<version>_<arch>.deb in the repository root. Run it on the oldest suite the package
# installs on, since dpkg-shlibdeps takes the builder's library versions as minimums.

set -eu

cd "$(dirname "$0")/../"

umask 022

# The UTC commit time sorts every build above the one before it, and the hash points at its source.
stamp="$(TZ=UTC git log -1 --format=%cd --date=format-local:%Y%m%d%H%M%S)"
commit="$(git rev-parse --short=8 HEAD)"
date="$(git log -1 --format=%cD)"
version="$(sed -n 's/^VERSION[[:space:]]*=[[:space:]]*//p' Makefile)+git${stamp}.${commit}"
arch="$(dpkg --print-architecture)"
deb="sxac_${version}_${arch}.deb"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
pkg="${work}/pkg"
doc="${pkg}/usr/share/doc/sxac"

export DEB_BUILD_MAINT_OPTIONS=hardening=+all
cppflags="$(dpkg-buildflags --get CPPFLAGS)"
cflags="$(dpkg-buildflags --get CFLAGS)"
ldflags="$(dpkg-buildflags --get LDFLAGS)"
make clean
make CPPFLAGS="${cppflags}" CFLAGS="${cflags}" LDFLAGS="${ldflags}"
make install DESTDIR="${pkg}" PREFIX=/usr
strip --remove-section=.comment --remove-section=.note "${pkg}/usr/bin/sxac"
gzip -9n "${pkg}/usr/share/man/man1/sxac.1"

mkdir -p "${doc}" "${pkg}/DEBIAN" "${work}/debian"
printf '%s\n' \
  'Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/' \
  'Upstream-Name: sxac' \
  'Source: https://github.com/h3nc4/sxac' \
  '' \
  'Files: *' \
  'Copyright: 2023-2024 Henrique Almeida <me@h3nc4.com>' \
  'License: GPL-3+' \
  ' On Debian systems, the full text of the GNU General Public License version 3' \
  ' can be found in /usr/share/common-licenses/GPL-3.' \
  >"${doc}/copyright"
printf '%s\n' \
  "sxac (${version}) unstable; urgency=medium" \
  '' \
  "  * Build of commit ${commit}." \
  '' \
  " -- Dreamweaver <me@h3nc4.com>  ${date}" |
  gzip -9n >"${doc}/changelog.gz"

# dpkg-shlibdeps reads the package list from debian/control, which a binary-only build lacks.
printf 'Source: sxac\n\nPackage: sxac\nArchitecture: any\n' >"${work}/debian/control"
deps="$(cd "${work}" && dpkg-shlibdeps -O pkg/usr/bin/sxac)"
size="$(du -sk "${pkg}/usr")"

printf '%s\n' \
  'Package: sxac' \
  "Version: ${version}" \
  "Architecture: ${arch}" \
  'Maintainer: Dreamweaver <me@h3nc4.com>' \
  "Installed-Size: ${size%%[[:space:]]*}" \
  "Depends: ${deps#shlibs:Depends=}" \
  'Section: x11' \
  'Priority: optional' \
  'Homepage: https://github.com/h3nc4/sxac' \
  'Description: simple X auto clicker' \
  ' sxac clicks a mouse button at a fixed interval through the XTest extension' \
  ' until it receives SIGINT or SIGTERM.' \
  >"${pkg}/DEBIAN/control"
(cd "${pkg}" && find usr -type f -exec md5sum {} +) >"${pkg}/DEBIAN/md5sums"

dpkg-deb --root-owner-group --build "${pkg}" "${deb}"
dpkg-deb --info "${deb}"
