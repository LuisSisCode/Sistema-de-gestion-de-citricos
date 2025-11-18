import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: usuariosRolesRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedades para la edición de usuarios
    property var nuevoUsuario: { "id_rol": 5, "nombre": "", "apellido": "", "usuario": "", "email": "", "contrasena": "" }
    property bool hayCambiosPendientes: false
    property var usuarioEditando: null
    
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE USUARIOS"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }

    // Contenido principal - Solo la sección de Usuarios
    Item {
        width: parent.width
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        
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
                    icon.source: "recursos/image/icons/agregar-usuario.svg"
                    implicitHeight: 36
                    background: Rectangle {
                        color: parent.hovered ? "#E65A00" : "#f5922f"
                        radius: height / 2
                    }
                    onClicked: {
                        // Inicializa los valores para el nuevo usuario
                        nuevoUsuario = { 
                            "id_rol": 1, 
                            "nombre": "", 
                            "apellido": "", 
                            "usuario": "", 
                            "email": "", 
                            "contrasena": "" 
                        }
                        
                        // para abrir una ventana secundaria...
                        nuevoUsuarioDialog.open()
                    }
                }

                TextField {
                    id: txtBuscarUsuarios
                    placeholderText: "Buscar usuario..."
                    implicitWidth: 450
                    implicitHeight: 28
                    leftPadding: 30  // Espacio para el icono
                    
                    background: Rectangle {
                        color: "#ffffff"
                        radius: height / 2
                        border.color: "#808080"
                        border.width: 1
                        
                        // Icono de lupa
                        Image {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            source: "recursos/image/icons/lupa.png" // Cambia por tu ruta
                            width: 16
                            height: 16
                        }
                    }
                    
                    onTextChanged: {
                        usuariosRolesModel.filtrar_usuarios(text)
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
                model: usuariosRolesModel ? usuariosRolesModel.usuarios_filtrados : []
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
                    width: usuariosRolesRoot.width
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
                                text: modelData.email
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
                                text: modelData.rol + (modelData.activo ? "" : " (Inactivo)")
                                elide: Text.ElideRight
                                width: parent.width - 20
                                color: modelData.activo ? "black" : "gray"
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
                                    icon.source: "recursos/image/icons/editar.svg"
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
                                    icon.source: "recursos/image/icons/basura.svg"
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
                    visible: usuariosRolesModel && usuariosRolesModel.usuarios ? usuariosRolesModel.usuarios.length === 0 : true
                }
            }
        }
    }
    // DIÁLOGO DE NUEVO USUARIO
    Dialog {
        id: nuevoUsuarioDialog
        title: "Nuevo Usuario"
        modal: true
        width: 500
        height: 650
        x: (parent.width - width) / 2
        y: (parent.height - height)
        padding: 25

        background: Rectangle {
            radius: 5
            border.width: 1
            border.color: "#EEEEEE"
            color: "white"
        }

        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            radius: 5

            Column {
                id: mainColumn
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
                spacing: 15

                // Título
                Text {
                    text: "Agregar Nuevo Usuario"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#2E7D32"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // Formulario - USANDO COLUMN EN LUGAR DE GRIDLAYOUT PARA MEJOR CONTROL
                Column {
                    width: parent.width
                    spacing: 12

                    // Fila Nombre
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Nombre:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtNombre
                            placeholderText: "Ingrese nombre"
                            width: parent.width - 150
                            height: 36
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.nombre = text
                        }
                    }

                    // Fila Apellido
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Apellido:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtApellido
                            placeholderText: "Ingrese apellido"
                            width: parent.width - 150
                            height: 36
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.apellido = text
                        }
                    }

                    // Fila Usuario
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Usuario:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtUsuario
                            placeholderText: "Ingrese nombre de usuario"
                            width: parent.width - 150
                            height: 36
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.usuario = text
                        }
                    }

                    // Fila Teléfono
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Teléfono:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtTelefono
                            placeholderText: "000-000-00"
                            width: parent.width - 150
                            height: 36
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.telefono = text
                        }
                    }

                    // Fila Dirección
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Dirección:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtDireccion
                            placeholderText: "Ingrese dirección"
                            width: parent.width - 150
                            height: 36
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.direccion = text
                        }
                    }

                    // Fila Email
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Email:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtCorreo
                            placeholderText: "Ingrese su email"
                            width: parent.width - 150
                            height: 36
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.email = text
                        }
                    }

                    // Fila Rol
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Rol:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        ComboBox {
                            id: cmbRol
                            width: parent.width - 150
                            height: 36
                            model: usuariosRolesModel ? usuariosRolesModel.roles : [] 
                            textRole: "nombre_rol"
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            
                            onCurrentIndexChanged: {
                                if (currentIndex >= 0 && model && currentIndex < model.length) {
                                    nuevoUsuario.id_rol = model[currentIndex].id_rol; 
                                }
                            }
                            Component.onCompleted: {
                                if (usuariosRolesModel) {
                                    usuariosRolesModel.cargar_roles();
                                }
                            }
                        }
                    }

                    // Fila Contraseña
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Contraseña:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtPassword
                            placeholderText: "Ingrese contraseña"
                            width: parent.width - 150
                            height: 36
                            echoMode: TextInput.Password
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onTextChanged: nuevoUsuario.contrasena = text
                        }
                    }

                    // Fila Confirmar Contraseña
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Confirmar:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtConfirmPassword
                            placeholderText: "Confirme la contraseña"
                            width: parent.width - 150
                            height: 36
                            echoMode: TextInput.Password
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                        }
                    }

                    // Fila Fecha
                    Row {
                        width: parent.width
                        spacing: 10
                        height: 40
                        
                        Text {
                            text: "Fecha creación:"
                            font.pixelSize: 14
                            width: 140
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                        
                        TextField {
                            id: txtFechaCreacion
                            placeholderText: "DD/MM/AAAA"
                            width: parent.width - 150
                            height: 36
                            readOnly: true
                            text: getFormattedDate()
                            background: Rectangle {
                                radius: 4
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                        }
                    }
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

        // Footer (MANTENER EL MISMO FOOTER)
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
                    // MANTENER LA LÓGICA ORIGINAL DE VALIDACIÓN
                    if (typeof mensajeValidacion !== 'undefined') {
                        mensajeValidacion.text = "";
                    }
                    
                    if (txtNombre.text.trim() === "" || txtApellido.text.trim() === "" || txtUsuario.text.trim() === "") {
                        mensajeValidacion.text = "Por favor, complete Nombre, Apellido y Nombre de Usuario.";
                        return;
                    }

                    if (txtCorreo.text.trim() === "") {
                        mensajeValidacion.text = "El correo electrónico es obligatorio.";
                        return;
                    }
                    var emailRegex = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
                    if (!emailRegex.test(txtCorreo.text.trim())) {
                        mensajeValidacion.text = "El formato del Email no es válido.";
                        return;
                    }

                    if (txtPassword.text === "") {
                        mensajeValidacion.text = "Debe ingresar una contraseña.";
                        return;
                    }
                    if (txtPassword.text !== txtConfirmPassword.text) {
                        mensajeValidacion.text = "Las contraseñas no coinciden.";
                        return;
                    }

                    if (!nuevoUsuario.id_rol || nuevoUsuario.id_rol <= 0) {
                        mensajeValidacion.text = "Debe seleccionar un Rol.";
                        return;
                    }

                    var datosUsuario = {
                        "id_rol": nuevoUsuario.id_rol,
                        "nombre": txtNombre.text.trim(),
                        "apellido": txtApellido.text.trim(),
                        "usuario": txtUsuario.text.trim(),
                        "email": txtCorreo.text.trim(),
                        "contrasena": txtPassword.text,
                        "telefono": txtTelefono.text.trim(),
                        "direccion": txtDireccion.text.trim(),
                        "activo": true
                    };

                    console.log("Datos a enviar:", JSON.stringify(datosUsuario));

                    var exito = usuariosRolesModel.agregar_usuario(JSON.stringify(datosUsuario));
                    
                    if (exito) {
                        nuevoUsuarioDialog.close();
                        showMessage("✅ Usuario guardado correctamente");
                        usuariosRolesModel.cargar_usuarios(); 
                    } else {
                        mensajeValidacion.text = "❌ Error al guardar el usuario. Verifique que el nombre de usuario y email sean únicos.";
                    }
                }
            }
        }

        onClosed: {
            // MANTENER LA LÓGICA ORIGINAL DE LIMPIEZA
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
                "email": "",
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
        width: 450
        height: 200
        x: (usuariosRolesRoot.width - width) / 2
        y: (usuariosRolesRoot.height - height) / 2
        
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

    // DIÁLOGO DE EDICIÓN DE USUARIO
    Dialog {
        id: editUsuarioDialog
        title: "Editar Usuario"
        modal: true
        width: 480
        height: 650
        x: (usuariosRolesRoot.width - width) / 2
        y: (usuariosRolesRoot.height - height) / 2
        padding: 25
    
        // Método para preparar el diálogo antes de abrirlo
        function prepararEdicion(usuario) {
            if (!usuario) {
                console.error("Usuario no válido para edición");
                return;
            }
            
            // Crear copia completa del usuario
            usuarioEditando = {
                "id_usuario": usuario.id_usuario,
                "nombre": usuario.nombre || "",
                "apellido": usuario.apellido || "",
                "usuario": usuario.usuario || "",
                "email": usuario.email || "",
                "telefono": usuario.telefono || "",
                "direccion": usuario.direccion || "",
                "id_rol": usuario.id_rol || 1,
                "activo": usuario.activo !== undefined ? usuario.activo : true
            };
            
            // Actualizar todos los campos
            txtEditNombre.text = usuarioEditando.nombre;
            txtEditApellido.text = usuarioEditando.apellido;
            txtEditUsuario.text = usuarioEditando.usuario;
            txtEditCorreo.text = usuarioEditando.email;
            txtEditTelefono.text = usuarioEditando.telefono;
            txtEditDireccion.text = usuarioEditando.direccion;
            chkEditActivo.checked = usuarioEditando.activo;
            
            // ⭐⭐ CORRECCIÓN: Cargar roles y seleccionar el correcto
            if (usuariosRolesModel) {
                usuariosRolesModel.cargar_roles();
            }
            
            // Esperar un momento para que se carguen los roles
            timerSeleccionarRol.start();
        }

        Timer {
            id: timerSeleccionarRol
            interval: 100
            onTriggered: {
                if (cmbEditRol.model && cmbEditRol.model.length > 0) {
                    var rolIndex = -1;
                    for (var i = 0; i < cmbEditRol.model.length; i++) {
                        if (cmbEditRol.model[i].id_rol === usuarioEditando.id_rol) {
                            rolIndex = i;
                            break;
                        }
                    }
                    cmbEditRol.currentIndex = rolIndex >= 0 ? rolIndex : 0;
                }
            }
        }
        
        contentItem: Rectangle {
        color: "white"
        radius: 5

        Column {
            id: mainColumnEdit
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 15
            
            // Título
            Text {
                text: "Editar Usuario"
                font.pixelSize: 18
                font.bold: true
                color: "#2E7D32"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Formulario - MISMO DISEÑO QUE NUEVO USUARIO
            Column {
                width: parent.width
                spacing: 12

                // Fila Nombre
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Nombre:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditNombre
                        placeholderText: "Ingrese nombre"
                        width: parent.width - 150
                        height: 36
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }
                
                // Fila Apellido
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Apellido:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditApellido
                        placeholderText: "Ingrese apellido"
                        width: parent.width - 150
                        height: 36
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }
                
                // Fila Usuario
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Usuario:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditUsuario
                        placeholderText: "Ingrese nombre de usuario"
                        width: parent.width - 150
                        height: 36
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }

                // Fila Teléfono
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Teléfono:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditTelefono
                        placeholderText: "000-000-00"
                        width: parent.width - 150
                        height: 36
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }

                // Fila Dirección
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Dirección:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditDireccion
                        placeholderText: "Ingrese dirección"
                        width: parent.width - 150
                        height: 36
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }
                
                // Fila Email
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Email:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    TextField {
                        id: txtEditCorreo
                        placeholderText: "Ingrese su email"
                        width: parent.width - 150
                        height: 36
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }
                
                // Fila Rol
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Rol:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    ComboBox {
                        id: cmbEditRol
                        width: parent.width - 150
                        height: 36
                        model: usuariosRolesModel ? usuariosRolesModel.roles : []
                        textRole: "nombre_rol"
                        background: Rectangle {
                            radius: 4
                            border.color: "#CCCCCC"
                            border.width: 1
                        }
                    }
                }
                
                // Fila Activo
                Row {
                    width: parent.width
                    spacing: 10
                    height: 40
                    
                    Text {
                        text: "Activo:"
                        font.pixelSize: 14
                        width: 140
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }
                    
                    CheckBox {
                        id: chkEditActivo
                        checked: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
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
                background: Rectangle {
                color: "#F5F5F5"
                height: 60
            }
                Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                implicitHeight: 36
                implicitWidth: 100
                background: Rectangle {
                    color: "#E0E0E0"
                    radius: 5
                }
                onClicked: editUsuarioDialog.close()
            }
            
            Button {
                text: "Guardar cambios"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                implicitHeight: 36
                implicitWidth: 120
                background: Rectangle {
                    color: parent.hovered ? "#388E3C" : "#4CAF50"
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
                        "email": txtEditCorreo.text,
                        "telefono": txtEditTelefono.text,
                        "direccion": txtEditDireccion.text,
                        "id_rol": cmbEditRol.model[cmbEditRol.currentIndex].id_rol,
                        "activo": chkEditActivo.checked
                    };
                    
                    console.log("Datos a actualizar:", JSON.stringify(datosActualizados));
                    
                    // Llamar al modelo para actualizar
                    var exito = usuariosRolesModel.actualizar_usuario(
                        usuarioEditando.id_usuario, 
                        JSON.stringify(datosActualizados)
                    );
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

    function validarNuevoUsuario() {
        if (!nuevoUsuario.nombre.trim()) {
            return "El nombre es obligatorio.";
        }
        if (!nuevoUsuario.apellido.trim()) {
            return "El apellido es obligatorio.";
        }
        if (!nuevoUsuario.usuario.trim()) {
            return "El nombre de usuario es obligatorio.";
        }
        // CRÍTICO: Verifica la contraseña
        if (!nuevoUsuario.contrasena || nuevoUsuario.contrasena.length < 4) { 
            return "La contraseña es obligatoria y debe ser más larga.";
        }
        // CRÍTICO: Verifica que se haya seleccionado un rol (id_rol)
        if (cmbRol.currentIndex === -1 || !nuevoUsuario.id_rol || nuevoUsuario.id_rol < 0) { 
            return "Debe seleccionar un Rol.";
        }
        // Aquí podrías agregar validaciones de formato de email, etc.
        
        return "OK"; // Éxito
    }

}    