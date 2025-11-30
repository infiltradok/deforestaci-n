/*******************************
  SCRIPT COMPLETO - SQL SERVER
  Base: reforestacion
*******************************/

-- 1) CREAR BASE DE DATOS
IF DB_ID('reforestacion') IS NULL
BEGIN
    CREATE DATABASE reforestacion
    CONTAINMENT = NONE;
END;
GO

USE reforestacion;
GO

-- 2) CREAR TABLAS (esquema dbo)
-- Nota: usando NVARCHAR para soportar acentos y IDENTITY para autoincremento.

-- Tabla Usuario
IF OBJECT_ID('dbo.Usuario') IS NOT NULL DROP TABLE dbo.Usuario;
CREATE TABLE dbo.Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombres NVARCHAR(100) NOT NULL,
    apellidos NVARCHAR(100) NOT NULL,
    correo NVARCHAR(120) NOT NULL UNIQUE,
    contrasena NVARCHAR(255) NOT NULL,
    rol NVARCHAR(20) NOT NULL
);
GO

-- Tabla Proyecto
IF OBJECT_ID('dbo.Proyecto') IS NOT NULL DROP TABLE dbo.Proyecto;
CREATE TABLE dbo.Proyecto (
    id_proyecto INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(150) NOT NULL,
    descripcion NVARCHAR(MAX) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    estado NVARCHAR(20) DEFAULT('Activo') NOT NULL
);
GO

-- Tabla Zona
IF OBJECT_ID('dbo.Zona') IS NOT NULL DROP TABLE dbo.Zona;
CREATE TABLE dbo.Zona (
    id_zona INT IDENTITY(1,1) PRIMARY KEY,
    nombre_zona NVARCHAR(100) NOT NULL,
    sector NVARCHAR(100) NULL,
    coordenadas NVARCHAR(150) NULL,
    id_proyecto INT NOT NULL,
    CONSTRAINT FK_Zona_Proyecto FOREIGN KEY (id_proyecto) REFERENCES dbo.Proyecto(id_proyecto)
);
GO

-- Tabla Especie
IF OBJECT_ID('dbo.Especie') IS NOT NULL DROP TABLE dbo.Especie;
CREATE TABLE dbo.Especie (
    id_especie INT IDENTITY(1,1) PRIMARY KEY,
    nombre_comun NVARCHAR(100) NOT NULL,
    nombre_cientifico NVARCHAR(150) NULL,
    temporada_siembra NVARCHAR(50) NULL
);
GO

-- Tabla Actividad
IF OBJECT_ID('dbo.Actividad') IS NOT NULL DROP TABLE dbo.Actividad;
CREATE TABLE dbo.Actividad (
    id_actividad INT IDENTITY(1,1) PRIMARY KEY,
    tipo_actividad NVARCHAR(50) NOT NULL,
    fecha DATE NOT NULL,
    cantidad INT NULL,
    id_zona INT NOT NULL,
    id_usuario INT NOT NULL,
    id_especie INT NULL,
    CONSTRAINT FK_Actividad_Zona FOREIGN KEY (id_zona) REFERENCES dbo.Zona(id_zona),
    CONSTRAINT FK_Actividad_Usuario FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT FK_Actividad_Especie FOREIGN KEY (id_especie) REFERENCES dbo.Especie(id_especie)
);
GO

-- Tabla Voluntario
IF OBJECT_ID('dbo.Voluntario') IS NOT NULL DROP TABLE dbo.Voluntario;
CREATE TABLE dbo.Voluntario (
    id_voluntario INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    disponibilidad NVARCHAR(50) NULL,
    telefono NVARCHAR(20) NULL,
    CONSTRAINT FK_Voluntario_Usuario FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
GO

-- Tabla Evidencia
IF OBJECT_ID('dbo.Evidencia') IS NOT NULL DROP TABLE dbo.Evidencia;
CREATE TABLE dbo.Evidencia (
    id_evidencia INT IDENTITY(1,1) PRIMARY KEY,
    foto NVARCHAR(255) NULL,
    coordenadas NVARCHAR(150) NULL,
    fecha_registro DATETIME NOT NULL CONSTRAINT DF_Evidencia_Fecha DEFAULT (GETDATE()),
    id_actividad INT NOT NULL,
    CONSTRAINT FK_Evidencia_Actividad FOREIGN KEY (id_actividad) REFERENCES dbo.Actividad(id_actividad)
);
GO

-- Tabla de auditoría simple para proyectos (para trigger)
IF OBJECT_ID('dbo.ProyectoAudit') IS NOT NULL DROP TABLE dbo.ProyectoAudit;
CREATE TABLE dbo.ProyectoAudit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    id_proyecto INT NULL,
    accion NVARCHAR(20),
    usuario NVARCHAR(100) NULL,
    fecha DATETIME DEFAULT (GETDATE()),
    detalles NVARCHAR(MAX) NULL
);
GO

