/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import Qt.location 5.0
import "common" as Common

Item {
    id: dialog
    signal goButtonClicked
    signal cancelButtonClicked

    anchors.fill: parent
    property int gap: 10
    opacity: 0

    property alias title: titleBar.text
    property alias startLatitude: latFrom.text
    property alias startLongitude: longFrom.text
    property alias endLatitude: latTo.text
    property alias endLongitude: longTo.text
    property alias startStreet: streetFrom.text
    property alias startCity: cityFrom.text
    property alias startCountry: countryFrom.text
    property alias endStreet: streetTo.text
    property alias endCity: cityTo.text
    property alias endCountry: countryTo.text
    property alias byCoordinates: coord.enabled
    property int travelMode: RouteQuery.CarTravel             // CarTravel, PedestrianTravel, BicycleTravel, PublicTransitTravel, TruckTravel
    property int routeOptimization: RouteQuery.ShortestRoute  // ShortestRoute, FastestRoute, MostEconomicRoute, MostScenicRoute
                                                              // TODO NoFeature, TollFeature, HighwayFeature, PublicTransitFeature, FerryFeature, TunnelFeature, DirtRoadFeature, ParksFeature, MotorPoolLaneFeature

    Common.Fader {}

    Rectangle {
        id: dialogRectangle
        color: "lightsteelblue"
        opacity: 1
        width: parent.width - gap*2;
        height: options.height + gap*3 + buttons.height + titleBar.height

        anchors {
            top: parent.top
            topMargin: 50
            left: parent.left
            leftMargin: gap
        }

        border.width: 1
        border.color: "darkblue"
        radius: 5

        Common.TitleBar {
            id: titleBar;
            width: parent.width; height: 40;
            anchors.top: parent.top; anchors.left: parent.left;
            opacity: 0.9
            text: "Route"
            onClicked: { dialog.cancelButtonClicked() }
        }

        Column {
           id: options
           spacing: gap
           width: dialogRectangle.width - gap*2

           anchors {
               top: titleBar.bottom
               topMargin: gap
               left: dialogRectangle.left
               leftMargin: gap
           }

            states: [
                State {
                    name: "Address"
                    PropertyChanges { target: coord; enabled: false }
                    PropertyChanges { target: address; enabled: true }
                }
            ]


//by coordinates
            Row {
                id: row1
                spacing: gap
                Image {
                    id: optionButtonCoord
                    anchors.verticalCenter:parent.verticalCenter
                    source: coord.enabled ? "resources/option_button_selected.png" : "resources/option_button.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { options.state = "" }
                    }
                }

                Rectangle {
                    id: coord
                    color: dialogRectangle.color
                    border.width: 1
                    border.color: enabled ? "black" : "grey"
                    radius: 5
                    width:options.width - optionButtonCoord.width - row1.spacing
                    height: longTo.y + longTo.height + gap
                    enabled: true

//start point
                    Text {
                        id: fromLabel;
                        font.bold: true;
                        enabled: coord.enabled
                        anchors {
                            top: latFrom.top
                            topMargin:latFrom.height + gap/6 - fromLabel.height/2
                            left: parent.left;
                            leftMargin: gap
                        }
                        text: "From"
                        color: enabled ? "black" : "grey"
                    }

                    TextWithLabel {
                        id: latFrom
                        width: parent.width - fromLabel.width - gap*3
                        text: "-27.575"
                        label: "latitude"
                        enabled: coord.enabled
                        anchors {
                            left: fromLabel.right
                            leftMargin: gap
                            top: parent.top
                            topMargin:gap
                        }
                    }

                    TextWithLabel {
                        id: longFrom
                        width: latFrom.width
                        text: "153.088"
                        label: "longitude"
                        enabled: coord.enabled
                        anchors {
                            left: latFrom.left
                            top: latFrom.bottom
                            topMargin:gap/3
                        }
                    }

//end point
                    Text {
                        id: toLabel;
                        font.bold: true;
                        width: fromLabel.width
                        enabled: coord.enabled
                        anchors {
                            top: latTo.top
                            topMargin:latTo.height + gap/6 - toLabel.height/2
                            left: parent.left;
                            leftMargin: gap;
                        }
                        text: "To"
                        color: enabled ? "black" : "grey"
                    }

                    TextWithLabel {
                        id: latTo
                        width: latFrom.width
                        text: "-27.465"
                        label: "latitude"
                        enabled: coord.enabled
                        anchors {
                            left: toLabel.right
                            leftMargin: gap
                            top: longFrom.bottom
                            topMargin:gap
                        }
                    }

                    TextWithLabel {
                        id: longTo
                        width: latTo.width
                        text: "153.023"
                        label: "longitude"
                        enabled: coord.enabled
                        anchors {
                            left: latTo.left
                            top: latTo.bottom
                            topMargin:gap/3
                        }
                    }
                }
            }

//by address
            Row {
                id: row2
                spacing: gap

                Image {
                    id: optionButtonAddress
                    source: address.enabled ? "resources/option_button_selected.png" : "resources/option_button.png"
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { options.state = "Address" }
                    }
                }

                Rectangle {
                    id: address
                    color: dialogRectangle.color
                    border.width: 1
                    border.color: enabled ? "black" : "grey"
                    radius: 5
                    width:coord.width
                    height: countryTo.y + countryTo.height + gap
                    enabled: false

//start point
                    Text {
                        id: fromLabel2;
                        font.bold: true;
                        enabled: address.enabled
                        anchors {
                            top: cityFrom.top
                            left: parent.left;
                            leftMargin: gap
                        }
                        text: "From"
                        color: enabled ? "black" : "grey"
                    }

                    TextWithLabel {
                        id: streetFrom
                        width: parent.width - fromLabel2.width - gap*3
                        text: "Brandl st"
                        label: "street"
                        enabled: address.enabled
                        anchors {
                            left: fromLabel2.right
                            leftMargin: gap
                            top: parent.top
                            topMargin:gap
                        }
                    }

                    TextWithLabel {
                        id: cityFrom
                        width: streetFrom.width
                        text: "Eight Mile Plains"
                        label: "city"
                        enabled: address.enabled
                        anchors {
                            left: streetFrom.left
                            top: streetFrom.bottom
                            topMargin:gap/3
                        }
                    }

                    TextWithLabel {
                        id: countryFrom
                        width: streetFrom.width
                        text: "Australia"
                        label: "country"
                        enabled: address.enabled
                        anchors {
                            left: streetFrom.left
                            top: cityFrom.bottom
                            topMargin:gap/3
                        }
                    }


//end point
                    Text {
                        id: toLabel2;
                        font.bold: true;
                        enabled: address.enabled
                        anchors {
                            top: cityTo.top
                            left: parent.left;
                            leftMargin: gap
                        }
                        text: "To"
                        color: enabled ? "black" : "grey"
                    }

                    TextWithLabel {
                        id: streetTo
                        width: parent.width - fromLabel2.width - gap*3
                        text: "Brunswick st"
                        label: "street"
                        enabled: address.enabled
                        anchors {
                            left: fromLabel2.right
                            leftMargin: gap
                            top: countryFrom.bottom
                            topMargin:gap
                        }
                    }

                    TextWithLabel {
                        id: cityTo
                        width: streetTo.width
                        text: "New Farm"
                        label: "city"
                        enabled: address.enabled
                        anchors {
                            left: streetTo.left
                            top: streetTo.bottom
                            topMargin:gap/3
                        }
                    }

                    TextWithLabel {
                        id: countryTo
                        width: streetTo.width
                        text: "Australia"
                        label: "country"
                        enabled: address.enabled
                        anchors {
                            left: streetTo.left
                            top: cityTo.bottom
                            topMargin:gap/3
                        }
                    }

                }
            }
        }

        Row {
            id: buttons
            anchors.top: options.bottom
            anchors.topMargin: gap
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: gap/3
            height: 32
            Common.Button {
                text: "Clear"
                width: 80; height: parent.height
                onClicked: {
                    if (byCoordinates == true){
                        latFrom.text = ""
                        longFrom.text = ""
                        latTo.text = ""
                        longTo.text = ""
                    }
                    else {
                        streetFrom.text = ""
                        cityFrom.text = ""
                        countryFrom.text = ""
                        streetTo.text = ""
                        cityTo.text = ""
                        countryTo.text = ""
                    }
                }
            }

            Common.Button {
                text: "Go!"
                width: 80; height: parent.height
                onClicked: {
                    dialog.goButtonClicked ()
                }
            }
        }
    }
}