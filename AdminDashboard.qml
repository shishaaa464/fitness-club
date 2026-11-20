import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

Pane {
    id: adminRoot
    signal logoutRequested()

    property var selectedClientDetails: null

    property double priceOnce: clientModel.savedPriceOnce !== undefined ? clientModel.savedPriceOnce : 500.0
    property double priceDiscount: clientModel.savedPriceDiscount !== undefined ? clientModel.savedPriceDiscount : 1500.0
    property double priceStandard: clientModel.savedPriceStandard !== undefined ? clientModel.savedPriceStandard : 2500.0

    // Диалог сохранения файла (Экспорт)
    FileDialog {
        id: exportDialog
        title: "Экспорт данных базы клуба"
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON файлы (*.json)"]
        defaultSuffix: "json"
        onAccepted: {
            clientModel.exportData(exportDialog.file);
        }
    }

    // Диалог открытия файла (Импорт)
    FileDialog {
        id: importDialog
        title: "Импорт данных базы клуба"
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON файлы (*.json)"]
        onAccepted: {
            clientModel.importData(importDialog.file);
        }
    }

    background: Rectangle {
        color: "#f4f6f9"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            RowLayout {
                spacing: 16
                Rectangle {
                    width: 54; height: 54; radius: 16
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#2563eb" }
                        GradientStop { position: 1.0; color: "#1e40af" }
                    }
                    Label { anchors.centerIn: parent; text: "⚡"; font.pixelSize: 24 }
                }
                ColumnLayout {
                    spacing: 3
                    Label {
                        text: "Панель администратора"
                        font.pixelSize: 26
                        font.bold: true
                        color: "#0f172a"
                    }
                    Label {
                        text: "Фитнес-клуб • Система управления"
                        font.pixelSize: 13
                        color: "#64748b"
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Выйти"
                Layout.preferredHeight: 42
                Layout.preferredWidth: 160

                background: Rectangle {
                    color: parent.hovered ? "#fef2f2" : "#ffffff"
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
                onClicked: adminRoot.logoutRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Connections {
                target: clientModel
                function onDataChanged() { statsTimer.restart(); }
                function onRowsInserted() { statsTimer.restart(); }
                function onRowsRemoved() { statsTimer.restart(); }
                function onRevenueChanged() { statsTimer.restart(); }
            }

            Connections {
                target: visitModel
                function onRowsInserted() { statsTimer.restart(); }
                function onRowsRemoved() { statsTimer.restart(); }
            }

            Timer {
                id: statsTimer
                interval: 10
                onTriggered: {
                    totalClientsLabel.text = clientModel.rowCount();
                    totalRevenueLabel.text = clientModel.getTotalRevenue() + " руб.";
                    totalVisitsLabel.text = visitModel.rowCount();
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 100
                color: "white"; border.color: "#e2e8f0"; radius: 16

                RowLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 18
                    Rectangle {
                        width: 52; height: 52; radius: 14; color: "#eff6ff"
                        Label { anchors.centerIn: parent; text: "👥"; font.pixelSize: 22 }
                    }
                    ColumnLayout {
                        spacing: 3
                        Label { text: "Всего клиентов"; color: "#64748b"; font.pixelSize: 12; font.bold: true }
                        Label { id: totalClientsLabel; text: clientModel.rowCount(); color: "#0f172a"; font.pixelSize: 24; font.bold: true }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 100
                color: "white"; border.color: "#e2e8f0"; radius: 16

                RowLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 18
                    Rectangle {
                        width: 52; height: 52; radius: 14; color: "#f0fdf4"
                        Label { anchors.centerIn: parent; text: "💰"; font.pixelSize: 22 }
                    }
                    ColumnLayout {
                        spacing: 3
                        Label { text: "Общий доход"; color: "#64748b"; font.pixelSize: 12; font.bold: true }
                        Label { id: totalRevenueLabel; text: clientModel.getTotalRevenue() + " руб."; color: "#16a34a"; font.pixelSize: 24; font.bold: true }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 100
                color: "white"; border.color: "#e2e8f0"; radius: 16

                RowLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 18
                    Rectangle {
                        width: 52; height: 52; radius: 14; color: "#f5f3ff"
                        Label { anchors.centerIn: parent; text: "🕒"; font.pixelSize: 22 }
                    }
                    ColumnLayout {
                        spacing: 3
                        Label { text: "Всего визитов"; color: "#64748b"; font.pixelSize: 12; font.bold: true }
                        Label { id: totalVisitsLabel; text: visitModel.rowCount(); color: "#7c3aed"; font.pixelSize: 24; font.bold: true }
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: 20
            columnSpacing: 20

            Component {
                id: dashboardTile
                Button {
                    property string tileIcon: ""
                    property string tileTitle: ""
                    property string tileDesc: ""

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 130

                    background: Rectangle {
                        color: parent.hovered ? "#f8fafc" : "#ffffff"
                        border.color: parent.hovered ? "#2563eb" : "#e2e8f0"
                        border.width: parent.hovered ? 2 : 1
                        radius: 16
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 18
                        Rectangle {
                            width: 58; height: 58; radius: 14
                            color: "#f1f5f9"
                            border.color: "#e2e8f0"
                            Label { anchors.centerIn: parent; text: tileIcon; font.pixelSize: 26 }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 6
                            Label { text: tileTitle; font.bold: true; color: "#0f172a"; font.pixelSize: 17 }
                            Label { text: tileDesc; color: "#64748b"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }
                }
            }

            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "📂"; item.tileTitle = "База клиентов"; item.tileDesc = "Просмотр карточек клиентов клуба"; item.clicked.connect(() => clientListPopup.open()) } }
            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "➕"; item.tileTitle = "Регистрация клиента"; item.tileDesc = "Оформление абонементов"; item.clicked.connect(() => registerPopup.open()) } }
            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "🏃"; item.tileTitle = "Учёт посещений"; item.tileDesc = "Сканирование приходов и актуальный лог визитов"; item.clicked.connect(() => visitsPopup.open()) } }
            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "📊"; item.tileTitle = "Отчёты и финансы"; item.tileDesc = "Генерация аналитики доходов и посещаемости"; item.clicked.connect(() => { reportOutputText.text = reportManager.generateReport(clientModel.rowCount(), visitModel.rowCount(), clientModel.getTotalRevenue()); reportPopup.open(); }) } }
            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "🔔"; item.tileTitle = "Уведомления"; item.tileDesc = "Контроль истекающих сроков действия абонементов"; item.clicked.connect(() => { notificationManager.checkExpirations(clientModel); notificationsPopup.open(); }) } }
            Loader { Layout.fillWidth: true; Layout.fillHeight: true; sourceComponent: dashboardTile; onLoaded: { item.tileIcon = "💳"; item.tileTitle = "Тарифы клуба"; item.tileDesc = "Динамическая настройка стоимости услуг"; item.clicked.connect(() => tariffsPopup.open()) } }
        }
    }

    Popup {
        id: clientListPopup; width: 680; height: 520; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            RowLayout {
                Layout.fillWidth: true
                Label { text: "📂 Управление базой клиентов"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
                Item { Layout.fillWidth: true }

                // Кнопки импорта и экспорта в шапке слева от кнопки закрытия
                Button {
                    text: "📤 Экспорт"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 100
                    background: Rectangle { color: parent.hovered ? "#f1f5f9" : "#ffffff"; border.color: "#cbd5e1"; radius: 8 }
                    onClicked: exportDialog.open()
                }
                Button {
                    text: "📥 Импорт"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 100
                    background: Rectangle { color: parent.hovered ? "#f1f5f9" : "#ffffff"; border.color: "#cbd5e1"; radius: 8 }
                    onClicked: importDialog.open()
                }

                Button { text: "✕"; onClicked: clientListPopup.close(); Layout.preferredWidth: 38; Layout.preferredHeight: 38 }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 12
                ComboBox { id: statusFilterCombo; model: ["Все статусы", "Только активные", "Только истекшие"]; Layout.preferredWidth: 200; Layout.preferredHeight: 40; onActivated: clientModel.setStatusFilter(index) }
                TextField { id: searchField; placeholderText: "🔍 Поиск по ФИО клиента..."; Layout.fillWidth: true; Layout.preferredHeight: 40; onTextChanged: clientModel.setFilter(searchField.text) }
            }
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: clientModel; spacing: 8
                delegate: Rectangle {
                    width: parent.width; height: 52; color: index % 2 === 0 ? "#ffffff" : "#f8fafc"; border.color: "#e2e8f0"; radius: 10
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 14
                        MouseArea {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            onClicked: {
                                let fullText = model.clientData !== undefined ? model.clientData.toString() : "";
                                let clientName = fullText.split(" | ")[0].replace("👤", "").trim();
                                selectedClientDetails = clientModel.getClientInfoByName(clientName);
                                clientDetailsPopup.open();
                            }
                            RowLayout {
                                anchors.fill: parent; spacing: 14
                                Rectangle {
                                    width: 12; height: 12; radius: 6
                                    color: (model.clientData && model.clientData.toString().includes("Заморожен")) ? "#eab308" :
                                           (model.clientData && model.clientData.toString().includes("Истёк")) ? "#ef4444" : "#22c55e"
                                }
                                Text { text: model.clientData !== undefined ? model.clientData : ""; font.pixelSize: 14; font.bold: true; color: "#1e293b"; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                        }
                        Button { text: "Удалить"; Layout.preferredWidth: 85; Layout.preferredHeight: 34; onClicked: clientModel.removeClient(index) }
                    }
                }
            }
        }
    }

    Popup {
        id: registerPopup; width: 480; height: 440; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            Label { text: "➕ Регистрация клиента"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
            GridLayout {
                columns: 2; rowSpacing: 16; columnSpacing: 16; Layout.fillWidth: true
                Label { text: "ФИО:"; color: "#64748b"; font.bold: true }
                TextField { id: nameField; placeholderText: "Иванов Иван"; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                Label { text: "Пароль:"; color: "#64748b"; font.bold: true }
                TextField { id: passFieldInput; placeholderText: "Для входа в личный кабинет"; echoMode: TextInput.Password; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                Label { text: "Телефон:"; color: "#64748b"; font.bold: true }
                TextField { id: phoneField; placeholderText: "+7 (000) 000-00-00"; inputMask: "+7 (000) 000-00-00"; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                Label { text: "Тариф:"; color: "#64748b"; font.bold: true }
                ComboBox {
                    id: strategyComboBox; Layout.fillWidth: true; Layout.preferredHeight: 40
                    model: [
                        "Разовый (" + adminRoot.priceOnce + " руб.)",
                        "Месячный льготный (" + adminRoot.priceDiscount + " руб.)",
                        "Месячный (" + adminRoot.priceStandard + " руб.)"
                    ]
                }
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Layout.alignment: Qt.AlignRight; spacing: 12
                Button { text: "Отмена"; onClicked: registerPopup.close(); Layout.preferredHeight: 40; Layout.preferredWidth: 100 }
                Button {
                    text: "Зарегистрировать"; Layout.preferredHeight: 40; Layout.preferredWidth: 150
                    onClicked: {
                        if (nameField.text.trim() !== "" && phoneField.text.indexOf("_") === -1) {
                            let uniqueId = "ID-" + Math.floor(Math.random() * 900 + 100);
                            let clientPassword = passFieldInput.text.trim() !== "" ? passFieldInput.text.trim() : "1234";
                            clientModel.addClientWithCustomPrices(uniqueId, nameField.text.trim(), phoneField.text.trim(), strategyComboBox.currentIndex, clientPassword, adminRoot.priceOnce, adminRoot.priceDiscount, adminRoot.priceStandard);
                            nameField.text = ""; phoneField.text = ""; passFieldInput.text = "";
                            registerPopup.close();
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: visitsPopup; width: 520; height: 480; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            Label { text: "🏃 Учёт посещений клуба"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
            TextField { id: clientNameInput; placeholderText: "Введите точное ФИО клиента..."; Layout.fillWidth: true; Layout.preferredHeight: 42 }
            Button {
                text: "Отметить приход клиента"
                Layout.fillWidth: true; Layout.preferredHeight: 40
                onClicked: {
                    let typedName = clientNameInput.text.trim();
                    if (typedName === "") return;

                    if (clientModel.clientExists(typedName)) {
                        let clientInfo = clientModel.getClientInfoByName(typedName);

                        if (clientInfo.status === "Активен") {
                            visitModel.addVisit(typedName);
                            clientModel.markClientVisit(typedName);
                            clientNameInput.text = "";
                            visitStatusLabel.text = "✓ Успешно: приход зафиксирован!";
                            visitStatusLabel.color = "#16a34a";
                        } else if (clientInfo.status === "Заморожен") {
                            visitStatusLabel.text = "❄️ Ошибка: абонемент заморожен!";
                            visitStatusLabel.color = "#ca8a04";
                        } else {
                            visitStatusLabel.text = "✕ Ошибка: абонемент истёк!";
                            visitStatusLabel.color = "#dc2626";
                        }
                    } else {
                        visitStatusLabel.text = "✕ Ошибка: клиент не найден в базе!";
                        visitStatusLabel.color = "#dc2626";
                    }
                }
            }
            Label { id: visitStatusLabel; text: ""; font.pixelSize: 13; font.bold: true }
            Label { text: "Последние визиты:"; font.bold: true; color: "#475569" }
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: visitModel; spacing: 8
                delegate: Rectangle {
                    width: parent.width; height: 40; color: "#f8fafc"; border.color: "#e2e8f0"; radius: 8
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: "👤 " + (model.clientName || "") + " | 🕒 " + (model.visitTime || ""); Layout.fillWidth: true; font.pixelSize: 13 }
                        Button { text: "Удалить"; Layout.preferredWidth: 65; Layout.preferredHeight: 28; onClicked: visitModel.removeVisit(index) }
                    }
                }
            }
        }
    }

    Popup {
        id: reportPopup; width: 500; height: 380; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            Label { text: "📊 Финансовый отчёт"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
            Text { id: reportOutputText; text: ""; font.pixelSize: 14; color: "#1e293b"; wrapMode: Text.WordWrap; Layout.fillWidth: true; Layout.fillHeight: true }
            Button { text: "Закрыть"; Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 130; Layout.preferredHeight: 40; onClicked: reportPopup.close() }
        }
    }

    Popup {
        id: notificationsPopup; width: 700; height: 450; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            Label { text: "🔔 Системные уведомления"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: notificationManager.notifications
                delegate: Text { text: "⚠️ " + modelData; color: "#dc2626"; font.pixelSize: 14; font.bold: true }
            }
            Button { text: "Закрыть"; Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 130; Layout.preferredHeight: 40; onClicked: notificationsPopup.close() }
        }
    }

    Popup {
        id: tariffsPopup; width: 460; height: 400; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            RowLayout {
                Layout.fillWidth: true
                Label { text: "💳 Управление тарифами"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
                Item { Layout.fillWidth: true }
                Button { text: "✕"; onClicked: tariffsPopup.close(); Layout.preferredWidth: 38; Layout.preferredHeight: 38 }
            }
            GridLayout {
                columns: 2; rowSpacing: 16; columnSpacing: 16; Layout.fillWidth: true
                Label { text: "Разовый визит:"; color: "#64748b"; font.bold: true }
                TextField { id: priceOnceField; text: adminRoot.priceOnce; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                Label { text: "Месячный льготный:"; color: "#64748b"; font.bold: true }
                TextField { id: priceDiscountField; text: adminRoot.priceDiscount; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                Label { text: "Месячный стандарт:"; color: "#64748b"; font.bold: true }
                TextField { id: priceStandardField; text: adminRoot.priceStandard; Layout.fillWidth: true; Layout.preferredHeight: 40 }
            }
            Item { Layout.fillHeight: true }
            Label { id: tariffStatusLabel; text: ""; font.pixelSize: 13; font.bold: true; color: "#16a34a"; Layout.alignment: Qt.AlignHCenter }
            Button {
                text: "Сохранить новые цены"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 42
                onClicked: {
                    if (priceOnceField.text.trim() !== "") adminRoot.priceOnce = parseFloat(priceOnceField.text);
                    if (priceDiscountField.text.trim() !== "") adminRoot.priceDiscount = parseFloat(priceDiscountField.text);
                    if (priceStandardField.text.trim() !== "") adminRoot.priceStandard = parseFloat(priceStandardField.text);

                    clientModel.savePricesToDisk(adminRoot.priceOnce, adminRoot.priceDiscount, adminRoot.priceStandard);

                    tariffStatusLabel.text = "✓ Цены успешно сохранены в систему!";
                    tariffStatusLabel.color = "#16a34a";
                }
            }
        }
    }

    Popup {
        id: clientDetailsPopup; width: 420; height: 440; anchors.centerIn: parent; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 20; border.color: "#e2e8f0" }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            RowLayout {
                Layout.fillWidth: true
                Label { text: "👤 Карточка клиента"; font.pixelSize: 22; font.bold: true; color: "#0f172a" }
                Item { Layout.fillWidth: true }
                Button { text: "✕"; onClicked: clientDetailsPopup.close(); Layout.preferredWidth: 38; Layout.preferredHeight: 38 }
            }
            GridLayout {
                columns: 2; rowSpacing: 12; columnSpacing: 16; Layout.fillWidth: true
                Label { text: "ФИО:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.name : ""; font.bold: true; font.pixelSize: 13; color: "#1e293b" }
                Label { text: "Телефон:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.phone : ""; font.pixelSize: 13; color: "#1e293b" }
                Label { text: "Абонемент:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.membershipType : ""; font.pixelSize: 13; color: "#1e293b" }
                Label { text: "Стоимость:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.price + " руб." : ""; font.bold: true; font.pixelSize: 13; color: "#16a34a" }
                Label { text: "Действует до:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.expiryDate : ""; font.pixelSize: 13; color: "#1e293b" }
                Label { text: "Пароль:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.password : ""; font.bold: true; font.pixelSize: 13; color: "#dc2626" }
                Label { text: "Статус:"; color: "#64748b"; font.pixelSize: 13 }
                Label { text: selectedClientDetails ? selectedClientDetails.status : ""; font.bold: true; font.pixelSize: 13; color: (selectedClientDetails && selectedClientDetails.status === "Активен") ? "#16a34a" : "#dc2626" }
            }
            Item { Layout.fillHeight: true }
            Button { text: "Закрыть"; Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 150; Layout.preferredHeight: 40; onClicked: clientDetailsPopup.close() }
        }
    }
}