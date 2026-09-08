-- Create the database for the project.
CREATE DATABASE Proyecto1;
GO

-- Switch the session to the new database.
USE Proyecto1;
GO

-- Table: T_Planetas
-- Stores planets with a name, galaxy, and population.
CREATE TABLE T_Planetas
(
    ID_Planeta INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(30) NOT NULL,
    Galaxia NVARCHAR(30) NOT NULL,
    Poblacion NVARCHAR(30) NOT NULL
);

-- Table: T_Bibliotecarios
-- Stores librarians associated with a planet.
CREATE TABLE T_Bibliotecarios
(
    ID_Bibliotecario INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre NVARCHAR(30) NOT NULL,
    Especie NVARCHAR(30) NOT NULL,
    Rango NVARCHAR(30) NOT NULL,
    ID_Planeta INT CONSTRAINT FK_Bibliotecarios_Planeta FOREIGN KEY (ID_Planeta) REFERENCES T_Planetas(ID_Planeta)
);

-- Table: T_Libros_Estelares
-- Stores interstellar books.
CREATE TABLE T_Libros_Estelares
(
    ID_Libro INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Titulo NVARCHAR(30) NOT NULL,
    Autor NVARCHAR(30) NOT NULL,
    Idioma_Universal NVARCHAR(30) NOT NULL
);

-- Table: T_Perfiles_Seguridad
-- Stores security profiles that users can reference.
CREATE TABLE T_Perfiles_Seguridad
(
    ID_Perfil INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nivel_Acceso NVARCHAR(30) NOT NULL,
    Restricciones_Biometricas NVARCHAR(30) NOT NULL
);

-- Table: T_Usuarios_Intergalacticos
-- Stores intergalactic users, their credentials, status, and profile.
CREATE TABLE T_Usuarios_Intergalacticos
(
    ID_Usuario INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre_Usuario NVARCHAR(30) NOT NULL,
    Credencial_Espacial NVARCHAR(30) NOT NULL,
    Estado BIT NOT NULL,
    ID_Perfil INT,
    CONSTRAINT FK_Usuarios_Perfil FOREIGN KEY (ID_Perfil) REFERENCES T_Perfiles_Seguridad (ID_Perfil)
);

-- Table: T_Ejemplares
-- Stores copies of books and their location.
CREATE TABLE T_Ejemplares
(
    ID_Ejemplar INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_Libro INT CONSTRAINT FK_Ejemplares_Libro FOREIGN KEY (ID_Libro) REFERENCES T_Libros_Estelares(ID_Libro),
    Estado_Conservacion NVARCHAR(30) NOT NULL,
    Ubicacion_Pasillo NVARCHAR(30) NOT NULL
);

-- Table: T_Prestamos
-- Stores loan records linking users to book copies.
CREATE TABLE T_Prestamos
(
    ID_Prestamo INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ID_Usuario INT
        CONSTRAINT FK_Prestamos_Usuario
        FOREIGN KEY (ID_Usuario)
        REFERENCES T_Usuarios_Intergalacticos(ID_Usuario),
    ID_Ejemplar INT
        CONSTRAINT FK_Prestamos_Ejemplar
        FOREIGN KEY (ID_Ejemplar)
        REFERENCES T_Ejemplares(ID_Ejemplar),
    Fecha_Estelar_Salida NVARCHAR(30) NOT NULL,
    Fecha_Estelar_Retorno NVARCHAR(30) NOT NULL
);

-- Insert initial sample users.
INSERT INTO T_Usuarios_Intergalacticos
    (Nombre_Usuario, Credencial_Espacial, ID_Perfil, Estado)
VALUES
    ('John Doe', 'CREDENCIAL_ESPACIAL_1', 1, 1),
    ('Jane Smith', 'CREDENCIAL_ESPACIAL_2', 2, 1),
    ('Michael Johnson', 'CREDENCIAL_ESPACIAL_3', 3, 1),
    ('Emily Davis', 'CREDENCIAL_ESPACIAL_4', 2, 1),
    ('David Wilson', 'CREDENCIAL_ESPACIAL_5', 2, 1);