-- 3) INSERTS: 10 datos por tabla
-- Usuarios (10)
INSERT INTO dbo.Usuario (nombres, apellidos, correo, contrasena, rol) VALUES
(N'Carlos','Ramírez Soto','carlos@example.com','pass123','Administrador'),
(N'María','Fernández Pérez','maria@example.com','pass123','Coordinador'),
(N'Luis','Gómez Rivera','luis@example.com','pass123','Voluntario'),
(N'Andrea','Torres Díaz','andrea@example.com','pass123','Voluntario'),
(N'Jorge','Santos Ruiz','jorge@example.com','pass123','Supervisor'),
(N'Lucía','Campos Vega','lucia@example.com','pass123','Voluntario'),
(N'Pedro','Valdivia Paredes','pedro@example.com','pass123','Coordinador'),
(N'Ana','Morales Silva','ana@example.com','pass123','Voluntario'),
(N'Marco','Ibáñez Quispe','marco@example.com','pass123','Supervisor'),
(N'Sofía','Navarro León','sofia@example.com','pass123','Voluntario');
GO

-- Proyectos (10)
INSERT INTO dbo.Proyecto (nombre, descripcion, fecha_inicio, fecha_fin, estado) VALUES
(N'Reforestación Andes', N'Proyecto en zonas altoandinas', '2025-01-10','2025-12-10','Activo'),
(N'Bosques de Vida', N'Recuperación de áreas taladas','2025-02-15','2026-01-30','Activo'),
(N'Selva Limpia', N'Restauración de suelos en selva baja','2025-03-01','2025-12-01','Activo'),
(N'Árboles para el Futuro', N'Campaña nacional de siembra','2025-01-20','2025-11-20','Inactivo'),
(N'EcoRegenera', N'Proyecto urbano de siembra','2025-04-10','2025-10-10','Activo'),
(N'Verde Perú', N'Protección de microcuencas','2025-05-05','2026-05-05','Activo'),
(N'Pulmón Amazónico', N'Reforestación por incendios','2025-06-18','2026-06-18','Activo'),
(N'Plan Ceja de Selva', N'Restauración ecológica','2025-07-12','2026-07-12','Activo'),
(N'Proyecto Sierra Verde', N'Incremento de cobertura arbórea','2025-02-01','2025-09-01','Activo'),
(N'Reverdeciendo el Sur', N'Siembra en zonas áridas del sur','2025-08-20','2026-03-10','Activo');
GO

-- Zonas (10) -> id_proyecto 1..10
INSERT INTO dbo.Zona (nombre_zona, sector, coordenadas, id_proyecto) VALUES
(N'Zona A1','Sector Norte','-12.045,-77.030',1),
(N'Zona B1','Sector Sur','-12.050,-77.040',2),
(N'Zona C1','Sector Este','-12.060,-77.020',3),
(N'Zona D1','Sector Oeste','-12.070,-77.050',4),
(N'Zona A2','Sector Alto','-12.080,-77.010',5),
(N'Zona B2','Sector Bajo','-12.090,-77.015',6),
(N'Zona C2','Sector Central','-12.095,-77.025',7),
(N'Zona D2','Sector Rural','-12.085,-77.035',8),
(N'Zona E1','Sector Bosque','-12.065,-77.045',9),
(N'Zona F1','Sector Quebrada','-12.055,-77.055',10);
GO

