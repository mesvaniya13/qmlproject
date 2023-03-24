
MediaPlayer {
        id: mediaPlayer

        function updateMetadata() {
            metadataInfo.clear();
            metadataInfo.read(mediaPlayer.metaData);
            metadataInfo.read(mediaPlayer.audioTracks[mediaPlayer.activeAudioTrack]);
            metadataInfo.read(mediaPlayer.videoTracks[mediaPlayer.activeVideoTrack]);
        }

        videoOutput: videoOutput


 video out 

 VideoOutput {
        id: videoOutput

        property bool fullScreen: false

        anchors.top: fullScreen ? parent.top : menuBar.bottom
        anchors.bottom: playbackControl.top
        anchors.left: parent.left
        anchors.right: parent.right

        TapHandler {
            onDoubleTapped: {
                parent.fullScreen ?  showNormal() : showFullScreen()
                parent.fullScreen = !parent.fullScreen
            }
            onTapped: {
                metadataInfo.visible = false
                audioTracksInfo.visible = false
                videoTracksInfo.visible = false
                subtitleTracksInfo.visible = false
            }
        }
    }


 accessing the video part

required property MediaPlayer mediaPlayer
    required property VideoOutput videoOutput
    required property MetadataInfo metadataInfo
    required property TracksInfo audioTracksInfo
    required property TracksInfo videoTracksInfo
    required property TracksInfo subtitleTracksInfo


file dialog box

FileDialog {
        id: fileDialog
        title: "Please choose a file"
        onAccepted: {
            mediaPlayer.stop()
            mediaPlayer.source = fileDialog.currentFile
            mediaPlayer.play()
        }
    }


menu file

 MenuBar {
        id: menuBar
        anchors.left: parent.left
        anchors.right: parent.right

        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&Open")
                onTriggered: fileDialog.open()

url functions
 
function loadUrl(url) {
        mediaPlayer.stop()
        mediaPlayer.source = url
        mediaPlayer.play()
    }


updateMetadata():

        function updateMetadata() {
            metadataInfo.clear();
            metadataInfo.read(mediaPlayer.metaData);
            metadataInfo.read(mediaPlayer.audioTracks[mediaPlayer.activeAudioTrack]);
            metadataInfo.read(mediaPlayer.videoTracks[mediaPlayer.activeVideoTrack]);
 called in the following places:

        onMetaDataChanged: { updateMetadata() }
        onTracksChanged: {
            audioTracksInfo.read(mediaPlayer.audioTracks);
            audioTracksInfo.selectedTrack = mediaPlayer.activeAudioTrack;
            videoTracksInfo.read(mediaPlayer.videoTracks);
            videoTracksInfo.selectedTrack = mediaPlayer.activeVideoTrack;
            subtitleTracksInfo.read(mediaPlayer.subtitleTracks);
            subtitleTracksInfo.selectedTrack = mediaPlayer.activeSubtitleTrack;
            updateMetadata()
        }
read() function

    function read(metadata) {
        if (metadata) {
            for (var key of metadata.keys()) {
                if (metadata.stringValue(key)) {
                    elements.append(
                                { name: metadata.metaDataKeyToString(key)
                                , value: metadata.stringValue(key)
                                })
                }
            }
        }
    }


 function read(metadataList) {
        var LanguageKey = 6;

        elements.clear()

        elements.append(
                    { language: "No Selected Track"
                    , trackNumber: -1
                    })

        if (!metadataList)
            return;

        metadataList.forEach(function (metadata, index) {
            var language = metadata.stringValue(LanguageKey);
            var label = language ? metadata.stringValue(LanguageKey) : "track " + (index + 1)
            elements.append(
                        { language: label
                        , trackNumber: index
                        })
        });
    }
To set a track, 

        ListView {
            id: trackList
            visible: elements.count > 0
            anchors.fill: parent
            model: elements
            delegate: RowLayout {
                width: trackList.width
                RadioButton {
                    checked: model.trackNumber === selectedTrack
                    text: model.language
                    ButtonGroup.group: group
                    onClicked: selectedTrack = model.trackNumber
                }
            }
        }
The onSelectectedTrackChanged signal

        id: audioTracksInfo

        anchors.right: parent.right
        anchors.top: videoOutput.fullScreen ? parent.top : menuBar.bottom
        anchors.bottom: playbackControl.opacity ? playbackControl.bottom : parent.bottom

        visible: false
        onSelectedTrackChanged:  mediaPlayer.activeAudioTrack = audioTracksInfo.selectedTrack

property definitions.

    required property MediaPlayer mediaPlayer
    property int mediaPlayerState: mediaPlayer.playbackState

Connections:

        target: mediaPlayer
        function onPlaybackStateChanged() { updateOpacity() }
        function onHasVideoChanged() { updateOpacity() }
    }

buttons:

 RoundButton {
                        id: pauseButton
                        radius: 50.0
                        text: "\u2016";
                        onClicked: mediaPlayer.pause()
                    }

                    RoundButton {
                        id: playButton
                        radius: 50.0
                        text: "\u25B6";
                        onClicked: mediaPlayer.play()
                    }

                    RoundButton {
                        id: stopButton
                        radius: 50.0
                        text: "\u25A0";
                        onClicked: mediaPlayer.stop()
                    }
                }
Playback states

        State {
            name: "playing"
            when: mediaPlayerState == MediaPlayer.PlayingState
            PropertyChanges { target: pauseButton; visible: true}
            PropertyChanges { target: playButton; visible: false}
            PropertyChanges { target: stopButton; visible: true}
        },
        State {
            name: "stopped"
            when: mediaPlayerState == MediaPlayer.StoppedState
            PropertyChanges { target: pauseButton; visible: false}
            PropertyChanges { target: playButton; visible: true}
            PropertyChanges { target: stopButton; visible: false}
        },
        State {
            name: "paused"
            when: mediaPlayerState == MediaPlayer.PausedState
            PropertyChanges { target: pauseButton; visible: false}
            PropertyChanges { target: playButton; visible: true}
            PropertyChanges { target: stopButton; visible: true}
        }
    ]


 MediaPlayer's position property like so:

        Text {
            id: mediaTime
            Layout.minimumWidth: 50
            Layout.minimumHeight: 18
            horizontalAlignment: Text.AlignRight
            text: {
                var m = Math.floor(mediaPlayer.position / 60000)
                var ms = (mediaPlayer.position / 1000 - m * 60).toFixed(1)
                return `${m}:${ms.padStart(4, 0)}`
            }
        }