-- Sample read query: return all users.
SELECT *
FROM T_Usuarios_Intergalacticos;

-- Sample read query with a parameter condition.
SELECT *
FROM T_Usuarios_Intergalacticos
WHERE ID_Usuario = 2;

-- Sample update query.
UPDATE T_Usuarios_Intergalacticos
SET
    Nombre_Usuario = 'Carlos Alvarado',
    Credencial_Espacial = 'Pase Especial',
    ID_Perfil = 3
WHERE ID_Usuario = 1;

-- Sample physical delete query.
-- DELETE FROM T_Usuarios_Intergalacticos WHERE ID_Usuario = 1;

-- Sample logical delete query.
UPDATE T_Usuarios_Intergalacticos
SET Estado = 0
WHERE ID_Usuario = 1;

GO

-- Create a view that returns only active users.
CREATE VIEW V_Usuarios_Activos
AS
    SELECT ID_Usuario, Nombre_Usuario, Credencial_Espacial
    FROM T_Usuarios_Intergalacticos
    WHERE Estado = 1;
GO

-- Stored procedure: insert a new user.
-- Validates required fields and returns a status message.
CREATE OR ALTER PROCEDURE SP_InsertarUsuario
    @Nombre_Usuario NVARCHAR(30),
    @Credencial_Espacial NVARCHAR(30),
    @ID_Perfil INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF
            @Nombre_Usuario IS NULL OR LEN(@Nombre_Usuario) = 0 OR
            @Credencial_Espacial IS NULL OR LEN(@Credencial_Espacial) = 0 OR
            @ID_Perfil IS NULL
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'Debes ingresar todos los datos obligatorios.' AS msj_texto;
            RETURN;
        END

        INSERT INTO T_Usuarios_Intergalacticos
        (
            Nombre_Usuario,
            Credencial_Espacial,
            ID_Perfil,
            Estado
        )
        VALUES
        (
            @Nombre_Usuario,
            @Credencial_Espacial,
            @ID_Perfil,
            1
        );

        SELECT
            'success' AS msj_tipo,
            'Exito al realizar la acción.' AS msj_texto;
    END TRY
    BEGIN CATCH
        SELECT
            'error' AS msj_tipo,
            ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the user creation stored procedure.
EXEC SP_InsertarUsuario
    'Carlos Alvarado',
    'Pase Especial',
    2,
    1;
GO

-- Stored procedure: read all active users.
CREATE OR ALTER PROCEDURE SP_LeerUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM T_Usuarios_Intergalacticos
            WHERE Estado = 1
        )
        BEGIN
            SELECT ID_Usuario, Nombre_Usuario, Credencial_Espacial, ID_Perfil, Estado
            FROM T_Usuarios_Intergalacticos
            WHERE Estado = 1;

            SELECT 'success' AS msj_tipo, 'Exito al realizar la acción.' AS msj_texto;
        END
        ELSE
        BEGIN
            SELECT 'warning' AS msj_tipo, 'No se encontraron registros.' AS msj_texto;
        END
    END TRY
    BEGIN CATCH
        SELECT 'error' AS msj_tipo, ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the read-all stored procedure.
EXEC SP_LeerUsuarios;
GO

-- Stored procedure: read a single user by ID.
CREATE OR ALTER PROCEDURE SP_LeerUsuariosPorID
    @ID_Usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate the incoming ID.
        IF @ID_Usuario IS NULL OR @ID_Usuario <= 0
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'Debes ingresar un ID válido.' AS msj_texto;
            RETURN;
        END

        -- If the user exists, return its data and a success message.
        IF EXISTS (
            SELECT 1
            FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario
        )
        BEGIN
            SELECT
                ID_Usuario,
                Nombre_Usuario,
                Credencial_Espacial,
                ID_Perfil,
                Estado
            FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario;

            SELECT
                'success' AS msj_tipo,
                'Usuario encontrado.' AS msj_texto;
        END
        ELSE
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'No se encontraron registros.' AS msj_texto;
        END
    END TRY
    BEGIN CATCH
        SELECT
            'error' AS msj_tipo,
            ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the read-by-id stored procedure.
