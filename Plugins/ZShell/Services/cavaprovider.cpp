#include "cavaprovider.hpp"

#include "audiocollector.hpp"
#include "audioprovider.hpp"
#include <algorithm>
#include <cava/cavacore.h>
#include <cmath>
#include <cstddef>
#include <qdebug.h>

namespace ZShell::services {

CavaProcessor::CavaProcessor(QObject* parent)
	: AudioProcessor(parent)
	, m_plan(nullptr)
	, m_in(new double[ac::CHUNK_SIZE])
	, m_out(nullptr)
	, m_bars(0) {
};

CavaProcessor::~CavaProcessor() {
	cleanup();
	delete[] m_in;
}

void CavaProcessor::process() {
	if (!m_plan || m_bars == 0 || !m_out) {
		return;
	}

	const int count = static_cast<int>(AudioCollector::instance().readChunk(m_in));

	// Process in data via cava
	cava_execute(m_in, count, m_out, m_plan);

	// Apply monstercat filter
	QVector<double> values(m_bars);

	for(int i = 0; i < m_bars; ++i) {
		values[i] = std::clamp(m_out[i], 0.0, 1.0);
	}

	// --- spectral contrast (removes the "everything rises together" effect)
	QVector<double> tmp = values;
	auto* b = tmp.data();
	auto* e = b + tmp.size();

	auto pct = [&](double p) -> double {
			   const qsizetype n = tmp.size();
			   if (n <= 0) return 0.0;

			   // p in [0,1] -> index in [0, n-1]
			   const double pos = p * double(n - 1);
			   qsizetype k = static_cast<qsizetype>(std::llround(pos));
			   k = std::clamp<qsizetype>(k, 0, n - 1);

			   auto first = tmp.begin();
			   auto nth   = first + k;
			   std::nth_element(first, nth, tmp.end());
			   return *nth;
		   };

	const double floor = pct(0.25);
	const double ceil  = pct(0.95);
	const double range = std::max(1e-6, ceil - floor);

	const double gamma = 1.6; // 1.3..2.2 range; higher = more contrast
	for (int i = 0; i < m_bars; ++i) {
		double x = (values[i] - floor) / range;
		x = std::clamp(x, 0.0, 1.0);
		values[i] = std::pow(x, gamma);
	}

	// Update values
	if (values != m_values) {
		m_values = std::move(values);
		emit valuesChanged(m_values);
	}
}

void CavaProcessor::setBars(int bars) {
	if (bars < 0) {
		qWarning() << "CavaProcessor::setBars: bars must be greater than 0. Setting to 0.";
		bars = 0;
	}

	if (m_bars != bars) {
		m_bars = bars;
		reload();
	}
}

void CavaProcessor::reload() {
	cleanup();
	initCava();
}

void CavaProcessor::cleanup() {
	if (m_plan) {
		cava_destroy(m_plan);
		m_plan = nullptr;
	}

	if (m_out) {
		delete[] m_out;
		m_out = nullptr;
	}
}

void CavaProcessor::initCava() {
	if (m_plan || m_bars == 0) {
		return;
	}

	m_plan = cava_init(m_bars, ac::SAMPLE_RATE, 1, 0, 0.55, 50, 10000);
	m_out = new double[static_cast<size_t>(m_bars)];
}

CavaProvider::CavaProvider(QObject* parent)
	: AudioProvider(parent)
	, m_bars(0)
	, m_values(m_bars, 0.0) {
	m_processor = new CavaProcessor();
	init();

	connect(static_cast<CavaProcessor*>(m_processor), &CavaProcessor::valuesChanged, this, &CavaProvider::updateValues);
}

int CavaProvider::bars() const {
	return m_bars;
}

void CavaProvider::setBars(int bars) {
	if (bars < 0) {
		qWarning() << "CavaProvider::setBars: bars must be greater than 0. Setting to 0.";
		bars = 0;
	}

	if (m_bars == bars) {
		return;
	}

	m_values.resize(bars, 0.0);
	m_bars = bars;
	emit barsChanged();
	emit valuesChanged();

	QMetaObject::invokeMethod(
		static_cast<CavaProcessor*>(m_processor), &CavaProcessor::setBars, Qt::QueuedConnection, bars);
}

QVector<double> CavaProvider::values() const {
	return m_values;
}

void CavaProvider::updateValues(QVector<double> values) {
	if (values != m_values) {
		m_values = values;
		emit valuesChanged();
	}
}

} // namespace ZShell::services
