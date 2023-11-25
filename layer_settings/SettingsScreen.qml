import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0

FocusScope {
id: root

    ListModel {
    id: settingsModel

        ListElement {
            settingName: "Game Background"
            settingSubtitle: ""
            setting: "Screenshot,Fanart,Boxart"
        }

        ListElement {
            settingName: "Background Music"
            settingSubtitle: "(Requires Reload)"
            setting: "No,Yes"
        }

        ListElement {
            settingName: "Word Wrap on Titles"
            settingSubtitle: "(Requires Reload)"
            setting: "Yes,No"
        }
        

    }

    property var generalPage: {
        return {
            pageName: "General",
            listmodel: settingsModel
        }
    }

    ListModel {
        id: homeSettingsModel
        ListElement {
            settingName: "Home view"
            settingSubtitle: ""
            setting: "Systems,Recent"
        }
        ListElement {
            settingName: "Time Format"
            settingSubtitle: ""
            setting: "12hr,24hr"
        }
        ListElement {
            settingName: "Display Battery Percentage"
            settingSubtitle: "(%)"
            setting: "No,Yes"
        }
        ListElement {
            settingName: "Number of recent games"
            settingSubtitle: "(default 12)"
            setting: "8,10,12,14,16,18,20"
        }
    }

    property var homePage: {
        return {
            pageName: "Home Screen",
            listmodel: homeSettingsModel
        }
    }

    ListModel {
        id: perfSettingsModel
        ListElement {
            settingName: "Enable DropShadows"
            settingSubtitle: ""
            setting: "Yes, No"
        }
    }

    property var performancePage: {
        return {
            pageName: "Performance",
            listmodel: perfSettingsModel
        }
    }

    ListModel {
        id: themeSettingsModel
        ListElement {
            settingName: "Basic White"
            settingSubtitle: ""
            setting: "Basic White, Basic Black"
        }
        ListElement {
            settingName: "Basic Black"
            settingSubtitle: ""
            setting: "Basic White, Basic Black"
        }
    }

    property var themeSettingsPage: {
        return {
            pageName: "Themes",
            listmodel: themeSettingsModel
        }
    }

    property var settingsArr: [generalPage, homePage, performancePage]

    property real itemheight: vpx(50)

    // Top bar
    Item {
        id: topBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: Math.round(screenheight * 0.1222)
        z: 5

        Image {
            id: headerIcon
            width: Math.round(screenheight*0.0611)
            height: width
            source: "../assets/images/navigation/Settings.png"
            sourceSize.width: vpx(64)
            sourceSize.height: vpx(64)

            anchors {
                top: parent.top; topMargin: Math.round(screenheight*0.0416)
                left: parent.left; leftMargin: vpx(38)
            }

            Text {
                id: collectionTitle
                text: "Theme Settings"
                color: theme.text
                font.family: titleFont.name
                font.pixelSize: Math.round(screenheight*0.0277)
                font.bold: true
                anchors {
                    verticalCenter: headerIcon.verticalCenter
                    left: parent.right; leftMargin: vpx(12)
                }
            }
        }

        ColorOverlay {
            anchors.fill: headerIcon
            source: headerIcon
            color: theme.text
            cached: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            onEntered: {}
            onExited: {}
            onClicked: {}
        }

        // Line
        Rectangle {
            y: parent.height - vpx(1)
            anchors.left: parent.left; anchors.right: parent.right
            height: 1
            color: theme.secondary
        }
    }

    ListView {
    id: pagelist
    
        focus: true
        anchors {
            top: topBar.bottom
            bottom: parent.bottom; //bottomMargin: helpMargin
            left: parent.left; //leftMargin: globalMargin
        }
        width: vpx(300)
        model: settingsArr
        delegate: Component {
        id: pageDelegate
        
            Item {
            id: pageRow

                property bool selected: ListView.isCurrentItem

                width: ListView.view.width
                height: itemheight + vpx(15)

                // square selector for left menu begins
                Rectangle {
                    id: hlBorder
                    width: parent.width
                    height: parent.height
                    radius: vpx(3)
                    color: theme.accent
                    layer.enabled: enableDropShadows
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 0
                        color: "#4D000000"
                        samples: 6
                        z: -2
                    }

                    opacity: selected && !settingsList.focus ? 0.5 : 0
                    Behavior on opacity { NumberAnimation { duration: 75 } }

                    // Highlight animation (ColorOverlay causes graphical glitches on W10)
                    Rectangle {
                        anchors.fill: parent
                        color: "white"//"#c0f0f3"
                        radius: hlBorder.radius
                        SequentialAnimation on opacity {
                            id: colorAnim
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.5; duration: 400; easing { type: Easing.OutQuad } }
                            NumberAnimation { to: 0; duration: 500; easing { type: Easing.InQuad } }
                            PauseAnimation { duration: 200 }
                        }
                    }
                }
                    
                    // Inner highlight
                Rectangle {
                    anchors { 
                        left: parent.left; leftMargin: vpx(4)
                        right: parent.right; rightMargin: vpx(4)
                        bottom: parent.bottom; bottomMargin: vpx(4)
                        top: parent.top; topMargin: vpx(4)
                    }
                    
                    color: "#202226"
                    opacity: selected && !settingsList.focus ? 1 : 0
                }
                // square selector ends here

                // Active indicator begins
                Rectangle {
                    anchors {
                        left: parent.left; leftMargin: vpx(10)
                        bottom: parent.bottom; bottomMargin: vpx(10)
                        top: parent.top; topMargin: vpx(10)
                    }
                    width: vpx(4)
                    height: parent.height
                    color: theme.accent
                    opacity: selected ? 1 : 0
                }
                // Active indicator ends

                // Page name
                Text {
                id: pageNameText
                
                    text: modelData.pageName
                    color: selected ? theme.accent : theme.text
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(22)
                    font.bold: false
                    verticalAlignment: Text.AlignVCenter
                    opacity: 1

                    width: contentWidth
                    height: parent.height
                    anchors {
                        left: parent.left; leftMargin: vpx(20)
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    onEntered: { /*navSound.play();*/}
                    onClicked: {
                        navSound.play();
                        pagelist.currentIndex = index;
                        settingsList.focus = true;
                    }
                }
            }
        } 

        Keys.onUpPressed: { navSound.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { navSound.play(); incrementCurrentIndex() }
        Keys.onPressed: {
            // Accept
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                navSound.play();
                settingsList.focus = true;
            }
            // Back
            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                if (settings.homeView == "Recent"){
                    showRecentScreen();
                } else {
                    showSystemsScreen();
                }
            }
        }

    }

    Rectangle {
        anchors {
            left: pagelist.right;
            top: pagelist.top; bottom: pagelist.bottom
        }
        width: vpx(1)
        color: theme.text
        opacity: 0.1
    }

    ListView {
    id: settingsList

        model: settingsArr[pagelist.currentIndex].listmodel
        delegate: settingsDelegate
        
        anchors {
            top: topBar.bottom; bottom: parent.bottom; 
            left: pagelist.right; //leftMargin: globalMargin
            right: parent.right; //rightMargin: globalMargin
        }
        width: vpx(500)

        spacing: vpx(0)
        orientation: ListView.Vertical

        preferredHighlightBegin: settingsList.height / 2 - itemheight
        preferredHighlightEnd: settingsList.height / 2
        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 100
        clip: false

        Component {
        id: settingsDelegate
        
            Item {
            id: settingRow

                property bool selected: ListView.isCurrentItem && settingsList.focus
                property variant settingList: setting.split(',')
                property int savedIndex: api.memory.get(settingName + 'Index') || 0

                function saveSetting() {
                    api.memory.set(settingName + 'Index', savedIndex);
                    api.memory.set(settingName, settingList[savedIndex]);
                }

                function nextSetting() {
                    if (savedIndex != settingList.length -1)
                        savedIndex++;
                    else
                        savedIndex = 0;
                }

                function prevSetting() {
                    if (savedIndex > 0)
                        savedIndex--;
                    else
                        savedIndex = settingList.length -1;
                }

                width: ListView.view.width
                height: itemheight + vpx(10)


                // square selector begins
                Rectangle {
                    anchors { 
                        left: parent.left; leftMargin: vpx(25)
                        right: parent.right; rightMargin: vpx(25)
                        bottom: parent.bottom
                    }
                    color: theme.accent
                    height: parent.height
                    width: parent.white
                    radius: vpx(3)
                    layer.enabled: enableDropShadows
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 0
                        color: "#4D000000"
                        samples: 6
                        z: -2
                    }
                    opacity: selected ? 0.5 : 0
                    Behavior on opacity { NumberAnimation { duration: 75 } }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "white"//"#c0f0f3"
                        radius: vpx(3)
                        SequentialAnimation on opacity {
                            id: colorAnim
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.5; duration: 400; easing { type: Easing.OutQuad } }
                            NumberAnimation { to: 0; duration: 500; easing { type: Easing.InQuad } }
                            PauseAnimation { duration: 200 }
                        }
                    }

                }

                Rectangle {
                    anchors { 
                        left: parent.left; leftMargin: vpx(29)
                        right: parent.right; rightMargin: vpx(29)
                        bottom: parent.bottom; bottomMargin: vpx(4)
                        top: parent.top; topMargin: vpx(4)
                    }
                    color: "#202226"
                    opacity: selected ? 1 : 0
                }
                // square selector ends, should be put above labels

                // Setting name
                Text {
                id: settingNameText
                
                    text: settingSubtitle != "" ? settingName + " " + settingSubtitle + ": " : settingName + ": "
                    color: theme.text
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(20)
                    verticalAlignment: Text.AlignVCenter
                    opacity: 1

                    width: contentWidth
                    height: parent.height
                    anchors {
                        left: parent.left; leftMargin: vpx(50)
                    }
                }
                // Setting value
                Text { 
                id: settingtext; 
                
                    text: settingList[savedIndex]; 
                    color: selected ? theme.accent : theme.text
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(20)
                    verticalAlignment: Text.AlignVCenter
                    opacity: 1

                    height: parent.height
                    anchors {
                        right: parent.right; rightMargin: vpx(50)
                    }
                }

                // Input handling
                // Next setting
                Keys.onRightPressed: {
                    selectSfx.play()
                    nextSetting();
                    saveSetting();
                }
                // Previous setting
                Keys.onLeftPressed: {
                    selectSfx.play();
                    prevSetting();
                    saveSetting();
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        selectSfx.play()
                        nextSetting();
                        saveSetting();
                    }
                    // Back
                    if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        navSound.play()
                        pagelist.focus = true;
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false //settings.MouseHover == "Yes"
                    onEntered: { /*navSound.play();*/ }
                    onClicked: {
                        if(selected){
                            selectSfx.play();
                            nextSetting();
                            saveSetting();
                        } else {
                            navSound.play();
                            settingsList.focus = true;
                            settingsList.currentIndex = index;
                        }
                    }
                }
                

                Rectangle {
                    y: parent.height - vpx(1)
                    anchors { 
                        left: parent.left; leftMargin: vpx(25)
                        right: parent.right; rightMargin: vpx(25)
                        bottom: parent.bottom
                    }
                    height: 1
                    color: theme.text
                    opacity: 0.1
                }
            }
        } 

        Keys.onUpPressed: { navSound.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { navSound.play(); incrementCurrentIndex() }
    }

}