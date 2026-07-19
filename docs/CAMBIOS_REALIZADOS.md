# Cambios realizados

- Se conservaron las pantallas PHP, estilos CSS y JavaScript de Proyecto 2.0.
- Se organizaron los archivos en carpetas según su función.
- Se corrigieron todos los `require` e `include` después de mover archivos.
- Se eliminaron las rutas fijas `/SISTEMA-BIOMETRICO`.
- Se agregó detección automática de la carpeta del proyecto.
- Se corrigió el nombre de la variable usada por los gráficos del dashboard.
- Se corrigió la doble lectura de la consulta del rol en usuarios.
- Se creó una base de datos compatible con los campos consultados por el código.
- Se agregaron Dockerfile, Docker Compose, Apache y variables de entorno.
- Se protegieron las carpetas internas mediante `.htaccess`.
- La clave del Arduino puede configurarse mediante `ARDUINO_API_KEY`.

## Separación esquema/datos para producción

- Se separó `docker/init.sql` en dos archivos:
  - `docker/init.sql` — Solo esquema (tablas, vistas, índices, config base)
  - `docker/data.sql` — Solo datos de prueba (INSERTs)
- Se actualizó `docker-compose.yml` para montar ambos archivos en orden:
  - `01-init.sql` (esquema)
  - `02-data.sql` (datos)
- Se eliminó `database/Base de Datos_BioAsistencia.sql` (duplicado de `bioasistencia.sql`)
- Se agregó `Makefile` con comandos de construcción y gestión Docker

## Validaciones realizadas

- Sintaxis PHP de todos los archivos.
- Sintaxis JavaScript de `main.js` y `dashboard.js`.
- Comprobación de rutas antiguas.
- Comprobación de archivos requeridos e incluidos.
- Comprobación de estructura y contenido del ZIP.

## Integración de la base de datos oficial

- Se incorporó la estructura de la base de datos como fuente oficial.
- Se reemplazaron las copias anteriores de `database/bioasistencia.sql` y `docker/init.sql`.
- Se corrigió el acceso inicial a `admin / Admin@2026`.
- Se alinearon programa, ciclo, reportes y estados de asistencia con la estructura entregada.
