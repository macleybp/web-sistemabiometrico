<?php

function limpiar_texto(?string $valor): string
{
    $valor = trim((string) $valor);
    $valor = strip_tags($valor);
    $valor = preg_replace('/\s+/', ' ', $valor);

    return $valor;
}

function obtener_estado_dispositivo(PDO $pdo): string
{
    try {
        $consulta = $pdo->query(
            "SELECT estado_biometrico,
                    TIMESTAMPDIFF(SECOND, fecha_actualizacion, NOW()) AS segundos_sin_senal
             FROM estado_dispositivo
             ORDER BY id_estado DESC
             LIMIT 1"
        );

        $estado = $consulta->fetch();

        if (!$estado) {
            return 'Estado Apagado';
        }

        $segundosSinSenal = (int) ($estado['segundos_sin_senal'] ?? 9999);

        if ($estado['estado_biometrico'] === 'Sistema Activo' && $segundosSinSenal <= 30) {
            return 'Sistema Activo';
        }

        return 'Estado Apagado';
    } catch (Throwable $e) {
        return 'Estado Apagado';
    }
}


function clase_estado_dispositivo(string $estado): string
{
    $estado = trim($estado);
    $estadoNormalizado = function_exists('mb_strtolower')
        ? mb_strtolower($estado, 'UTF-8')
        : strtolower($estado);

    if (
        $estadoNormalizado === 'sistema activo' ||
        $estadoNormalizado === 'activo' ||
        $estadoNormalizado === 'conectado'
    ) {
        return 'sistema-activo';
    }

    return 'estado-apagado';
}


function formatear_fecha(?string $fecha): string
{
    if (!$fecha) {
        return '-';
    }

    $tiempo = strtotime($fecha);

    if (!$tiempo) {
        return '-';
    }

    return date('d/m/Y', $tiempo);
}

function formatear_hora(?string $hora): string
{
    if (!$hora) {
        return '-';
    }

    return substr($hora, 0, 5);
}

function calcular_porcentaje(int $valor, int $total): int
{
    if ($total <= 0) {
        return 0;
    }

    return (int) round(($valor / $total) * 100);
}

function obtener_estadisticas_dashboard(PDO $pdo): array
{
    $fechaHoy = date('Y-m-d');

    try {
        $consulta = $pdo->query(
            "SELECT COUNT(*) AS total
             FROM estudiantes
             WHERE estado = 'Activo'"
        );

        $estudiantesRegistrados = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $estudiantesRegistrados = 0;
    }

    try {
        $consulta = $pdo->prepare(
            "SELECT COUNT(*) AS total
             FROM asistencias
             WHERE fecha = :fecha
             AND estado_entrada IN ('Puntual', 'Tardanza')"
        );

        $consulta->execute([
            'fecha' => $fechaHoy
        ]);

        $asistenciasHoy = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $asistenciasHoy = 0;
    }

    try {
        $consulta = $pdo->prepare(
            "SELECT COUNT(*) AS total
             FROM asistencias
             WHERE fecha = :fecha
             AND estado_entrada = 'Puntual'"
        );

        $consulta->execute([
            'fecha' => $fechaHoy
        ]);

        $puntualesHoy = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $puntualesHoy = 0;
    }

    try {
        $consulta = $pdo->prepare(
            "SELECT COUNT(*) AS total
             FROM asistencias
             WHERE fecha = :fecha
             AND estado_entrada = 'Tardanza'"
        );

        $consulta->execute([
            'fecha' => $fechaHoy
        ]);

        $tardanzasHoy = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $tardanzasHoy = 0;
    }

    try {
        $consulta = $pdo->prepare(
            "SELECT COUNT(*) AS total
             FROM asistencias
             WHERE fecha = :fecha
             AND estado_entrada IN ('Falto', 'Falta')"
        );

        $consulta->execute([
            'fecha' => $fechaHoy
        ]);

        $faltasHoy = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $faltasHoy = 0;
    }

    try {
        $consulta = $pdo->prepare(
            "SELECT COUNT(*) AS total
             FROM asistencias
             WHERE fecha = :fecha
             AND hora_entrada IS NOT NULL
             AND hora_salida IS NULL
             AND estado_salida IN ('Sin registro de salida', 'Pendiente', 'Salida pendiente')"
        );

        $consulta->execute([
            'fecha' => $fechaHoy
        ]);

        $salidasPendientes = (int) ($consulta->fetch()['total'] ?? 0);
    } catch (Throwable $e) {
        $salidasPendientes = 0;
    }

    try {
        $consulta = $pdo->query(
            "SELECT e.nombres,
                    e.apellidos,
                    e.codigo_estudiante,
                    a.fecha,
                    a.hora_entrada,
                    a.hora_salida,
                    a.estado_entrada,
                    a.estado_salida,
                    a.metodo_registro
             FROM asistencias a
             INNER JOIN estudiantes e ON a.id_estudiante = e.id_estudiante
             ORDER BY a.fecha DESC,
                      COALESCE(a.hora_salida, a.hora_entrada, '00:00:00') DESC,
                      a.id_asistencia DESC
             LIMIT 1"
        );

        $ultimaMarcacion = $consulta->fetch();
    } catch (Throwable $e) {
        $ultimaMarcacion = null;
    }

    return [
        'estudiantes_registrados' => $estudiantesRegistrados,
        'asistencias_hoy' => $asistenciasHoy,
        'puntuales_hoy' => $puntualesHoy,
        'tardanzas_hoy' => $tardanzasHoy,
        'faltas_hoy' => $faltasHoy,
        'salidas_pendientes' => $salidasPendientes,
        'ultima_marcacion' => $ultimaMarcacion ?: null
    ];
}

