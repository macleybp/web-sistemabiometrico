<?php

date_default_timezone_set('America/Lima');

require_once __DIR__ . '/../config/conexion.php';

header('Content-Type: application/json; charset=utf-8');

function responder_estado_api(array $datos, int $codigoHttp = 200): void
{
    http_response_code($codigoHttp);
    echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function validar_clave_estado(): void
{
    $claveSecretaArduino = clave_api_arduino();
    $claveRecibida = $_POST['clave'] ?? $_GET['clave'] ?? '';

    if (!hash_equals($claveSecretaArduino, (string) $claveRecibida)) {
        responder_estado_api([
            'estado' => 'error',
            'mensaje' => 'Acceso no autorizado'
        ], 401);
    }
}

function asegurar_tabla_estado(PDO $pdo): void
{
    $pdo->exec(
        "CREATE TABLE IF NOT EXISTS estado_dispositivo (
            id_estado INT AUTO_INCREMENT PRIMARY KEY,
            estado_biometrico VARCHAR(50) NOT NULL DEFAULT 'Estado Apagado',
            estado_sensor VARCHAR(50) NOT NULL DEFAULT 'Apagado',
            estado_wifi VARCHAR(50) NOT NULL DEFAULT 'Desconectado',
            mensaje VARCHAR(255) NULL,
            fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

validar_clave_estado();
$diasSemana = [
    1 => 'Lunes',
    2 => 'Martes',
    3 => 'Miércoles',
    4 => 'Jueves',
    5 => 'Viernes',
    6 => 'Sábado',
    7 => 'Domingo'
];

$diaHoy = $diasSemana[(int) date('N')];

$consultaHorario = $pdo->prepare("
    SELECT COUNT(*) 
    FROM horarios 
    WHERE dia_semana = ?
    AND tipo_actividad = 'Clase'
    AND estado = 'Activo'
");

$consultaHorario->execute([$diaHoy]);
$hayClaseHoy = (int) $consultaHorario->fetchColumn();

$tipoDia = $hayClaseHoy > 0 ? 'dia_laborable' : 'dia_no_laborable';
$lcdLinea1 = $hayClaseHoy > 0 ? 'Sistema Activo' : 'Dia no laborable';
$lcdLinea2 = $hayClaseHoy > 0 ? 'Coloque dedo' : 'No marcar';

try {
    asegurar_tabla_estado($pdo);

    $estadoSensor = $_POST['sensor'] ?? $_GET['sensor'] ?? 'activo';
    $estadoSensor = strtolower(trim((string) $estadoSensor));

    if ($estadoSensor === 'activo') {
        $estadoBiometrico = 'Sistema Activo';
        $estadoSensorTexto = 'Activo';
        $estadoWifiTexto = 'Conectado';
        $mensaje = 'Señal de vida recibida desde Arduino';
    } else {
        $estadoBiometrico = 'Estado Apagado';
        $estadoSensorTexto = 'Apagado';
        $estadoWifiTexto = 'Desconectado';
        $mensaje = 'Sensor biométrico apagado o sin respuesta';
    }

    $consulta = $pdo->query(
        "SELECT id_estado
         FROM estado_dispositivo
         ORDER BY id_estado DESC
         LIMIT 1"
    );

    $idEstado = $consulta->fetchColumn();

    if ($idEstado) {
        $actualizar = $pdo->prepare(
            "UPDATE estado_dispositivo
             SET estado_biometrico = :estado_biometrico,
                 estado_sensor = :estado_sensor,
                 estado_wifi = :estado_wifi,
                 mensaje = :mensaje,
                 fecha_actualizacion = NOW()
             WHERE id_estado = :id_estado"
        );

        $actualizar->execute([
            'estado_biometrico' => $estadoBiometrico,
            'estado_sensor' => $estadoSensorTexto,
            'estado_wifi' => $estadoWifiTexto,
            'mensaje' => $mensaje,
            'id_estado' => (int) $idEstado
        ]);
    } else {
        $insertar = $pdo->prepare(
            "INSERT INTO estado_dispositivo
             (estado_biometrico, estado_sensor, estado_wifi, mensaje)
             VALUES
             (:estado_biometrico, :estado_sensor, :estado_wifi, :mensaje)"
        );

        $insertar->execute([
            'estado_biometrico' => $estadoBiometrico,
            'estado_sensor' => $estadoSensorTexto,
            'estado_wifi' => $estadoWifiTexto,
            'mensaje' => $mensaje
        ]);
    }

responder_estado_api([
    'estado' => 'ok',
    'estado_biometrico' => $estadoBiometrico,
    'estado_sensor' => $estadoSensorTexto,
    'estado_wifi' => $estadoWifiTexto,
    'mensaje' => $mensaje,
    'hay_clases_hoy' => $hayClaseHoy > 0,
    'tipo_dia' => $tipoDia,
    'lcd_linea_1' => $lcdLinea1,
    'lcd_linea_2' => $lcdLinea2,
    'fecha_actualizacion' => date('Y-m-d H:i:s')
]);
} catch (Throwable $e) {
    responder_estado_api([
        'estado' => 'error',
        'mensaje' => 'No se pudo actualizar el estado del dispositivo'
    ], 500);
}