EXEC SP_LeerUsuariosPorID 2;
GO

-- Stored procedure: update an existing user.
CREATE OR ALTER PROCEDURE SP_ActualizarUsuarios
    @ID_Usuario INT,
    @Nombre_Usuario NVARCHAR(30),
    @Credencial_Espacial NVARCHAR(30),
    @ID_Perfil INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate inputs before updating.
        IF
            @ID_Usuario IS NULL OR
            @ID_Usuario <= 0 OR
            @Nombre_Usuario IS NULL OR
            LEN(LTRIM(RTRIM(@Nombre_Usuario))) = 0 OR
            @Credencial_Espacial IS NULL OR
            LEN(LTRIM(RTRIM(@Credencial_Espacial))) = 0 OR
            @ID_Perfil IS NULL OR
            @ID_Perfil <= 0
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'Debes ingresar todos los datos obligatorios.' AS msj_texto;
            RETURN;
        END

        -- Only update if the user exists.
        IF EXISTS (
            SELECT 1
            FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario
        )
        BEGIN
            UPDATE T_Usuarios_Intergalacticos
            SET
                Nombre_Usuario = @Nombre_Usuario,
                Credencial_Espacial = @Credencial_Espacial,
                ID_Perfil = @ID_Perfil
            WHERE ID_Usuario = @ID_Usuario;

            SELECT
                'success' AS msj_tipo,
                'Exito al realizar la acción.' AS msj_texto;
        END
        ELSE
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'No se encontraron registros.' AS msj_texto;
        END
    END TRY
    BEGIN CATCH
        SELECT
            'error' AS msj_tipo,
            ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the update stored procedure.
EXEC SP_ActualizarUsuarios
    @ID_Usuario = 4,
    @Nombre_Usuario = 'Test',
    @Credencial_Espacial = 'ABC123',
    @ID_Perfil = 1;
GO

-- Stored procedure: logical delete of a user.
-- This marks the user as inactive by setting Estado = 0.
CREATE OR ALTER PROCEDURE SP_EliminarUsuario
    @ID_Usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @ID_Usuario IS NULL OR @ID_Usuario <= 0
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'Debes ingresar un ID válido.' AS msj_texto;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario
              AND Estado = 1
        )
        BEGIN
            UPDATE T_Usuarios_Intergalacticos
            SET Estado = 0
            WHERE ID_Usuario = @ID_Usuario;

            SELECT
                'success' AS msj_tipo,
                'Usuario eliminado correctamente.' AS msj_texto;
        END
        ELSE
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'No se encontraron registros.' AS msj_texto;
        END
    END TRY
    BEGIN CATCH
        SELECT
            'error' AS msj_tipo,
            ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the logical delete stored procedure.
EXEC SP_EliminarUsuario 1;
GO

-- Stored procedure: physical delete of a user.
-- This permanently removes the row from the table.
CREATE OR ALTER PROCEDURE SP_EliminarUsuarioFisico
    @ID_Usuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @ID_Usuario IS NULL OR @ID_Usuario <= 0
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'Debes ingresar un ID válido.' AS msj_texto;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario
        )
        BEGIN
            DELETE FROM T_Usuarios_Intergalacticos
            WHERE ID_Usuario = @ID_Usuario;

            SELECT
                'success' AS msj_tipo,
                'Usuario eliminado físicamente.' AS msj_texto;
        END
        ELSE
        BEGIN
            SELECT
                'warning' AS msj_tipo,
                'No se encontraron registros.' AS msj_texto;
        END
    END TRY
    BEGIN CATCH
        SELECT
            'error' AS msj_tipo,
            ERROR_MESSAGE() AS msj_texto;
    END CATCH
END;
GO

-- Example execution of the physical delete stored procedure.
EXEC SP_EliminarUsuarioFisico 1;