-- Especies (10)
INSERT INTO dbo.Especie (nombre_comun, nombre_cientifico, temporada_siembra) VALUES
(N'Quinual', N'Polylepis spp.', N'Invierno'),
(N'Eucalipto', N'Eucalyptus globulus', N'Todo el año'),
(N'Pino', N'Pinus radiata', N'Otoño'),
(N'Molle', N'Schinus molle', N'Primavera'),
(N'Cedro', N'Cedrela odorata', N'Verano'),
(N'Shihuahuaco', N'Dipteryx micrantha', N'Invierno'),
(N'Caoba', N'Swietenia macrophylla', N'Verano'),
(N'Capirona', N'Calycophyllum spruceanum', N'Primavera'),
(N'Aliso', N'Alnus acuminata', N'Otoño'),
(N'Huaranhuay', N'Tecoma stans', N'Todo el año');
GO

-- Actividades (10) -> id_zona 1..10, id_usuario 1..10, id_especie 1..10
INSERT INTO dbo.Actividad (tipo_actividad, fecha, cantidad, id_zona, id_usuario, id_especie) VALUES
(N'Siembra','2025-01-15',50,1,1,1),
(N'Riego','2025-01-18',120,2,2,2),
(N'Fertilización','2025-02-10',30,3,3,3),
(N'Limpieza','2025-02-20',20,4,4,4),
(N'Siembra','2025-03-01',80,5,5,5),
(N'Riego','2025-03-05',150,6,6,6),
(N'Control de plagas','2025-03-12',25,7,7,7),
(N'Siembra','2025-04-01',60,8,8,8),
(N'Mantenimiento','2025-04-05',40,9,9,9),
(N'Siembra','2025-04-10',100,10,10,10);
GO

-- Voluntarios (10) -> id_usuario 1..10
INSERT INTO dbo.Voluntario (id_usuario, disponibilidad, telefono) VALUES
(1,N'Fines de semana','987654321'),
(2,N'Tardes','912345678'),
(3,N'Mañanas','923456789'),
(4,N'Horario completo','934567890'),
(5,N'Fines de semana','945678901'),
(6,N'Tardes','956789012'),
(7,N'Mañanas','967890123'),
(8,N'Horario completo','978901234'),
(9,N'Fines de semana','989012345'),
(10,N'Tardes','990123456');
GO

-- Evidencias (10) -> id_actividad 1..10 (fecha_registro usa DEFAULT GETDATE)
INSERT INTO dbo.Evidencia (foto, coordenadas, id_actividad) VALUES
(N'foto1.jpg','-12.045,-77.030',1),
(N'foto2.jpg','-12.050,-77.040',2),
(N'foto3.jpg','-12.060,-77.020',3),
(N'foto4.jpg','-12.070,-77.050',4),
(N'foto5.jpg','-12.080,-77.010',5),
(N'foto6.jpg','-12.090,-77.015',6),
(N'foto7.jpg','-12.095,-77.025',7),
(N'foto8.jpg','-12.085,-77.035',8),
(N'foto9.jpg','-12.065,-77.045',9),
(N'foto10.jpg','-12.055,-77.055',10);
GO

-- 4) VISTAS (2 ejemplos)
-- Resumen de actividades por zona con responsable y especie
IF OBJECT_ID('dbo.vw_resumen_actividades','V') IS NOT NULL DROP VIEW dbo.vw_resumen_actividades;
GO
CREATE VIEW dbo.vw_resumen_actividades
AS
SELECT 
    z.id_zona,
    z.nombre_zona,
    p.nombre AS proyecto,
    a.tipo_actividad,
    a.fecha,
    a.cantidad,
    u.nombres + N' ' + u.apellidos AS responsable,
    e.nombre_comun AS especie
FROM dbo.Zona z
INNER JOIN dbo.Actividad a ON z.id_zona = a.id_zona
INNER JOIN dbo.Usuario u ON u.id_usuario = a.id_usuario
LEFT JOIN dbo.Especie e ON e.id_especie = a.id_especie
LEFT JOIN dbo.Proyecto p ON p.id_proyecto = z.id_proyecto;
GO