function obtener_total_alertas(PDO $pdo): int
{
    try {
        $consulta = $pdo->query(
            "SELECT COUNT(*) AS total
             FROM alertas
             WHERE estado = 'Activa'
             AND porcentaje_inasistencia >= 30"
        );

        $fila = $consulta->fetch();

        return (int) ($fila['total'] ?? 0);
    } catch (Throwable $e) {
        return 0;
    }
}

function obtener_datos_semana(PDO $pdo): array
{
    $inicioSemana = date('Y-m-d', strtotime('monday this week'));

    $dias = [
        ['nombre' => 'Lunes', 'corto' => 'Lun'],
        ['nombre' => 'Martes', 'corto' => 'Mar'],
        ['nombre' => 'Miércoles', 'corto' => 'Mié'],
        ['nombre' => 'Jueves', 'corto' => 'Jue'],
        ['nombre' => 'Viernes', 'corto' => 'Vie']
    ];

    $datos = [];

    foreach ($dias as $indice => $dia) {
        $fecha = date('Y-m-d', strtotime($inicioSemana . " +$indice days"));

        $puntuales = 0;
        $tardanzas = 0;
        $faltas = 0;

        try {
            $consulta = $pdo->prepare(
                "SELECT estado_entrada,
                        COUNT(*) AS total
                 FROM asistencias
                 WHERE fecha = :fecha
                 GROUP BY estado_entrada"
            );

            $consulta->execute([
                'fecha' => $fecha
            ]);

            while ($fila = $consulta->fetch()) {
                if ($fila['estado_entrada'] === 'Puntual') {
                    $puntuales = (int) $fila['total'];
                }

                if ($fila['estado_entrada'] === 'Tardanza') {
                    $tardanzas = (int) $fila['total'];
                }

                if ($fila['estado_entrada'] === 'Falto') {
                    $faltas = (int) $fila['total'];
                }
            }
        } catch (Throwable $e) {
            $puntuales = 0;
            $tardanzas = 0;
            $faltas = 0;
        }

        $total = $puntuales + $tardanzas + $faltas;

        $datos[] = [
            'dia' => $dia['corto'],
            'nombre_dia' => $dia['nombre'],
            'fecha' => $fecha,
            'puntuales' => $puntuales,
            'tardanzas' => $tardanzas,
            'faltas' => $faltas,
            'total' => $total,
            'puntual' => $puntuales,
            'tardanza' => $tardanzas,
            'falto' => $faltas
        ];
    }

    return $datos;
}

function obtener_datos_generales(PDO $pdo): array
{
    $puntuales = 0;
    $tardanzas = 0;
    $faltas = 0;

    try {
        $consulta = $pdo->query(
            "SELECT estado_entrada,
                    COUNT(*) AS total
             FROM asistencias
             GROUP BY estado_entrada"
        );

        while ($fila = $consulta->fetch()) {
            if ($fila['estado_entrada'] === 'Puntual') {
                $puntuales = (int) $fila['total'];
            }

            if ($fila['estado_entrada'] === 'Tardanza') {
                $tardanzas = (int) $fila['total'];
            }

            if ($fila['estado_entrada'] === 'Falto') {
                $faltas = (int) $fila['total'];
            }
        }
    } catch (Throwable $e) {
        $puntuales = 0;
        $tardanzas = 0;
        $faltas = 0;
    }

    $total = $puntuales + $tardanzas + $faltas;

    return [
        'puntuales' => $puntuales,
        'tardanzas' => $tardanzas,
        'faltas' => $faltas,
        'total' => $total,
        'puntual' => $puntuales,
        'tardanza' => $tardanzas,
        'falto' => $faltas
    ];
}