-- ------------------------------------------------------------
-- PostgreSQL function equivalents for Supabase
-- These functions return JSON with message and data.
-- ------------------------------------------------------------
-- ============================================================================
--  PROYECTO 1 · Base de datos intergaláctica (PostgreSQL)
--  Script organizado: esquemas → tablas → restricciones/índices →
--  datos iniciales → vista → funciones CRUD → consultas de ejemplo
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. CREACIÓN DE LA BASE DE DATOS (sesión separada)
--    CREATE DATABASE no puede ejecutarse dentro del mismo script/sesión que
--    el resto de instrucciones, y "GO" es sintaxis de SQL Server (no existe
--    en PostgreSQL). Ejecuta esta línea UNA sola vez, antes que el resto:
--      psql -U <tu_usuario> -d postgres -c "CREATE DATABASE Proyecto1;"
--    Después conéctate a la base Proyecto1 y ejecuta todo lo demás.
-- ----------------------------------------------------------------------------
-- CREATE DATABASE Proyecto1;

-- ----------------------------------------------------------------------------
-- 1. ESQUEMAS Y RUTA DE BÚSQUEDA
--    Se crean los esquemas referenciados antes de fijar el search_path;
--    si tu instalación usa el esquema por defecto "public", elimina este
--    bloque y no hagas SET search_path.
-- ----------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS proyecto1;
CREATE SCHEMA IF NOT EXISTS private;

SET search_path TO proyecto1, private;

-- ----------------------------------------------------------------------------
-- 2. TABLAS
-- ----------------------------------------------------------------------------

-- Planetas: nombre, galaxia y población.
CREATE TABLE T_Planetas
(
    ID_Planeta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre     VARCHAR(30) NOT NULL,
    Galaxia    VARCHAR(30) NOT NULL,
    Poblacion  VARCHAR(30) NOT NULL   -- observación: es un valor numérico; considera BIGINT
);

-- Bibliotecarios asociados a un planeta.
CREATE TABLE T_Bibliotecarios
(
    ID_Bibliotecario INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre           VARCHAR(30) NOT NULL,
    Especie          VARCHAR(30) NOT NULL,
    Rango            VARCHAR(30) NOT NULL,
    ID_Planeta       INT,
    CONSTRAINT FK_Bibliotecarios_Planeta
        FOREIGN KEY (ID_Planeta) REFERENCES T_Planetas(ID_Planeta)
);

-- Libros estelares.
CREATE TABLE T_Libros_Estelares
(
    ID_Libro          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Titulo            VARCHAR(30) NOT NULL,
    Autor             VARCHAR(30) NOT NULL,
    Idioma_Universal  VARCHAR(30) NOT NULL
);

-- Perfiles de seguridad referenciados por los usuarios.
CREATE TABLE T_Perfiles_Seguridad
(
    ID_Perfil                 INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nivel_Acceso              VARCHAR(30) NOT NULL,
    Restricciones_Biometricas VARCHAR(30) NOT NULL
);

-- Usuarios intergalácticos: credenciales, estado y perfil.
CREATE TABLE T_Usuarios_Intergalacticos
(
    ID_Usuario          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre_Usuario      VARCHAR(30) NOT NULL,
    Credencial_Espacial VARCHAR(30) NOT NULL,
    Estado              BOOLEAN NOT NULL,
    ID_Perfil           INT,
    CONSTRAINT FK_Usuarios_Perfil
        FOREIGN KEY (ID_Perfil) REFERENCES T_Perfiles_Seguridad(ID_Perfil)
);

-- ----------------------------------------------------------------------------
-- 3. RESTRICCIONES ÚNICAS E ÍNDICES
--    (Agrupadas aquí, antes de los datos iniciales. La restricción duplicada
--     de T_Planetas que aparecía dos veces en el original se ha reducido a una.)
-- ----------------------------------------------------------------------------
ALTER TABLE T_Planetas
    ADD CONSTRAINT UQ_Planetas_Nombre_Galaxia UNIQUE (Nombre, Galaxia);

ALTER TABLE T_Usuarios_Intergalacticos
    ADD CONSTRAINT UQ_Usuarios_Nombre_Usuario UNIQUE (Nombre_Usuario);

ALTER TABLE T_Usuarios_Intergalacticos
    ADD CONSTRAINT UQ_Usuarios_Credencial_Espacial UNIQUE (Credencial_Espacial);

