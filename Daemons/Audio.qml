pragma Singleton

import qs.Config
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    property string previousSinkName: ""
    property string previousSourceName: ""

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: []
    })

    readonly property list<PwNode> sinks: nodes.sinks
    readonly property list<PwNode> sources: nodes.sources

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property bool sourceMuted: !!source?.audio?.muted
    readonly property real sourceVolume: source?.audio?.volume ?? 0

    function setVolume(newVolume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(100, newVolume));
        }
    }

    function incrementVolume(amount: real): void {
        setVolume(volume + (amount || 5));
    }

    function decrementVolume(amount: real): void {
        setVolume(volume - (amount || 5));
    }

    function setSourceVolume(newVolume: real): void {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(100, newVolume));
        }
    }

    function incrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume + (amount || 5));
    }

    function decrementSourceVolume(amount: real): void {
        setSourceVolume(sourceVolume - (amount || 5));
    }

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

	function setAppAudioVolume(appStream: PwNode, newVolume: real): void {
		if ( appStream?.ready && appStream?.audio ) {
			appStream.audio.muted = false;
			appStream.audio.volume = Math.max(0, Math.min(100, newVolume));
		}
	}

    onSinkChanged: {
        if (!sink?.ready)
            return;

        const newSinkName = sink.description || sink.name || qsTr("Unknown Device");

        previousSinkName = newSinkName;
    }

    onSourceChanged: {
        if (!source?.ready)
            return;

        const newSourceName = source.description || source.name || qsTr("Unknown Device");

        previousSourceName = newSourceName;
    }

    Component.onCompleted: {
        previousSinkName = sink?.description || sink?.name || qsTr("Unknown Device");
        previousSourceName = source?.description || source?.name || qsTr("Unknown Device");
    }

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources]
    }

	PwNodeLinkTracker {
		id: sinkLinkTracker
		node: root.sink
	}

	PwObjectTracker {
		objects: root.appStreams
	}

	readonly property var appStreams: {
		var defaultSink = root.sink;
		var defaultSinkId = defaultSink.id;
		var connectedStreamIds = {};
		var connectedStreams = [];

		if ( !sinkLinkTracker.linkGroups ) {
			return [];
		}

		var linkGroupsCount = 0;
		if (sinkLinkTracker.linkGroups.length !== undefined) {
			linkGroupsCount = sinkLinkTracker.linkGroups.length;
		} else if (sinkLinkTracker.linkGroups.count !== undefined) {
			linkGroupsCount = sinkLinkTracker.linkGroups.count;
		} else {
			return [];
		}

		if ( linkGroupsCount === 0 ) {
			return [];
		}

		var intermediateNodeIds = {};
		var nodesToCheck = [];

		for (var i = 0; i < linkGroupsCount; i++) {
			var linkGroup;
			if (sinkLinkTracker.linkGroups.get) {
				linkGroup = sinkLinkTracker.linkGroups.get(i);
			} else {
				linkGroup = sinkLinkTracker.linkGroups[i];
			}

			if (!linkGroup || !linkGroup.source) {
				continue;
			}

			var sourceNode = linkGroup.source;

			if (sourceNode.isStream && sourceNode.audio) {
				if (!connectedStreamIds[sourceNode.id]) {
					connectedStreamIds[sourceNode.id] = true;
					connectedStreams.push(sourceNode);
				}
			} else {
				intermediateNodeIds[sourceNode.id] = true;
				nodesToCheck.push(sourceNode);
			}
		}

		if (nodesToCheck.length > 0 || connectedStreams.length === 0) {
			try {
				var allNodes = [];
				if (Pipewire.nodes) {
					if (Pipewire.nodes.count !== undefined) {
						var nodeCount = Pipewire.nodes.count;
						for (var n = 0; n < nodeCount; n++) {
							var node;
							if (Pipewire.nodes.get) {
								node = Pipewire.nodes.get(n);
							} else {
								node = Pipewire.nodes[n];
							}
							if (node)
								allNodes.push(node);
						}
					} else if (Pipewire.nodes.values) {
						allNodes = Pipewire.nodes.values;
					}
				}

				for (var j = 0; j < allNodes.length; j++) {
					var node = allNodes[j];
					if (!node || !node.isStream || !node.audio) {
						continue;
					}

					var streamId = node.id;
					if (connectedStreamIds[streamId]) {
						continue;
					}

					if (Object.keys(intermediateNodeIds).length > 0) {
						connectedStreamIds[streamId] = true;
						connectedStreams.push(node);
					} else if (connectedStreams.length === 0) {
						connectedStreamIds[streamId] = true;
						connectedStreams.push(node);
					}
				}
			} catch (e)
			{}
		}
		return connectedStreams;
	}
}
