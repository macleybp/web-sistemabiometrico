USE bioasistencia;

-- ========================================
-- DATOS DE PRUEBA
-- ========================================

INSERT INTO usuarios (id_usuario, id_rol, nombres, apellidos, usuario, correo, contrasena, estado) VALUES
(1, 1, 'Administrador', 'General', 'admin', 'admin@bioasistencia.local', '$2y$12$0267sGYwFUwugvRIXBShA.TW265.2CuPl9XUtyPz7mSfdghz1Je7W', 'Activo'),
(2, 2, 'Franshesca', 'Lamadrid Bringas', 'f.lamadrid', 'franshesca.lamadrid@bioasistencia.local', '$2y$12$0267sGYwFUwugvRIXBShA.TW265.2CuPl9XUtyPz7mSfdghz1Je7W', 'Activo'),
(3, 2, 'Diana Carolina', 'Mil Osorio', 'diana.mil', 'diana.mil@bioasistencia.local', '$2y$12$0267sGYwFUwugvRIXBShA.TW265.2CuPl9XUtyPz7mSfdghz1Je7W', 'Activo'),
(4, 2, 'Luis Antonio', 'Pairazamán Polo', 'luis.pairazaman', 'luis.pairazaman@bioasistencia.local', '$2y$12$0267sGYwFUwugvRIXBShA.TW265.2CuPl9XUtyPz7mSfdghz1Je7W', 'Activo'),
(5, 2, 'Arturo', 'Licham Abanto', 'arturo.licham', 'arturo.licham@bioasistencia.local', '$2y$12$0267sGYwFUwugvRIXBShA.TW265.2CuPl9XUtyPz7mSfdghz1Je7W', 'Activo');

INSERT INTO docentes
(id_docente, id_usuario, codigo_docente, nombres, apellidos, dni, correo, telefono, especialidad, titulo_cargo, correo_institucional, whatsapp, estado)
VALUES
(1, 2, 'DOC001', 'Franshesca', 'Lamadrid Bringas', '70000001', 'franshesca.lamadrid@bioasistencia.local', '900000001', 'Análisis de Problemas y ADS', 'Docente de Computación e Informática', 'franshesca.lamadrid@bioasistencia.local', '900000001', 'Activo'),
(2, 3, 'DOC002', 'Diana Carolina', 'Mil Osorio', '70000002', 'diana.mil@bioasistencia.local', '900000002', 'Diseño Web y Base de Datos', 'Docente de Computación e Informática', 'diana.mil@bioasistencia.local', '900000002', 'Activo'),
(3, 4, 'DOC003', 'Luis Antonio', 'Pairazamán Polo', '70000003', 'luis.pairazaman@bioasistencia.local', '900000003', 'Innovación Tecnológica y SQL', 'Docente de Computación e Informática', 'luis.pairazaman@bioasistencia.local', '900000003', 'Activo'),
(4, 5, 'DOC004', 'Arturo', 'Licham Abanto', '70000004', 'arturo.licham@bioasistencia.local', '900000004', 'Programación Orientada a Objetos', 'Docente de Computación e Informática', 'arturo.licham@bioasistencia.local', '900000004', 'Activo');

INSERT INTO cursos (id_curso, codigo_curso, nombre_curso, descripcion, ciclo, programa_estudios, horas_semanales, estado) VALUES
(1, 'CUR001', 'Identificación de Análisis de Problema', 'Curso orientado a identificar, analizar y plantear problemas tecnológicos.', 'V', 'Computación e Informática', 3, 'Activo'),
(2, 'CUR002', 'Diseño Web', 'Curso de diseño y construcción de interfaces web.', 'V', 'Computación e Informática', 5, 'Activo'),
(3, 'CUR003', 'Fundamentos de Innovación Tecnológica', 'Curso de fundamentos para desarrollar soluciones innovadoras.', 'V', 'Computación e Informática', 3, 'Activo'),
(4, 'CUR004', 'Programación Orientada a Objetos', 'Curso de programación con clases, objetos y métodos.', 'V', 'Computación e Informática', 4, 'Activo'),
(5, 'CUR005', 'Análisis y Diseño de Sistemas', 'Curso de modelado, análisis y diseño de soluciones de software.', 'V', 'Computación e Informática', 4, 'Activo'),
(6, 'CUR006', 'Diseño de Base de Datos', 'Curso de modelado, normalización y diseño de bases de datos.', 'V', 'Computación e Informática', 3, 'Activo'),
(7, 'CUR007', 'Gestión de Lenguaje de Consultas', 'Curso de SQL, consultas, procedimientos y transacciones.', 'V', 'Computación e Informática', 4, 'Activo');

