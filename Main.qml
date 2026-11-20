import QtQuick
import QtQuick.Controls

Window {
    width: 950
    height: 650
    visible: true
    title: "Администрирование фитнес-клуба"

    property string loggedInClientName: ""

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: LoginScreen {
            onLoginAccepted: (username, role) => {
                if (role === "Администратор") {
                    stackView.replace(adminDashboardComponent);
                } else {
                    stackView.replace(clientProfileComponent, { "currentClientName": username });
                }
            }
        }
    }

    Component {
        id: adminDashboardComponent
        AdminDashboard {
            onLogoutRequested: {
                stackView.replace(loginScreenComponent);
            }
        }
    }

    Component {
        id: clientProfileComponent
        ClientProfile {
            onLogoutRequested: {
                stackView.replace(loginScreenComponent);
            }
        }
    }

    Component {
        id: loginScreenComponent
        LoginScreen {
            onLoginAccepted: (username, role) => {
                if (role === "Администратор") {
                    stackView.replace(adminDashboardComponent);
                } else {
                    stackView.replace(clientProfileComponent, { "currentClientName": username });
                }
            }
        }
    }
}