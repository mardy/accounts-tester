import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.OnlineAccounts 2.0

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
        title: i18n.tr("Test owncloud authentication")

        ListItem.Standard {
            id: requestPasswordPolicyField
            text: i18n.tr("Request password from user")
            visible: false // enable when https://bugs.launchpad.net/bugs/1544863 gets fixed
            control: CheckBox {
                id: requestPasswordPolicyBtn
            }
        }

        ListView {
            id: accountsList
            spacing: units.gu(1)
            anchors {
                top: requestPasswordPolicyField.bottom
                left: parent.left
                right: parent.right
                bottom: authorizeBtn.top
            }
            model: accountsModel
            delegate: Rectangle {
                id: wrapper
                width: accountsList.width
                height: units.gu(10)
                color: "green"

                Connections {
                    target: model.account
                    onAuthenticationReply: if ("errorCode" in authenticationData) {
                        console.warn("Authentication error: " + authenticationData.errorText + " (" + authenticationData.errorCode + ")")
                        accountsList.headerItem.text = "Error " + authenticationData.errorCode + ": " + authenticationData.errorText
                    } else {
                        console.log("Got authenticationData: " + JSON.stringify(authenticationData))
                        accountsList.headerItem.text = authenticationData.Password
                    }
                }

                Button {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)

                    text: i18n.tr("Authenticate %1").arg(displayName)
                    iconSource: model.account.service.iconSource

                    onClicked: {
                        var params = {}
                        if (requestPasswordPolicyBtn.checked) {
                            params["invalidateCachedReply"] = true
                        }
                        model.account.authenticate(params)
                    }
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
            visible: accountsModel.ready
            onClicked: accountsModel.requestAccess("it.mardy.account-tester_owncloud-tester_owncloud", {})
        }
    }

    AccountModel {
        id: accountsModel
        applicationId: "it.mardy.account-tester_owncloud-tester"
    }
}
