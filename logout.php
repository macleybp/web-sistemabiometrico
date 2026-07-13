<?php

require_once __DIR__ . '/auth.php';

cerrar_sesion();

header('Location: login.php');
exit;