CREATE DATABASE IF NOT EXISTS bioasistencia
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bioasistencia;

CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150),
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    ultimo_acceso DATETIME NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    codigo_estudiante VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150),
    telefono VARCHAR(20),
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    codigo_docente VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150),
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL,
    codigo_curso VARCHAR(20) NOT NULL UNIQUE,
    id_docente INT,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    FOREIGN KEY (id_docente) REFERENCES docentes(id_docente)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS horarios (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_curso INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS huellas (
    id_huella INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_sensor INT NOT NULL UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS asistencias (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME NULL,
    hora_salida TIME NULL,
    estado_entrada ENUM('Puntual', 'Tardanza', 'Falto', 'Falta') DEFAULT 'Puntual',
    estado_salida ENUM('Pendiente', 'Salida pendiente', 'Temprano', 'Normal') DEFAULT 'Pendiente',
    metodo_registro VARCHAR(50) DEFAULT 'Huella digital',
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS estado_dispositivo (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    estado_biometrico VARCHAR(50) NOT NULL,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS alertas (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    nivel_riesgo VARCHAR(50) DEFAULT 'Normal',
    porcentaje_inasistencia DECIMAL(5,2) DEFAULT 0,
    estado ENUM('Activa', 'Inactiva', 'Resuelta') DEFAULT 'Activa',
    descripcion TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
) ENGINE=InnoDB;

INSERT INTO roles (nombre_rol) VALUES
    ('Administrador'),
    ('Docente'),
    ('Usuario')
ON DUPLICATE KEY UPDATE nombre_rol = nombre_rol;

INSERT INTO estado_dispositivo (estado_biometrico) VALUES
    ('Estado Apagado')
ON DUPLICATE KEY UPDATE estado_biometrico = estado_biometrico;
