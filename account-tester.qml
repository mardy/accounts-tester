import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "it.mardy.account-tester"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(100)
    height: units.gu(75)
    
    Page {
        title: i18n.tr("Test account access")

        ListView {
            id: accountsList
            spacing: units.gu(1)
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: authorizeBtn.top
            }
            model: accountsModel
            delegate: Rectangle {
                id: wrapper
                width: accountsList.width
                height: units.gu(10)
                color: accts.enabled ? "green" : "red"

                AccountService {
                    id: accts
                    objectHandle: accountServiceHandle
                    onAuthenticated: accountsList.headerItem.text = reply.Secret
                    onAuthenticationError: {
                        console.log("Authentication failed, code " + error.code)
                        accountsList.headerItem.text = "Error " + error.code
                    }
                }

                Button {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)

                    text: i18n.tr("Authenticate %1").arg(displayName)

                    onClicked: accts.authenticate(null)
                }
            }
            header: Label {
                id: resultLabel
                width: accountsList.width
                height: units.gu(5)
                text: i18n.tr("Result")
            }
        }

        Button {
            id: authorizeBtn
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            text: i18n.tr("Request access")
            onClicked: setup.exec()
        }
    }

    AccountServiceModel {
        id: accountsModel
        includeDisabled: true
        serviceType: "account-tester-type"
    }

    Setup {
        id: setup
        providerId: "it.mardy.account-tester_plugin"
        applicationId: "it.mardy.account-tester_account-tester"
    }
}
