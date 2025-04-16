import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: usuariosRolesRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedades para la edición de usuarios
    property var nuevoUsuario: { "id_rol": 5, "nombre": "", "apellido": "", "usuario": "", "correo": "", "contrasena": "" }
    property bool hayCambiosPendientes: false
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE ACCESO AL SISTEMA"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }

    // Contenido principal con pestañas
    TabBar {
        id: tabBar
        width: parent.width
        anchors.top: titleBar.bottom
        spacing: 20

        background: Rectangle {
            color: "white"
            Rectangle {
                width: parent.width 
                height: 0
                color: "#EEEEEE"
                anchors.bottom: parent.bottom
            }
        }

        TabButton {
            text: "Usuarios"
            width: implicitWidth + 50
            height: 30
            background: Rectangle {
                color: parent.checked ? "#32CD32":"#4CAF50"
                radius: height / 2
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        TabButton {
            text: "Roles y Permisos"
            width: implicitWidth + 50
            height: 30
            background: Rectangle {
                color: parent.checked ? "#32CD32":"#4CAF50"
                radius: height / 2
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Contenedor de páginas de pestañas
    StackLayout {
        width: parent.width
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        currentIndex: tabBar.currentIndex

        // Página de Usuarios
        Item {
            // Barra de acciones
            Rectangle {
                id: actionBar
                width: parent.width
                height: 50
                color: "white"
                radius: 25
                border.color: "#EEEEEE"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    spacing: 10

                    Button {
                        text: "Nuevo Usuario"
                        icon.source: "Image/Image_UI_interfaz/Inconos/agregar-usuario.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#f5922f"
                            radius: height / 2
                        }
                        onClicked: {
                            // Inicializa los valores para el nuevo usuario
                            nuevoUsuario = { 
                                "id_rol": 1, 
                                "nombre": "", 
                                "apellido": "", 
                                "usuario": "", 
                                "correo": "", 
                                "contrasena": "" 
                            }
                            
                            // para abrir una ventana secundaria...
                            nuevoUsuarioDialog.open()
                        }
                    }

                    TextField {
                        placeholderText: "Buscar usuario..."
                        implicitWidth: 450
                        implicitHeight: 25
                        background: Rectangle {
                            color: "#b2c4c9"
                            radius: height / 2
                        }
                    }
                }
            }

            // Tabla de usuarios
            Rectangle {
                anchors.top: actionBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                // Aqui visualisamos los usuario que ya tenemos registrados en la base de datos
                ListView {
                    id: usuariosListView
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    model: usuariosRolesModel.usuarios
                    headerPositioning: ListView.OverlayHeader

                    // Cabecera de la tabla
                    header: Rectangle {
                        width: parent.width
                        height: 40
                        color: "#F5F5F5"
                        z: 2

                        Row {
                            anchors.fill: parent

                            Text {
                                width: parent.width * 0.05
                                height: parent.height
                                text: "ID"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                width: parent.width * 0.2
                                height: parent.height
                                text: "Nombre Completo"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.2
                                height: parent.height
                                text: "Usuario"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.25
                                height: parent.height
                                text: "Correo"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.15
                                height: parent.height
                                text: "Rol"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.15
                                height: parent.height
                                text: "Acciones"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // Delegado para cada fila
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                        // Usamos Row con Rectangles para cada columna
                        Row {
                            anchors.fill: parent
                            spacing: 0  // Sin espaciado entre columnas

                            // Columna ID
                            Rectangle {
                                width: parent.width * 0.05
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.id_usuario
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // Columna Nombre Completo
                            Rectangle {
                                width: parent.width * 0.2
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.nombre_completo
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Usuario
                            Rectangle {
                                width: parent.width * 0.2
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.usuario
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Correo
                            Rectangle {
                                width: parent.width * 0.25
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.correo
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Rol
                            Rectangle {
                                width: parent.width * 0.15
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.rol
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Acciones
                            Rectangle {
                                width: parent.width * 0.15
                                height: parent.height
                                color: "transparent"
                                
                                Row {
                                    spacing: 10
                                    anchors.centerIn: parent
                                    
                                    Button {
                                        width: 36
                                        height: 36
                                        icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Editar"
                                        onClicked: {
                                            editUsuarioDialog.prepararEdicion(modelData);
                                            editUsuarioDialog.open();
                                            
                                        }
                                    }
                                    
                                    Button {
                                        width: 36
                                        height: 36
                                        icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Eliminar"
                                        onClicked: {
                                            // Aquí llamamos al DIALOGO donde nos muestra si estamos seguros de eliminar a ese usuario
                                            confirmDeleteDialog.userId = modelData.id_usuario;
                                            confirmDeleteDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Mensaje cuando no hay datos
                    Text {
                        anchors.centerIn: parent
                        text: "No hay usuarios registrados.\nHaga clic en 'Nuevo Usuario' para agregar uno."
                        color: "#757575"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        visible: usuariosRolesModel.usuarios.length === 0
                    }
                }
            }
        }

        // Página de Roles y Permisos (simplificada para ahora)
        Item {
            // Panel de roles
            Rectangle {
                id: rolesPanel
                width: parent.width * 0.3
                height: parent.height
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Roles"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: usuariosRolesModel.roles
                        spacing: 5

                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: ListView.isCurrentItem ? "#E3F2FD" : "transparent"
                            radius: 4

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                                text: modelData.nombre
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    parent.ListView.view.currentIndex = index;
                                    // Cargar los permisos para este rol
                                    usuariosRolesModel.cargar_permisos_por_rol(modelData.id_rol);
                                    hayCambiosPendientes = false; // Reiniciamos el estado
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay roles definidos."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: usuariosRolesModel.roles.length === 0
                        }
                    }

                    Button {
                        text: "Nuevo Rol"
                        Layout.fillWidth: true
                        implicitHeight: 36
                        onClicked: {
                            // Aquí también deberíamos usar un diálogo en lugar de un mensaje simple
                            nuevoRolDialog.open();
                        }
                    }
                }
            }

            // Panel de permisos
            Rectangle {
                anchors.left: rolesPanel.right
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "Permisos del Rol: Seleccione un rol"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    // Lista de permisos con checkboxes
                    ListView {
                        id: permisosListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: usuariosRolesModel.permisos
                        spacing: 10

                        delegate: RowLayout {
                            width: parent ? parent.width : 0
                            height: 40
                            spacing: 15

                            CheckBox {
                                id: permisoCheck   
                                checked: modelData.permitido
                                Layout.leftMargin: 10
                                onCheckedChanged: {
                                    // Actualizar el modelo local temporalmente
                                    // La actualización permanente ocurrirá cuando se guarden los cambios
                                    if (checked !== modelData.permitido) {
                                        // Marcamos visualmente que ha habido cambios
                                        hayCambiosPendientes = true
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: modelData.seccion
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Text {
                                    text: modelData.descripcion
                                    font.pixelSize: 12
                                    color: "#757575"
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay permisos definidos o\nno se ha seleccionado ningún rol."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: usuariosRolesModel.permisos.length === 0
                        }
                    }

                    // Botones de acción
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        spacing: 10

                        Button {
                            text: "Cancelar"
                            implicitHeight: 36
                            flat: true
                        }

                        Button {
                            text: "Guardar Cambios"
                            implicitHeight: 36
                            enabled: hayCambiosPendientes
                            opacity: enabled ? 1.0 : 0.5
                            onClicked: {
                                var permisosActualizados = [];
                                for (let i = 0; i < permisosListView.count; i++) {
                                    let item = permisosListView.itemAtIndex(i);
                                    if (item) {
                                        let checkBox = item.children[0]; // El primer hijo es el CheckBox
                                        
                                        permisosActualizados.push({
                                            seccion: usuariosRolesModel.permisos[i].seccion,
                                            permitido: checkBox.checked
                                        });
                                    }
                                }
                                // Aquí necesitas implementar en tu modelo Python un método para guardar los permisos
                                // var exito = usuariosRolesModel.guardarPermisos(rolSeleccionadoId, permisosActualizados);
                                
                                // Por ahora, mostramos un mensaje:
                                showMessage("Cambios guardados correctamente (función en desarrollo)");
                                hayCambiosPendientes = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVO USUARIO
    Dialog {
        id: nuevoUsuarioDialog
        title: "Nuevo Usuario"
        modal: true
        width: 550
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"

            ScrollView {
                id: scrollView
                anchors.fill: parent
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    id: mainColumn
                    width: scrollView.width - 30 // Asegurar que no se extienda demasiado
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    spacing: 15

                    // Título
                    Text {
                        text: "Agregar Nuevo Usuario"
                        font.pixelSize: 18
                        font.bold: true
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Formulario
                    GridLayout {
                        width: parent.width
                        columns: 2
                        columnSpacing: 15
                        rowSpacing: 10

                        // Nombre
                        Text {
                            text: "Nombre:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtNombre
                            placeholderText: "Ingrese nombre"
                            Layout.fillWidth: true
                            height: 36
                            onTextChanged: nuevoUsuario.nombre = text
                        }

                        // Apellido
                        Text {
                            text: "Apellido:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtApellido
                            placeholderText: "Ingrese apellido"
                            Layout.fillWidth: true
                            height: 36
                            onTextChanged: nuevoUsuario.apellido = text
                        }

                        // Usuario
                        Text {
                            text: "Usuario:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtUsuario
                            placeholderText: "Ingrese nombre de usuario"
                            Layout.fillWidth: true
                            height: 36
                            onTextChanged: nuevoUsuario.usuario = text
                        }

                        // Teléfono Usuario
                        Text {
                            text: "Teléfono:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtTelefono
                            placeholderText: "000-000-00"
                            Layout.fillWidth: true
                            height: 36
                            onTextChanged: nuevoUsuario.telefono = text
                        }

                        // Dirección Usuario
                        Text {
                            text: "Dirección:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtDireccion
                            placeholderText: "Ingresa tu dirección"
                            Layout.fillWidth: true
                            height: 36
                            onTextChanged: nuevoUsuario.direccion = text
                        }

                        // Correo electrónico
                        Text {
                            text: "Correo electrónico:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtCorreo
                            placeholderText: "Ingrese correo electrónico"
                            Layout.fillWidth: true
                            height: 36
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                            onTextChanged: nuevoUsuario.correo = text
                        }

                        // Rol
                        Text {
                            text: "Rol:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        ComboBox {
                            id: cmbRol
                            Layout.fillWidth: true
                            height: 36
                            model: usuariosRolesModel.roles
                            textRole: "nombre"
                            onCurrentIndexChanged: {

                                if (currentIndex >= 0 && model && currentIndex < model.length) {
                                    nuevoUsuario.id_rol = model[currentIndex].id_rol;
                                }
                            }
                            Component.onCompleted: {
                                currentIndex = 0;  // Simplemente selecciona el primer elemento
                            }
                        }

                        // Contraseña
                        Text {
                            text: "Contraseña:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtPassword
                            placeholderText: "Ingrese contraseña"
                            Layout.fillWidth: true
                            height: 36
                            echoMode: TextInput.Password
                            onTextChanged: nuevoUsuario.contrasena = text
                        }

                        // Confirmar contraseña
                        Text {
                            text: "Confirmar contraseña:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtConfirmPassword
                            placeholderText: "Confirme la contraseña"
                            Layout.fillWidth: true
                            height: 36
                            echoMode: TextInput.Password
                        }

                        // Fecha de creación
                        Text {
                            text: "Fecha de creación:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }

                        TextField {
                            id: txtFechaCreacion
                            placeholderText: "DD/MM/AAAA"
                            Layout.fillWidth: true
                            height: 36
                            readOnly: true
                            text: getFormattedDate()
                        }
                    }

                    // Espacio adicional
                    Item {
                        width: parent.width
                        height: 20
                    }

                    // Mensaje de validación
                    Rectangle {
                        width: parent.width
                        height: mensajeValidacion.text ? mensajeValidacion.height + 20 : 0
                        color: "#FFF0F0"
                        border.color: "#FFD0D0"
                        radius: 4
                        visible: mensajeValidacion.text !== ""

                        Text {
                            id: mensajeValidacion
                            anchors.centerIn: parent
                            width: parent.width - 20
                            text: ""
                            color: "#D32F2F"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        footer: DialogButtonBox {
            background: Rectangle {
                color: "#F5F5F5"
                height: 60
            }

            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                implicitHeight: 36
                implicitWidth: 100
                onClicked: nuevoUsuarioDialog.close()
            }

            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                implicitHeight: 36
                implicitWidth: 100
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // Validaciones (mantiene el mismo código)
                    if (txtNombre.text === "" || txtApellido.text === "" || txtUsuario.text === "" || txtCorreo.text === "") {
                        mensajeValidacion.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }

                    var emailRegex = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
                    if (!emailRegex.test(txtCorreo.text)) {
                        mensajeValidacion.text = "El formato del correo electrónico no es válido";
                        return;
                    }

                    if (txtPassword.text === "") {
                        mensajeValidacion.text = "Debe ingresar una contraseña";
                        return;
                    }

                    if (txtPassword.text !== txtConfirmPassword.text) {
                        mensajeValidacion.text = "Las contraseñas no coinciden";
                        return;
                    }

                    if (nuevoUsuario.id_rol <= 0) {
                        mensajeValidacion.text = "Debe seleccionar un rol";
                        return;
                    }

                    // Preparar los datos
                    var datosUsuario = {
                        "id_rol": nuevoUsuario.id_rol,
                        "nombre": txtNombre.text,
                        "apellido": txtApellido.text,
                        "usuario": txtUsuario.text,
                        "correo": txtCorreo.text,
                        "contrasena": txtPassword.text,
                        "telefono": txtTelefono.text,
                        "direccion": txtDireccion.text,
                        "activo": true
                    };

                    console.log("Datos a enviar:", JSON.stringify(datosUsuario));

                    // Guardar usuario
                    var exito = usuariosRolesModel.agregar_usuario(JSON.stringify(datosUsuario));
                    if (exito) {
                        nuevoUsuarioDialog.close();
                        showMessage("Usuario guardado correctamente");
                    } else {
                        mensajeValidacion.text = "Error al guardar el usuario en la base de datos. Verifique que el nombre de usuario y correo sean únicos.";
                    }
                }
            }
        }

        // Resetea el formulario al cerrar
        onClosed: {
            txtNombre.text = ""
            txtApellido.text = ""
            txtUsuario.text = ""
            txtTelefono.text = ""
            txtDireccion.text = ""
            txtCorreo.text = ""
            txtPassword.text = ""
            txtConfirmPassword.text = ""
            cmbRol.currentIndex = 0
            mensajeValidacion.text = ""

            nuevoUsuario = {
                "id_rol": 5,
                "nombre": "",
                "apellido": "",
                "usuario": "",
                "correo": "",
                "contrasena": "",
                "telefono": "",
                "direccion": ""
            }
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR
    Dialog {
        id: confirmDeleteDialog
        title: "Confirmar eliminación"
        modal: true
        
        property int userId: -1
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar este usuario?"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }
                
                Text {
                    width: parent.width
                    text: "Esta acción no se puede deshacer."
                    font.pixelSize: 14
                    font.italic: true
                    color: "#F44336"
                    wrapMode: Text.WordWrap
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Eliminar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: "#F44336"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        onAccepted: {
            var exito = usuariosRolesModel.eliminar_usuario(confirmDeleteDialog.userId);
            if (exito) {
                showMessage("Usuario eliminado correctamente");
            } else {
                showMessage("Error al eliminar el usuario");
            }
        }
    }

    // DIÁLOGO DE NUEVO ROL
    Dialog {
        id: nuevoRolDialog
        title: "Nuevo Rol"
        modal: true
        width: 500
        height: 380
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property var nuevoRol: { "roleId": "", "nombre": "", "descripcion": "", "activo": true }
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: "Agregar Nuevo Rol"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // Formulario
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
                    // Nombre del rol
                    Text {
                        text: "Nombre del Rol*:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreRol
                        placeholderText: "Ej: Administrador, Empleado, etc."
                        Layout.fillWidth: true
                        onTextChanged: nuevoRol.nombre = text
                    }
                    
                    // Descripción
                    Text {
                        text: "Descripción:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtDescripcionRol
                        placeholderText: "Describa las funciones y responsabilidades de este rol"
                        Layout.fillWidth: true
                        wrapMode: TextEdit.Wrap
                        Layout.preferredHeight: 80
                        onTextChanged: nuevoRol.descripcion = text
                    }
                    
                    // Fecha de creación
                    Text {
                        text: "Fecha de creación:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaCreacionRol
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        readOnly: true
                        text: getFormattedDate() // Llamamos a la función para obtener la fecha formateada
                    }
                    
                    // Activo
                    Text {
                        text: "Activo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    CheckBox {
                        id: chkActivoRol
                        checked: true
                        onCheckedChanged: nuevoRol.activo = checked
                    }
                    
                }
                
                // Espacio adicional
                Item {
                    width: parent.width
                    height: 20
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionRol
                    width: parent.width
                    text: ""
                    color: "red"
                    visible: usuariosRolesModel && usuariosRolesModel.usuarios && usuariosRolesModel.usuarios.length === 0
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: nuevoRolDialog.close()
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // Validación de campos obligatorios
                    if (txtNombreRol.text === "") {
                        mensajeValidacionRol.text = "Por favor, ingrese el nombre del rol";
                        return;
                    }
                    
                    // Verificar si el nombre del rol ya existe
                    for (let i = 0; i < usuariosRolesModel.roles.length; i++) {
                        if (usuariosRolesModel.roles[i].nombre.toLowerCase() === txtNombreRol.text.toLowerCase()) {
                            mensajeValidacionRol.text = "Este nombre de rol ya existe";
                            return;
                        }
                    }
                    // Preparar datos para el nuevo rol
                    var datosRol = {
                        "nombre": txtNombreRol.text,
                        "descripcion": txtDescripcionRol.text,
                        "activo": chkActivoRol.checked
                    };

                     // Llamar al modelo para guardar
                    var exito = usuariosRolesModel.agregar_rol(JSON.stringify(datosRol));
                    if (exito) {
                        nuevoRolDialog.close();
                        showMessage("Rol guardado correctamente");
                    } else {
                        mensajeValidacionRol.text = "Error al guardar el rol en la base de datos";
                    }
                }
            }
        }
    
    // Resetea el formulario al cerrar
    onClosed: {
        txtNombreRol.text = ""
        txtDescripcionRol.text = ""
        chkActivoRol.checked = true
        mensajeValidacionRol.text = ""
    }
}
    // DIÁLOGO DE EDICIÓN DE USUARIO
Dialog {
    id: editUsuarioDialog
    title: "Editar Usuario"
    modal: true
    width: 500
    height: 420
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    // Inicializar la propiedad con un objeto vacío
    property var usuarioEditando: null
    
    // Método para preparar el diálogo antes de abrirlo
    function prepararEdicion(usuario) {
        // Crear una copia del objeto usuario para editar
        usuarioEditando = {
            "id_usuario": usuario.id_usuario,
            "nombre": usuario.nombre,
            "apellido": usuario.apellido,
            "usuario": usuario.usuario,
            "correo": usuario.correo,
            "id_rol": usuario.id_rol,
            "activo": usuario.activo
        };
        
        // Actualizar los campos del formulario
        txtEditNombre.text = usuario.nombre || "";
        txtEditApellido.text = usuario.apellido || "";
        txtEditUsuario.text = usuario.usuario || "";
        txtEditCorreo.text = usuario.correo || "";
        chkEditActivo.checked = usuario.activo;
        
        // Seleccionar el rol correcto en el ComboBox
        let rolIndex = -1;
        if (cmbEditRol.model) {
            for (let i = 0; i < cmbEditRol.model.length; i++) {
                if (cmbEditRol.model[i].id_rol === usuario.id_rol) {
                    rolIndex = i;
                    break;
                }
            }
            
            if (rolIndex >= 0) {
                cmbEditRol.currentIndex = rolIndex;
            }
        }
    }
    
    // Contenido del diálogo
    contentItem: Rectangle {
        color: "white"
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Título
            Text {
                text: "Editar Usuario"
                font.pixelSize: 18
                font.bold: true
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Formulario
            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 10
                rowSpacing: 15
                
                // Nombre
                Text {
                    text: "Nombre:"
                    Layout.alignment: Qt.AlignRight
                }
                
                TextField {
                    id: txtEditNombre
                    placeholderText: "Ingrese nombre"
                    Layout.fillWidth: true
                }
                
                // Apellido
                Text {
                    text: "Apellido:"
                    Layout.alignment: Qt.AlignRight
                }
                
                TextField {
                    id: txtEditApellido
                    placeholderText: "Ingrese apellido"
                    Layout.fillWidth: true
                }
                
                // Usuario
                Text {
                    text: "Usuario:"
                    Layout.alignment: Qt.AlignRight
                }
                
                TextField {
                    id: txtEditUsuario
                    placeholderText: "Ingrese nombre de usuario"
                    Layout.fillWidth: true
                }
                
                // Correo electrónico
                Text {
                    text: "Correo electrónico:"
                    Layout.alignment: Qt.AlignRight
                }
                
                TextField {
                    id: txtEditCorreo
                    placeholderText: "Ingrese correo electrónico"
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                }
                
                // Rol
                Text {
                    text: "Rol:"
                    Layout.alignment: Qt.AlignRight
                }
                
                ComboBox {
                    id: cmbEditRol
                    Layout.fillWidth: true
                    model: usuariosRolesModel ? usuariosRolesModel.roles : []
                    textRole: "nombre"
                    onCurrentIndexChanged: {
                        if (usuarioEditando && currentIndex >= 0 && model && currentIndex < model.length) {
                            usuarioEditando.id_rol = model[currentIndex].id_rol;
                        }
                    }
                }
                
                // Activo
                Text {
                    text: "Activo:"
                    Layout.alignment: Qt.AlignRight
                }
                
                CheckBox {
                    id: chkEditActivo
                    checked: true
                }
            }
            
            // Mensaje de validación
            Rectangle {
                width: parent.width
                height: mensajeValidacionEdit.text ? mensajeValidacionEdit.height + 20 : 0
                color: "#FFF0F0"
                border.color: "#FFD0D0"
                radius: 4
                visible: mensajeValidacionEdit.text !== ""
                
                Text {
                    id: mensajeValidacionEdit
                    anchors.centerIn: parent
                    width: parent.width - 20
                    text: ""
                    color: "#D32F2F"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
    
    footer: DialogButtonBox {
        Button {
            text: "Cancelar"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            implicitHeight: 36
            implicitWidth: 100
            onClicked: editUsuarioDialog.close()
        }
        
        Button {
            text: "Guardar cambios"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            implicitHeight: 36
            implicitWidth: 100
            background: Rectangle {
                color: "#4CAF50"
                radius: 5
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                // Validación básica
                if (!usuarioEditando) {
                    mensajeValidacionEdit.text = "Error: No hay usuario para editar";
                    return;
                }
                
                if (txtEditNombre.text === "" || txtEditUsuario.text === "" || txtEditCorreo.text === "") {
                    mensajeValidacionEdit.text = "Por favor, complete todos los campos obligatorios";
                    return;
                }
                
                // Preparar datos para actualizar
                var datosActualizados = {
                    "nombre": txtEditNombre.text,
                    "apellido": txtEditApellido.text,
                    "usuario": txtEditUsuario.text,
                    "correo": txtEditCorreo.text,
                    "id_rol": cmbEditRol.model[cmbEditRol.currentIndex].id_rol,
                    "activo": chkEditActivo.checked
                };
                
                console.log("Datos a actualizar:", JSON.stringify(datosActualizados));
                
                // Llamar al modelo para actualizar
                var exito = usuariosRolesModel.actualizar_usuario(usuarioEditando.id_usuario, JSON.stringify(datosActualizados));
                if (exito) {
                    editUsuarioDialog.close();
                    showMessage("Usuario actualizado correctamente");
                } else {
                    mensajeValidacionEdit.text = "Error al actualizar el usuario";
                }
            }
        }
    }
    
    // Limpiar al cerrar
    onClosed: {
        usuarioEditando = null;
        txtEditNombre.text = "";
        txtEditApellido.text = "";
        txtEditUsuario.text = "";
        txtEditCorreo.text = "";
        mensajeValidacionEdit.text = "";
    }
}   
    // Componente para mostrar mensajes
    Rectangle {
        id: messageToast
        width: messageText.width + 40
        height: 40
        radius: 20
        color: "#333333"
        opacity: 0.9
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        z: 1000
        
        Text {
            id: messageText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 14
            text: ""
        }
        
        property string text: ""
        onTextChanged: messageText.text = text
        
        Timer {
            id: messageToastTimer
            interval: 3000
            onTriggered: messageToast.visible = false
        }
    }
    
    // Función para mostrar mensajes
    function showMessage(message) {
        messageToast.text = message
        messageToast.visible = true
        messageToastTimer.restart()
    }
    // Función para formatear la fecha
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
        }
    }    

