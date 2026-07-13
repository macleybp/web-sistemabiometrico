<?php

$host = 'localhost';
$puerto = '3306';
$nombre_bd = 'bioasistencia';
$usuario_bd = 'root';
$contrasena_bd = '123456';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;port=$puerto;dbname=$nombre_bd;charset=$charset";

$opciones_pdo = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::ATTR_STRINGIFY_FETCHES => false
];

try {
    $pdo = new PDO($dsn, $usuario_bd, $contrasena_bd, $opciones_pdo);
} catch (PDOException $e) {
    http_response_code(500);
    echo 'No se pudo establecer conexión con la base de datos.';
    exit;
}