#include "writefile.hpp"

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtQuick/qquickitemgrabresult.h>
#include <QtQuick/qquickwindow.h>
#include <qdir.h>
#include <qfileinfo.h>
#include <qfuturewatcher.h>
#include <qqmlengine.h>

namespace ZShell {

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path) {
    this->saveItem(target, path, QRect(), QJSValue(), QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect) {
    this->saveItem(target, path, rect, QJSValue(), QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved) {
    this->saveItem(target, path, QRect(), onSaved, QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, QJSValue onSaved, QJSValue onFailed) {
    this->saveItem(target, path, QRect(), onSaved, onFailed);
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect, QJSValue onSaved) {
    this->saveItem(target, path, rect, onSaved, QJSValue());
}

void ZShellIo::saveItem(QQuickItem* target, const QUrl& path, const QRect& rect, QJSValue onSaved, QJSValue onFailed) {
    if (!target) {
        qWarning() << "ZShellIo::saveItem: a target is required";
        return;
    }

    if (!path.isLocalFile()) {
        qWarning() << "ZShellIo::saveItem:" << path << "is not a local file";
        return;
    }

    if (!target->window()) {
        qWarning() << "ZShellIo::saveItem: unable to save target" << target << "without a window";
        return;
    }

    auto scaledRect = rect;
    const qreal scale = target->window()->devicePixelRatio();
    if (rect.isValid() && !qFuzzyCompare(scale + 1.0, 2.0)) {
        scaledRect =
            QRectF(rect.left() * scale, rect.top() * scale, rect.width() * scale, rect.height() * scale).toRect();
    }

    const QSharedPointer<const QQuickItemGrabResult> grabResult = target->grabToImage();

    QObject::connect(grabResult.data(), &QQuickItemGrabResult::ready, this,
        [grabResult, scaledRect, path, onSaved, onFailed, this]() {
            const auto future = QtConcurrent::run([=]() {
                QImage image = grabResult->image();

                if (scaledRect.isValid()) {
                    image = image.copy(scaledRect);
                }

                const QString file = path.toLocalFile();
                const QString parent = QFileInfo(file).absolutePath();
                return QDir().mkpath(parent) && image.save(file);
            });

            auto* watcher = new QFutureWatcher<bool>(this);
            auto* engine = qmlEngine(this);

            QObject::connect(watcher, &QFutureWatcher<bool>::finished, this, [=]() {
                if (watcher->result()) {
                    if (onSaved.isCallable()) {
                        onSaved.call(
                            { QJSValue(path.toLocalFile()), engine->toScriptValue(QVariant::fromValue(path)) });
                    }
                } else {
                    qWarning() << "ZShellIo::saveItem: failed to save" << path;
                    if (onFailed.isCallable()) {
                        onFailed.call({ engine->toScriptValue(QVariant::fromValue(path)) });
                    }
                }
                watcher->deleteLater();
            });
            watcher->setFuture(future);
        });
}

bool ZShellIo::copyFile(const QUrl& source, const QUrl& target, bool overwrite) const {
    if (!source.isLocalFile()) {
        qWarning() << "ZShellIo::copyFile: source" << source << "is not a local file";
        return false;
    }
    if (!target.isLocalFile()) {
        qWarning() << "ZShellIo::copyFile: target" << target << "is not a local file";
        return false;
    }

    if (overwrite) {
        if (!QFile::remove(target.toLocalFile())) {
            qWarning() << "ZShellIo::copyFile: overwrite was specified but failed to remove" << target.toLocalFile();
            return false;
        }
    }

    return QFile::copy(source.toLocalFile(), target.toLocalFile());
}

bool ZShellIo::deleteFile(const QUrl& path) const {
    if (!path.isLocalFile()) {
        qWarning() << "ZShellIo::deleteFile: path" << path << "is not a local file";
        return false;
    }

    return QFile::remove(path.toLocalFile());
}

QString ZShellIo::toLocalFile(const QUrl& url) const {
    if (!url.isLocalFile()) {
        qWarning() << "ZShellIo::toLocalFile: given url is not a local file" << url;
        return QString();
    }

    return url.toLocalFile();
}

} // namespace ZShell
