/**
 * Main
 * accuweather/main.qml
 */

import QtQuick 1.1
import boxee.components 1.0
import "control.js" as AccuWeather

Window {
  id: root
  focalItem: focusMe

  property bool advisory: false
  property bool errorOn: false
  property bool launched: false
  property bool weatherMetric: false
  property string postalCode: '00000'
  property string advisoryText: 'Current Forecast'

  // temporary
  property string styleMedium: "DIN Next LT MED"

  function showError(msg) {
    errorMessage.text = msg;
    errorOn = true;

    if (!launched) {
      launched = true;
      boxeeAPI.appStarted(true);
    }
  }

  function populateForecast(result) {
    if (!result.isOk) {
      showError(result.message);
      return;
    }

    advisory = result.data.advisory;
    cityLabel.text = result.data.locationLabel;

    fiveDayModel.clear();
    currentModel.clear();
    currentModel.append(result.data.current);

    for (var day = 0; day < result.data.fiveDay.length; day++)
      fiveDayModel.append(result.data.fiveDay[day]);

    if (!launched) {
      launched = true;
      boxeeAPI.appStarted(true);
    }

    // uncomment below to test advisories
    // advisory = true;
    // result.data.advisoryType = 'AREAL FLOOD ADVISORY'

    if (advisory && result.data.advisoryType)
      advisoryText = result.data.advisoryType;
  }

  Component.onCompleted: {
    launched = false;
    postalCode = boxeeAPI.postalCode();
    weatherMetric = boxeeAPI.weatherMetric()
    AccuWeather.currentForcast(postalCode, weatherMetric, populateForecast);
  }

  Keys.onPressed: {
    switch (event.key) {
      case Qt.Key_H:
      case Qt.Key_Home:
      case Qt.Key_HomePage:
      case Qt.Key_Escape:
        {
          windowManager.pop();
          boxeeAPI.appStopped();
        }
    }
  }

  Item {
    id: focusMe
    focus: true
  }

  Column {
    y: 70
    x: 96
    spacing: 15

    Image {
      width: 696
      height: 54
      source: "media/accuweather-logo-large.png"
    }

    Label {
      id: cityLabel
      x: 3
      opacity: 0.6
      color: "white"
      font.bold: true
      font.pixelSize: 38
      visible: !errorOn
    }
  }

  Item {
    id: weather
    visible: !errorOn && launched
    anchors.fill: parent

    Image {
      id: currentBg
      x: 96
      y: 234
      width: 588
      height: 762
      source: "media/currentconditions-bg.png"
    }

    Image {
      visible: advisory
      width: 86
      height: 84
      source: "media/WeatherAdvisory.png"
      anchors.topMargin: 1
      anchors.top: currentBg.top
      anchors.left: currentBg.left
    }

    Image {
      id: fiveDayBg
      width: 1104
      height: 762
      anchors.top: currentBg.top
      anchors.left: currentBg.right
      anchors.leftMargin: 36
      source: "media/fivedayforecast-bg.png"
    }

    ListView {
      id: currentView
      width: currentBg.width
      height: currentBg.height
      anchors.fill: currentBg

      delegate: Item {
        width: parent.width
        height: parent.height

        Column {
          spacing: 1
          width: parent.width
          anchors.topMargin: 40
          anchors.top: parent.top

          AccuLabel {
            width: 480
            font.pixelSize: 44
            wrapMode: Text.WordWrap
            text: (advisory) ? advisoryText : "Current Forecast"
            color: (advisory) ? "#df861c" : "#f8f8f8"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
          }

          Row {
            height: 194
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
              width: 180
              height: 180
              source: "media/weather/" + weathericon + ".png"
              anchors.verticalCenter: parent.verticalCenter
            }

            AccuLabel {
              //platformStyle: LabelstyleMedium
              text: temperature + '°'
              font.pixelSize: 160
              font.family: styleMedium
              anchors.verticalCenterOffset: 10
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          AccuLabel {
            font.pixelSize: 48
            text: weathertext
            anchors.horizontalCenter: parent.horizontalCenter
          }
        }

        Column {
          width: 510
          spacing: 20
          anchors.bottomMargin: 30
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "RealFeel"
            }

            AccuLabel {
              text: realfeel + "° " + (weatherMetric ? "C" : "F")
              font.bold: false;
              anchors.right: parent.right
            }
          }

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "Humidity"
            }

            AccuLabel {
              text: humidity
              font.bold: false;
              anchors.right: parent.right
            }
          }

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "Wind"
            }

            AccuLabel {
              text: winddirection + " " + windspeed + (weatherMetric ? " KMH" : " MPH")
              font.bold: false;
              anchors.right: parent.right
            }
          }

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "Visibility"
            }

            AccuLabel {
              text: visibility + (weatherMetric ? " KMs" : " Miles")
              font.bold: false;
              anchors.right: parent.right
            }
          }

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "Sunrise"
            }

            AccuLabel {
              text: sunrise
              font.bold: false;
              anchors.right: parent.right
            }
          }

          Item {
            height: 40
            width: parent.width

            AccuLabel {
              text: "Sunset"
            }

            AccuLabel {
              text: sunset
              font.bold: false;
              anchors.right: parent.right
            }
          }
        }
      }

      model: ListModel {
        id: currentModel
      }
    }

    ListView {
      id: fiveDayView
      contentHeight: 150
      width: fiveDayBg.width
      height: fiveDayBg.height
      anchors.fill: fiveDayBg
      orientation: ListView.Vertical

      delegate: Item {
        x: 60
        width: 1000
        height: 150

        AccuLabel {
          text: daycode
          font.pixelSize: 56
          font.family: styleMedium
          anchors.verticalCenterOffset: 18
          anchors.verticalCenter: parent.verticalCenter
        }

        AccuLabel {
          x: 465
          font.pixelSize: 72
          font.family: styleMedium
          text: daytime.hightemperature + '°'
          anchors.verticalCenterOffset: 18
          anchors.verticalCenter: parent.verticalCenter
        }

        AccuLabel {
          x: 590
          opacity: 0.4
          font.pixelSize: 72
          font.family: styleMedium
          text: nighttime.lowtemperature + '°'
          anchors.verticalCenterOffset: 18
          anchors.verticalCenter: parent.verticalCenter
        }

        Image {
          width: 110
          height: 110
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: 8
          source: "media/weather/" + daytime.weathericon + ".png"
        }
      }

      model: ListModel {
        id: fiveDayModel
      }
    }
  }

  Label {
    id: errorMessage
    visible: errorOn
    width: parent.width
    font.pixelSize: 68
    horizontalAlignment: Text.AlignHCenter
    anchors.verticalCenter: parent.verticalCenter
  }

  Timer {
    repeat: true
    running: true
    interval: 600000
    onTriggered: AccuWeather.currentForcast(postalCode, weatherMetric, populateForecast);
  }
}
