import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
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
 
    PageStack {
        id: pageStack
        Component.onCompleted: push(accountListPage)
    }

    Page {
        id: accountListPage

        header: PageHeader {
            title: i18n.tr("Test account creation")
            flickable: accountsList
        }

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
                        var response = ""
                        switch (model.authenticationMethod) {
                            case Account.AuthenticationMethodSasl:
                                response = authenticationData.Response; break;
                            case Account.AuthenticationMethodPassword:
                                response = authenticationData.Password; break;
                            case Account.AuthenticationMethodOAuth1:
                            case Account.AuthenticationMethodOAuth2:
                                response = authenticationData.AccessToken; break;
                        }
                        console.log("Response " + response)
                        accountsList.headerItem.text = response
                    }
                }

                Button {
                    anchors.fill: parent
                    anchors.margins: units.gu(2)

                    text: i18n.tr("Authenticate %1").arg(displayName)
                    iconSource: model.account.service.iconSource

                    onClicked: {
                        var params = {}
                        if (model.authenticationMethod == Account.AuthenticationMethodSasl) {
                            params["MechList"] = "PLAIN"
                            if (requestPasswordPolicyBtn.checked) {
                                params["invalidateCachedReply"] = true
                            }
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
            text: i18n.tr("Create new account")
            visible: accountsModel.ready
            onClicked: pageStack.push(providerListPage)
        }
    }

    Component {
        id: providerListPage
        Page {
            header: PageHeader {
                title: i18n.tr("Choose provider")
                flickable: providersList
            }

            ListView {
                id: providersList
                spacing: units.gu(1)
                anchors.fill: parent
                model: accountsModel.serviceList
                delegate: ListItem.Standard {
                    text: modelData.displayName
                    iconSource: modelData.iconSource
                    onTriggered: accountsModel.requestAccess(modelData.serviceId, {})
                }
            }
        }
    }

    AccountModel {
        id: accountsModel
        applicationId: "it.mardy.account-tester_provider-tester"
        onCountChanged: if (pageStack.depth > 1) pageStack.pop()
    }
}
