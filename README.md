# BioAsistencia

Sistema biométrico de control de asistencia estudiantil. Plataforma web desarrollada en PHP para registrar, consultar y supervisar la asistencia de estudiantes mediante identificación biométrica (huella digital).

Institución: **IESTP Ciro Alegría Bazán** — Programa: Informática Empresarial, IV Ciclo.

---

## Stack tecnológico

| Componente       | Detalle                          |
| ---------------- | -------------------------------- |
| Backend          | PHP 8.2                          |
| Servidor web     | Apache 2.4 (mod_rewrite)         |
| Base de datos    | MySQL 8.0                        |
| Frontend         | HTML, CSS, JavaScript (vanilla)  |
| Contenedorización| Docker + Docker Compose          |
| Exportación      | XLSX vía ZipArchive (sin librerías externas) |

No utiliza Composer, npm ni frameworks externos.

---

## Estructura del proyecto

```
web-sistemabiometrico/
├── config/
│   └── conexion.php                 # Conexión PDO a la base de datos
├── includes/
│   ├── auth.php                     # Sesiones, login, control de roles
│   ├── funciones.php                # Funciones auxiliares y consultas
│   └── sidebar.php                  # Menú lateral (según rol)
├── pages/
│   ├── dashboard.php                # Panel principal con estadísticas
│   ├── estudiantes.php              # Gestión de estudiantes
│   ├── docentes.php                 # Gestión de docentes
│   ├── cursos_horarios.php          # Cursos y horarios semanales
│   ├── asistencia.php               # Registro diario de asistencia
│   ├── reportes.php                 # Reportes semanales
│   ├── alertas.php                  # Alertas de inasistencia
│   ├── usuarios.php                 # Gestión de usuarios del sistema
│   ├── configuracion.php            # Configuración del sistema
│   └── perfil.php                   # Perfil del usuario
├── api/
│   └── registrar_asistencia.php     # API para sensor biométrico (Arduino)
├── exports/
│   └── exportar_reporte_excel.php   # Exportación de reportes a XLSX
├── assets/
│   ├── css/styles.css               # Estilos de la aplicación
│   ├── js/main.js                   # JavaScript compartido
│   ├── js/dashboard.js              # Gráficos del dashboard
│   └── img/logo.png                 # Logo de la aplicación
├── docker/
│   ├── init.sql                     # Script de inicialización de BD
│   └── apache-vhost.conf            # Configuración de Apache
├── index.php                        # Punto de entrada
├── login.php                        # Página de inicio de sesión
├── logout.php                       # Cierre de sesión
├── Dockerfile
├── docker-compose.yml
└── .dockerignore
```

---

## Requisitos

### Para desarrollo local con Docker (recomendado)

