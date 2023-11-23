import QtQuick 2.8
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import "../utils.js" as Utils

FocusScope {
    id: root
    property bool showBack: !recentScreen.focus && !systemsScreen.focus
    property bool showCollControls: softwareScreen.focus
    
    property var gameData: softwareList[sortByIndex].currentGame(currentScreenID)
    property string collectionShortName: Utils.processPlatformName(currentGame.collections.get(0).shortName)

    Item {
        id: background

        width: parent.width
        height: parent.height

        Behavior on opacity { NumberAnimation { duration: 200 }}

        Image {
            id: controllerIcon
            width: vpx(80)
            height: vpx(70)
            horizontalAlignment: Image.AlignLeft
            fillMode: Image.PreserveAspectFit
            source: collectionShortName ? "../assets/images/controllers/" + collectionShortName + ".svg" : "../assets/images/controllers/switch.svg"
            visible: false

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: vpx(25)
            }
        }

        ColorOverlay {
            anchors.fill: controllerIcon
            source: controllerIcon
            color: theme.text
            smooth: true
            cached: true
            visible: softwareScreen.focus || recentScreen.focus || favoritesScreen.focus
        }

        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            spacing: vpx(50)
            layoutDirection: Qt.RightToLeft

            ControllerHelpButton {
                id: buttonOK
                button: "btn_A"
                label: "OK"
                Layout.fillWidth: true
                Layout.minimumWidth: vpx(50)
                Layout.preferredWidth: vpx(50)
            }
            
            ControllerHelpButton {
                id: buttonBack
                button: "btn_B"
                label: "Back"
                Layout.fillWidth: true
                Layout.minimumWidth: vpx(50)
                Layout.preferredWidth: vpx(65)

                onClicked: { showRecentScreen(); }

                visible: showBack
            }
            
            ControllerHelpButton {
                id: buttonFavorite
                button: "btn_Y"
                label: "Favourite"
                Layout.fillWidth: true
                Layout.minimumWidth: vpx(100)
                Layout.preferredWidth: vpx(100)
                visible: softwareScreen.focus || recentScreen.focus || favoritesScreen.focus
            }
            
            ControllerHelpButton {
                id: buttonZoom
                button: "btn_X"
                label: "Zoom"
                Layout.fillWidth: true
                Layout.minimumWidth: vpx(50)
                Layout.preferredWidth: vpx(75)
                visible: softwareScreen.focus || favoritesScreen.focus
            }


            ControllerHelpButton {
                id: buttonNext
                button: "btn_R"
                label: "Next"
                Layout.fillWidth: true
                Layout.minimumWidth: vpx(70)
                Layout.preferredWidth: vpx(70)

                onClicked: {
                    turnOnSfx.play();
                    if (currentCollection < api.collections.count-1) {
                        nextCollection++;
                    } else {
                        nextCollection = -1;
                    }
                }

                visible: showCollControls
            }

            //Previous Collection Button
            ControllerHelpButton {
                id: buttonPrev
                button: "btn_L"
                label: "Previous"
                Layout.fillWidth: false
                Layout.minimumWidth: vpx(90)
                Layout.preferredWidth: vpx(90)

                onClicked: {
                    turnOffSfx.play();
                    if (currentCollection == -1) {
                        nextCollection = api.collections.count-1;
                    } else{ 
                        nextCollection--;
                    }
                }

                visible: showCollControls
            }

        }

    }//background
}//root
