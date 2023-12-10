EAPI=8

inherit git-r3

DESCRIPTION="Powkiddy X55 joystick tools"
HOMEPAGE="https://github.com/vognev/remotepad"
EGIT_REPO_URI="${HOMEPAGE}"

KEYWORDS="*"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="
	dev-python/python-evdev
"

src_install() {
	mkdir -p "${ED}/usr/bin" "${ED}/etc/systemd/system"

	install -Dm755 remotepad-client.py -T "${ED}/usr/bin/remotepad-client"
	install -Dm755 remotepad-server.py -T "${ED}/usr/bin/remotepad-server"
	install -Dm755 powkiddy-mapper.py  -T "${ED}/usr/bin/powkiddy-mapper"
	install -Dm644 powkiddy-mapper.service -Dt "${ED}/etc/systemd/system"
}

