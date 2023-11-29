import QtQuick 2.15
import QtGraphicalEffects 1.12
import "../global"
import "../Lists"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils


Item {
    id: topbar
    width: parent.width;
    // height: Math.round(screenheight * 0.2569);
    
    // Top bar
    Image {
        id: profileIcon
        width: Math.round(screenheight * 0.0833)
        height: width
        source: "../assets/images/profile_icon-" + settings.profileIcon + ".png"
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
            font.pixelSize: Math.round(screenheight*0.0377)
            font.bold: false
    }
    
    Row {
        spacing: vpx(15)
        
        anchors {
            // left: parent.left;
            right: parent.right;
            top: parent.top; topMargin: Math.round(screenheight * 0.0228);
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
            color: theme.text
            font.family: titleFont.name
            // font.weight: 
            font.letterSpacing: 4
            font.pixelSize: Math.round(screenheight*0.0377)
            horizontalAlignment: Text.Right
            font.capitalization: Font.SmallCaps
        }
        Row {
            spacing: vpx(5)
            anchors {
                top: parent.top; topMargin: parent.topMargin;
                bottom: parent.bottom
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
                font.pixelSize: Math.round(screenheight*0.0377)
                horizontalAlignment: Text.Right
                Component.onCompleted: font.capitalization = Font.SmallCaps
                //font.capitalization: Font.SmallCaps
                visible: isNaN(api.device.batteryPercent) ? false : showPercent
            }
            BatteryIcon {
                id: batteryIcon
                width: Math.round(screenheight * 0.0455)
                height: width / 1.5
                anchors {
                    top: parent.top; topMargin: vpx(5);
                }
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: theme.text
                    antialiasing: false
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
            Image {
                
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
                visible: true
                // visible: chargingStatus && batteryIcon.level < 99
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
