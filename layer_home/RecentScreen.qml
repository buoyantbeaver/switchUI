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

        property var batteryStatus: isNaN(api.device.batteryPercent) ? screenheight : parseInt(api.device.batteryPercent*100);

        Keys.onPressed: {
            if (event.isAutoRepeat)
                return;
            // B: Go back
            if (api.keys.isCancel(event)) {
                event.accepted = true;
                recentSwitcher.focus = true
                if (recentSwitcher.currentIndex != recentSwitcher.count - 1) {
                    navSound.play();
                    recentSwitcher.currentIndex = recentSwitcher.count - 1
                } else {
                    navSound.play();
                    recentSwitcher.currentIndex = 0
                }
                return;
            }
        }

        TopBar {
            id: topbar
            
            anchors {
                left: parent.left; leftMargin: vpx(60)
                right: parent.right; rightMargin: vpx(60)
                top: parent.top; topMargin: Math.round(screenheight * 0.0472)
            }

            height: Math.round(screenheight * 0.2569)
            focus: false
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
            
            MenuButton {
                id: androidButton
                width: vpx(86); height: vpx(100)
                label: "Android"
                autoColor: false
                icon: "../assets/images/android-robot.svg"

                Keys.onPressed: {
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        selectSfx.play();
                        Internal.system.quit();
                    }
                }

                Keys.onLeftPressed:{
                    borderSfx.play();
                    settingsButton.focus = true
                }

                Keys.onRightPressed:{
                    navSound.play();
                    favoriteButton.focus = true
                }

                onClicked: {
                    if (androidButton.focus) {
                        selectSfx.play();
                        Internal.system.quit();
                    }
                    else
                        androidButton.focus = true;
                        navSound.play();
                        recentSwitcher.currentIndex = -1;
                }

                visible: enableAndroidButton;
            }
            
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
                    if (androidButton.visible) {
                        androidButton.focus = true
                    } else {
                        settingsButton.focus = true
                    }
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
                        recentSwitcher.currentIndex = -1;
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
                    if (androidButton.visible) {
                        androidButton.focus = true
                    } else {
                        favoriteButton.focus = true
                    }
                }
                onClicked: {
                    if (settingsButton.focus) {
                        // requestQuit();
                        navSound.play();
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