- [Docker](https://docs.docker.com/get-docker/) ≥ 20.10
- [Docker Compose](https://docs.docker.com/compose/install/) ≥ 2.0

### Para desarrollo local sin Docker

- PHP ≥ 8.2 con extensiones: `pdo_mysql`, `mysqli`, `gd`, `zip`, `opcache`
- MySQL ≥ 8.0 o MariaDB ≥ 10.5
- Servidor web con Apache (mod_rewrite habilitado) o PHP built-in server

---

## Instalación con Docker (recomendado)

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/web-sistemabiometrico.git
cd web-sistemabiometrico
```

### 2. Levantar los servicios

```bash
docker-compose up -d --build
```

Esto construirá la imagen de PHP y levantará los contenedores:

| Servicio | Contenedor           | Puerto |
| -------- | -------------------- | ------ |
| Web      | bioasistencia-web    | 8080   |
| MySQL    | bioasistencia-db     | 3307   |

### 3. Verificar que los servicios estén corriendo

```bash
docker-compose ps
```

### 4. Acceder a la aplicación

```
http://localhost:8080
```

La base de datos se inicializa automáticamente con el esquema base al primer levantamiento.

### 5. Datos de acceso iniciales

No se crea un usuario por defecto en el script SQL. Para crear el primer usuario administrador, puedes insertarlo directamente en la base de datos:

```bash
docker-compose exec db mysql -uroot -p123456 bioasistencia
```

```sql
INSERT INTO usuarios (id_rol, usuario, contrasena, nombres, apellidos, correo, estado)
VALUES (
    1,
    'admin',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Administrador',
    'General',
    'admin@bioasistencia.local',
    'Activo'
);
```

> **Credenciales por defecto:** usuario `admin`, contraseña `password`.
> El hash corresponde a `password_hash('password', PASSWORD_BCRYPT)`.

### Comandos útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs solo del servicio web
docker-compose logs -f web

# Reiniciar solo el servicio web
docker-compose restart web

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (resetear base de datos)
docker-compose down -v

# Acceder a la consola MySQL
docker-compose exec db mysql -uroot -p123456 bioasistencia

# Acceder al contenedor web
docker-compose exec web bash
```

---

## Instalación sin Docker (desarrollo local manual)

### 1. Configurar PHP

Asegúrate de tener PHP 8.2+ con las extensiones necesarias:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install php php-mysql php-gd php-zip php-mbstring php-xml libapache2-mod-php

# macOS (Homebrew)
brew install php

# Habilitar mod_rewrite (Apache)
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 2. Configurar MySQL

```sql
CREATE DATABASE bioasistencia
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Importar esquema
mysql -u root -p bioasistencia < docker/init.sql
```

### 3. Configurar la conexión

Edita `config/conexion.php` con tus credenciales:

```php
$host = 'localhost';
$puerto = '3306';
$nombre_bd = 'bioasistencia';
$usuario_bd = 'root';
$contrasena_bd = 'tu_contraseña';
```

O utiliza variables de entorno:

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=bioasistencia
export DB_USER=root
export DB_PASS=tu_contraseña
```

### 4. Configurar el servidor web

#### Apache

Crea un VirtualHost apuntando al directorio del proyecto:

```apache
<VirtualHost *:80>
    ServerName bioasistencia.local
    DocumentRoot /ruta/a/web-sistemabiometrico

    <Directory /ruta/a/web-sistemabiometrico>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### PHP built-in server (para desarrollo rápido)

```bash
php -S localhost:8080 -t .
```

### 5. Crear usuario administrador

Accede a MySQL e inserta el usuario inicial:

```bash
mysql -u root -p bioasistencia
```

```sql
INSERT INTO usuarios (id_rol, usuario, contrasena, nombres, apellidos, correo, estado)
VALUES (1, 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador', 'General', 'admin@bioasistencia.local', 'Activo');
```

---

## Variables de entorno

| Variable              | Valor por defecto | Descripción                    |
| --------------------- | ----------------- | ------------------------------ |
| `DB_HOST`             | `localhost`       | Host de MySQL                  |
| `DB_PORT`             | `3306`            | Puerto de MySQL                |
| `DB_NAME`             | `bioasistencia`   | Nombre de la base de datos     |
| `DB_USER`             | `root`            | Usuario de MySQL               |
| `DB_PASS`             | `123456`          | Contraseña de MySQL            |
| `MYSQL_ROOT_PASSWORD` | `123456`          | Password root (solo Docker)    |
| `MYSQL_DATABASE`      | `bioasistencia`   | BD a crear (solo Docker)       |

---

## Despliegue en producción

### 1. Configurar el servidor

Se requiere un servidor con:
- PHP 8.2+ (con extensiones: `pdo_mysql`, `mysqli`, `gd`, `zip`, `opcache`)
- MySQL 8.0+
- Apache 2.4 con `mod_rewrite` o Nginx con PHP-FPM

### 2. Clonar y configurar

```bash
git clone https://github.com/tu-usuario/web-sistemabiometrico.git /var/www/bioasistencia
cd /var/www/bioasistencia
```

### 3. Variables de entorno

Configura las variables de entorno en tu servidor (Apache, systemd, o `.env`):

```bash
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=bioasistencia
export DB_USER=bioasistencia_user
export DB_PASS=contraseña_segura_production
```

### 4. Configurar Apache

```apache
<VirtualHost *:443>
    ServerName bioasistencia.tudominio.com
    DocumentRoot /var/www/bioasistencia

    <Directory /var/www/bioasistencia>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/bioasistencia.crt
    SSLCertificateKeyFile /etc/ssl/private/bioasistencia.key
</VirtualHost>
```

### 5. Configurar MySQL en producción

```sql
-- Crear usuario dedicado (NO usar root)
CREATE USER 'bioasistencia_user'@'localhost' IDENTIFIED BY 'contraseña_segura';
GRANT ALL PRIVILEGES ON bioasistencia.* TO 'bioasistencia_user'@'localhost';
FLUSH PRIVILEGES;

-- Importar esquema
mysql -u root -p bioasistencia < /var/www/bioasistencia/docker/init.sql
```

### 6. Permisos de archivos

```bash
sudo chown -R www-data:www-data /var/www/bioasistencia
sudo find /var/www/bioasistencia -type d -exec chmod 755 {} \;
sudo find /var/www/bioasistencia -type f -exec chmod 644 {} \;
```

### 7. Habilitar HTTPS

```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d bioasistencia.tudominio.com
```

### 8. Optimizaciones recomendadas

```ini
; php.ini - Production
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
display_errors=Off
log_errors=On
error_log=/var/log/php/bioasistencia_error.log
session.cookie_httponly=1
session.cookie_secure=1
session.cookie_samesite=Strict
```

---

## API biométrica

El endpoint `api/registrar_asistencia.php` recibe datos del sensor de huellas (Arduino):

### Método POST

```bash
curl -X POST http://localhost:8080/api/registrar_asistencia.php \
  -d "id_sensor=1"
```

### Método GET

```
http://localhost:8080/api/registrar_asistencia.php?id_sensor=1
```

### Respuesta JSON

```json
{
    "success": true,
    "mensaje": "Entrada registrada",
    "estudiante": "Juan Pérez",
    "estado": "Puntual",
    "hora": "08:15:00"
}
```

### Lógica de asistencia

| Primer toque del día | Segundo toque del día |
| --------------------- | ---------------------- |
| Registra **entrada**  | Registra **salida**    |

El estado se calcula comparando la hora de entrada con la hora oficial configurada:
- **Puntual**: dentro del horario + tolerancia
- **Tardanza**: fuera del horario pero aún en el mismo día
- **Falto**: sin registro para ese día

---

## Funcionalidades

### Panel de control (Dashboard)
- 8 tarjetas de estadísticas en tiempo real
- Gráfico semanal de asistencia (barras)
- Gráfico de puntualidad general (donut)
- Últimos 8 registros biométricos
- Indicador de estado del dispositivo
- Reloj en vivo

### Gestión de estudiantes
- Registro, edición y desactivación
- Asignación de ID de sensor biométrico
- Código automático (EST001, EST002, ...)
- Búsqueda y filtrado

### Gestión de docentes
- CRUD completo (solo administradores)
- Creación automática de cuenta de usuario vinculada

### Cursos y horarios
- Gestión de cursos con código único
- Horarios semanales (lunes a viernes)
- Tipos de actividad: Clase y Receso

### Asistencia
- Vista diaria con filtros por fecha, estudiante y estado
- Estados visuales: Puntual (verde), Tardanza (naranja), Falto (rojo)
- Método de registro: Huella digital o Manual

### Reportes
- Reportes semanales con estadísticas
- Exportación a archivo XLSX
- Historial de reportes generados

### Alertas de inasistencia
- Cálculo automático porcentaje de inasistencia
- Niveles de riesgo:
  - **Normal**: < 20%
  - **Atención**: 20-24%
  - **Riesgo**: 25-29%
  - **Alerta crítica**: ≥ 30%
- Enlaces directos a WhatsApp y correo

### Perfil de usuario
- Visualización y edición de datos personales
- Cambio de contraseña
- Resumen de asistencia de los últimos 30 días

---

## Seguridad

- Contraseñas hasheadas con `PASSWORD_BCRYPT`
- Cookies de sesión: `httponly`, `samesite=Strict`, `secure` (en HTTPS)
- Regeneración de ID de sesión al iniciar sesión
- Control de acceso por roles (Administrador, Docente, Usuario)
- Consultas preparadas PDO (protección contra SQL Injection)
- Validación de entrada con `htmlspecialchars()` y funciones de limpieza

---

## Licencia

Proyecto académico — IESTP Ciro Alegría Bazán.