-- Vista de voluntarios disponibles (ejemplo)
IF OBJECT_ID('dbo.vw_voluntarios_disponibles','V') IS NOT NULL DROP VIEW dbo.vw_voluntarios_disponibles;
GO
CREATE VIEW dbo.vw_voluntarios_disponibles
AS
SELECT v.id_voluntario, v.id_usuario, u.nombres + N' ' + u.apellidos AS nombre, v.disponibilidad, v.telefono
FROM dbo.Voluntario v
INNER JOIN dbo.Usuario u ON u.id_usuario = v.id_usuario;
GO

-- 5) TRIGGERS (2 ejemplos)
-- Trigger 1: Evidencia - si por alguna razón no vino fecha_registro (NULL), asignar GETDATE() [aunque ya hay DEFAULT]
IF OBJECT_ID('dbo.trg_Evidencia_SetFecha','TR') IS NOT NULL DROP TRIGGER dbo.trg_Evidencia_SetFecha;
GO
CREATE TRIGGER dbo.trg_Evidencia_SetFecha
ON dbo.Evidencia
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE e
    SET fecha_registro = GETDATE()
    FROM dbo.Evidencia e
    INNER JOIN inserted i ON e.id_evidencia = i.id_evidencia
    WHERE i.fecha_registro IS NULL;
END;
GO

-- Trigger 2: Auditoría simple al insertar o actualizar Proyecto
IF OBJECT_ID('dbo.trg_Proyecto_Audit','TR') IS NOT NULL DROP TRIGGER dbo.trg_Proyecto_Audit;
GO
CREATE TRIGGER dbo.trg_Proyecto_Audit
ON dbo.Proyecto
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Inserciones
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.ProyectoAudit (id_proyecto, accion, usuario, detalles)
        SELECT i.id_proyecto, 
               CASE WHEN d.id_proyecto IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
               SUSER_SNAME(), -- nombre de la sesión SQL
               N'Nombre=' + ISNULL(i.nombre,N'') + N'; Estado=' + ISNULL(i.estado,N'')
        FROM inserted i
        LEFT JOIN deleted d ON i.id_proyecto = d.id_proyecto;
    END

    -- Eliminaciones
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.ProyectoAudit (id_proyecto, accion, usuario, detalles)
        SELECT d.id_proyecto, 'DELETE', SUSER_SNAME(), N'Nombre=' + ISNULL(d.nombre,N'') + N'; Estado=' + ISNULL(d.estado,N'')
        FROM deleted d;
    END
END;
GO

-- 6) PROCEDIMIENTOS ALMACENADOS (2 ejemplos)
-- (A) Registrar Proyecto (simple)
IF OBJECT_ID('dbo.sp_registrar_proyecto','P') IS NOT NULL DROP PROCEDURE dbo.sp_registrar_proyecto;
GO
CREATE PROCEDURE dbo.sp_registrar_proyecto
    @p_nombre NVARCHAR(150),
    @p_descripcion NVARCHAR(MAX) = NULL,
    @p_fecha_inicio DATE = NULL,
    @p_fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Proyecto (nombre, descripcion, fecha_inicio, fecha_fin, estado)
    VALUES (@p_nombre, @p_descripcion, @p_fecha_inicio, @p_fecha_fin, 'Activo');

    SELECT SCOPE_IDENTITY() AS id_proyecto_creado;
END;
GO

-- (B) Registrar Actividad con control transaccional (ejemplo con TRY/CATCH)
IF OBJECT_ID('dbo.sp_registrar_actividad','P') IS NOT NULL DROP PROCEDURE dbo.sp_registrar_actividad;
GO
CREATE PROCEDURE dbo.sp_registrar_actividad
    @tipo_actividad NVARCHAR(50),
    @fecha DATE,
    @cantidad INT = NULL,
    @id_zona INT,
    @id_usuario INT,
    @id_especie INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validaciones básicas
        IF NOT EXISTS (SELECT 1 FROM dbo.Zona WHERE id_zona = @id_zona)
            THROW 51000, 'La zona indicada no existe.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE id_usuario = @id_usuario)
            THROW 51001, 'El usuario indicado no existe.', 1;

        INSERT INTO dbo.Actividad (tipo_actividad, fecha, cantidad, id_zona, id_usuario, id_especie)
        VALUES (@tipo_actividad, @fecha, @cantidad, @id_zona, @id_usuario, @id_especie);

        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS id_actividad_creada;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en sp_registrar_actividad: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