-- Índice en clave foránea para mejor rendimiento.
CREATE INDEX IX_Bibliotecarios_ID_Planeta ON T_Bibliotecarios(ID_Planeta);

-- Índice para consultas frecuentes sobre estado activo/inactivo.
CREATE INDEX IX_Usuarios_Estado ON T_Usuarios_Intergalacticos(Estado);

-- Índices pendientes: las tablas T_Ejemplares y T_Prestamos NO están definidas
-- en este script, por lo que estos índices se dejan comentados (ver lista de
-- dependencias al final). Si esas tablas viven en otro script, descoméntalos.
-- CREATE INDEX IX_Ejemplares_ID_Libro   ON T_Ejemplares(ID_Libro);
-- CREATE INDEX IX_Prestamos_ID_Usuario  ON T_Prestamos(ID_Usuario);
-- CREATE INDEX IX_Prestamos_ID_Ejemplar ON T_Prestamos(ID_Ejemplar);

-- ----------------------------------------------------------------------------
-- 4. DATOS INICIALES
--    Los perfiles se insertan primero para respetar la FK de los usuarios
--    (ID_Perfil 1, 2 y 3 existen). Todos los valores caben en VARCHAR(30).
-- ----------------------------------------------------------------------------
INSERT INTO T_Perfiles_Seguridad (Nivel_Acceso, Restricciones_Biometricas)
VALUES
    ('Básico', 'Ninguna'),
    ('Intermedio', 'Huella Digital'),
    ('Avanzado', 'Escaneo Retinal');

INSERT INTO T_Usuarios_Intergalacticos
    (Nombre_Usuario, Credencial_Espacial, ID_Perfil, Estado)
VALUES
    ('John Doe',        'CREDENCIAL_ESPACIAL_1', 1, TRUE),
    ('Jane Smith',      'CREDENCIAL_ESPACIAL_2', 2, TRUE),
    ('Michael Johnson', 'CREDENCIAL_ESPACIAL_3', 3, TRUE),
    ('Emily Davis',     'CREDENCIAL_ESPACIAL_4', 2, TRUE),
    ('David Wilson',    'CREDENCIAL_ESPACIAL_5', 2, TRUE);

-- ----------------------------------------------------------------------------
-- 5. VISTA: usuarios activos
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW V_Usuarios_Activos AS
SELECT ID_Usuario, Nombre_Usuario, Credencial_Espacial
FROM T_Usuarios_Intergalacticos
WHERE Estado = TRUE;

-- ----------------------------------------------------------------------------
-- 6. FUNCIONES CRUD (API JSONB)
--    Se conserva la versión FUNCIÓN que devuelve jsonb (la que consume el
--    frontend). Las versiones PROCEDURE con SELECT sueltos se han eliminado:
--    en PostgreSQL un SELECT sin destino dentro de un PROCEDURE es inválido
--    (error 42601) y no devuelve resultados. Cada función se elimina antes
--    de crearse para que el script sea re-ejecutable.
-- ----------------------------------------------------------------------------

-- 6.1 Insertar usuario -------------------------------------------------------
DROP FUNCTION IF EXISTS SP_InsertarUsuario(text, text, integer);

CREATE FUNCTION SP_InsertarUsuario(
    p_Nombre_Usuario text,
    p_Credencial_Espacial text,
    p_ID_Perfil integer
) RETURNS jsonb AS $$
BEGIN
    IF p_Nombre_Usuario IS NULL OR length(trim(p_Nombre_Usuario)) = 0 OR
       p_Credencial_Espacial IS NULL OR length(trim(p_Credencial_Espacial)) = 0 OR
       p_ID_Perfil IS NULL THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar todos los datos obligatorios.',
            'datos', jsonb_build_array()
        );
    END IF;

    INSERT INTO T_Usuarios_Intergalacticos(
        Nombre_Usuario,
        Credencial_Espacial,
        ID_Perfil,
        Estado
    ) VALUES (
        p_Nombre_Usuario,
        p_Credencial_Espacial,
        p_ID_Perfil,
        true
    );

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Exito al realizar la acción.',
        'datos', jsonb_build_array()
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.2 Leer todos los usuarios activos ----------------------------------------
DROP FUNCTION IF EXISTS SP_LeerUsuarios();

