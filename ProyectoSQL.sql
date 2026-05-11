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

DROP FUNCTION IF EXISTS SP_InsertarUsuario(text, text, integer);
CREATE FUNCTION SP_InsertarUsuario(
    p_Nombre_Usuario text,
    p_Credencial_Espacial text,
    p_ID_Perfil integer
) RETURNS jsonb AS $$
DECLARE
    salida jsonb;
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
    WHERE Estado = true;

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