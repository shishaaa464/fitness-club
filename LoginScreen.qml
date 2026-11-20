import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: loginRoot

    signal loginAccepted(string username, string role)

    function handleLogin() {
        let login = userField.text.trim();
        let password = passField.text;

        if (login === "") {
            errorLabel.text = "Введите логин пользователя!";
            return;
        }

        if (login === "admin") {
            if (password === "1234") {
                errorLabel.text = "";
                loginRoot.loginAccepted("Администратор", "Администратор");
            } else {
                errorLabel.text = "Неверный пароль администратора!";
            }
            return;
        }

        if (clientModel.validateClientLogin(login, password)) {
            errorLabel.text = "";
            loginRoot.loginAccepted(login, "Клиент");
        } else {
            errorLabel.text = "Ошибка: Неверное имя или пароль клиента!";
        }
    }

    background: Rectangle {
        color: "#f4f6f9"
    }

    Item {
        anchors.centerIn: parent
        width: 400
        height: 480

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: "#e2e8f0"
            border.width: 1
            radius: 24

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 36
                spacing: 22

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 14

                    Rectangle {
                        width: 54; height: 54; radius: 16
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#2563eb" }
                            GradientStop { position: 1.0; color: "#1e40af" }
                        }
                        Label {
                            anchors.centerIn: parent
                            text: "⚡"
                            font.pixelSize: 26
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    Label {
                        text: "Добро пожаловать"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#0f172a"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label {
                        text: "Войдите в систему фитнес-клуба"
                        font.pixelSize: 13
                        color: "#64748b"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Item { Layout.preferredHeight: 4 }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Логин / ФИО"; font.pixelSize: 12; font.bold: true; color: "#475569" }

                    TextField {
                        id: userField
                        placeholderText: "например, admin или Иван"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        font.pixelSize: 14

                        background: Rectangle {
                            color: userField.activeFocus ? "#ffffff" : "#f8fafc"
                            border.color: userField.activeFocus ? "#2563eb" : "#cbd5e1"
                            border.width: userField.activeFocus ? 2 : 1
                            radius: 12
                        }

                        focus: true
                        Component.onCompleted: {
                            userField.forceActiveFocus();
                        }

                        Keys.onReturnPressed: {
                            passField.forceActiveFocus();
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Пароль"; font.pixelSize: 12; font.bold: true; color: "#475569" }

                    TextField {
                        id: passField
                        placeholderText: "••••••••"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        font.pixelSize: 14

                        background: Rectangle {
                            color: passField.activeFocus ? "#ffffff" : "#f8fafc"
                            border.color: passField.activeFocus ? "#2563eb" : "#cbd5e1"
                            border.width: passField.activeFocus ? 2 : 1
                            radius: 12
                        }

                        Keys.onReturnPressed: {
                            handleLogin();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: errorLabel.visible ? 36 : 0
                    color: "#fef2f2"
                    border.color: "#f87171"
                    radius: 8
                    visible: errorLabel.text !== ""

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 8
                        Label { text: "⚠️"; font.pixelSize: 12 }
                        Label {
                            id: errorLabel
                            text: ""
                            color: "#dc2626"
                            font.pixelSize: 12
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Button {
                    text: "Войти в систему"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46

                    background: Rectangle {
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: parent.parent.hovered ? "#1d4ed8" : "#2563eb" }
                            GradientStop { position: 1.0; color: parent.parent.hovered ? "#1e40af" : "#1d4ed8" }
                        }
                        radius: 12
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        handleLogin();
                    }
                }
            }
        }
    }
}