CREATE FUNCTION SP_LeerUsuarios() RETURNS jsonb AS $$
DECLARE
    datos jsonb;
BEGIN
    SELECT jsonb_agg(jsonb_build_object(
        'ID_Usuario', ID_Usuario,
        'Nombre_Usuario', Nombre_Usuario,
        'Credencial_Espacial', Credencial_Espacial,
        'ID_Perfil', ID_Perfil,
        'Estado', Estado
    )) INTO datos
    FROM T_Usuarios_Intergalacticos
   ;

    IF datos IS NULL THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros.',
            'datos', jsonb_build_array()
        );
    END IF;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Exito al realizar la acción.',
        'datos', datos
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.3 Leer un usuario por ID ---------------------------------------------------
DROP FUNCTION IF EXISTS SP_LeerUsuariosPorID(integer);

CREATE FUNCTION SP_LeerUsuariosPorID(
    p_ID_Usuario integer
) RETURNS jsonb AS $$
DECLARE
    datos jsonb;
BEGIN
    IF p_ID_Usuario IS NULL OR p_ID_Usuario <= 0 THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar un ID válido.',
            'datos', jsonb_build_array()
        );
    END IF;

    SELECT jsonb_agg(jsonb_build_object(
        'ID_Usuario', ID_Usuario,
        'Nombre_Usuario', Nombre_Usuario,
        'Credencial_Espacial', Credencial_Espacial,
        'ID_Perfil', ID_Perfil,
        'Estado', Estado
    )) INTO datos
    FROM T_Usuarios_Intergalacticos
    WHERE ID_Usuario = p_ID_Usuario;

    IF datos IS NULL THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros.',
            'datos', jsonb_build_array()
        );
    END IF;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Usuario encontrado.',
        'datos', datos
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.4 Actualizar usuario -------------------------------------------------------
DROP FUNCTION IF EXISTS SP_ActualizarUsuarios(integer, text, text, integer);
CREATE FUNCTION SP_ActualizarUsuarios(
    p_ID_Usuario integer,
    p_Nombre_Usuario text,
    p_Credencial_Espacial text,
    p_ID_Perfil integer
) RETURNS jsonb AS $$
BEGIN
    IF p_ID_Usuario IS NULL OR p_ID_Usuario <= 0 OR
       p_Nombre_Usuario IS NULL OR length(trim(p_Nombre_Usuario)) = 0 OR
       p_Credencial_Espacial IS NULL OR length(trim(p_Credencial_Espacial)) = 0 OR
       p_ID_Perfil IS NULL OR p_ID_Perfil <= 0 THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar todos los datos obligatorios.',
            'datos', jsonb_build_array()
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM T_Usuarios_Intergalacticos
        WHERE ID_Usuario = p_ID_Usuario
    ) THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros.',
            'datos', jsonb_build_array()
        );
    END IF;

    UPDATE T_Usuarios_Intergalacticos
    SET
        Nombre_Usuario = p_Nombre_Usuario,
        Credencial_Espacial = p_Credencial_Espacial,
        ID_Perfil = p_ID_Perfil
    WHERE ID_Usuario = p_ID_Usuario;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Exito al realizar la acción.',
        'datos', jsonb_build_array()
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.5 Borrado lógico (Estado = false) ------------------------------------------
DROP FUNCTION IF EXISTS SP_EliminarUsuario(integer);
CREATE FUNCTION SP_EliminarUsuario(
    p_ID_Usuario integer
) RETURNS jsonb AS $$
BEGIN
    IF p_ID_Usuario IS NULL OR p_ID_Usuario <= 0 THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar un ID válido.',
            'datos', jsonb_build_array()
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM T_Usuarios_Intergalacticos
        WHERE ID_Usuario = p_ID_Usuario
          AND Estado = true
    ) THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros.',
            'datos', jsonb_build_array()
        );
    END IF;

    UPDATE T_Usuarios_Intergalacticos
    SET Estado = false
    WHERE ID_Usuario = p_ID_Usuario;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Usuario eliminado correctamente.',
        'datos', jsonb_build_array()
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.6 Borrado físico (DELETE) ----------------------------------------------------
DROP FUNCTION IF EXISTS SP_EliminarUsuarioFisico(integer);
CREATE FUNCTION SP_EliminarUsuarioFisico(
    p_ID_Usuario integer
) RETURNS jsonb AS $$
BEGIN
    IF p_ID_Usuario IS NULL OR p_ID_Usuario <= 0 THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar un ID válido.',
            'datos', jsonb_build_array()
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM T_Usuarios_Intergalacticos
        WHERE ID_Usuario = p_ID_Usuario
    ) THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros.',
            'datos', jsonb_build_array()
        );
    END IF;

    DELETE FROM T_Usuarios_Intergalacticos
    WHERE ID_Usuario = p_ID_Usuario;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Usuario eliminado físicamente.',
        'datos', jsonb_build_array()
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- 6.7 Reactivar usuario (Estado = true) ------------------------------------------
DROP FUNCTION IF EXISTS SP_ReactivarUsuario(integer);
CREATE FUNCTION SP_ReactivarUsuario(
    p_ID_Usuario integer
) RETURNS jsonb AS $$
BEGIN
    IF p_ID_Usuario IS NULL OR p_ID_Usuario <= 0 THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'Debes ingresar un ID válido.',
            'datos', jsonb_build_array()
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM T_Usuarios_Intergalacticos
        WHERE ID_Usuario = p_ID_Usuario
          AND Estado = false
    ) THEN
        RETURN jsonb_build_object(
            'msj_tipo', 'warning',
            'msj_texto', 'No se encontraron registros inactivos.',
            'datos', jsonb_build_array()
        );
    END IF;

    UPDATE T_Usuarios_Intergalacticos
    SET Estado = true
    WHERE ID_Usuario = p_ID_Usuario;

    RETURN jsonb_build_object(
        'msj_tipo', 'success',
        'msj_texto', 'Usuario reactivado correctamente.',
        'datos', jsonb_build_array()
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'msj_tipo', 'error',
        'msj_texto', sqlerrm,
        'datos', jsonb_build_array()
    );
