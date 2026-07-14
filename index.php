<?php

require_once __DIR__ . '/includes/auth.php';

if (usuario_autenticado()) {
    header('Location: pages/dashboard.php');
    exit;
}

header('Location: login.php');
exit;