INSERT INTO docente_curso (id_docente_curso, id_docente, id_curso, estado) VALUES
(1, 1, 1, 'Activo'),
(2, 2, 2, 'Activo'),
(3, 3, 3, 'Activo'),
(4, 4, 4, 'Activo'),
(5, 1, 5, 'Activo'),
(6, 2, 6, 'Activo'),
(7, 3, 7, 'Activo');

INSERT INTO periodos_academicos (id_periodo, nombre_periodo, fecha_inicio, fecha_fin, estado) VALUES
(1, 'V Ciclo 2026', '2026-04-13', '2026-08-14', 'Activo'),
(2, 'VI Ciclo 2026', '2026-09-07', '2026-12-18', 'Inactivo');

INSERT INTO estudiantes
(id_estudiante, id_periodo, codigo_estudiante, nombres, apellidos, dni, correo, correo_institucional, telefono, whatsapp, direccion, programa_estudios, ciclo, turno, estado_academico, estado)
VALUES
(1, 1, 'EST001', 'Felipe Giampiere', 'Abanto Alvarado', '76000001', 'est001@bioasistencia.local', 'est001@iestpchepen.edu.pe', '910000001', '910000001', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(2, 1, 'EST002', 'Maxi Elizeth', 'Aguilar Llamóctanta', '76000002', 'est002@bioasistencia.local', 'est002@iestpchepen.edu.pe', '910000002', '910000002', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(3, 1, 'EST003', 'Treicy Mariana', 'Apari Rojas', '76000003', 'est003@bioasistencia.local', 'est003@iestpchepen.edu.pe', '910000003', '910000003', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(4, 1, 'EST004', 'Kris Belen', 'Barboza Pardo', '76000004', 'est004@bioasistencia.local', 'est004@iestpchepen.edu.pe', '910000004', '910000004', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(5, 1, 'EST005', 'Diana Lili', 'Briones Pilco', '76000005', 'est005@bioasistencia.local', 'est005@iestpchepen.edu.pe', '910000005', '910000005', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(6, 1, 'EST006', 'Adriana Zharit', 'Cabanillas Zelada', '76000006', 'est006@bioasistencia.local', 'est006@iestpchepen.edu.pe', '910000006', '910000006', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(7, 1, 'EST007', 'Darwin', 'Castañeda Becerra', '76000007', 'est007@bioasistencia.local', 'est007@iestpchepen.edu.pe', '910000007', '910000007', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(8, 1, 'EST008', 'Jhonatan Ernesto', 'Castañeda Cubas', '76000008', 'est008@bioasistencia.local', 'est008@iestpchepen.edu.pe', '910000008', '910000008', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(9, 1, 'EST009', 'Alberto Aldair', 'Correa Tejada', '76000009', 'est009@bioasistencia.local', 'est009@iestpchepen.edu.pe', '910000009', '910000009', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(10, 1, 'EST010', 'Victor Orlando', 'Davila Rodas', '76000010', 'est010@bioasistencia.local', 'est010@iestpchepen.edu.pe', '910000010', '910000010', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(11, 1, 'EST011', 'Maria Brigitte', 'Flores Quispe', '76000011', 'est011@bioasistencia.local', 'est011@iestpchepen.edu.pe', '910000011', '910000011', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(12, 1, 'EST012', 'Marco Antonio', 'Gutiérrez Cerna', '76000012', 'est012@bioasistencia.local', 'est012@iestpchepen.edu.pe', '910000012', '910000012', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(13, 1, 'EST013', 'Briana Milenka', 'Henandez Boza', '76000013', 'est013@bioasistencia.local', 'est013@iestpchepen.edu.pe', '910000013', '910000013', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(14, 1, 'EST014', 'Jeanlucas', 'Hernández Díaz', '76000014', 'est014@bioasistencia.local', 'est014@iestpchepen.edu.pe', '910000014', '910000014', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(15, 1, 'EST015', 'Duilio Jefferson', 'Huangal Quiroz', '76000015', 'est015@bioasistencia.local', 'est015@iestpchepen.edu.pe', '910000015', '910000015', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(16, 1, 'EST016', 'Harrison Bryan', 'Machuca León', '76000016', 'est016@bioasistencia.local', 'est016@iestpchepen.edu.pe', '910000016', '910000016', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(17, 1, 'EST017', 'Fernando Alexis', 'Moncada Espinoza', '76000017', 'est017@bioasistencia.local', 'est017@iestpchepen.edu.pe', '910000017', '910000017', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(18, 1, 'EST018', 'Jeferson Jair', 'Monja Sandoval', '76000018', 'est018@bioasistencia.local', 'est018@iestpchepen.edu.pe', '910000018', '910000018', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(19, 1, 'EST019', 'Helena Graciela', 'Pacheco Sanchez', '76000019', 'est019@bioasistencia.local', 'est019@iestpchepen.edu.pe', '910000019', '910000019', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(20, 1, 'EST020', 'Karla Xiomara', 'Palomino Pineda', '76000020', 'est020@bioasistencia.local', 'est020@iestpchepen.edu.pe', '910000020', '910000020', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(21, 1, 'EST021', 'José Gerardo', 'Pinedo Lezama', '76000021', 'est021@bioasistencia.local', 'est021@iestpchepen.edu.pe', '910000021', '910000021', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(22, 1, 'EST022', 'Carlos Arturo', 'Quispe Cruzado', '76000022', 'est022@bioasistencia.local', 'est022@iestpchepen.edu.pe', '910000022', '910000022', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(23, 1, 'EST023', 'Jose Hilton', 'Rivaspata Vasquez', '76000023', 'est023@bioasistencia.local', 'est023@iestpchepen.edu.pe', '910000023', '910000023', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(24, 1, 'EST024', 'Fernando Juhior', 'Rojas Valera', '76000024', 'est024@bioasistencia.local', 'est024@iestpchepen.edu.pe', '910000024', '910000024', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(25, 1, 'EST025', 'Yan Carlos', 'Sanchez Tarrillo', '76000025', 'est025@bioasistencia.local', 'est025@iestpchepen.edu.pe', '910000025', '910000025', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(26, 1, 'EST026', 'Willians Estuart', 'Soberon Mujica', '76000026', 'est026@bioasistencia.local', 'est026@iestpchepen.edu.pe', '910000026', '910000026', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo'),
(27, 1, 'EST027', 'Jhonatan Jois', 'Suarez Tejada', '76000027', 'est027@bioasistencia.local', 'est027@iestpchepen.edu.pe', '910000027', '910000027', 'Chepén', 'Computación e Informática', 'V', 'Tarde', 'Regular', 'Activo');

INSERT INTO huellas (id_estudiante, id_sensor, dedo_registrado, plantilla_huella, estado) VALUES
(1, 1, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(2, 2, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(3, 3, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(4, 4, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(5, 5, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(6, 6, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(7, 7, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(8, 8, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(9, 9, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(10, 10, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(11, 11, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(12, 12, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(13, 13, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(14, 14, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(15, 15, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(16, 16, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(17, 17, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(18, 18, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(19, 19, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(20, 20, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(21, 21, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(22, 22, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(23, 23, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(24, 24, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(25, 25, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(26, 26, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa'),
(27, 27, 'Índice derecho', 'ID de sensor asignado según número de lista del aula', 'Activa');

INSERT INTO horarios (id_curso, id_docente, dia_semana, hora_inicio, hora_fin, tipo_actividad, aula, estado) VALUES
(1, 1, 'Lunes', '14:00:00', '16:15:00', 'Clase', 'Aula 01', 'Activo'),
(NULL, NULL, 'Lunes', '16:15:00', '16:45:00', 'Receso', 'Patio', 'Activo'),
(2, 2, 'Lunes', '16:45:00', '19:00:00', 'Clase', 'Laboratorio 01', 'Activo'),
(3, 3, 'Martes', '14:00:00', '16:15:00', 'Clase', 'Aula 01', 'Activo'),
(NULL, NULL, 'Martes', '16:15:00', '16:45:00', 'Receso', 'Patio', 'Activo'),
(4, 4, 'Martes', '16:45:00', '19:00:00', 'Clase', 'Laboratorio 01', 'Activo'),
(2, 2, 'Miércoles', '14:00:00', '16:15:00', 'Clase', 'Laboratorio 01', 'Activo'),
(NULL, NULL, 'Miércoles', '16:15:00', '16:45:00', 'Receso', 'Patio', 'Activo'),
(5, 1, 'Miércoles', '16:45:00', '19:00:00', 'Clase', 'Aula 01', 'Activo'),
(4, 4, 'Jueves', '14:00:00', '15:30:00', 'Clase', 'Laboratorio 01', 'Activo'),
(6, 2, 'Jueves', '15:30:00', '16:15:00', 'Clase', 'Laboratorio 01', 'Activo'),
(NULL, NULL, 'Jueves', '16:15:00', '16:45:00', 'Receso', 'Patio', 'Activo'),
(6, 2, 'Jueves', '16:45:00', '19:00:00', 'Clase', 'Laboratorio 01', 'Activo'),
(7, 3, 'Viernes', '14:00:00', '16:15:00', 'Clase', 'Laboratorio 01', 'Activo'),
(NULL, NULL, 'Viernes', '16:15:00', '16:45:00', 'Receso', 'Patio', 'Activo'),
(7, 3, 'Viernes', '16:45:00', '17:30:00', 'Clase', 'Laboratorio 01', 'Activo'),
(5, 1, 'Viernes', '17:30:00', '19:00:00', 'Clase', 'Aula 01', 'Activo');