import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: clientProfileRoot

    signal logoutRequested()

    property string currentClientName: ""

    property var clientData: null

    onCurrentClientNameChanged: {
        if (currentClientName !== "") {
            clientData = clientModel.getClientInfoByName(currentClientName);
        }
    }

    Component.onCompleted: {
        if (currentClientName !== "") {
            clientData = clientModel.getClientInfoByName(currentClientName);
        }
    }

    background: Rectangle {
        color: "#f4f6f9"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 20

        RowLayout {
            Layout.fillWidth: true

            RowLayout {
                spacing: 16
                Rectangle {
                    width: 56; height: 56; radius: 18
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#3b82f6" }
                        GradientStop { position: 1.0; color: "#1d4ed8" }
                    }
                    Label {
                        anchors.centerIn: parent
                        text: clientData && clientData.name ? clientData.name.charAt(0).toUpperCase() : "👤"
                        font.pixelSize: 24; font.bold: true; color: "white"
                    }
                }
                ColumnLayout {
                    spacing: 3
                    Label {
                        text: clientData ? clientData.name : "Загрузка..."
                        font.pixelSize: 22
                        font.bold: true
                        color: "#0f172a"
                    }
                    Label {
                        text: "Личный кабинет участника клуба"
                        font.pixelSize: 13
                        color: "#64748b"
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Выйти"
                Layout.preferredHeight: 40
                Layout.preferredWidth: 120

                background: Rectangle {
                    color: parent.hovered ? "#fee2e2" : "#ffffff"
                    border.color: parent.hovered ? "#f87171" : "#e2e8f0"
                    border.width: parent.hovered ? 2 : 1
                    radius: 12
                }
                contentItem: Text {
                    text: parent.text
                    color: "#dc2626"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: clientProfileRoot.logoutRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            Rectangle {
                Layout.preferredWidth: 420
                Layout.fillHeight: true
                color: "white"
                border.color: "#e2e8f0"
                radius: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 18

                    RowLayout {
                        Layout.fillWidth: true
                        RowLayout {
                            spacing: 12
                            Rectangle {
                                width: 44; height: 44; radius: 12
                                color: "#eff6ff"
                                Label { anchors.centerIn: parent; text: "🎫"; font.pixelSize: 20 }
                            }
                            ColumnLayout {
                                spacing: 2
                                Label { text: "Электронный абонемент"; font.pixelSize: 16; font.bold: true; color: "#0f172a" }
                                Label { text: "Ваш текущий статус и тариф"; font.pixelSize: 12; color: "#64748b" }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            height: 32; width: 130; radius: 16
                            color: (clientData && clientData.status === "Активен") ? "#dcfce7" :
                                   (clientData && clientData.status === "Заморожен") ? "#fef9c3" : "#fee2e2"
                            RowLayout {
                                anchors.centerIn: parent; spacing: 6
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: (clientData && clientData.status === "Активен") ? "#16a34a" :
                                           (clientData && clientData.status === "Заморожен") ? "#ca8a04" : "#dc2626"
                                }
                                Label {
                                    text: clientData ? clientData.status : "Загрузка"
                                    font.bold: true; font.pixelSize: 12
                                    color: (clientData && clientData.status === "Активен") ? "#16a34a" :
                                           (clientData && clientData.status === "Заморожен") ? "#ca8a04" : "#dc2626"
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#f1f5f9" }

                    GridLayout {
                        columns: 2
                        rowSpacing: 14
                        columnSpacing: 20
                        Layout.fillWidth: true

                        Label { text: "ФИО клиента:"; color: "#64748b"; font.pixelSize: 13; font.bold: true }
                        Label { text: clientData ? clientData.name : ""; font.bold: true; font.pixelSize: 14; color: "#1e293b" }

                        Label { text: "Телефон:"; color: "#64748b"; font.pixelSize: 13; font.bold: true }
                        Label { text: clientData ? clientData.phone : ""; font.bold: true; font.pixelSize: 14; color: "#1e293b" }

                        Label { text: "Тип абонемента:"; color: "#64748b"; font.pixelSize: 13; font.bold: true }
                        Label { text: clientData ? clientData.membershipType : ""; font.bold: true; font.pixelSize: 14; color: "#2563eb" }

                        Label { text: "Стоимость:"; color: "#64748b"; font.pixelSize: 13; font.bold: true }
                        Label { text: clientData ? (clientData.price + " руб.") : ""; font.bold: true; font.pixelSize: 14; color: "#16a34a" }

                        Label { text: "Действует до:"; color: "#64748b"; font.pixelSize: 13; font.bold: true }
                        Label { text: clientData ? clientData.expiryDate : ""; font.bold: true; font.pixelSize: 14; color: "#1e293b" }
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        text: "❄️ Заморозить абонемент"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        background: Rectangle {
                            color: parent.hovered ? "#f1f5f9" : "#ffffff"
                            border.color: "#cbd5e1"
                            radius: 10
                        }
                        onClicked: {
                            freezeConfirmPopup.open();
                        }
                    }

                    Label {
                        id: freezeStatusLabel
                        text: ""
                        font.pixelSize: 12
                        font.bold: true
                        color: "#16a34a"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#f8fafc"
                        radius: 10
                        border.color: "#e2e8f0"

                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 8
                            Label { text: "💡"; font.pixelSize: 14 }
                            Label { text: "Показывайте этот экран при входе."; font.pixelSize: 12; font.bold: true; color: "#475569" }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e2e8f0"
                radius: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: "📊 Ваша история посещений"; font.pixelSize: 16; font.bold: true; color: "#0f172a" }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "Всего визитов: " + (clientData ? visitModel.getClientVisitCount(clientData.name) : 0)
                            font.pixelSize: 12; color: "#64748b"; font.bold: true
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#f1f5f9" }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: visitModel
                        spacing: 8

                        delegate: Rectangle {
                            width: parent.width; height: 44
                            visible: (model.clientName && clientData && model.clientName.trim().toLowerCase() === clientData.name.trim().toLowerCase())
                            color: "#f8fafc"
                            border.color: "#e2e8f0"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12
                                Label { text: "🏃 Визит в тренажерный зал"; font.pixelSize: 13; font.bold: true; color: "#1e293b" }
                                Item { Layout.fillWidth: true }
                                Label { text: "🕒 " + (model.visitTime || ""); font.pixelSize: 13; color: "#64748b" }
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: freezeConfirmPopup
        width: 380; height: 260
        anchors.centerIn: parent
        modal: true; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "white"; radius: 16; border.color: "#e2e8f0" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; spacing: 16

            Label {
                text: "❄️ Заморозка абонемента"
                font.pixelSize: 18; font.bold: true; color: "#0f172a"
            }

            Label {
                text: "Вы действительно хотите заморозить абонемент? Проход в клуб будет временно приостановлен, а срок действия продлится."
                font.pixelSize: 13; color: "#64748b"
                wrapMode: Text.WordWrap; Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Label { text: "Дней (до 14):"; font.pixelSize: 13; font.bold: true; color: "#1e293b" }
                SpinBox {
                    id: freezeDaysSpin
                    from: 1; to: 14; value: 7
                    Layout.fillWidth: true; Layout.preferredHeight: 36
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignRight; spacing: 10
                Button {
                    text: "Отмена"
                    Layout.preferredHeight: 36; Layout.preferredWidth: 100
                    onClicked: freezeConfirmPopup.close()
                }
                Button {
                    text: "Да, заморозить"
                    Layout.preferredHeight: 36; Layout.preferredWidth: 130
                    background: Rectangle { color: "#2563eb"; radius: 8 }
                    contentItem: Text {
                        text: parent.text; color: "white"; font.bold: true; font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (clientData && clientData.name) {
                            clientModel.requestFreeze(clientData.name, freezeDaysSpin.value);
                            clientData = clientModel.getClientInfoByName(clientData.name);

                            freezeStatusLabel.text = "✓ Абонемент заморожен на " + freezeDaysSpin.value + " дн.";
                        }
                        freezeConfirmPopup.close();
                    }
                }
            }
        }
    }
}