mediaSlider uses the MediaPlayer seekable

        Slider {
            id: mediaSlider
            Layout.fillWidth: true
            enabled: mediaPlayer.seekable
            to: 1.0
            value: mediaPlayer.position / mediaPlayer.duration

            onMoved: mediaPlayer.setPosition(value * mediaPlayer.duration)
        }


 playback rate control:

 Slider {
            id: slider
            Layout.fillWidth: true
            snapMode: Slider.SnapOnRelease
            enabled: true
            from: 0.5
            to: 2.5
            stepSize: 0.5
            value: 1.0

            onMoved: { mediaPlayer.setPlaybackRate(value) }

audio outputs:

required property MediaPlayer mediaPlayer
    property bool muted: false
    property real volume: volumeSlider.value/100.

    implicitHeight: buttons.height

    RowLayout {
        anchors.fill: parent

        Item {
            id: buttons

            width: muteButton.implicitWidth
            height: muteButton.implicitHeight

            RoundButton {
                id: muteButton
                radius: 50.0
                icon.source: muted ? "qrc:///Mute_Icon.svg" : "qrc:///Speaker_Icon.svg"
                onClicked: { muted = !muted }
            }
        }

        Slider {
            id: volumeSlider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            enabled: true
            to: 100.0
            value: 100.0
        }
        Text {
            text: "Rate " + slider.value + "x"
}
