CREATE DATABASE IF NOT EXISTS bioasistencia
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bioasistencia;

SET NAMES utf8mb4;
SET time_zone = '-05:00';

-- ========================================
-- TABLAS
-- ========================================

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200) NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombres VARCHAR(120) NOT NULL,
    apellidos VARCHAR(120) NOT NULL,
    usuario VARCHAR(60) NOT NULL UNIQUE,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    ultimo_acceso DATETIME NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_roles
        FOREIGN KEY (id_rol)
        REFERENCES roles(id_rol)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NULL,
    codigo_docente VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(120) NOT NULL,
    apellidos VARCHAR(120) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    correo VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    especialidad VARCHAR(150) NULL,
    titulo_cargo VARCHAR(150) NOT NULL DEFAULT 'Docente',
    correo_institucional VARCHAR(150) NULL,
    whatsapp VARCHAR(20) NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_docentes_usuario UNIQUE (id_usuario),
    CONSTRAINT fk_docentes_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    codigo_curso VARCHAR(20) NULL UNIQUE,
    nombre_curso VARCHAR(160) NOT NULL,
    descripcion VARCHAR(300) NULL,
    ciclo VARCHAR(20) NOT NULL DEFAULT 'V',
    programa_estudios VARCHAR(160) NOT NULL DEFAULT 'Computación e Informática',
    horas_semanales INT NOT NULL DEFAULT 0,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE docente_curso (
    id_docente_curso INT AUTO_INCREMENT PRIMARY KEY,
    id_docente INT NOT NULL,
    id_curso INT NOT NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_docente_curso UNIQUE (id_docente, id_curso),
    CONSTRAINT fk_docente_curso_docentes
        FOREIGN KEY (id_docente)
        REFERENCES docentes(id_docente)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_docente_curso_cursos
        FOREIGN KEY (id_curso)
        REFERENCES cursos(id_curso)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE periodos_academicos (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_periodo VARCHAR(100) NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_periodo_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    id_periodo INT NOT NULL DEFAULT 1,
    codigo_estudiante VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(120) NOT NULL,
    apellidos VARCHAR(120) NOT NULL,
    dni VARCHAR(15) NULL UNIQUE,
    correo VARCHAR(150) NULL UNIQUE,
    correo_institucional VARCHAR(150) NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    whatsapp VARCHAR(20) NULL,
    direccion VARCHAR(250) NULL,
    programa_estudios VARCHAR(160) NOT NULL DEFAULT 'Computación e Informática',
    ciclo VARCHAR(20) NOT NULL DEFAULT 'V',
    turno ENUM('Mañana','Tarde','Noche') NOT NULL DEFAULT 'Tarde',
    estado_academico ENUM('Regular','Retirado','Egresado') NOT NULL DEFAULT 'Regular',
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_estudiantes_periodos
        FOREIGN KEY (id_periodo)
        REFERENCES periodos_academicos(id_periodo)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE huellas (
    id_huella INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_sensor INT NOT NULL UNIQUE,
    dedo_registrado VARCHAR(50) NOT NULL DEFAULT 'Índice derecho',
    plantilla_huella TEXT NULL,
    estado ENUM('Activa','Inactiva','Pendiente') NOT NULL DEFAULT 'Activa',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_huella_estudiante UNIQUE (id_estudiante),
    CONSTRAINT fk_huellas_estudiantes
        FOREIGN KEY (id_estudiante)
        REFERENCES estudiantes(id_estudiante)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_huella_sensor CHECK (id_sensor > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE horarios (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_curso INT NULL,
    id_docente INT NULL,
    dia_semana ENUM('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tipo_actividad ENUM('Clase','Receso') NOT NULL DEFAULT 'Clase',
    aula VARCHAR(60) NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_horarios_cursos
        FOREIGN KEY (id_curso)
        REFERENCES cursos(id_curso)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_horarios_docentes
        FOREIGN KEY (id_docente)
        REFERENCES docentes(id_docente)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_horarios_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE asistencias (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME NULL,
    hora_salida TIME NULL,
    estado_entrada ENUM('Puntual','Tardanza','Falto','Falta') NOT NULL,
    estado_salida ENUM('Sin registro de salida','Salida Registrada','Salida Anticipada','No aplica') NOT NULL DEFAULT 'Sin registro de salida',
    metodo_registro ENUM('Huella','Manual','Sistema') NOT NULL DEFAULT 'Huella',
    observacion VARCHAR(300) NULL,
    registrado_por INT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_asistencia_estudiante_fecha UNIQUE (id_estudiante, fecha),
    CONSTRAINT fk_asistencias_estudiantes
        FOREIGN KEY (id_estudiante)
        REFERENCES estudiantes(id_estudiante)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_asistencias_usuarios
        FOREIGN KEY (registrado_por)
        REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_asistencia_horas CHECK (
        hora_salida IS NULL OR hora_entrada IS NULL OR hora_salida >= hora_entrada
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alertas (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    tipo_alerta ENUM('Tardanza','Falta','Salida Anticipada','Huella no registrada','Sistema') NULL,
    nivel_alerta ENUM('Informativo','Seguimiento','Crítico') NULL DEFAULT 'Informativo',
    porcentaje_inasistencia DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    nivel_riesgo ENUM('Normal','Atención','Riesgo','Alerta crítica','Sin datos') NOT NULL DEFAULT 'Normal',
    titulo VARCHAR(160) NULL,
    descripcion TEXT NULL,
    estado ENUM('Activa','Resuelta','Pendiente','Atendida','Archivada') NOT NULL DEFAULT 'Activa',
    fecha_alerta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_atencion DATETIME NULL,
    atendido_por INT NULL,
    CONSTRAINT fk_alertas_estudiantes
        FOREIGN KEY (id_estudiante)
        REFERENCES estudiantes(id_estudiante)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_alertas_usuarios
        FOREIGN KEY (atendido_por)
        REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE configuracion (
    id_configuracion INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT NULL,
    descripcion VARCHAR(255) NULL,
    nombre_configuracion VARCHAR(120) NULL,
    valor_configuracion TEXT NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estado_dispositivo (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_dispositivo VARCHAR(120) NULL,
    estado ENUM('Activo','Apagado','Desconectado','Error') NULL DEFAULT 'Desconectado',
    ultimo_evento VARCHAR(250) NULL,
    ultima_conexion DATETIME NULL,
    estado_biometrico VARCHAR(50) NOT NULL DEFAULT 'Estado Apagado',
    estado_sensor VARCHAR(50) NOT NULL DEFAULT 'Apagado',
    estado_wifi VARCHAR(50) NOT NULL DEFAULT 'Desconectado',
    mensaje VARCHAR(255) NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reportes (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    nombre_reporte VARCHAR(160) NULL,
    tipo_reporte ENUM('Diario','Semanal','Mensual','Personalizado') NOT NULL DEFAULT 'Semanal',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    semana_inicio DATE NULL,
    semana_fin DATE NULL,
    generado_por INT NULL,
    ruta_archivo VARCHAR(250) NULL,
    fecha_generado DATETIME NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reportes_usuarios
        FOREIGN KEY (generado_por)
        REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_reportes_fechas CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT chk_reportes_semana CHECK (semana_fin IS NULL OR semana_inicio IS NULL OR semana_fin >= semana_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- ÍNDICES
-- ========================================

CREATE INDEX idx_usuarios_rol ON usuarios(id_rol);
CREATE INDEX idx_docentes_estado ON docentes(estado);
CREATE INDEX idx_cursos_estado ON cursos(estado);
CREATE INDEX idx_estudiantes_periodo ON estudiantes(id_periodo);
CREATE INDEX idx_estudiantes_estado ON estudiantes(estado);
CREATE INDEX idx_huellas_sensor ON huellas(id_sensor);
CREATE INDEX idx_horarios_dia ON horarios(dia_semana);
CREATE INDEX idx_asistencias_fecha ON asistencias(fecha);
CREATE INDEX idx_asistencias_estado ON asistencias(estado_entrada);
CREATE INDEX idx_asistencias_salida ON asistencias(estado_salida);
CREATE INDEX idx_alertas_estado ON alertas(estado);
CREATE INDEX idx_alertas_nivel ON alertas(nivel_alerta);
CREATE INDEX idx_alertas_riesgo ON alertas(nivel_riesgo);
CREATE INDEX idx_reportes_fechas ON reportes(fecha_inicio, fecha_fin);
CREATE INDEX idx_reportes_semana ON reportes(semana_inicio, semana_fin);

-- ========================================
-- DATOS BASE (mínimos para funcionamiento)
-- ========================================

INSERT INTO roles (id_rol, nombre_rol, descripcion, estado) VALUES
(1, 'Administrador', 'Acceso completo al sistema biométrico de asistencia.', 'Activo'),
(2, 'Docente', 'Acceso a módulos académicos, asistencia, reportes y perfil.', 'Activo');

INSERT INTO configuracion
(clave, valor, nombre_configuracion, valor_configuracion, descripcion)
VALUES
('hora_entrada_oficial', '14:00:00', 'Hora oficial de entrada', '14:00:00', 'Hora base para determinar asistencia puntual o tardanza.'),
('hora_salida_oficial', '19:00:00', 'Hora oficial de salida', '19:00:00', 'Hora base para determinar salida registrada o salida anticipada.'),
('tolerancia_minutos', '0', 'Minutos de tolerancia', '0', 'Tolerancia aplicada después de la hora oficial de entrada.'),
('minutos_tolerancia', '0', 'Minutos de tolerancia', '0', 'Clave auxiliar conservada por compatibilidad.'),
('nombre_institucion', 'Instituto Público de Chepén', 'Nombre de la institución', 'Instituto Público de Chepén', 'Nombre institucional mostrado en reportes y sistema.'),
('nombre_sistema', 'BioAsistencia', 'Nombre del sistema', 'BioAsistencia', 'Nombre comercial o interno del sistema biométrico.'),
('modo_registro', 'Huella', 'Modo de registro principal', 'Huella', 'Modo principal usado para registrar asistencia.'),
('estado_wifi', 'Pendiente', 'Estado del módulo WiFi', 'Pendiente', 'Estado informativo del ESP8266.'),
('puerto_serial', '9600', 'Velocidad serial', '9600', 'Velocidad de comunicación con Arduino Mega.');

INSERT INTO estado_dispositivo
(nombre_dispositivo, estado, ultimo_evento, ultima_conexion, estado_biometrico, estado_sensor, estado_wifi, mensaje)
VALUES
('Sistema Biométrico BioAsistencia', 'Desconectado', 'Pendiente de conexión con Arduino.', NULL, 'Estado Apagado', 'Apagado', 'Desconectado', 'Sistema pendiente de conexión.');

-- ========================================
-- VISTAS
-- ========================================

CREATE VIEW vw_estudiantes_huella AS
SELECT
    e.id_estudiante,
    e.codigo_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
    e.dni,
    e.correo,
    e.correo_institucional,
    e.telefono,
    e.whatsapp,
    e.programa_estudios,
    e.ciclo,
    e.turno,
    e.estado_academico,
    e.estado AS estado_estudiante,
    h.id_huella,
    h.id_sensor,
    h.dedo_registrado,
    h.estado AS estado_huella,
    p.nombre_periodo
FROM estudiantes e
INNER JOIN periodos_academicos p ON p.id_periodo = e.id_periodo
LEFT JOIN huellas h ON h.id_estudiante = e.id_estudiante;

CREATE VIEW vw_horario_semanal AS
SELECT
    h.id_horario,
    CASE h.dia_semana
        WHEN 'Lunes' THEN 1
        WHEN 'Martes' THEN 2
        WHEN 'Miércoles' THEN 3
        WHEN 'Jueves' THEN 4
        WHEN 'Viernes' THEN 5
        WHEN 'Sábado' THEN 6
        WHEN 'Domingo' THEN 7
    END AS orden_dia,
    h.dia_semana,
    h.hora_inicio,
    h.hora_fin,
    h.tipo_actividad,
    h.aula,
    c.codigo_curso,
    c.nombre_curso,
    CONCAT(d.nombres, ' ', d.apellidos) AS docente,
    d.titulo_cargo,
    h.estado
FROM horarios h
LEFT JOIN cursos c ON c.id_curso = h.id_curso
LEFT JOIN docentes d ON d.id_docente = h.id_docente;

CREATE VIEW vw_asistencia_detallada AS
SELECT
    a.id_asistencia,
    a.fecha,
    a.hora_entrada,
    a.hora_salida,
    a.estado_entrada,
    a.estado_salida,
    a.metodo_registro,
    a.observacion,
    e.id_estudiante,
    e.codigo_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
    e.programa_estudios,
    e.ciclo,
    e.turno,
    h.id_sensor,
    u.usuario AS registrado_por_usuario,
    a.fecha_registro
FROM asistencias a
INNER JOIN estudiantes e ON e.id_estudiante = a.id_estudiante
LEFT JOIN huellas h ON h.id_estudiante = e.id_estudiante
LEFT JOIN usuarios u ON u.id_usuario = a.registrado_por;

CREATE VIEW vw_resumen_asistencia_diaria AS
SELECT
    fecha,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN estado_entrada = 'Puntual' THEN 1 ELSE 0 END) AS total_puntuales,
    SUM(CASE WHEN estado_entrada = 'Tardanza' THEN 1 ELSE 0 END) AS total_tardanzas,
    SUM(CASE WHEN estado_entrada IN ('Falto','Falta') THEN 1 ELSE 0 END) AS total_faltas,
    SUM(CASE WHEN estado_salida = 'Sin registro de salida' THEN 1 ELSE 0 END) AS total_salidas_pendientes,
    SUM(CASE WHEN estado_salida = 'Salida Anticipada' THEN 1 ELSE 0 END) AS total_salidas_anticipadas,
    SUM(CASE WHEN estado_salida = 'Salida Registrada' THEN 1 ELSE 0 END) AS total_salidas_registradas
FROM asistencias
GROUP BY fecha;

CREATE VIEW vw_alertas_detalladas AS
SELECT
    al.id_alerta,
    al.tipo_alerta,
    al.nivel_alerta,
    al.titulo,
    al.descripcion,
    al.porcentaje_inasistencia,
    al.nivel_riesgo,
    al.estado,
    al.fecha_alerta,
    al.fecha_atencion,
    e.codigo_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos) AS estudiante,
    u.usuario AS atendido_por_usuario
FROM alertas al
INNER JOIN estudiantes e ON e.id_estudiante = al.id_estudiante
LEFT JOIN usuarios u ON u.id_usuario = al.atendido_por;