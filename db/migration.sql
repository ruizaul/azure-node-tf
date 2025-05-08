-- Script de migración para la base de datos en Azure SQL
-- Este script crea las tablas necesarias para la aplicación node-tf

-- Verifica si la tabla Usuarios existe, si no, la crea
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios')
BEGIN
    CREATE TABLE Usuarios (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        email NVARCHAR(150) NOT NULL UNIQUE
    );
    
    PRINT 'Tabla Usuarios creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla Usuarios ya existe';
END

-- Inserta algunos datos de ejemplo si la tabla está vacía
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios') AND NOT EXISTS (SELECT TOP 1 * FROM Usuarios)
BEGIN
    INSERT INTO Usuarios (nombre, email) 
    VALUES 
        ('Juan Pérez', 'juan@ejemplo.com'),
        ('María García', 'maria@ejemplo.com'),
        ('Carlos Rodríguez', 'carlos@ejemplo.com');
        
    PRINT 'Datos de ejemplo insertados en la tabla Usuarios';
END 