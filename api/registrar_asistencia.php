<?php

date_default_timezone_set('America/Lima');

require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/funciones.php';

header('Content-Type: application/json; charset=utf-8');

function responder_api(array $datos, int $codigoHttp = 200): void
{
    http_response_code($codigoHttp);
    echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function obtener_parametro_sensor(): int
{
    $valor = $_POST['id_sensor']
        ?? $_GET['id_sensor']
        ?? $_POST['id_huella']
        ?? $_GET['id_huella']
        ?? '';

    $raw = file_get_contents('php://input');

    if ($valor === '' && is_string($raw) && $raw !== '') {
        if (preg_match('/ASISTENCIA\s*:\s*([0-9]+)/i', $raw, $coincidencia)) {
            $valor = $coincidencia[1];
        } elseif (preg_match('/id_sensor\s*=\s*([0-9]+)/i', $raw, $coincidencia)) {
            $valor = $coincidencia[1];
        } elseif (preg_match('/id_huella\s*=\s*([0-9]+)/i', $raw, $coincidencia)) {
            $valor = $coincidencia[1];
        } elseif (preg_match('/^[0-9]+$/', trim($raw))) {
            $valor = trim($raw);
        }
    }

    if (!preg_match('/^[0-9]+$/', (string) $valor)) {
        return 0;
    }

    return (int) $valor;
}

function obtener_configuracion_api(PDO $pdo, string $clave, string $valorDefecto): string
{
    try {
        $consulta = $pdo->prepare(
            "SELECT valor
             FROM configuracion
             WHERE clave = :clave
             LIMIT 1"
        );

        $consulta->execute([
            'clave' => $clave
        ]);

        $valor = $consulta->fetchColumn();

        return $valor !== false && $valor !== null && $valor !== '' ? (string) $valor : $valorDefecto;
    } catch (Throwable $e) {
        return $valorDefecto;
    }
}

function obtener_valores_enum_api(PDO $pdo, string $tabla, string $columna): array
{
    try {
        $consulta = $pdo->prepare(
            "SELECT COLUMN_TYPE
             FROM INFORMATION_SCHEMA.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
             AND TABLE_NAME = :tabla
             AND COLUMN_NAME = :columna
             LIMIT 1"
        );

        $consulta->execute([
            'tabla' => $tabla,
            'columna' => $columna
        ]);

        $fila = $consulta->fetch();

        if (!$fila || !str_starts_with($fila['COLUMN_TYPE'], 'enum')) {
            return [];
        }

        preg_match_all("/'((?:[^'\\\\]|\\\\.)*)'/", $fila['COLUMN_TYPE'], $coincidencias);

        return array_map(function ($valor) {
            return str_replace("\\'", "'", $valor);
        }, $coincidencias[1]);
    } catch (Throwable $e) {
        return [];
    }
}

function elegir_valor_api(array $permitidos, string $principal, string $alternativo): string
{
    if (count($permitidos) === 0) {
        return $principal;
    }

    if (in_array($principal, $permitidos, true)) {
        return $principal;
    }

    if (in_array($alternativo, $permitidos, true)) {
        return $alternativo;
    }

    return $permitidos[0];
}

function segundos_hora_api(string $hora): int
{
    $partes = explode(':', $hora);
    $horas = (int) ($partes[0] ?? 0);
    $minutos = (int) ($partes[1] ?? 0);
    $segundos = (int) ($partes[2] ?? 0);

    return ($horas * 3600) + ($minutos * 60) + $segundos;
}

function actualizar_estado_dispositivo_api(PDO $pdo, string $mensaje): void
{
    try {
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
                 SET estado_biometrico = 'Sistema Activo',
                     estado_sensor = 'Activo',
                     estado_wifi = 'Conectado',
                     mensaje = :mensaje,
                     fecha_actualizacion = NOW()
                 WHERE id_estado = :id_estado"
            );

            $actualizar->execute([
                'mensaje' => $mensaje,
                'id_estado' => (int) $idEstado
            ]);
        } else {
            $insertar = $pdo->prepare(
                "INSERT INTO estado_dispositivo
                 (estado_biometrico, estado_sensor, estado_wifi, mensaje)
                 VALUES
                 ('Sistema Activo', 'Activo', 'Conectado', :mensaje)"
            );

            $insertar->execute([
                'mensaje' => $mensaje
            ]);
        }
    } catch (Throwable $e) {
        return;
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'GET') {
    responder_api([
        'estado' => 'error',
        'mensaje' => 'Método no permitido'
    ], 405);
}

