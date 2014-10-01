import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.OnlineAccounts 0.1

Column {
    id: root

    property variant __account: account

    signal finished

    anchors.margins: units.gu(1)
    spacing: units.gu(2)

    Label {
        text: i18n.dtr("account-tester", "Username:")

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.anchors.margins
    }

    TextField {
        id: usernameField
        objectName: "usernameField"
        placeholderText: i18n.dtr("account-tester", "Your username")
        width: root.width - (2 * root.anchors.margins)
        anchors.left: parent.left
        anchors.margins: parent.anchors.margins
        focus: true
        KeyNavigation.tab: passwordField
    }

    Label {
        text: i18n.dtr("account-tester", "Password:")
    }

    TextField {
        id: passwordField
        objectName: "passwordField"
        placeholderText: i18n.dtr("account-tester", "Your password")
        echoMode: TextInput.Password
        width: root.width - (2 * root.anchors.margins)

        inputMethodHints: Qt.ImhSensitiveData
    }

    Row {
        id: buttons
        height: units.gu(5)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: units.gu(1)
        Button {
            id: btnCancel
            objectName: "cancelButton"
            text: i18n.dtr("account-tester", "Cancel")
            color: "#1c091a"
            height: parent.height
            width: (parent.width / 2) - 0.5 * parent.spacing
            onClicked: finished()
        }
        Button {
            id: btnContinue
            objectName: "continueButton"
            text: i18n.dtr("account-tester", "Continue")
            color: "#cc3300"
            height: parent.height
            width: (parent.width / 2) - 0.5 * parent.spacing
            onClicked: {
                account.updateDisplayName(usernameField.text)
                creds.userName = usernameField.text
                creds.secret = passwordField.text
                creds.sync()
            }
        }
    }

    Credentials {
        id: creds
        caption: account.provider.id
        acl: ["unconfined"]
        storeSecret: true
        onCredentialsIdChanged: root.credentialsStored()
    }

    AccountService {
        id: globalAccountSettings
        objectHandle: account.accountServiceHandle
        autoSync: false
    }

    function credentialsStored() {
        console.log("Credentials stored, id: " + creds.credentialsId)
        if (creds.credentialsId == 0) return

        globalAccountSettings.updateServiceEnabled(true)
        globalAccountSettings.credentials = creds
        account.synced.connect(finished)
        account.sync()
    }

}
