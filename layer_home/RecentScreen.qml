import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.11
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils
//import QtQml 2.0

FocusScope {
    id: root

    // Build the games list but with extra menu options at the start and end
    ListModel {
    id: gamesListModel

        property var activeCollection: listRecent.games

        Component.onCompleted: {
            clear();
            buildList();
        }

        onActiveCollectionChanged: {
            clear();
            buildList();
        }

        function buildList() {
            for(var i=0; i<activeCollection.count; i++) {
                append(createListElement(i));
            };

            append({
                "name":         "All Software",
                "idx":          -3,
                "icon":         "../assets/images/allsoft_icon.svg",
                "background":   ""
            });
        }

        function createListElement(i) {
            return {
                name:       listRecent.games.get(i).title,
                idx:        i,
                icon:       listRecent.games.get(i).assets.logo,
                background: listRecent.games.get(i).assets.screenshots[0]
            }
        }
    }

    Item {
        id: recentScreenContainer
        width: parent.width
        height: parent.height

        property var batteryStatus: isNaN(api.device.batteryPercent) ? "" : parseInt(api.device.batteryPercent*100);

        Item {
        id: topbar

            
            height: Math.round(screenheight * 0.2569)
            anchors {
                left: parent.left; leftMargin: vpx(60)
                right: parent.right; rightMargin: vpx(60)
                top: parent.top; topMargin: Math.round(screenheight * 0.0472)
            }

            // Top bar
            Image {
                id: profileIcon
                anchors {
                    top: parent.top;
                    left: parent.left;
                }
                width: Math.round(screenheight * 0.0833)
                height: width
                source: "../assets/images/profile_icon.png"
                sourceSize { width: 128; height:128 }
                smooth: true
                antialiasing: true
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
            }

            Text {
                    id: collectionRecentTitle
                    text: currentCollection == -1 ? "" : api.collections.get(currentCollection).name
                    color: theme.text
                    font.family: titleFont.name
                    font.pixelSize: Math.round(screenheight*0.0277)
                    font.bold: true
                    anchors {
                        verticalCenter: profileIcon.verticalCenter
                        left: profileIcon.right; leftMargin: vpx(12)
                    }
                }
            
            RowLayout {
                spacing: vpx(20)
                anchors {
                        verticalCenter: profileIcon.verticalCenter;
                        right: parent.right; rightMargin: vpx(15)
                    }
                Text {
                    id: sysTime

                    //12HR-"h:mmap" 24HR-"hh:mm"
                    property var timeSetting: (settings.timeFormat === "12hr") ? "h:mmap" : "hh:mm";

                    function set() {
                        sysTime.text = Qt.formatTime(new Date(), timeSetting) 
                    }

                    Timer {
                        id: textTimer
                        interval: 60000 // Run the timer every minute
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: sysTime.set()
                    }

                    onTimeSettingChanged: sysTime.set()

                    // anchors {
                    //     verticalCenter: profileIcon.verticalCenter;
                    //     right: parent.right; rightMargin: vpx(15)
                    // }
                    color: theme.text
                    font.family: titleFont.name
                    font.weight: Font.Bold
                    font.letterSpacing: 4
                    font.pixelSize: Math.round(screenheight*0.0277)
                    horizontalAlignment: Text.Right
                    font.capitalization: Font.SmallCaps
                }

                RowLayout {
                    anchors {
                        bottom: parent.bottom;
                    }

                    Text {
                        id: batteryPercentage

                        function set() {
                            batteryPercentage.text = recentScreenContainer.batteryStatus+"%";
                        }

                        Timer {
                            id: percentTimer
                            interval: 60000 // Run the timer every minute
                            repeat: isNaN(api.device.batteryPercent) ? false : showPercent
                            running: isNaN(api.device.batteryPercent) ? false : showPercent
                            triggeredOnStart: isNaN(api.device.batteryPercent) ? "" : showPercent
                            onTriggered: batteryPercentage.set()
                        }

                        color: theme.text
                        font.family: titleFont.name
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        font.pixelSize: Math.round(screenheight*0.0277)
                        horizontalAlignment: Text.Right
                        Component.onCompleted: font.capitalization = Font.SmallCaps
                        //font.capitalization: Font.SmallCaps
                        visible: isNaN(api.device.batteryPercent) ? false : showPercent
                    }

                    BatteryIcon{
                        id: batteryIcon
                        width: Math.round(screenheight * 0.0433)
                        height: width / 1.5
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: theme.text
                            antialiasing: true
                            cached: true
                        }

                        function set() {
                            batteryIcon.level = recentScreenContainer.batteryStatus;
                        }

                        Timer {
                            id: iconTimer
                            interval: 60000 // Run the timer every minute
                            repeat: true
                            running: true
                            triggeredOnStart: true
                            onTriggered: batteryIcon.set()
                        }

                        visible: isNaN(api.device.batteryPercent) ? false : true

                        
                    }

                    Row {

                        Image{
                            id: chargingIcon

                            property bool chargingStatus: api.device.batteryCharging

                            width: height/2
                            height: sysTime.paintedHeight
                            fillMode: Image.PreserveAspectFit
                            source: "../assets/images/charging.svg"
                            sourceSize.width: 32
                            sourceSize.height: 64
                            smooth: true
                            horizontalAlignment: Image.AlignLeft
                            visible: chargingStatus && batteryIcon.level < 99
                            layer.enabled: true
                            layer.effect: ColorOverlay {
                                color: theme.text
                                antialiasing: true
                                cached: true
                            }

                            function set() {
                                chargingStatus = api.device.batteryCharging;
                            }

                            Timer {
                                id: chargingIconTimer
                                interval: 10000 // Run the timer every minute
                                repeat: isNaN(api.device.batteryPercent) ? false : true
                                running: isNaN(api.device.batteryPercent) ? false : true
                                triggeredOnStart: isNaN(api.device.batteryPercent) ? false : true
                                onTriggered: chargingIcon.set()
                            }

                        }
                    }

                }
             
            }
        }


        // Recent menu
        RecentList {
            id: recentSwitcher
            anchors {
                left: parent.left; leftMargin: vpx(98)
                right: parent.right
                top: topbar.bottom;
            }
            height: Math.round(screenheight * 0.3555)
            focus: true
            
        }

        // Button menu
        RowLayout {
            id: buttonMenu
            spacing: vpx(22)

            anchors {
                top: recentSwitcher.bottom;
                bottom: parent.bottom
            }

            Keys.onUpPressed: {
                navSound.play();
                recentSwitcher.focus = true
                recentSwitcher.currentIndex = recentSwitcher._index
            }

            Keys.onDownPressed:{
                borderSfx.play();
            }

            x: parent.width/2 - buttonMenu.width/2
            
            // MenuButton {
            //     id: allSoftwareButton
            //     width: vpx(86); height: vpx(100)
            //     label: "All Software"
            //     autoColor: false
            //     icon: "../assets/images/allsoft_icon_blue.svg"

            //     Keys.onPressed: {
            //         if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            //             event.accepted = true;
            //             selectSfx.play();
            //             showSoftwareScreen();
            //         }
            //     }

            //     Keys.onLeftPressed:{
            //         borderSfx.play();
            //     }

            //     Keys.onRightPressed:{
            //         navSound.play();
            //         favoriteButton.focus = true
            //     }

            //     onClicked: {
            //         if (allSoftwareButton.focus) {
            //             selectSfx.play();
            //             showSoftwareScreen();
            //         }
            //         else
            //             allSoftwareButton.focus = true;
            //             navSound.play();
            //             recentSwitcher.currentIndex = -1;
            //     }
            // }
            
            MenuButton {
                id: favoriteButton
                width: vpx(86); height: vpx(100)
                label: "Favourites"
                autoColor: false
                icon: "../assets/images/heart.png"

                Keys.onPressed: {
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        selectSfx.play();
                        showFavoritesScreen();
                    }
                }

                Keys.onLeftPressed:{
                    navSound.play();
                    // allSoftwareButton.focus = true
                    settingsButton.focus = true
                }

                Keys.onRightPressed:{
                    navSound.play();
                    systemsButton.focus = true
                }

                onClicked: {
                    if (favoriteButton.focus) {
                        selectSfx.play();
                        showFavoritesScreen();
                    }
                    else
                        favoriteButton.focus = true;
                        navSound.play();
                        recentSwitcher.currentIndex = -1;
                }
            }
            
            MenuButton {
                id: systemsButton
                width: vpx(86); height: vpx(100)
                label: "Systems"
                autoColor: false
                icon: "../assets/images/systems.png"

                Keys.onPressed: {
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        selectSfx.play();
                        showSystemsScreen();
                    }
                }

                Keys.onLeftPressed:{
                    navSound.play();
                    favoriteButton.focus = true
                }

                Keys.onRightPressed:{
                    navSound.play();
                    themeButton.focus = true
                }

                onClicked: {
                    if (systemsButton.focus) {
                        selectSfx.play();
                        showSystemsScreen();
                    }
                    else
                        systemsButton.focus = true;
                        navSound.play();
                        themeButton.currentIndex = -1;
                }
            }

            MenuButton {
                id: themeButton
                width: vpx(86); height: vpx(100)
                label: (theme === themeLight) ? "Dark Mode" : "Light Mode"
                icon: "../assets/images/navigation/theme.svg"

                Keys.onPressed: {
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        selectSfx.play();
                        toggleDarkMode();
                    }
                }

                Keys.onLeftPressed:{
                    navSound.play();
                    systemsButton.focus = true
                }

                Keys.onRightPressed:{
                    navSound.play();
                    settingsButton.focus = true
                }

                onClicked: {
                    if (themeButton.focus) {
                        selectSfx.play();
                        toggleDarkMode();
                    }
                    else
                        themeButton.focus = true;
                        navSound.play();
                        recentSwitcher.currentIndex = -1;
                }
            }

            MenuButton {
                id: settingsButton
                width: vpx(86); height: vpx(100)
                label: "Theme Settings"
                icon: "../assets/images/navigation/Settings.png"

                //Disabled until settings screen is built/implemented
                Keys.onPressed: {
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        showSettingsScreen();
                    }
                }

                Keys.onLeftPressed:{
                    navSound.play();
                    themeButton.focus = true
                }

                Keys.onRightPressed:{
                    borderSfx.play();
                    favoriteButton.focus = true
                }
                onClicked: {
                    if (settingsButton.focus) {
                        showSettingsScreen();
                    }
                    else
                        settingsButton.focus = true;
                        navSound.play();
                        recentSwitcher.currentIndex = -1;
                }
                visible: true
            }
        }
    }
}
