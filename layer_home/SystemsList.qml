import QtQuick 2.15
import QtGraphicalEffects 1.12
import "../global"
import "../Lists"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils


ListView {
    id: collectionsLayout
    //anchors.fill: parent
    property int _index: 0
    spacing: vpx(14)
    orientation: ListView.Horizontal
    
    displayMarginBeginning: vpx(107)
    displayMarginEnd: vpx(107)

    preferredHighlightBegin: vpx(0)
    preferredHighlightEnd: vpx(1077)
    highlightRangeMode: ListView.StrictlyEnforceRange // Highlight never moves outside the range
    snapMode: ListView.SnapToItem
    highlightMoveDuration: 100
    highlightMoveVelocity: -1
    keyNavigationWraps: true
    
    NumberAnimation { id: anim; property: "scale"; to: 0.7; duration: 100 }

    model: gamesListModel
    delegate: recentListDelegate

    Component {
        id: recentListDelegate
        Rectangle {
            id: wrapper

            property bool selected: ListView.isCurrentItem
            property var systemData: api.collections.get(idx)
            property bool isGame: idx >= 0

            onSystemDataChanged: { if (selected) updateData() }
            onSelectedChanged: { if (selected) updateData() }

            function updateData() {
                currentGame = systemData;
                currentScreenID = idx;
            }

            width: collectionsLayout.height//collectionsLayout.height : collectionsLayout.height*0.7
            height: width
            color: "transparent"

            anchors.verticalCenter: parent.verticalCenter

            Rectangle{
                id: background
                width: collectionsLayout.height // collectionsLayout.height*0.7
                height: width
                radius: 0
                opacity: 1
                color: theme.button
                layer.enabled: enableDropShadows
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 0
                    color: "#4D000000"
                    radius: 3.0
                    samples: 6
                    z: -2
                }
                
                anchors.centerIn: parent
                
            }

            // Preference order for Game Backgrounds
            property var gameBG: {
                return getGameBackground(systemData, settings.gameBackground);
            }

            Image {
                id: gameImage
                width: collectionsLayout.height
                height: width
                smooth: true
                fillMode: Image.PreserveAspectCrop
                source: "../assets/images/systems/" + systemData.shortName  + ".jpg"
                asynchronous: true
                sourceSize { width: 512; height: 512 }
                
                anchors.centerIn: parent
            }

            //white overlay on screenshot for better logo visibility over screenshot
            Rectangle {
                width: gameImage.width
                height: gameImage.height
                color: "white"
                opacity: 0.15
                visible: logo.source != "" && gameImage.source != ""
            }

            MouseArea {
                anchors.fill: gameImage
                hoverEnabled: true
                onEntered: {}
                onExited: {}
                onClicked: {
                    if (selected) {
                        anim.start();
                        navigateToSystem();
                    }
                    else
                        navSound.play();
                        homeSwitcher.currentIndex = index
                        homeSwitcher.focus = true
                        buttonMenu.focus = false

                }
            }

            Text {
                id: topTitle
                text: systemData.name // name
                color: theme.accent
                font.family: titleFont.name
                font.pixelSize: Math.round(screenheight*0.035)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                //clip: true
                //elide: Text.ElideRight

                anchors {
                    horizontalCenter: gameImage.horizontalCenter
                    bottom: gameImage.top; bottomMargin: Math.round(screenheight*0.025)
                }

                opacity: wrapper.ListView.isCurrentItem ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 75 } }
            }

            Component.onCompleted: {
                if (wordWrap) {
                    if (topTitle.paintedWidth > gameImage.width * 1.70) {
                        topTitle.width = gameImage.width * 1.5
                    }
                }
            }

            HighlightBorder {
                id: highlightBorder
                width: gameImage.width + vpx(18)//vpx(274)
                height: width//vpx(274)
                
                anchors.centerIn: parent
                

                x: vpx(-9)
                y: vpx(-9)
                z: -1

                selected: wrapper.ListView.isCurrentItem
            }

        }
    }

    Keys.onLeftPressed: {
        navSound.play();
        decrementCurrentIndex();
    }
    Keys.onRightPressed: {
        navSound.play();
        incrementCurrentIndex();
    }

    Keys.onUpPressed:{
        borderSfx.play();
    }

    Keys.onDownPressed: {
        _index = currentIndex;
        navSound.play();
        allSoftwareButton.focus = true
        homeSwitcher.currentIndex = -1
    }


    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            navigateToSystem();
        }
    }
    
    function navigateToSystem(){
        anim.start();
        nextCollection = currentScreenID;
        showSoftwareScreen();
    }
}

