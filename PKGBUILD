pkgname='zshell'
pkgver=0.1.0
pkgrel=1
pkgdesc='The cli for zshell'
arch=('any')
url='https://github.com/Zacharias-Brohn/z-bar-qt'
license=('GPL-3.0-only')
depends=('python' 'python-pillow' 'python-materialyoucolor' 'libnotify' 'swappy' 'dart-sass'
	'app2unit' 'wl-clipboard' 'dconf' 'cliphist')
makedepends=('python-build' 'python-installer' 'python-hatch' 'python-hatch-vcs')
source=("$pkgname::git+$url.git")
sha256sums=('SKIP')

build() {
	cd "${srcdir}/${pkgname}/cli"
	python -m build --wheel --no-isolation

	cd ..
	cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/
	cmake --build build
}

package() {
	cd "${srcdir}/${pkgname}/cli"
	python -m installer --destdir="$pkgdir" dist/*.whl

	cd ..
	DESTDIR="$pkgdir" cmake --install build
}
