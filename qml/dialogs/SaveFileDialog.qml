import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import FileSaver 1.0

Dialog {
    id: page
    property string name
    property string selectedPath: ""
    property string fileContent
    property bool _fileExists : true

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function _checkFileExists() {
        _fileExists = FileSaver.exists(selectedPath, nameField.text)
    }

    Component {
        id: folderPickerPage

        FolderPickerPage {
            dialogTitle: qsTr("Export to")
            onSelectedPathChanged: {
                page.selectedPath = selectedPath
                _checkFileExists()
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        DialogHeader {
            acceptText: _fileExists ? qsTr("Override") : defaultAcceptText
        }

        Column {
            id: column
            anchors.bottom: parent.bottom
            width: parent.width
            height: nameField.height + passwordField.height


            TextField {
                id: nameField
                width: parent.width
                text: name
                placeholderText: qsTr("File name")
                label: _fileExists ? qsTr("File exists") : qsTr("File name")

                leftItem: _fileExists ? warn : null

                onTextChanged: {
                    _checkFileExists()
                }
            }


            TextField {
                id: passwordField
                text: selectedPath
                placeholderText: qsTr("Path")
                label: qsTr("Path")
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-folder"
                EnterKey.onClicked: {
                    pageStack.push(folderPickerPage)
                }

                rightItem: IconButton {
                    onClicked: {
                        pageStack.push(folderPickerPage)
                    }

                    width: icon.width
                    height: icon.height
                    icon.source: "image://theme/icon-m-folder"
                }
            }
        }
    }

    Icon {
        id: warn
        source: "image://theme/icon-s-warning?" + Theme.highlightColor
        visible: _fileExists
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            FileSaver.saveTo(fileContent, selectedPath, nameField.text, true)
        }
    }

}