$idSensor = obtener_parametro_sensor();

if ($idSensor <= 0) {
    responder_api([
        'estado' => 'error',
        'mensaje' => 'ID de sensor no válido'
    ], 400);
}

try {
    $consultaEstudiante = $pdo->prepare(
        "SELECT e.id_estudiante,
                e.codigo_estudiante,
                e.nombres,
                e.apellidos,
                h.id_sensor
         FROM huellas h
         INNER JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
         WHERE h.id_sensor = :id_sensor
         AND h.estado = 'Activa'
         AND e.estado = 'Activo'
         LIMIT 1"
    );

    $consultaEstudiante->execute([
        'id_sensor' => $idSensor
    ]);

    $estudiante = $consultaEstudiante->fetch();

    if (!$estudiante) {
        actualizar_estado_dispositivo_api($pdo, 'Huella no registrada en la base de datos. ID sensor: ' . $idSensor);

        responder_api([
            'estado' => 'error',
            'tipo' => 'huella_no_registrada',
            'mensaje' => 'No existe estudiante activo para el ID de sensor enviado',
            'id_sensor' => $idSensor
        ]);
    }

    $fechaHoy = date('Y-m-d');
    $horaActual = date('H:i:s');

    $horaEntradaOficial = obtener_configuracion_api($pdo, 'hora_entrada_oficial', '14:00');
    $horaSalidaOficial = obtener_configuracion_api($pdo, 'hora_salida_oficial', '19:00');
    $toleranciaMinutos = (int) obtener_configuracion_api($pdo, 'tolerancia_minutos', '0');

    $opcionesEstadoEntrada = obtener_valores_enum_api($pdo, 'asistencias', 'estado_entrada');
    $opcionesEstadoSalida = obtener_valores_enum_api($pdo, 'asistencias', 'estado_salida');
    $opcionesMetodo = obtener_valores_enum_api($pdo, 'asistencias', 'metodo_registro');

    $segundosActual = segundos_hora_api($horaActual);
    $segundosEntrada = segundos_hora_api(strlen($horaEntradaOficial) === 5 ? $horaEntradaOficial . ':00' : $horaEntradaOficial);
    $segundosSalida = segundos_hora_api(strlen($horaSalidaOficial) === 5 ? $horaSalidaOficial . ':00' : $horaSalidaOficial);

    $estadoEntradaBase = $segundosActual <= ($segundosEntrada + ($toleranciaMinutos * 60)) ? 'Puntual' : 'Tardanza';
    $estadoEntrada = elegir_valor_api($opcionesEstadoEntrada, $estadoEntradaBase, 'Puntual');
    $estadoSalidaBase = $segundosActual < $segundosSalida ? 'Salida Anticipada' : 'Salida Registrada';
    $estadoSalida = elegir_valor_api($opcionesEstadoSalida, $estadoSalidaBase, 'Salida Registrada');
    $estadoSalidaPendiente = elegir_valor_api($opcionesEstadoSalida, 'Sin registro de salida', 'Pendiente');
    $metodoRegistro = elegir_valor_api($opcionesMetodo, 'Huella', 'Manual');

    $consultaAsistencia = $pdo->prepare(
        "SELECT id_asistencia,
                hora_entrada,
                estado_entrada,
                hora_salida,
                estado_salida
         FROM asistencias
         WHERE id_estudiante = :id_estudiante
         AND fecha = :fecha
         LIMIT 1"
    );

    $consultaAsistencia->execute([
        'id_estudiante' => (int) $estudiante['id_estudiante'],
        'fecha' => $fechaHoy
    ]);

    $asistencia = $consultaAsistencia->fetch();

    if (!$asistencia) {
        $registrarEntrada = $pdo->prepare(
            "INSERT INTO asistencias
             (id_estudiante, fecha, hora_entrada, estado_entrada, hora_salida, estado_salida, metodo_registro, observacion)
             VALUES
             (:id_estudiante, :fecha, :hora_entrada, :estado_entrada, NULL, :estado_salida, :metodo_registro, :observacion)"
        );

        $registrarEntrada->execute([
            'id_estudiante' => (int) $estudiante['id_estudiante'],
            'fecha' => $fechaHoy,
            'hora_entrada' => $horaActual,
            'estado_entrada' => $estadoEntrada,
            'estado_salida' => $estadoSalidaPendiente,
            'metodo_registro' => $metodoRegistro,
            'observacion' => 'Entrada registrada por sensor biométrico'
        ]);

        actualizar_estado_dispositivo_api($pdo, 'Entrada registrada: ' . $estudiante['nombres'] . ' ' . $estudiante['apellidos'] . ' - ID sensor ' . $idSensor);

        responder_api([
            'estado' => 'ok',
            'tipo' => 'entrada',
            'mensaje' => 'Entrada registrada correctamente',
            'id_sensor' => $idSensor,
            'id_estudiante' => (int) $estudiante['id_estudiante'],
            'codigo_estudiante' => $estudiante['codigo_estudiante'],
            'estudiante' => trim($estudiante['nombres'] . ' ' . $estudiante['apellidos']),
            'fecha' => $fechaHoy,
            'hora' => $horaActual,
            'estado_entrada' => $estadoEntrada
        ]);
    }

    if ($asistencia['hora_salida'] === null || $asistencia['hora_salida'] === '') {
        $registrarSalida = $pdo->prepare(
            "UPDATE asistencias
             SET hora_salida = :hora_salida,
                 estado_salida = :estado_salida,
                 metodo_registro = :metodo_registro,
                 observacion = :observacion
             WHERE id_asistencia = :id_asistencia"
        );

        $registrarSalida->execute([
            'hora_salida' => $horaActual,
            'estado_salida' => $estadoSalida,
            'metodo_registro' => $metodoRegistro,
            'observacion' => 'Salida registrada por sensor biométrico',
            'id_asistencia' => (int) $asistencia['id_asistencia']
        ]);

        actualizar_estado_dispositivo_api($pdo, 'Salida registrada: ' . $estudiante['nombres'] . ' ' . $estudiante['apellidos'] . ' - ID sensor ' . $idSensor);

        responder_api([
            'estado' => 'ok',
            'tipo' => 'salida',
            'mensaje' => 'Salida registrada correctamente',
            'id_sensor' => $idSensor,
            'id_estudiante' => (int) $estudiante['id_estudiante'],
            'codigo_estudiante' => $estudiante['codigo_estudiante'],
            'estudiante' => trim($estudiante['nombres'] . ' ' . $estudiante['apellidos']),
            'fecha' => $fechaHoy,
            'hora' => $horaActual,
            'estado_salida' => $estadoSalida
        ]);
    }

    actualizar_estado_dispositivo_api($pdo, 'Marcación repetida: ' . $estudiante['nombres'] . ' ' . $estudiante['apellidos'] . ' - ID sensor ' . $idSensor);

    responder_api([
        'estado' => 'ok',
        'tipo' => 'ya_registrado',
        'mensaje' => 'El estudiante ya tiene entrada y salida registradas para hoy',
        'id_sensor' => $idSensor,
        'id_estudiante' => (int) $estudiante['id_estudiante'],
        'codigo_estudiante' => $estudiante['codigo_estudiante'],
        'estudiante' => trim($estudiante['nombres'] . ' ' . $estudiante['apellidos']),
        'fecha' => $fechaHoy,
        'hora_entrada' => $asistencia['hora_entrada'],
        'hora_salida' => $asistencia['hora_salida']
    ]);
} catch (Throwable $e) {
    responder_api([
        'estado' => 'error',
        'mensaje' => 'No se pudo registrar la asistencia',
        'detalle' => $e->getMessage()
    ], 500);
}