-- 7) EJEMPLOS DE USO (llamadas a los procedimientos)
-- EXEC dbo.sp_registrar_proyecto @p_nombre = N'Proyecto Demo', @p_descripcion = N'Creado desde SP', @p_fecha_inicio = '2025-09-01';
-- EXEC dbo.sp_registrar_actividad @tipo_actividad=N'Siembra', @fecha='2025-09-02', @cantidad=20, @id_zona=1, @id_usuario=1, @id_especie=1;

-- 8) SEGURIDAD (ejemplos) -- crear login, usuario, rol y asignar permisos
-- Advertencia: crear logins requiere permisos de nivel servidor.
-- Si tu entorno es local y tienes permisos, puedes ejecutar lo siguiente. Si estás en un host compartido, omite la creación de login.

-- Crear login de SQL Server (usuario de ejemplo)
-- IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'reforestador_login')
-- BEGIN
--     CREATE LOGIN reforestador_login WITH PASSWORD = 'P@ssw0rd123';
-- END;
-- GO

-- Crear usuario en la base de datos para ese login y un rol específico
-- IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'reforestador')
-- BEGIN
--     CREATE USER reforestador FOR LOGIN reforestador_login;
-- END;
-- GO

-- Crear un rol de base de datos y otorgar permisos mínimos
-- IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ReforestadorRole')
-- BEGIN
--     CREATE ROLE ReforestadorRole;
-- END;
-- GO

-- Agregar usuario al rol
-- ALTER ROLE ReforestadorRole ADD MEMBER reforestador;
-- GO

-- Conceder permisos al rol (ejemplo: solo SELECT y INSERT en tablas relacionadas con actividades)
-- GRANT SELECT ON dbo.Zona TO ReforestadorRole;
-- GRANT SELECT, INSERT ON dbo.Actividad TO ReforestadorRole;
-- GRANT INSERT ON dbo.Evidencia TO ReforestadorRole;
-- GO

-- Nota: para administración más fina, usar permisos DENY/REVOKE según necesidad.

-- 9) RESPALDO (BACKUP) - ejemplos
-- Ajusta las rutas según tu servidor y permisos de disco.

-- Backup completo
-- BACKUP DATABASE reforestacion
-- TO DISK = N'C:\Backups\reforestacion_full.bak'
-- WITH FORMAT, INIT, NAME = N'Reforestacion-Full-Backup', SKIP, STATS = 10;
-- GO

-- Backup diferencial (basado en el último completo)
-- BACKUP DATABASE reforestacion
-- TO DISK = N'C:\Backups\reforestacion_diff.bak'
-- WITH DIFFERENTIAL, NAME = N'Reforestacion-Diff-Backup', STATS = 10;
-- GO

-- Restore (ejemplo) - Ten cuidado: RESTORE reemplaza la base de datos
-- RESTORE DATABASE reforestacion
-- FROM DISK = N'C:\Backups\reforestacion_full.bak'
-- WITH REPLACE, STATS = 10;
-- GO

-- 10) EJEMPLOS ADICIONALES ÚTILES
-- a) Muestra resumen de actividades desde la vista
SELECT TOP 100 * FROM dbo.vw_resumen_actividades;
GO

-- b) Muestra voluntarios disponibles
SELECT * FROM dbo.vw_voluntarios_disponibles;
GO

-- c) Revisar auditoría de proyectos
SELECT TOP 100 * FROM dbo.ProyectoAudit ORDER BY fecha DESC;
GO

/***********************************************
  FIN DEL SCRIPT
  - Ajusta rutas de BACKUP según tu servidor.
  - Si tu servidor no permite CREATE LOGIN, omite esa sección.
  - Si quieres que haga cambios (p. ej. usar schemas distintos,
    agregar índices, o cifrado de contraseñas), dime y lo ajusto.
***********************************************/