END;

$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 7. CONSULTAS DE EJEMPLO
--    Ojo: los datos sembrados ocupan los IDs 1 a 5. Las consultas que usan
--    ID_Usuario = 7 son ejemplos y no afectarán a ninguna fila real.
-- ----------------------------------------------------------------------------

-- Todos los usuarios.
SELECT *
FROM T_Usuarios_Intergalacticos;

-- Un usuario por ID (sin resultado si el ID 7 no existe tras el seed).
SELECT *
FROM T_Usuarios_Intergalacticos
WHERE ID_Usuario = 7;

-- Actualizar un usuario (ejemplo; con los datos sembrados, no coincide con nadie).
UPDATE T_Usuarios_Intergalacticos
SET
    Nombre_Usuario = 'Carlos Alvarado',
    Credencial_Espacial = 'Pase Especial',
    ID_Perfil = 3
WHERE ID_Usuario = 7;

-- Borrado lógico (desactiva al usuario 1, 'John Doe').
UPDATE T_Usuarios_Intergalacticos
SET Estado = FALSE
WHERE ID_Usuario = 1;

-- Consultar la vista de usuarios activos.
SELECT * FROM V_Usuarios_Activos;

-- Ejemplos de uso de las funciones CRUD (devuelven jsonb):
-- SELECT * FROM SP_LeerUsuarios();
-- SELECT * FROM SP_LeerUsuariosPorID(1);
-- SELECT * FROM SP_InsertarUsuario('Nuevo Usuario', 'CREDENCIAL_ESPACIAL_9', 2);
-- SELECT * FROM SP_ActualizarUsuarios(6, 'Nuevo Usuario', 'CREDENCIAL_ESPACIAL_9', 2);
-- SELECT * FROM SP_EliminarUsuario(6);
-- SELECT * FROM SP_ReactivarUsuario(6);
-- SELECT * FROM SP_EliminarUsuarioFisico(6);
