<?php

require_once __DIR__ . '/auth.php';

if (usuario_autenticado()) {
    header('Location: dashboard.php');
    exit;
}

header('Location: login.php');
exit;