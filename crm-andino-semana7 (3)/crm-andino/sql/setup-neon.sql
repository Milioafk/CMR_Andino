-- ===== CRM Andino Perú — Semana 7 — Neon (PostgreSQL) =====
-- Ejecutar en el SQL Editor de Neon, bloque por bloque.

-- 1) Tabla de usuarios con rol (si ya la tienes, el ALTER solo agrega la columna que falte)
CREATE TABLE IF NOT EXISTS usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  contrasena VARCHAR(100) NOT NULL
);
ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS rol VARCHAR(20) NOT NULL DEFAULT 'cliente'
  CHECK (rol IN ('cliente', 'administrador', 'empleado'));

-- 2) Tabla del caso (si ya la tienes de la Semana 6, solo se agrega id_usuario)
CREATE TABLE IF NOT EXISTS solicitudes_demo_crm (
  id SERIAL PRIMARY KEY,
  codigo_seguimiento VARCHAR(20) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  empresa VARCHAR(100) NOT NULL,
  correo VARCHAR(120) NOT NULL,
  num_usuarios VARCHAR(10) NOT NULL DEFAULT '1-3',
  mensaje TEXT,
  estado VARCHAR(20) NOT NULL DEFAULT 'registrado',
  fecha_registro TIMESTAMP NOT NULL DEFAULT NOW()
);
ALTER TABLE solicitudes_demo_crm ADD COLUMN IF NOT EXISTS id_usuario INT REFERENCES usuarios(id);

-- 3) Datos de prueba: 10 clientes + 1 administrador + 2 empleados (contraseña 1234)
INSERT INTO usuarios (nombre, correo, contrasena, rol)
SELECT 'Cliente ' || n, 'cliente' || n || '@correo.com', '1234', 'cliente'
FROM generate_series(1, 10) AS n
UNION ALL
VALUES
  ('Admin de prueba', 'admin@correo.com', '1234', 'administrador'),
  ('Empleado Uno', 'empleado1@correo.com', '1234', 'empleado'),
  ('Empleado Dos', 'empleado2@correo.com', '1234', 'empleado')
ON CONFLICT (correo) DO NOTHING
RETURNING id, nombre, rol;

-- 4) 3 solicitudes por cada cliente = 30 filas (ejecutar UNA sola vez)
INSERT INTO solicitudes_demo_crm (id_usuario, codigo_seguimiento, nombre, empresa, correo, num_usuarios, mensaje, estado)
SELECT u.id,
       'COD-' || lpad((u.id * 10 + s)::text, 8, '0'),
       u.nombre, 'Empresa ' || u.id, u.correo, '4-10',
       'Solicitud de prueba ' || s,
       CASE WHEN s = 1 THEN 'registrado' ELSE 'atendido' END
FROM usuarios u CROSS JOIN generate_series(1, 3) AS s
WHERE u.rol = 'cliente';

-- 5) Verificación para la captura de la entrega
SELECT rol, COUNT(*) FROM usuarios GROUP BY rol;
SELECT COUNT(*) AS total_registros FROM solicitudes_demo_crm;
