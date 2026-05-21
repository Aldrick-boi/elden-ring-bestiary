USE Elden_Ring;


/*
CREACION DE TABLAS 
*/


CREATE TABLE categoria_enemigo (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50)  NOT NULL UNIQUE,
    barra_vida_visible BOOLEAN NOT NULL DEFAULT FALSE,
    tiene_cinematica BOOLEAN NOT NULL DEFAULT FALSE,
    respawnea_al_descansar BOOLEAN NOT NULL DEFAULT TRUE,
    descripcion TEXT
);

CREATE TABLE ubicacion (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_region VARCHAR(100) NOT NULL UNIQUE,
    nivel_recomendado_min INT NOT NULL,
    nivel_recomendado_max INT NOT NULL,
    clima_predominante VARCHAR(50) NOT NULL DEFAULT 'Templado',
    es_zona_subterranea BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_nivel_min CHECK (nivel_recomendado_min >= 1),
    CONSTRAINT chk_nivel_rango CHECK (nivel_recomendado_max >= nivel_recomendado_min),
    CONSTRAINT chk_nivel_max_cap CHECK (nivel_recomendado_max <= 713)
);

CREATE TABLE faccion (
    id_faccion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_faccion VARCHAR(100) NOT NULL UNIQUE,
    lider_faccion VARCHAR(100),
    emblema_representativo VARCHAR(100),
    aliados_naturales VARCHAR(255),
    descripcion_lore TEXT
);

CREATE TABLE origen_contenido (
    id_origen INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    es_dlc BOOLEAN NOT NULL DEFAULT FALSE,
    version_parche VARCHAR(50) NOT NULL,
    director VARCHAR(100) NOT NULL DEFAULT 'Hidetaka Miyazaki',
    descripcion TEXT
);

CREATE TABLE tipo_objeto (
    id_tipo_objeto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE,
    es_consumible BOOLEAN NOT NULL DEFAULT FALSE,
    es_equipable BOOLEAN NOT NULL DEFAULT FALSE,
    limite_inventario INT NOT NULL DEFAULT 999,
    descripcion TEXT,
    CONSTRAINT chk_limite_inv CHECK (limite_inventario > 0)
);

CREATE TABLE atributo_combate (
    id_atributo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_atributo VARCHAR(50) NOT NULL UNIQUE,
    color_visual VARCHAR(50) NOT NULL DEFAULT 'Blanco',
    stat_asociado VARCHAR(50),
    es_dano_fisico BOOLEAN NOT NULL DEFAULT FALSE,
    descripcion TEXT
);

CREATE TABLE efecto_estado (
    id_efecto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_efecto VARCHAR(50) NOT NULL UNIQUE,
    stat_que_lo_mitiga VARCHAR(50) NOT NULL,
    duracion_base_segundos INT NOT NULL DEFAULT 0,
    hace_dano_porcentual BOOLEAN NOT NULL DEFAULT FALSE,
    efecto_visual VARCHAR(100),
    CONSTRAINT chk_duracion CHECK (duracion_base_segundos >= 0)
);

CREATE TABLE questline (
    id_quest INT AUTO_INCREMENT PRIMARY KEY,
    nombre_quest VARCHAR(100) NOT NULL UNIQUE,
    npc_iniciador VARCHAR(100) NOT NULL,
    recompensa_final VARCHAR(100),
    es_obligatoria_historia BOOLEAN NOT NULL DEFAULT FALSE,
    lore_asociado TEXT
);

CREATE TABLE enemigo (
    id_enemigo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    hp_base INT NOT NULL,
    dmg_base INT NOT NULL,
    id_categoria INT NOT NULL,
    id_faccion INT NOT NULL,
    id_ubicacion INT NOT NULL,
    id_origen INT NOT NULL,
    CONSTRAINT chk_hp_positivo  CHECK (hp_base > 0),
    CONSTRAINT chk_dmg_positivo CHECK (dmg_base >= 0),
    CONSTRAINT fk_enemigo_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria_enemigo(id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enemigo_faccion
        FOREIGN KEY (id_faccion) REFERENCES faccion(id_faccion)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enemigo_ubicacion
        FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enemigo_origen
        FOREIGN KEY (id_origen) REFERENCES origen_contenido(id_origen)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ficha_jefe (
    id_enemigo INT PRIMARY KEY,
    titulo_jefe VARCHAR(100) NOT NULL,
    tema_musical VARCHAR(100),
    numero_fases INT NOT NULL DEFAULT 1,
    recompensa_runas INT NOT NULL,
    es_jefe_remembranza BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_invocacion_npc BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_fases CHECK (numero_fases BETWEEN 1 AND 5),
    CONSTRAINT chk_runas CHECK (recompensa_runas >= 0),
    CONSTRAINT fk_ficha_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE objeto_drop (
    id_objeto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_objeto VARCHAR(100) NOT NULL UNIQUE,
    valor_en_runas INT NOT NULL DEFAULT 0,
    peso_kg DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
    descripcion_lore TEXT,
    id_tipo_objeto INT NOT NULL,
    CONSTRAINT chk_valor_runas CHECK (valor_en_runas >= 0),
    CONSTRAINT chk_peso CHECK (peso_kg >= 0),
    CONSTRAINT fk_objeto_tipo
        FOREIGN KEY (id_tipo_objeto) REFERENCES tipo_objeto(id_tipo_objeto)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE enemigo_quest (
    id_enemigo INT NOT NULL,
    id_quest INT NOT NULL,
    rol_en_mision  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_enemigo, id_quest),
    CONSTRAINT fk_eq_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_eq_quest
        FOREIGN KEY (id_quest) REFERENCES questline(id_quest)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE enemigo_resistencia (
    id_enemigo INT NOT NULL,
    id_atributo INT NOT NULL,
    reduccion_dano DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (id_enemigo, id_atributo),
    CONSTRAINT chk_reduccion CHECK (reduccion_dano BETWEEN 0 AND 100),
    CONSTRAINT fk_er_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_er_atributo
        FOREIGN KEY (id_atributo) REFERENCES atributo_combate(id_atributo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE enemigo_debilidad (
    id_enemigo INT NOT NULL,
    id_atributo INT NOT NULL,
    multiplicador_dano DECIMAL(4,2) NOT NULL,
    PRIMARY KEY (id_enemigo, id_atributo),
    CONSTRAINT chk_multiplicador CHECK (multiplicador_dano > 1.00 AND multiplicador_dano <= 5.00),
    CONSTRAINT fk_ed_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ed_atributo
        FOREIGN KEY (id_atributo) REFERENCES atributo_combate(id_atributo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE enemigo_drop (
    id_enemigo INT NOT NULL,
    id_objeto INT NOT NULL,
    probabilidad_drop DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (id_enemigo, id_objeto),
    CONSTRAINT chk_probabilidad CHECK (probabilidad_drop > 0 AND probabilidad_drop <= 100),
    CONSTRAINT fk_edrop_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_edrop_objeto
        FOREIGN KEY (id_objeto) REFERENCES objeto_drop(id_objeto)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ataque_aplica_efecto (
    id_enemigo INT NOT NULL,
    id_efecto INT NOT NULL,
    puntos_acumulacion INT NOT NULL,
    PRIMARY KEY (id_enemigo, id_efecto),
    CONSTRAINT chk_puntos_acum CHECK (puntos_acumulacion > 0),
    CONSTRAINT fk_aae_enemigo
        FOREIGN KEY (id_enemigo) REFERENCES enemigo(id_enemigo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_aae_efecto
        FOREIGN KEY (id_efecto) REFERENCES efecto_estado(id_efecto)
        ON DELETE CASCADE ON UPDATE CASCADE
);



/*
INSERT DE DATOS 
*/



INSERT INTO categoria_enemigo (nombre_categoria, barra_vida_visible, tiene_cinematica, respawnea_al_descansar, descripcion) VALUES
('Normal', FALSE, FALSE, TRUE,  'Enemigo base que reaparece al descansar en una Gracia.'),
('Élite', FALSE, FALSE, TRUE,  'Enemigo común pero con stats elevados.'),
('Minijefe', TRUE,  FALSE, FALSE, 'Enemigo con barra de vida visible, no respawnea.'),
('Jefe de Mazmorra', TRUE,  FALSE, FALSE, 'Jefe que custodia el final de catacumbas o ruinas.'),
('Jefe Mayor', TRUE,  TRUE,  FALSE, 'Jefe principal con cinemática de introducción.'),
('Jefe de Remembranza', TRUE,  TRUE,  FALSE, 'Jefe principal que otorga una Remembranza al morir.'),
('Jefe Final', TRUE,  TRUE,  FALSE, 'Jefe que define un final del juego.'),
('NPC Invasor', TRUE,  FALSE, FALSE, 'NPC hostil que invade al jugador en zonas específicas.'),
('NPC Cazador Rojo', TRUE,  FALSE, FALSE, 'Invasor enviado por la facción Volcano Manor.'),
('Fauna Pacífica', FALSE, FALSE, TRUE,  'Criaturas no hostiles del entorno.'),
('Fauna Hostil', FALSE, FALSE, TRUE,  'Animales salvajes agresivos.'),
('Bestia Mítica', TRUE,  FALSE, FALSE, 'Criatura legendaria de gran tamaño, no es jefe formal.'),
('Soldado Caído', FALSE, FALSE, TRUE,  'Soldado errante sin facción definida.'),
('Espíritu Errante', FALSE, FALSE, TRUE,  'Fantasma de baja amenaza.'),
('Espíritu Pesadilla', TRUE,  FALSE, FALSE, 'Aparición rara con drops únicos.'),
('Guardián de Tesoro', TRUE,  FALSE, FALSE, 'Custodia ítems raros en cofres o altares.'),
('Caballero de Facción', FALSE, FALSE, TRUE,  'Tropa élite leal a una facción.'),
('Mago Hechicero', FALSE, FALSE, TRUE,  'Enemigo lanzador de hechizos.'),
('Clérigo Encantador', FALSE, FALSE, TRUE,  'Enemigo usuario de encantamientos sagrados.'),
('Asesino', FALSE, FALSE, TRUE,  'Enemigo sigiloso con ataques rápidos.'),
('Bestia Sagrada', TRUE,  FALSE, FALSE, 'Criatura asociada al Árbol Áureo.'),
('Bestia Profanada', TRUE,  FALSE, FALSE, 'Criatura corrompida por sangre o llama.'),
('Bestia de Sombra', TRUE,  FALSE, FALSE, 'Criatura del Reino de la Sombra (DLC).'),
('Soldado Hornsent', FALSE, FALSE, TRUE,  'Soldado del pueblo Hornsent (DLC).'),
('Soldado Mesmer', FALSE, FALSE, TRUE,  'Tropa al servicio de Messmer (DLC).'),
('Furtivo Albinaúrico', FALSE, FALSE, TRUE,  'Albinaúrico sigiloso de las criptas.'),
('Jefe Opcional', TRUE,  TRUE,  FALSE, 'Jefe que no es obligatorio para terminar el juego.'),
('Dragón', TRUE,  FALSE, FALSE, 'Dragón antiguo o regular del juego.'),
('Centinela', FALSE, FALSE, TRUE,  'Guardia mecánico o de piedra.'),
('Crustáceo Gigante', FALSE, FALSE, TRUE,  'Cangrejos o langostas de gran tamaño.');

INSERT INTO ubicacion (nombre_region, nivel_recomendado_min, nivel_recomendado_max, clima_predominante, es_zona_subterranea) VALUES
('Limgrave', 1, 30, 'Templado', FALSE),
('Necrolimbo', 10, 35, 'Niebla', FALSE),
('Península Llorosa', 5, 25, 'Lluvioso', FALSE),
('Castillo Tempestad', 15, 35, 'Tormenta', FALSE),
('Liurnia de los Lagos', 30, 60, 'Lluvioso', FALSE),
('Academia Raya Lucaria', 40, 65, 'Niebla', FALSE),
('Caelid', 60, 90, 'Putrefacción', FALSE),
('Tierras Heridas', 70, 100, 'Putrefacción', FALSE),
('Mesetas de Altus', 60,  90, 'Templado', FALSE),
('Leyndell Capital Real', 80, 110, 'Solemne', FALSE),
('Volcano Manor', 85, 115, 'Volcánico', FALSE),
('Monte Gelmir', 75, 100, 'Volcánico', FALSE),
('Cima de los Gigantes', 100, 130, 'Nevado', FALSE),
('Crumbling Farum Azula', 120, 150, 'Tormenta', FALSE),
('Leyndell Capital de Cenizas', 130, 160, 'Cenizas', FALSE),
('Tierras Sagradas', 140, 170, 'Niebla nevada', FALSE),
('Río Siofra', 30, 60, 'Subterráneo', TRUE),
('Río Ainsel', 50, 80, 'Subterráneo', TRUE),
('Nokron Ciudad Eterna', 40, 70, 'Subterráneo', TRUE),
('Nokstella Ciudad Eterna', 60, 85, 'Subterráneo', TRUE),
('Deeproot Depths', 90, 120, 'Subterráneo', TRUE),
('Pozo Lava de Mohgwyn', 110, 140, 'Sangre', TRUE),
('Tierra de Sombra', 120, 160, 'Crepúsculo', FALSE),
('Cerulean Coast', 120, 150, 'Lluvia espectral', FALSE),
('Castillo Ensis', 130, 160, 'Templado', FALSE),
('Scadu Altus', 140, 170, 'Crepúsculo', FALSE),
('Reborde Furtivo', 145, 175, 'Niebla', FALSE),
('Ciudad Eterna Belurat', 135, 165, 'Crepúsculo', FALSE),
('Enir-Ilim', 170, 200, 'Solemne', FALSE),
('Abismo de los Finger Ruins', 130, 160, 'Crepúsculo', FALSE);

INSERT INTO faccion (nombre_faccion, lider_faccion, emblema_representativo, aliados_naturales, descripcion_lore) VALUES
('Sin facción / Fauna', NULL, NULL, NULL, 'Centinela para enemigos sin afiliación facción específica.'),
('Casa Hoslow', 'Juno Hoslow', 'Trenza sangrienta', 'Casa Volcano', 'Casa noble obsesionada con el combate y la sangre.'),
('Académicos Raya Lucaria', 'Rennala', 'Luna llena', 'Carianos', 'Hechiceros expertos en magia glintstone.'),
('Casa Caria', 'Rennala', 'Luna creciente', 'Académicos Raya Lucaria', 'Casa noble de Liurnia, dominio de la magia carianos.'),
('Volcano Manor', 'Rykard', 'Serpiente envenenada','Casa Hoslow', 'Mansión de exiliados que invaden Sin Sombra.'),
('Iglesia Áurea', 'Reina Marika', 'Árbol Áureo', 'Caballeros Sin Sombra', 'Religión oficial de las Tierras Intermedias.'),
('Sangre de Mohgwyn', 'Mohg', 'Tres cuernos', 'Cultistas Albinaúricos', 'Culto a la sangre liderado por Mohg.'),
('Familia Real Carian', 'Ranni', 'Carian dorado', 'Academia', 'Realeza maga de Liurnia.'),
('Crucificantes', 'Maliketh', 'Garra negra', 'Iglesia Áurea', 'Sirvientes de la diosa de la muerte.'),
('Tarnished Errantes', NULL, 'Anillo dorado', NULL, 'Sin Sombra exiliados que regresan a Tierras Intermedias.'),
('Caballeros Sin Sombra', 'Godfrey', 'León dorado', 'Iglesia Áurea', 'Antigua orden élite del Lord Sin Sombra.'),
('Bandidos Demi-humanos', 'Rey Demi-humano', 'Calavera tribal', 'Fauna Hostil', 'Tribus salvajes de demi-humanos.'),
('Ejército Putrefacto', 'Malenia', 'Aegis Putrefacto', 'Sin facción / Fauna', 'Restos del ejército de Malenia.'),
('Clan Nox', NULL, 'Hormiga eterna', 'Albinaúricos', 'Antiguos habitantes subterráneos.'),
('Albinaúricos', NULL, 'Frasco vacío', 'Clan Nox', 'Raza creada artificialmente, perseguida.'),
('Cultistas del Frenesí', 'Mohg', 'Ojo amarillo', 'Sangre de Mohgwyn', 'Locos seguidores de la Llama Frenética.'),
('Dragones Antiguos', 'Placidusax', 'Dragón estelar', 'Sin facción / Fauna', 'Dragones que precedieron al Anillo Áureo.'),
('Estirpe Crucible', NULL, 'Cuernos crucible', 'Iglesia Áurea', 'Antiguos guerreros del aspecto crucible.'),
('Hornsent', NULL, 'Cuernos sagrados', 'Sin facción / Fauna', 'Pueblo cornudo del Reino de la Sombra (DLC).'),
('Ejército de Messmer', 'Messmer', 'Serpiente de fuego', 'Iglesia Áurea', 'Tropas leales al hijo de Marika (DLC).'),
('Curtidores de Sombra', NULL, 'Marca de sombra', 'Hornsent', 'Trabajadores que curten cuero de bestias (DLC).'),
('Caballeros Limosna', NULL, 'Cuenco roto', 'Sin facción / Fauna', 'Caballeros desposeídos que mendigan (DLC).'),
('Iglesia Innominada', 'Marika', 'Cruz mancillada', 'Iglesia Áurea', 'Antigua iglesia previa al Anillo Áureo (DLC).'),
('Devotos de Miquella', 'Miquella', 'Cruz dorada', 'Sin facción / Fauna', 'Seguidores del Lord Empíreo (DLC).'),
('Caballeros del Carbón', NULL, 'Llama negra', 'Crucificantes', 'Antigua orden ahora corrupta.'),
('Mineros Perfumadores',    NULL, 'Hoz de minero', 'Sin facción / Fauna', 'Habitantes de cuevas minerales.'),
('Niños Marioneta', NULL, 'Hilo carmesí', 'Familia Real Carian', 'Marionetas mágicas de los Carian.'),
('Soldados Godrick', 'Godrick el Injertado','Soldado injertado',   'Sin facción / Fauna', 'Soldados del usurpador de Limgrave.'),
('Cuervos del Pico', NULL, 'Pluma negra', 'Sin facción / Fauna', 'Demi-humanos asesinos.'),
('Niebla Espectral', NULL, 'Ojo de niebla', 'Sin facción / Fauna', 'Espíritus que rondan las ruinas.');

INSERT INTO origen_contenido (nombre, es_dlc, version_parche, director, descripcion) VALUES
('Base Game - Lanzamiento', FALSE, '1.00', 'Hidetaka Miyazaki', 'Versión original de lanzamiento, 25 de febrero 2022.'),
('Base Game - Parche 1.02', FALSE, '1.02', 'Hidetaka Miyazaki', 'Ajustes de balance, adición de invocaciones espirituales mejoradas.'),
('Base Game - Parche 1.03', FALSE, '1.03', 'Hidetaka Miyazaki', 'Quest de Diallos extendida, ajustes a hechizos.'),
('Base Game - Parche 1.04', FALSE, '1.04', 'Hidetaka Miyazaki', 'Balance de armas, nerfeo a Mimic Tear.'),
('Base Game - Parche 1.05', FALSE, '1.05', 'Hidetaka Miyazaki', 'Mejoras de rendimiento y correcciones menores.'),
('Base Game - Parche 1.06', FALSE, '1.06', 'Hidetaka Miyazaki', 'Ajustes a Rivers of Blood y otras armas dominantes.'),
('Base Game - Parche 1.07', FALSE, '1.07', 'Hidetaka Miyazaki', 'Adición de animaciones para multijugador.'),
('Base Game - Parche 1.08', FALSE, '1.08', 'Hidetaka Miyazaki', 'Coliseo PvP introducido.'),
('Base Game - Parche 1.09', FALSE, '1.09', 'Hidetaka Miyazaki', 'Balance de PvP y ajustes de daño.'),
('Base Game - Parche 1.10', FALSE, '1.10', 'Hidetaka Miyazaki', 'Mejoras a hechizos sagrados y ajustes de stagger.'),
('Base Game - Parche 1.11', FALSE, '1.11', 'Hidetaka Miyazaki', 'Correcciones de bugs en quests.'),
('Base Game - Parche 1.12', FALSE, '1.12', 'Hidetaka Miyazaki', 'Preparación pre-DLC, ajustes de mapa.'),
('Shadow of the Erdtree - DLC', TRUE,  '1.12.1', 'Hidetaka Miyazaki', 'Expansión principal del Reino de la Sombra, 21 de junio 2024.'),
('SOTE - Parche 1.12.2', TRUE, '1.12.2', 'Hidetaka Miyazaki', 'Ajuste de daño Scadutree y nerfeo a varios jefes del DLC.'),
('SOTE - Parche 1.12.3', TRUE,  '1.12.3', 'Hidetaka Miyazaki', 'Balance de armas nuevas del DLC.'),
('SOTE - Parche 1.13', TRUE, '1.13', 'Hidetaka Miyazaki', 'Ajustes a Promised Consort Radahn.'),
('SOTE - Parche 1.14', TRUE, '1.14', 'Hidetaka Miyazaki', 'Correcciones menores y balance.'),
('SOTE - Parche 1.15', TRUE, '1.15', 'Hidetaka Miyazaki', 'Mejoras a hitboxes de jefes del DLC.'),
('SOTE - Parche 1.16', TRUE, '1.16', 'Hidetaka Miyazaki', 'Ajustes finales y balance general.'),
('Base Game - Hotfix Caelid', FALSE, '1.04.1', 'Hidetaka Miyazaki', 'Hotfix para spawns infinitos en Caelid.'),
('Base Game - Hotfix Liurnia', FALSE, '1.05.1', 'Hidetaka Miyazaki', 'Corrección de quest de Ranni.'),
('Base Game - Hotfix Mohgwyn', FALSE, '1.06.1', 'Hidetaka Miyazaki', 'Ajuste de farmeo runas en Pozo Lava.'),
('SOTE - Hotfix Messmer', TRUE, '1.13.1', 'Hidetaka Miyazaki', 'Hotfix para hitbox de Messmer fase 2.'),
('SOTE - Hotfix Radahn', TRUE, '1.13.2', 'Hidetaka Miyazaki', 'Reducción de daño cruzado de Radahn.'),
('SOTE - Hotfix Bayle', TRUE, '1.14.1', 'Hidetaka Miyazaki', 'Ajuste de animaciones de Bayle.'),
('Base Game - Evento Estacional 1', FALSE, '1.07.S', 'Hidetaka Miyazaki', 'Evento de invasiones temáticas.'),
('Base Game - Evento Estacional 2', FALSE, '1.10.S', 'Hidetaka Miyazaki', 'Coliseo evento limitado.'),
('SOTE - Evento Estacional 1', TRUE,  '1.14.S', 'Hidetaka Miyazaki', 'Evento de cazadores cooperativos.'),
('Base Game - Parche Aniversario', FALSE, '1.10.A', 'Hidetaka Miyazaki', 'Parche conmemorativo del primer aniversario.'),
('SOTE - Parche Final', TRUE, '1.16.1', 'Hidetaka Miyazaki', 'Parche final del DLC, cierre de balance.');

INSERT INTO tipo_objeto (nombre_tipo, es_consumible, es_equipable, limite_inventario, descripcion) VALUES
('Espada larga', FALSE, TRUE,  10,  'Arma de filo de tamaño medio, balance entre alcance y velocidad.'),
('Espadón', FALSE, TRUE,  10,  'Arma a dos manos de gran tamaño.'),
('Daga', FALSE, TRUE,  10,  'Arma ligera de ataque crítico.'),
('Lanza', FALSE, TRUE,  10,  'Arma de gran alcance para estocadas.'),
('Hacha', FALSE, TRUE,  10,  'Arma de filo pesada con buen poise damage.'),
('Mazo', FALSE, TRUE,  10,  'Arma contundente de daño bruto.'),
('Katana', FALSE, TRUE,  10,  'Arma de filo del este, alta velocidad.'),
('Curva', FALSE, TRUE,  10,  'Espada curva ideal para combos.'),
('Báculo', FALSE, TRUE,  10,  'Catalizador de hechicería glintstone.'),
('Sello sagrado', FALSE, TRUE,  10,  'Catalizador de encantamientos sagrados.'),
('Arco', FALSE, TRUE,  10,  'Arma a distancia de proyectiles.'),
('Ballesta', FALSE, TRUE,  10,  'Arma a distancia de pernos.'),
('Escudo pequeño', FALSE, TRUE,  10,  'Escudo ligero para parry.'),
('Escudo mediano', FALSE, TRUE,  10,  'Escudo balanceado de defensa estándar.'),
('Escudo torre', FALSE, TRUE,  10,  'Escudo grande de máxima defensa.'),
('Armadura ligera', FALSE, TRUE,  10,  'Equipo de protección ligera.'),
('Armadura media', FALSE, TRUE,  10,  'Equipo de protección balanceada.'),
('Armadura pesada', FALSE, TRUE,  10,  'Equipo de máxima defensa, alto peso.'),
('Talismán', FALSE, TRUE,  10,  'Accesorio pasivo de hasta 4 slots.'),
('Hechizo', FALSE, TRUE,  20,  'Magia memorable utilizable con báculo o sello.'),
('Ceniza de guerra', FALSE, TRUE,  20,  'Habilidad especial aplicable a armas.'),
('Material de mejora', FALSE, FALSE, 999, 'Material para mejorar armas en herrería.'),
('Material de cocina', FALSE, FALSE, 999, 'Ingrediente para crear consumibles.'),
('Consumible curativo', TRUE,  FALSE, 999, 'Objeto que restaura vida o estados.'),
('Consumible ofensivo', TRUE,  FALSE, 99,  'Objeto que causa daño al usar.'),
('Runa', FALSE, FALSE, 999, 'Moneda principal del juego.'),
('Remembranza', FALSE, FALSE, 5,   'Item raro que se canjea por recompensas únicas.'),
('Espíritu invocable', FALSE, TRUE,  20,  'Cenizas invocables para combate.'),
('Llave', FALSE, FALSE, 99,  'Abre puertas o pasajes específicos.'),
('Carta de información', FALSE, FALSE, 99,  'Documento que revela lore o ubicaciones.');

INSERT INTO atributo_combate (nombre_atributo, color_visual, stat_asociado, es_dano_fisico, descripcion) VALUES
('Físico Estándar', 'Blanco', 'STR',  TRUE,  'Daño físico genérico, sin tipo especial.'),
('Físico Contundente', 'Blanco', 'STR',  TRUE,  'Daño de impacto, efectivo vs esqueletos.'),
('Físico Cortante', 'Blanco', 'DEX',  TRUE,  'Daño de corte, efectivo vs humanoides ligeros.'),
('Físico Perforante', 'Blanco', 'DEX',  TRUE,  'Daño de estocada, efectivo vs armaduras pesadas.'),
('Magia', 'Azul', 'INT', FALSE, 'Daño mágico glintstone, débil a Físico.'),
('Fuego', 'Naranja', 'FAI', FALSE, 'Daño de fuego, efectivo vs criaturas con armadura.'),
('Rayo', 'Amarillo', 'FAI', FALSE, 'Daño eléctrico, efectivo vs dragones.'),
('Sagrado', 'Dorado', 'FAI', FALSE, 'Daño sagrado, efectivo vs no-muertos.'),
('Hemorragia', 'Rojo', 'ARC', FALSE, 'Efecto de estado físico, % de daño al activar.'),
('Veneno', 'Verde', 'ARC',  FALSE, 'Efecto de estado, daño con el tiempo.'),
('Putrefacción Escarlata','Carmesí',   'ARC',  FALSE, 'Versión letal del veneno.'),
('Frostbite', 'Cian', 'INT',  FALSE, 'Reduce defensas y consume estamina.'),
('Sueño', 'Lavanda', 'ARC',  FALSE, 'Duerme al enemigo, evita acciones.'),
('Locura', 'Amarillo viv','ARC',  FALSE, 'Reduce vida y FP al activar.'),
('Hechizo de Muerte', 'Negro', 'FAI',  FALSE, 'Mata instantáneamente al activar.'),
('Magia Carian', 'Azul lunar', 'INT',  FALSE, 'Variante de magia con espadas mágicas.'),
('Magia Glintstone', 'Azul claro',  'INT',  FALSE, 'Magia clásica de Raya Lucaria.'),
('Magia Estelar', 'Violeta', 'INT',  FALSE, 'Magia que invoca cuerpos celestes.'),
('Magia Cristalina', 'Cyan', 'INT',  FALSE, 'Magia que crea fragmentos sólidos.'),
('Fuego Negro', 'Negro', 'FAI',  FALSE, 'Fuego corrupto, ignora algunas defensas.'),
('Llama Frenética', 'Amarillo', 'FAI',  FALSE, 'Fuego que aplica Locura.'),
('Llama Gigante', 'Rojo', 'FAI',  FALSE, 'Fuego primigenio de los gigantes.'),
('Magia Gravitacional', 'Negro', 'INT',  FALSE, 'Magia que manipula gravedad.'),
('Magia Sangre', 'Carmesí', 'ARC',  FALSE, 'Hechicería de sangre, aplica hemorragia.'),
('Sagrado Maldito', 'Dorado oscuro','FAI', FALSE, 'Variante sagrada del DLC, ignora resistencias.'),
('Aspecto Crucible', 'Bronce', 'FAI',  FALSE, 'Magia primigenia de la Estirpe Crucible.'),
('Daño Espectral', 'Plateado', 'INT',  FALSE, 'Daño de espíritus, ignora armadura física.'),
('Ataque de Sombra', 'Púrpura', 'INT',  FALSE, 'Daño exclusivo del DLC, escala con Scadutree.'),
('Daño Verdadero', 'Blanco puro', 'NULL', FALSE, 'Daño que ignora todas las resistencias.'),
('Daño Stamina', 'Gris', 'END',  TRUE,  'Daño que afecta solo la barra de estamina.');

INSERT INTO efecto_estado (nombre_efecto, stat_que_lo_mitiga, duracion_base_segundos, hace_dano_porcentual, efecto_visual) VALUES
('Hemorragia', 'Robusteza',  0,   TRUE,  'Explosión carmesí'),
('Veneno', 'Inmunidad',  90,  FALSE, 'Burbujas verdes'),
('Putrefacción Escarlata','Inmunidad', 90,  FALSE, 'Vapor escarlata'),
('Frostbite', 'Robusteza',  30,  TRUE,  'Cristales azules'),
('Sueño', 'Concentración',15,FALSE, 'Símbolos de luna'),
('Locura', 'Concentración',0, TRUE,  'Llamas amarillas en ojos'),
('Hechizo de Muerte', 'Vitalidad',  0,   TRUE,  'Aura negra'),
('Quemadura', 'Vitalidad',  10,  FALSE, 'Llamas naranjas'),
('Aturdimiento', 'Robusteza',  3,   FALSE, 'Estrellas amarillas'),
('Parálisis', 'Robusteza',  5,   FALSE, 'Electricidad estática'),
('Maldición Gravedad', 'Inmunidad',  20,  FALSE, 'Aura morada densa'),
('Reducción defensa', 'Inmunidad',  20,  FALSE, 'Aura roja tenue'),
('Reducción ataque', 'Inmunidad',  20,  FALSE, 'Aura azul tenue'),
('Confusión', 'Concentración',10,FALSE, 'Aura iridiscente'),
('Marca de Caza', 'Inmunidad',  30,  FALSE, 'Sigilo dorado'),
('Maldición Sangre', 'Robusteza',  0,   TRUE,  'Sangre flotante'),
('Calor extremo', 'Vitalidad',  15,  FALSE, 'Vapor rojo'),
('Frío extremo', 'Vitalidad',  15,  FALSE, 'Vapor blanco'),
('Estasis', 'Concentración',5, FALSE, 'Aura blanca rígida'),
('Drenado de FP', 'Concentración',10,FALSE, 'Aura morada'),
('Drenado de Stamina', 'Vitalidad',  10,  FALSE, 'Aura amarilla'),
('Maldición Llama Negra','Vitalidad',  10,  TRUE,  'Llama negra'),
('Mortificación', 'Vitalidad',  5,   FALSE, 'Aura sagrada'),
('Bendición Áurea', 'Inmunidad',  60,  FALSE, 'Aura dorada brillante'),
('Aura de Sombra', 'Inmunidad',  20,  FALSE, 'Niebla púrpura'),
('Marchitamiento', 'Inmunidad',  60,  FALSE, 'Hojas secas'),
('Llaga Sangrante', 'Robusteza',  10,  TRUE,  'Goteo carmesí'),
('Crisálida', 'Concentración',8, FALSE, 'Capullo dorado'),
('Eco Mortal', 'Vitalidad',  5,   TRUE,  'Eco oscuro'),
('Plaga Escarlata', 'Inmunidad',  120, TRUE,  'Esporas escarlatas');

INSERT INTO questline (nombre_quest, npc_iniciador, recompensa_final, es_obligatoria_historia, lore_asociado) VALUES
('La Reina Eterna', 'Ranni', 'Final Reina Eterna', TRUE,  'Ranni busca romper el ciclo del Anillo Áureo.'),
('La Hoja del Crepúsculo', 'Millicent', 'Prótesis Rosada', FALSE, 'Millicent intenta superar la putrefacción escarlata.'),
('Casa Volcano', 'Lady Tanith', 'Esmeralda del Carmesí', FALSE, 'Tanith dirige invasores contra blancos específicos.'),
('Sin Sombra Inquebrantable', 'Diallos', 'Karian Gauntlets', FALSE, 'Diallos busca a su sirviente perdido.'),
('Lágrimas de Liurnia', 'Sellen', 'Recomposición de Sellen', FALSE, 'Sellen busca recuperar su cuerpo verdadero.'),
('El Errante de la Roca', 'Boc', 'Belleza de Marika', FALSE, 'Boc el demi-humano busca aceptación.'),
('La Marca del Águila', 'Bernahl', 'Beast Champion Set', FALSE, 'Bernahl deja Volcano Manor por la verdad.'),
('Sangre de la Realeza', 'Yura', 'Espada Nagakiba', FALSE, 'Yura caza al asesino de sangre Eleonora.'),
('El Lord Caído', 'Goldmask', 'Final del Orden Perfecto', TRUE,  'Goldmask busca restaurar la ley fundamental.'),
('Las Dos Hermanas', 'Hyetta', 'Final de la Llama Frenética', TRUE,  'Hyetta ascienden mediante el llama frenética.'),
('Hechicería Carian', 'Thops', 'Hechizo Thops Imbuído', FALSE, 'Thops busca regresar a la Academia.'),
('Caballero de Roundtable', 'Brother Corhyn', 'Hechizo Triple Anillo', FALSE, 'Corhyn busca esparcir las enseñanzas áureas.'),
('Las Llaves de la Capital', 'Dung Eater', 'Final del Mancilladoramente Yermo', FALSE, 'Dung Eater busca mancillar a todos.'),
('La Princesa Caída', 'Nepheli Loux', 'Hacha de Erdtree', FALSE, 'Nepheli busca su origen verdadero.'),
('Las Hormigas Eternas', 'Latenna', 'Espíritu Latenna', FALSE, 'Latenna busca regresar al Halligtree.'),
('La Sombra Errante', 'Blaidd', 'Espadón Royal Greatsword', FALSE, 'Blaidd sirve a Ranni desde su creación.'),
('La Madre de las Hormigas', 'Patches', 'Inventario completo Patches', FALSE, 'Patches comerciante y traidor habitual.'),
('La Caza de Mohg', 'White Mask Varré', 'Bloody Finger', FALSE, 'Varré busca sangre digna de Mohg.'),
('El Druida Putrefacto', 'Gowry', 'Aguja Sin Lluvia', FALSE, 'Gowry manipula a Millicent.'),
('La Espada Carian', 'Iji', 'Espada Ornamental Carian', FALSE, 'Iji protege el legado de Ranni.'),
('La Mensajera de Marika', 'Roderika', 'Mejora invocaciones espíritu', FALSE, 'Roderika descubre su don con espíritus.'),
('El Coloso Caído', 'D, Cazador de Muertos', 'Set D Cazador', FALSE, 'D persigue a los muertos andantes.'),
('La Caza de Bayle', 'Igon', 'Lanza de Igon', FALSE, 'Igon busca venganza contra el dragón Bayle (DLC).'),
('La Cruz de Miquella', 'Sir Ansbach', 'Set Ansbach', TRUE,  'Ansbach guía al Sin Sombra por el camino de Miquella (DLC).'),
('El Caballero de Limosna', 'Thiollier', 'Veneno de Thiollier', FALSE, 'Thiollier sirve a Saint Trina (DLC).'),
('La Hija de Marika', 'Leda', 'Set Leda', FALSE, 'Leda lidera la cruzada por Miquella (DLC).'),
('El Hijo del Fuego', 'Hornsent', 'Maza Mohgwyn', FALSE, 'Último Hornsent busca venganza contra Marika (DLC).'),
('La Marca del Crucible', 'Freyja', 'Hacha Crucible', FALSE, 'Freyja honra al aspecto Crucible.'),
('La Cruz Innominada', 'Moore', 'Lágrima de Moore', FALSE, 'Moore carga con culpa antigua (DLC).'),
('El Hijo del Fuego Eterno', 'Dane', 'Hechizo Llama Eterna', FALSE, 'Dane busca su lugar tras Volcano Manor.');


/*
enemigo (40 enemigos: 30 jefes + 10 normales/fauna)

IDs de catálogos referenciados:

    categoria_enemigo: 1=Normal, 3=Minijefe, 4=Jefe Mazmorra, 5=Jefe Mayor, 6=Jefe Remembranza, 7=Jefe Final, 10=Fauna Pacífica, 11=Fauna Hostil, 27=Jefe Opcional, 28=Dragón, etc.

    faccion: 1=Sin facción, 2=Hoslow, 3=Raya Lucaria, 4=Caria, 5=Volcano, 6=Iglesia Áurea, 7=Mohgwyn, 8=Real Carian, 9=Crucificantes, 17=Dragones Antiguos, 19=Hornsent, 20=Messmer, 24=Miquella, etc.

    ubicacion: 1=Limgrave, 4=Castillo Tempestad, 5=Liurnia, 6=Raya Lucaria,  7=Caelid, 10=Leyndell, 11=Volcano, 14=Farum Azula, etc.
    
    origen_contenido: 1=Base 1.00, 13=DLC, 14=DLC, etc.
*/
INSERT INTO enemigo (nombre, hp_base, dmg_base, id_categoria, id_faccion, id_ubicacion, id_origen) VALUES
('Godrick el Injertado', 6080,  470,  6,  28, 4,  1),   -- Jefe Remembranza, Soldados Godrick, Castillo Tempestad
('Rennala Reina Luna Llena', 6177,  420,  6,  3,  6,  1),   -- Jefe Remembranza, Academia, Raya Lucaria
('Radahn Azote de las Estrellas', 18527, 850,  6,  10, 7,  1),   -- Jefe Remembranza, Tarnished/General, Caelid
('Rykard Señor de la Blasfemia', 38847, 580,  6,  5,  11, 1),   -- Jefe Remembranza, Volcano Manor
('Morgott Rey Omen', 10477, 720,  6,  6,  10, 1),   -- Jefe Remembranza, Iglesia Áurea, Leyndell
('Mohg Lord de la Sangre', 18389, 900,  6,  7,  22, 4),   -- Jefe Remembranza, Mohgwyn, Pozo Lava
('Malenia Hoja de Miquella', 33251, 950,  6,  13, 16, 1),   -- Jefe Remembranza, Ejército Putrefacto, Tierras Sagradas
('Maliketh la Hoja Negra', 13837, 880,  6,  9,  14, 1),   -- Jefe Remembranza, Crucificantes, Farum Azula
('Hoarah Loux Guerrero', 19332, 920,  6,  11, 15, 1),   -- Jefe Remembranza, Caballeros Sin Sombra
('Bestia Áurea Élder', 24661, 1000, 7,  6,  15, 1),   -- Jefe Final, Iglesia Áurea, Leyndell Cenizas
('Margit el Caído', 4945,  430,  5,  28, 4,  1),   -- Jefe Mayor, Soldados Godrick, Castillo Tempestad
('Ancestral Espíritu Sagrado', 6310,  490,  5,  18, 19, 1),   -- Jefe Mayor, Estirpe Crucible, Nokron
('Mohg el Omen', 15093, 720,  5,  7,  21, 4),   -- Jefe Mayor, Mohgwyn, Deeproot Depths
('Astel Naturalborn of the Void', 10589, 740,  5,  1,  20, 1),   -- Jefe Mayor, Sin facción, Nokstella
('Fia Princesa de la Muerte', 9588,  600,  5,  9,  21, 1),   -- Jefe Mayor, Crucificantes, Deeproot
('Caballero de la Llama Negra', 7234,  640,  5,  25, 14, 1),   -- Jefe Mayor, Caballeros del Carbón, Farum Azula
('Placidusax Dragón Ancestral', 18345, 1050, 5,  17, 14, 1),   -- Jefe Mayor, Dragones Antiguos, Farum Azula
('Bayle el Aterrador', 21500, 1120, 6,  17, 24, 13),  -- Jefe Remembranza, Dragones Antiguos, Cerulean (DLC)
('Messmer el Empalador', 17890, 980,  6,  20, 25, 13),  -- Jefe Remembranza, Ejército Messmer, Castillo Ensis (DLC)
('Romina Santa de la Plaga', 15234, 920,  6,  13, 26, 13),  -- Jefe Remembranza, Ejército Putrefacto, Scadu Altus (DLC)
('Promised Consort Radahn', 25789, 1180, 7,  24, 29, 13),  -- Jefe Final, Devotos Miquella, Enir-Ilim (DLC)
('Putrescent Knight', 11567, 830,  5,  13, 27, 13),  -- Jefe Mayor, Ejército Putrefacto, Reborde Furtivo (DLC)
('Rellana Hermana Gemela', 13456, 870,  6,  24, 25, 13),  -- Jefe Remembranza, Devotos Miquella, Castillo Ensis (DLC)
('Comendador Gaius', 14523, 920,  5,  20, 26, 13),  -- Jefe Mayor, Ejército Messmer, Scadu Altus (DLC)
('Bestia Divina Danzante de León', 10234, 780,  5,  19, 26, 13),  -- Jefe Mayor, Hornsent, Scadu Altus (DLC)
('Sombra del Sol Águila', 8456,  640,  4,  6,  10, 1),   -- Jefe Mazmorra, Iglesia Áurea, Leyndell
('Cavalier del Atardecer', 5234,  490,  4,  9,  14, 1),   -- Jefe Mazmorra, Crucificantes, Farum Azula
('Cabeza de Cabra Sagrada', 7890,  580,  4,  18, 12, 1),   -- Jefe Mazmorra, Estirpe Crucible, Monte Gelmir
('Hermano Ulcerado', 6234,  520,  4,  1,  7,  20),  -- Jefe Mazmorra, Sin facción, Caelid (parche)
('Black Blade Tiche', 4567,  430,  4,  9,  9,  1),   -- Jefe Mazmorra, Crucificantes, Mesetas Altus

('Soldado de Godrick', 420,   85,   1,  28, 1,  1),   -- Normal, Soldados Godrick, Limgrave
('Hechicero de Raya Lucaria', 680,   145,  18, 3,  6,  1),   -- Mago, Académicos, Raya Lucaria
('Tropa de Mohgwyn', 820,   180,  17, 7,  22, 1),   -- Caballero Facción, Mohgwyn, Pozo Lava
('Soldado Hornsent Lancero', 950,   210,  24, 19, 28, 13),  -- Soldado Hornsent, DLC
('Cangrejo Gigante Caelid', 1450,  260,  30, 1,  7,  1),   -- Crustáceo, Sin facción, Caelid
('Oveja Lanuda', 180,   25,   10, 1,  1,  1),   -- Fauna Pacífica, Limgrave
('Lobo Demi-humano', 560,   115,  11, 12, 3,  1),   -- Fauna Hostil, Demi-humanos
('Tortuga Mensajera', 45,    0,    10, 1,  5,  1),   -- Fauna Pacífica, Liurnia
('Espíritu Errante Hornsent', 890,   190,  14, 19, 28, 13),  -- Espíritu Errante, Hornsent, DLC
('Patrulla Asesino Negro', 1200,  340,  20, 9,  10, 1);   -- Asesino, Crucificantes, Leyndell

INSERT INTO ficha_jefe (id_enemigo, titulo_jefe, tema_musical, numero_fases, recompensa_runas, es_jefe_remembranza, requiere_invocacion_npc) VALUES
(1,  'Godrick the Grafted', 'Godrick the Grafted', 2, 20000,  TRUE,  FALSE),
(2,  'Rennala, Queen of the Full Moon',  'Rennala, Queen of the Full Moon',  2, 40000,  TRUE,  FALSE),
(3,  'Starscourge Radahn', 'Starscourge Radahn', 2, 70000,  TRUE,  TRUE),
(4,  'Rykard, Lord of Blasphemy', 'Rykard, Lord of Blasphemy', 1, 70000,  TRUE,  FALSE),
(5,  'Morgott, the Omen King', 'Morgott, the Omen King', 1, 120000, TRUE,  FALSE),
(6,  'Mohg, Lord of Blood', 'Mohg, Lord of Blood', 2, 420000, TRUE,  FALSE),
(7,  'Malenia, Blade of Miquella', 'Malenia, Blade of Miquella', 2, 480000, TRUE,  FALSE),
(8,  'Maliketh, the Black Blade', 'Maliketh, the Black Blade', 2, 220000, TRUE,  FALSE),
(9,  'Hoarah Loux, Warrior', 'Hoarah Loux, Warrior', 2, 300000, TRUE,  FALSE),
(10, 'Elden Beast', 'The Final Battle', 2, 500000, FALSE, FALSE),
(11, 'Margit, the Fell Omen', 'Margit, the Fell Omen', 1, 6000,   FALSE, FALSE),
(12, 'Ancestor Spirit', 'Ancestral Follower', 1, 24000,  FALSE, FALSE),
(13, 'Mohg, the Omen', 'Mohg, Lord of Blood', 1, 60000,  FALSE, FALSE),
(14, 'Astel, Naturalborn of the Void', 'Astel', 1, 80000,  FALSE, FALSE),
(15, 'Fia''s Champions', 'Honored Dead', 1, 60000,  FALSE, FALSE),
(16, 'Godskin Duo', 'Godskin Apostles', 1, 90000,  FALSE, FALSE),
(17, 'Dragonlord Placidusax', 'Dragonlord Placidusax', 2, 280000, FALSE, FALSE),
(18, 'Bayle the Dread', 'Bayle the Dread', 2, 400000, TRUE,  TRUE),
(19, 'Messmer the Impaler', 'Messmer the Impaler', 2, 380000, TRUE,  FALSE),
(20, 'Romina, Saint of the Bud', 'Romina, Saint of the Bud', 1, 320000, TRUE,  FALSE),
(21, 'Promised Consort Radahn', 'Radahn, Consort of Miquella', 2, 700000, FALSE, TRUE),
(22, 'Putrescent Knight', 'Putrescent Knight', 1, 240000, FALSE, FALSE),
(23, 'Rellana, Twin Moon Knight', 'Rellana, Twin Moon Knight', 2, 200000, TRUE,  FALSE),
(24, 'Commander Gaius', 'Commander Gaius', 1, 260000, FALSE, FALSE),
(25, 'Divine Beast Dancing Lion', 'Divine Beast Dancing Lion', 1, 180000, FALSE, FALSE),
(26, 'Royal Knight Loretta', 'Royal Knight Loretta', 1, 14000,  FALSE, FALSE),
(27, 'Crucible Knight Ordovis', 'Crucible Knight', 1, 18000,  FALSE, FALSE),
(28, 'Black Blade Kindred', 'Black Blade Kindred', 1, 23000,  FALSE, FALSE),
(29, 'Ulcerated Tree Spirit', 'Ulcerated Tree Spirit', 1, 28000,  FALSE, FALSE),
(30, 'Black Knife Assassin', 'Black Knife Assassin', 1, 8200,   FALSE, FALSE);


/*
id_tipo_objeto: 1=Espada larga, 2=Espadón, 4=Lanza, 6=Mazo, 7=Katana, 19=Talismán, 22=Material de mejora, 24=Consumible curativo, 26=Runa, 27=Remembranza, etc.
*/

INSERT INTO objeto_drop (nombre_objeto, valor_en_runas, peso_kg, descripcion_lore, id_tipo_objeto) VALUES
('Remembranza del Injertado' ,20000,  0.00, 'Recuerdo destilado de Godrick, se canjea con Enia.', 27),
('Remembranza Reina Luna Llena', 30000,  0.00, 'Recuerdo destilado de Rennala.', 27),
('Remembranza Azote de las Estrellas', 40000,  0.00, 'Recuerdo destilado de Radahn.', 27),
('Remembranza del Blasfemo', 50000,  0.00, 'Recuerdo destilado de Rykard.', 27),
('Remembranza del Rey Omen', 50000,  0.00, 'Recuerdo destilado de Morgott.', 27),
('Remembranza del Lord Sangriento', 50000,  0.00, 'Recuerdo destilado de Mohg.', 27),
('Remembranza de la Aguja Putrefacta', 50000,  0.00, 'Recuerdo destilado de Malenia.', 27),
('Espada de Maliketh', 4000,   12.00,'Espada negra forjada por Maliketh, escala con FAI.', 2),
('Lanza Bloodhound''s Fang', 3500, 8.50, 'Espadón curvo del cazador de sangre Bloodhound.', 2),
('Rivers of Blood', 5000, 8.00, 'Katana ensangrentada que aplica hemorragia.', 7),
('Greatrune de Mohg', 0, 0.00, 'Runa mayor que aumenta vida tras invocar espíritus.', 27),
('Greatrune de Morgott', 0, 0.00, 'Runa mayor que aumenta vida máxima.', 27),
('Hígado de Bestia Sagrada', 1200, 0.50, 'Material para mejorar espíritus invocables.', 22),
('Lágrima Áurea', 500, 0.10, 'Material para reforzar invocaciones a +10.', 22),
('Talismán de Godrick', 2500, 1.20, 'Aumenta todos los stats en +5.', 19),
('Talismán Marca de Radagon', 2000, 1.10, 'Reduce daño físico recibido.', 19),
('Frasco de Lágrimas Carmesí', 0, 0.30, 'Frasco curativo principal, restaura HP.', 24),
('Frasco de Lágrimas Cerúleas', 0, 0.30, 'Frasco que restaura FP para hechizos.', 24),
('Frasco Maravilloso de Físico', 0, 0.40, 'Frasco mixto con cristales para crear efectos.', 24),
('Runa Áurea (10)', 400, 0.00, 'Runa que otorga 400 runas al usarse.', 26),
('Runa Áurea Heroica', 15000, 0.00, 'Runa rara que otorga 15000 runas.', 26),
('Espada Carian Real', 3000, 10.00,'Espada mágica de la realeza Carian.', 1),
('Maza Crucible', 2500, 11.00,'Maza con runas de la Estirpe Crucible.', 6),
('Espadón del Lord Sangriento', 4500,   13.50,'Espadón empapado en sangre de Mohg.', 2),
('Aguja Sin Lluvia', 0, 0.00, 'Aguja que detiene la propagación de la Putrefacción Escarlata.', 29),
('Aguja Antigua sin Vainilla', 0, 0.00, 'Aguja antigua para Millicent.', 29),
('Cuerno Sagrado Hornsent', 3500, 2.00, 'Cuerno tallado por los Hornsent del DLC.', 22),
('Llama Negra de Messmer', 5500, 0.50, 'Catalizador de fuego negro de Messmer.', 10),
('Lanza de Bayle', 4800, 9.00, 'Lanza forjada del aliento de Bayle.', 4),
('Escarabajo Áureo Vivo', 0, 0.10, 'Material raro que dropea de escarabajos en zonas Áureas.', 23);

INSERT INTO enemigo_quest (id_enemigo, id_quest, rol_en_mision) VALUES
(3, 1, 'Jefe a derrotar para Ranni avance'),
(6, 18, 'Objetivo final de la caza de Mohg'),
(7, 2, 'Boss final de la quest de Millicent'),
(2, 11, 'Maestra que reconoce el legado de Thops'),
(5, 9, 'Bloqueo previo al final del Orden Perfecto'),
(8, 10, 'Bloqueo previo al final de Llama Frenética'),
(4, 3, 'Líder de Volcano Manor, objetivo de Tanith'),
(11, 4, 'Antagonista del camino de Diallos'),
(14, 1, 'Jefe opcional en la cadena de Ranni'),
(15, 13, 'NPC convertido en obstáculo Deeproot'),
(13, 18, 'Pre-jefe en la ruta de Varré'),
(12, 14, 'Aliado simbólico en la quest de Nepheli'),
(16, 22, 'Aliado fallecido aludido por Bernahl'),
(17, 16, 'Reto opcional para Blaidd'),
(18, 22, 'Objetivo final de la venganza de Igon'),
(19, 23, 'Antagonista del camino de Miquella'),
(20, 23, 'Guardiana del Aeonia del DLC'),
(21, 23, 'Jefe final de la cruzada de Miquella'),
(23, 23, 'Hermana gemela aludida en el camino de Miquella'),
(24, 23, 'Comandante caído en cruz de Miquella'),
(25, 26, 'Bestia del juicio Hornsent'),
(27, 27, 'Bloqueo a la marca del Crucible'),
(30, 21, 'Asesino que persigue a Roderika'),
(29, 9, 'Mini-jefe que aparece en el camino de Goldmask'),
(28, 28, 'Cabeza de cabra final en la cruz innominada'),
(26, 19, 'Royal Knight mencionada por Gowry'),
(22, 23, 'Putrescente errante del DLC'),
(31, 4, 'Soldado regular en castillo, obstáculo común'),
(33, 18, 'Tropa Mohgwyn que aparece en farmeo de Varré'),
(40, 8, 'Asesino contratado contra Yura');


/*
atributo IDs: 1=Físico, 5=Magia, 6=Fuego, 7=Rayo, 8=Sagrado, 9=Hemorragia, 10=Veneno, 12=Frostbite, 14=Locura
*/

INSERT INTO enemigo_resistencia (id_enemigo, id_atributo, reduccion_dano) VALUES
(1,6, 20.00), -- Godrick resiste fuego
(2, 5,  40.00), -- Rennala muy resistente a magia
(3, 9, 30.00), -- Radahn resiste hemorragia
(4, 6, 60.00), -- Rykard inmune a fuego (vive en lava)
(5, 8, 25.00), -- Morgott resiste sagrado
(6, 9, 50.00), -- Mohg resiste hemorragia (la usa él mismo)
(7, 11, 70.00), -- Malenia resiste putrefacción escarlata
(8, 8, 35.00), -- Maliketh resiste sagrado
(9, 1, 15.00), -- Hoarah Loux resiste físico
(10, 8, 30.00), -- Elden Beast resiste sagrado
(11, 6, 20.00), -- Margit similar a Godrick
(13, 9, 45.00), -- Mohg Omen similar al mayor
(14, 5, 40.00), -- Astel resiste magia (es estelar)
(17, 7, 35.00), -- Placidusax resiste rayo (es dragón)
(18, 7, 50.00), -- Bayle dragón resistente a rayo
(18, 6, 40.00), -- Bayle también resiste fuego
(19, 6, 55.00), -- Messmer inmune a fuego (lo usa)
(20, 11, 65.00), -- Romina resiste putrefacción
(21, 5, 30.00), -- Promised Consort resiste magia
(21, 8, 25.00), -- y sagrado
(22, 11, 50.00), -- Putrescent Knight resiste putrefacción
(23, 5, 35.00), -- Rellana resiste magia carian
(24, 9, 20.00), -- Gaius
(25, 8, 30.00), -- Divine Beast resiste sagrado
(28, 8, 45.00), -- Black Blade Kindred resiste sagrado
(29, 6, 30.00), -- Ulcerated Tree Spirit resiste fuego
(31, 1, 10.00), -- Soldado Godrick básico
(32, 5, 25.00), -- Hechicero Raya Lucaria resiste magia
(34, 6, 20.00), -- Hornsent lancero
(36, 6, 5.00); -- Oveja muy poca resistencia

INSERT INTO enemigo_debilidad (id_enemigo, id_atributo, multiplicador_dano) VALUES
(1,  9,  1.50),   -- Godrick débil a hemorragia
(2,  9,  1.30),   -- Rennala débil a hemorragia
(3,  9,  1.40),   -- Radahn débil a hemorragia
(4,  9,  1.60),   -- Rykard débil a hemorragia
(5,  9,  1.25),   -- Morgott débil a hemorragia
(6,  11, 1.50),   -- Mohg débil a putrefacción
(7,  12, 1.45),   -- Malenia débil a frostbite (uno de sus pocos puntos)
(8,  1,  1.30),   -- Maliketh débil a físico crudo
(9,  13, 1.20),   -- Hoarah Loux débil a sueño
(10, 1,  1.40),   -- Elden Beast débil a físico (sorprendentemente)
(11, 9,  1.50),   -- Margit débil a hemorragia
(13, 11, 1.40),   -- Mohg Omen débil a putrefacción
(14, 12, 1.30),   -- Astel débil a frostbite
(15, 8,  1.55),   -- Fia's Champions débiles a sagrado (son no-muertos)
(16, 8,  1.60),   -- Godskin Duo débil a sagrado
(17, 9,  1.25),   -- Placidusax débil a hemorragia
(18, 12, 1.40),   -- Bayle débil a frostbite
(19, 5,  1.30),   -- Messmer débil a magia
(20, 6,  1.35),   -- Romina débil a fuego (irónico, mata su putrefacción)
(21, 12, 1.30),   -- Promised Consort débil a frostbite
(22, 6,  1.45),   -- Putrescent Knight débil a fuego
(23, 9,  1.35),   -- Rellana débil a hemorragia
(24, 7,  1.40),   -- Gaius débil a rayo (su jabalí está aterrado)
(25, 9,  1.25),   -- Divine Beast débil a hemorragia
(27, 9,  1.50),   -- Crucible Knight débil a hemorragia
(28, 9,  1.30),   -- Black Blade Kindred débil a hemorragia
(29, 6,  1.40),   -- Ulcerated débil a fuego
(31, 9,  2.00),   -- Soldado normal muy débil a hemorragia
(32, 1,  1.60),   -- Hechicero débil a físico (poca armadura)
(36, 1,  2.50);   -- Oveja muy débil a físico (es ganado)

INSERT INTO enemigo_drop (id_enemigo, id_objeto, probabilidad_drop) VALUES
(1,  1,  100.00),  -- Godrick siempre dropea su remembranza
(1,  15, 100.00),  -- Godrick siempre dropea su talismán
(2,  2,  100.00),  -- Rennala remembranza garantizada
(3,  3,  100.00),  -- Radahn remembranza garantizada
(4,  4,  100.00),  -- Rykard remembranza
(5,  5,  100.00),  -- Morgott remembranza
(5,  12, 100.00),  -- Morgott greatrune
(6,  6,  100.00),  -- Mohg remembranza
(6,  11, 100.00),  -- Mohg greatrune
(6,  24, 5.00),    -- Mohg dropea espadón sangriento raramente
(7,  7,  100.00),  -- Malenia remembranza
(8,  8,  100.00),  -- Maliketh dropea su espada
(9,  16, 8.00),    -- Hoarah Loux talismán de Radagon raro
(11, 20, 100.00),  -- Margit dropea Runa Áurea
(12, 13, 100.00),  -- Ancestor Spirit dropea hígado
(17, 21, 100.00),  -- Placidusax runa heroica
(18, 29, 100.00),  -- Bayle dropea su lanza
(19, 28, 100.00),  -- Messmer dropea su llama negra
(20, 25, 100.00),  -- Romina dropea Aguja Sin Lluvia (lore-friendly)
(21, 14, 100.00),  -- Promised Consort lágrima áurea
(22, 13, 75.00),   -- Putrescent dropea hígado
(23, 22, 50.00),   -- Rellana dropea espada Carian Real
(24, 23, 30.00),   -- Gaius dropea maza Crucible
(25, 27, 100.00),  -- Divine Beast dropea cuerno Hornsent
(27, 23, 100.00),  -- Crucible Knight dropea su maza
(28, 8,  3.00),    -- Black Blade Kindred raramente dropea espada Maliketh
(29, 14, 25.00),   -- Ulcerated dropea lágrima áurea
(30, 9,  10.00),   -- Black Knife Assassin dropea Bloodhound's Fang raramente
(31, 20, 15.00),   -- Soldado dropea runa básica
(32, 17, 5.00),    -- Hechicero dropea frasco carmesí raramente
(33, 18, 8.00),    -- Tropa Mohgwyn frasco cerúleo
(34, 19, 6.00),    -- Hornsent frasco maravilloso
(36, 20, 100.00),  -- Oveja siempre dropea runa pequeña
(38, 30, 1.00),    -- Tortuga raramente dropea escarabajo
(40, 9,  8.00);    -- Asesino dropea Bloodhound's Fang


/*
efecto IDs: 1=Hemorragia, 2=Veneno, 3=Putrefacción Escarlata, 4=Frostbite, 5=Sueño, 6=Locura, 8=Quemadura, 7=Hechizo Muerte
*/

INSERT INTO ataque_aplica_efecto (id_enemigo, id_efecto, puntos_acumulacion) VALUES
(6, 1, 130),   -- Mohg aplica hemorragia fuerte
(7,  3,  300),   -- Malenia Waterfowl aplica putrefacción brutal
(20, 3,  250),   -- Romina aplica putrefacción
(13, 1,  90),    -- Mohg Omen hemorragia
(4,  8,  80),    -- Rykard quemadura
(19, 8,  150),   -- Messmer aplica quemadura
(8,  7,  60),    -- Maliketh hechizo de muerte (Destined Death)
(28, 7,  55),    -- Black Blade Kindred igual
(3,  1,  60),    -- Radahn aplica hemorragia con flechas
(14, 5,  70),    -- Astel sueño con su agarre
(17, 4,  90),    -- Placidusax frostbite con aliento
(18, 8,  170),   -- Bayle quemadura masiva
(2,  4,  80),    -- Rennala frostbite con hechizos
(15, 7,  50),    -- Fia's Champions hechizo muerte
(22, 3,  200),   -- Putrescent Knight putrefacción
(25, 1,  70),    -- Divine Beast hemorragia con zarpazos
(24, 1,  85),    -- Gaius hemorragia con embestida
(21, 1,  60),    -- Promised Consort hemorragia con cruz
(23, 4,  75),    -- Rellana frostbite con luna
(16, 8,  90),    -- Godskin Duo quemadura
(27, 1,  60),    -- Crucible Knight hemorragia con cuernos
(29, 8,  100),   -- Ulcerated quemadura con expulsión
(30, 1,  90),    -- Black Knife Assassin hemorragia
(40, 1,  85),    -- Patrulla Asesino hemorragia
(34, 1,  60),    -- Hornsent Lancero hemorragia con lanza
(33, 1,  70),    -- Tropa Mohgwyn hemorragia
(37, 1,  40),    -- Lobo Demi-humano hemorragia leve
(35, 2,  90),    -- Cangrejo Caelid veneno
(39, 4,  50),    -- Espíritu Hornsent frostbite leve
(32, 4,  60);    -- Hechicero Raya Lucaria frostbite



/*
VIEWS
*/

CREATE OR REPLACE VIEW vw_bestiario_completo AS
SELECT
    e.id_enemigo,
    e.nombre AS nombre_enemigo,
    c.nombre_categoria,
    f.nombre_faccion,
    u.nombre_region,
    u.nivel_recomendado_min,
    u.nivel_recomendado_max,
    o.nombre AS origen,
    o.es_dlc,
    e.hp_base,
    e.dmg_base,
    fj.titulo_jefe,
    fj.numero_fases,
    fj.recompensa_runas,
    fj.es_jefe_remembranza,
    CASE
        WHEN fj.id_enemigo IS NOT NULL THEN 'Sí'
        ELSE 'No'
    END AS tiene_ficha_jefe
FROM enemigo e
INNER JOIN categoria_enemigo c ON e.id_categoria  = c.id_categoria
INNER JOIN faccion f ON e.id_faccion = f.id_faccion
INNER JOIN ubicacion u ON e.id_ubicacion = u.id_ubicacion
INNER JOIN origen_contenido o ON e.id_origen = o.id_origen
LEFT  JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo;

CREATE OR REPLACE VIEW vw_ranking_jefes_por_region AS
SELECT
    u.id_ubicacion,
    u.nombre_region,
    u.nivel_recomendado_min,
    u.nivel_recomendado_max,
    COUNT(fj.id_enemigo) AS total_jefes,
    ROUND(AVG(e.hp_base), 0) AS hp_promedio,
    MAX(e.hp_base) AS hp_maximo,
    MIN(e.hp_base) AS hp_minimo,
    SUM(fj.recompensa_runas) AS runas_totales_zona,
    ROUND(AVG(fj.recompensa_runas), 0) AS runas_promedio,
    SUM(CASE WHEN o.es_dlc = TRUE  THEN 1 ELSE 0 END) AS jefes_dlc,
    SUM(CASE WHEN o.es_dlc = FALSE THEN 1 ELSE 0 END) AS jefes_base,
    SUM(CASE WHEN fj.es_jefe_remembranza = TRUE THEN 1 ELSE 0 END)
   AS jefes_remembranza
FROM ficha_jefe fj
INNER JOIN enemigo e ON fj.id_enemigo = e.id_enemigo
INNER JOIN ubicacion u ON e.id_ubicacion = u.id_ubicacion
INNER JOIN origen_contenido o ON e.id_origen = o.id_origen
GROUP BY u.id_ubicacion, u.nombre_region, u.nivel_recomendado_min, u.nivel_recomendado_max
ORDER BY total_jefes DESC, runas_totales_zona DESC;


/*
TESTEAR LAS VIEWS
*/

-- Ver todos los enemigos con su info completa
SELECT * FROM vw_bestiario_completo;

-- Solo enemigos del DLC
SELECT nombre_enemigo, nombre_region, hp_base
FROM vw_bestiario_completo
WHERE es_dlc = TRUE;

-- Ranking de regiones más densas en jefes
SELECT nombre_region, total_jefes, runas_totales_zona
FROM vw_ranking_jefes_por_region;




/*
JOINS
*/


-- inner
SELECT
    u.nombre_region,
    e.nombre AS jefe,
    fj.titulo_jefe,
    fj.numero_fases,
    fj.recompensa_runas,
    o.version_parche
FROM enemigo e
INNER JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo
INNER JOIN ubicacion u  ON e.id_ubicacion = u.id_ubicacion
INNER JOIN origen_contenido o  ON e.id_origen = o.id_origen
WHERE o.es_dlc = TRUE
ORDER BY u.nombre_region, fj.recompensa_runas DESC;

-- left
SELECT
    e.id_enemigo,
    e.nombre AS enemigo,
    c.nombre_categoria,
    u.nombre_region,
    ed.id_objeto,
    CASE
        WHEN ed.id_objeto IS NULL THEN 'SIN DROPS REGISTRADOS'
        ELSE 'Drops registrados'
    END AS estado_drops
FROM enemigo e
INNER JOIN categoria_enemigo c ON e.id_categoria = c.id_categoria
INNER JOIN ubicacion u ON e.id_ubicacion = u.id_ubicacion
LEFT  JOIN enemigo_drop ed ON e.id_enemigo = ed.id_enemigo
WHERE ed.id_objeto IS NULL
ORDER BY c.nombre_categoria, e.nombre;

-- right
SELECT
    ef.nombre_efecto,
    ef.stat_que_lo_mitiga,
    ef.duracion_base_segundos,
    COUNT(aae.id_enemigo) AS cantidad_enemigos_lo_usan,
    GROUP_CONCAT(e.nombre SEPARATOR ', ') AS lista_enemigos
FROM enemigo e
INNER JOIN ataque_aplica_efecto aae ON e.id_enemigo = aae.id_enemigo
RIGHT JOIN efecto_estado ef ON aae.id_efecto = ef.id_efecto
GROUP BY ef.id_efecto, ef.nombre_efecto, ef.stat_que_lo_mitiga, ef.duracion_base_segundos
ORDER BY cantidad_enemigos_lo_usan DESC, ef.nombre_efecto;

-- cross
SELECT
    c.nombre_categoria,
    a.nombre_atributo,
    CONCAT(c.nombre_categoria, ' vs ', a.nombre_atributo) AS combinacion,
    COUNT(ed.id_enemigo) AS enemigos_debiles
FROM categoria_enemigo c
CROSS JOIN atributo_combate a
LEFT JOIN enemigo e ON e.id_categoria = c.id_categoria
LEFT JOIN enemigo_debilidad ed ON ed.id_enemigo = e.id_enemigo AND ed.id_atributo = a.id_atributo
GROUP BY c.nombre_categoria, a.nombre_atributo
ORDER BY c.nombre_categoria, a.nombre_atributo;




/*
Store procedure 
*/


-- Uno 
DELIMITER $$

CREATE PROCEDURE sp_registrar_enemigo_completo(
    IN p_nombre VARCHAR(100),
    IN p_hp_base INT,
    IN p_dmg_base INT,
    IN p_id_categoria INT,
    IN p_id_faccion INT,
    IN p_id_ubicacion INT,
    IN p_id_origen INT,
    IN p_es_jefe BOOLEAN,
    IN p_titulo_jefe VARCHAR(100),
    IN p_tema_musical VARCHAR(100),
    IN p_numero_fases INT,
    IN p_recompensa_runas INT,
    IN p_es_remembranza BOOLEAN,
    IN p_requiere_invocacion BOOLEAN,
    OUT p_id_generado INT
)
BEGIN
    INSERT INTO enemigo (nombre, hp_base, dmg_base,
                         id_categoria, id_faccion,
                         id_ubicacion, id_origen)
    VALUES (p_nombre, p_hp_base, p_dmg_base,
            p_id_categoria, p_id_faccion,
            p_id_ubicacion, p_id_origen);

    SET p_id_generado = LAST_INSERT_ID();

    IF p_es_jefe = TRUE THEN
        INSERT INTO ficha_jefe (id_enemigo, titulo_jefe, tema_musical,
                                numero_fases, recompensa_runas,
                                es_jefe_remembranza, requiere_invocacion_npc)
        VALUES (p_id_generado, p_titulo_jefe, p_tema_musical,
                p_numero_fases, p_recompensa_runas,
                p_es_remembranza, p_requiere_invocacion);
    END IF;
END$$

DELIMITER ;


--DOs
DELIMITER $$

CREATE PROCEDURE sp_reporte_runas_por_region(
    IN p_nombre_region VARCHAR(100)
)
BEGIN
    DECLARE v_existe_region INT DEFAULT 0;

    SELECT COUNT(*) INTO v_existe_region
    FROM ubicacion
    WHERE nombre_region = p_nombre_region;

    IF v_existe_region = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La región especificada no existe en el sistema.';
    END IF;

    SELECT
        e.nombre AS jefe,
        fj.titulo_jefe,
        e.hp_base,
        fj.numero_fases,
        fj.recompensa_runas,
        CASE
            WHEN fj.es_jefe_remembranza = TRUE THEN 'Sí'
            ELSE 'No'
        END AS otorga_remembranza,
        u.nombre_region
    FROM ficha_jefe fj
    INNER JOIN enemigo e ON fj.id_enemigo = e.id_enemigo
    INNER JOIN ubicacion u ON e.id_ubicacion = u.id_ubicacion
    WHERE u.nombre_region = p_nombre_region
    ORDER BY fj.recompensa_runas DESC;
END$$

DELIMITER ;



/*
TRIGGERS 
*/


CREATE TABLE auditoria_enemigo (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_enemigo_afectado INT NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    usuario_responsable VARCHAR(100) NOT NULL DEFAULT (CURRENT_USER()),
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_operacion CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
)



-- 1
DELIMITER $$

CREATE TRIGGER trg_validar_ficha_jefe_antes_insert
BEFORE INSERT ON ficha_jefe
FOR EACH ROW
BEGIN
    DECLARE v_nombre_categoria VARCHAR(50);

    SELECT c.nombre_categoria INTO v_nombre_categoria
    FROM enemigo e
    INNER JOIN categoria_enemigo c ON e.id_categoria = c.id_categoria
    WHERE e.id_enemigo = NEW.id_enemigo;

    IF v_nombre_categoria NOT IN (
        'Minijefe',
        'Jefe de Mazmorra',
        'Jefe Mayor',
        'Jefe de Remembranza',
        'Jefe Final',
        'Jefe Opcional'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede crear ficha_jefe: el enemigo no es de categoría tipo jefe.';
    END IF;
END$$

DELIMITER ;


-- 2
DELIMITER $$

CREATE TRIGGER trg_auditar_cambios_enemigo
AFTER UPDATE ON enemigo
FOR EACH ROW
BEGIN
    IF OLD.hp_base <> NEW.hp_base THEN
        INSERT INTO auditoria_enemigo
            (id_enemigo_afectado, operacion, campo_modificado,
             valor_anterior, valor_nuevo)
        VALUES
            (NEW.id_enemigo, 'UPDATE', 'hp_base',
             CAST(OLD.hp_base AS CHAR), CAST(NEW.hp_base AS CHAR));
    END IF;

    IF OLD.dmg_base <> NEW.dmg_base THEN
        INSERT INTO auditoria_enemigo
            (id_enemigo_afectado, operacion, campo_modificado,
             valor_anterior, valor_nuevo)
        VALUES
            (NEW.id_enemigo, 'UPDATE', 'dmg_base',
             CAST(OLD.dmg_base AS CHAR), CAST(NEW.dmg_base AS CHAR));
    END IF;
END$$

DELIMITER ; 




/*
EVENTOS PROGRAMADOS 
*/

SET GLOBAL event_scheduler = ON;

CREATE TABLE resumen_auditoria_historico (
    id_resumen INT AUTO_INCREMENT PRIMARY KEY,
    fecha_corte DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    registros_eliminados INT NOT NULL DEFAULT 0,
    operaciones_insert INT NOT NULL DEFAULT 0,
    operaciones_update INT NOT NULL DEFAULT 0,
    operaciones_delete INT NOT NULL DEFAULT 0,
    enemigo_mas_editado  VARCHAR(100),
    observaciones TEXT
)

DELIMITER $$

CREATE EVENT IF NOT EXISTS ev_limpieza_auditoria_mensual
ON SCHEDULE EVERY 30 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION PRESERVE
ENABLE
COMMENT 'Limpia auditoría con más de 90 días y genera resumen histórico'
DO
BEGIN
    DECLARE v_total_borrar INT DEFAULT 0;

    SELECT COUNT(*) INTO v_total_borrar
    FROM auditoria_enemigo
    WHERE fecha_evento < (NOW() - INTERVAL 90 DAY);

    IF v_total_borrar > 0 THEN
        INSERT INTO resumen_auditoria_historico
            (registros_eliminados, observaciones)
        VALUES
            (v_total_borrar,
             CONCAT('Limpieza automática: ', v_total_borrar, ' registros eliminados.'));

        DELETE FROM auditoria_enemigo
        WHERE fecha_evento < (NOW() - INTERVAL 90 DAY);
    END IF;
END$$

DELIMITER ;

/*
USUARIOS Y PERMISOS
*/

-- Limpieza previa (por si se re-corre el script)
DROP USER IF EXISTS 'bestiario_admin'@'localhost';
DROP USER IF EXISTS 'bestiario_editor'@'localhost';
DROP USER IF EXISTS 'bestiario_lector'@'localhost';

/*
ROL 1: ADMINISTRADOR
Acceso total a la base, incluyendo gestión de estructura, ejecución de procedures y consulta de auditoría.
*/

CREATE USER 'bestiario_admin'@'localhost'
    IDENTIFIED BY 'AdminER_2026!';

GRANT ALL PRIVILEGES ON Elden_Ring.*
    TO 'bestiario_admin'@'localhost'
    WITH GRANT OPTION;

/*
ROL 2: EDITOR / OPERATIVO
Puede agregar y modificar contenido del bestiario, pero no puede borrar registros ni tocar catálogos canónicos ni la auditoría.
*/

CREATE USER 'bestiario_editor'@'localhost'
    IDENTIFIED BY 'EditorER_2026!';

GRANT SELECT ON Elden_Ring.*
    TO 'bestiario_editor'@'localhost';

GRANT INSERT, UPDATE ON Elden_Ring.enemigo TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.ficha_jefe TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.objeto_drop TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.enemigo_quest TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.enemigo_resistencia TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.enemigo_debilidad TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.enemigo_drop TO 'bestiario_editor'@'localhost';
GRANT INSERT, UPDATE ON Elden_Ring.ataque_aplica_efecto  TO 'bestiario_editor'@'localhost';

GRANT EXECUTE ON PROCEDURE Elden_Ring.sp_registrar_enemigo_completo
    TO 'bestiario_editor'@'localhost';

REVOKE INSERT, UPDATE, DELETE
    ON Elden_Ring.faccion FROM 'bestiario_editor'@'localhost';
REVOKE INSERT, UPDATE, DELETE
    ON Elden_Ring.ubicacion FROM 'bestiario_editor'@'localhost';
REVOKE INSERT, UPDATE, DELETE
    ON Elden_Ring.origen_contenido FROM 'bestiario_editor'@'localhost';
REVOKE INSERT, UPDATE, DELETE
    ON Elden_Ring.auditoria_enemigo FROM 'bestiario_editor'@'localhost';

/*
ROL 3: LECTOR / CONSULTA
Solo lectura, y solo a través de las vistas.
No accede a tablas crudas ni a auditoría.
*/

CREATE USER 'bestiario_lector'@'localhost'
    IDENTIFIED BY 'LectorER_2026!';

GRANT SELECT ON Elden_Ring.vw_bestiario_completo
    TO 'bestiario_lector'@'localhost';
GRANT SELECT ON Elden_Ring.vw_ranking_jefes_por_region
    TO 'bestiario_lector'@'localhost';

GRANT EXECUTE ON PROCEDURE Elden_Ring.sp_reporte_runas_por_region
    TO 'bestiario_lector'@'localhost';

FLUSH PRIVILEGES;



/*
CONSULTAS ORIENTADAS AL NEGOCIO 
*/

/*
CONSULTA NEGOCIO 1 — TENDENCIA
Pregunta: 
¿Cómo ha evolucionado la introducción de jefes a lo largo de las versiones del juego? 
Esto identifica en qué parches se agregó más contenido y permite ver el peso del DLC vs el juego base en términos de jefes.
*/

SELECT
    o.version_parche,
    o.nombre AS version,
    CASE WHEN o.es_dlc = TRUE THEN 'DLC' ELSE 'Base' END AS tipo_contenido,
    COUNT(fj.id_enemigo) AS jefes_introducidos,
    SUM(fj.recompensa_runas) AS runas_totales_aportadas
FROM origen_contenido o
LEFT JOIN enemigo    e  ON o.id_origen = e.id_origen
LEFT JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo
GROUP BY o.id_origen, o.version_parche, o.nombre, o.es_dlc
ORDER BY o.es_dlc, o.version_parche;


/*
CONSULTA NEGOCIO 2 — COMPORTAMIENTO
Pregunta: 
¿Cuáles son los efectos de estado más "populares" entre los enemigos del juego? 
Esto sirve a los jugadores para saber a qué efectos deben subir resistencias prioritariamente al armar sus builds.
*/

SELECT
    ef.nombre_efecto,
    ef.stat_que_lo_mitiga,
    COUNT(aae.id_enemigo) AS cantidad_enemigos_lo_usan,
    AVG(aae.puntos_acumulacion) AS acumulacion_promedio,
    MAX(aae.puntos_acumulacion) AS acumulacion_maxima,
    MIN(aae.puntos_acumulacion) AS acumulacion_minima
FROM efecto_estado ef
INNER JOIN ataque_aplica_efecto aae ON ef.id_efecto = aae.id_efecto
GROUP BY ef.id_efecto, ef.nombre_efecto, ef.stat_que_lo_mitiga
ORDER BY cantidad_enemigos_lo_usan DESC, acumulacion_promedio DESC;


/*
CONSULTA NEGOCIO 3 — REPORTE OPERATIVO
Pregunta: ¿Qué objetos del bestiario tienen baja probabilidadde drop (≤10%)? 
Esto sirve como reporte operativo para jugadores que están farmeando objetos raros: cuáles son, de qué enemigo caen y dónde encontrar a ese enemigo.
*/

SELECT
    obj.nombre_objeto,
    to_o.nombre_tipo AS tipo_objeto,
    obj.valor_en_runas,
    e.nombre AS dropeado_por,
    u.nombre_region AS farmear_en,
    ed.probabilidad_drop AS probabilidad
FROM objeto_drop obj
INNER JOIN tipo_objeto to_o ON obj.id_tipo_objeto = to_o.id_tipo_objeto
INNER JOIN enemigo_drop ed ON obj.id_objeto = ed.id_objeto
INNER JOIN enemigo e ON ed.id_enemigo = e.id_enemigo
INNER JOIN ubicacion u ON e.id_ubicacion = u.id_ubicacion
WHERE ed.probabilidad_drop <= 10.00
ORDER BY ed.probabilidad_drop ASC, obj.valor_en_runas DESC;


/*
CONSULTA NEGOCIO 4 — COMPARAR CATEGORÍAS
Pregunta: ¿Cómo se comparan las distintas categorías de enemigos en términos de dificultad? 
Permite ver cuánto más HP/daño tiene un jefe vs un enemigo normal, y dimensionar la curva de progresión del juego.
*/

SELECT
    c.nombre_categoria,
    COUNT(e.id_enemigo) AS cantidad_enemigos,
    ROUND(AVG(e.hp_base), 0) AS hp_promedio,
    MIN(e.hp_base) AS hp_minimo,
    MAX(e.hp_base) AS hp_maximo,
    ROUND(AVG(e.dmg_base), 0) AS dmg_promedio,
    MAX(e.dmg_base) AS dmg_maximo
FROM categoria_enemigo c
INNER JOIN enemigo e ON c.id_categoria = e.id_categoria
GROUP BY c.id_categoria, c.nombre_categoria
ORDER BY hp_promedio DESC;







/*
CONSULTAS ANALÍTICAS
*/

/*
CONSULTA ANALÍTICA 1
¿Cuáles son los jefes más rentables?
Métrica: runas obtenidas por punto de HP (recompensa vs esfuerzo).
*/

SELECT
    e.nombre AS jefe,
    c.nombre_categoria,
    CASE WHEN o.es_dlc = TRUE THEN 'DLC' ELSE 'Base' END AS contenido,
    e.hp_base,
    fj.recompensa_runas,
    ROUND(fj.recompensa_runas / e.hp_base, 2) AS runas_por_hp
FROM enemigo e
INNER JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo
INNER JOIN categoria_enemigo c ON e.id_categoria = c.id_categoria
INNER JOIN origen_contenido o ON e.id_origen = o.id_origen
ORDER BY runas_por_hp DESC;


/*
CONSULTA ANALÍTICA 2
¿Cuáles son las regiones más peligrosas?
Basado en cantidad de jefes, HP promedio y diversidad de efectos de estado.
*/

SELECT
    u.nombre_region,
    u.nivel_recomendado_min,
    u.nivel_recomendado_max,
    COUNT(DISTINCT e.id_enemigo) AS total_enemigos,
    COUNT(DISTINCT fj.id_enemigo) AS total_jefes,
    ROUND(AVG(e.hp_base), 0) AS hp_promedio,
    COUNT(DISTINCT aae.id_efecto) AS efectos_distintos_en_zona,
    CASE
        WHEN COUNT(DISTINCT aae.id_efecto) >= 5 THEN 'Extremo'
        WHEN COUNT(DISTINCT aae.id_efecto) >= 3 THEN 'Alto'
        WHEN COUNT(DISTINCT aae.id_efecto) >= 1 THEN 'Moderado'
        ELSE 'Bajo'
    END AS nivel_peligro
FROM ubicacion u
LEFT JOIN enemigo e ON u.id_ubicacion = e.id_ubicacion
LEFT JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo
LEFT JOIN ataque_aplica_efecto aae ON e.id_enemigo = aae.id_enemigo
GROUP BY u.id_ubicacion, u.nombre_region, u.nivel_recomendado_min, u.nivel_recomendado_max
HAVING total_jefes >= 1
ORDER BY total_jefes DESC, efectos_distintos_en_zona DESC;


/*
CONSULTA ANALÍTICA 3
¿Qué facciones tienen más presencia élite (jefes) y cuáles más presencia masiva (tropas)?
*/

-- Facciones con más jefes
SELECT
    f.nombre_faccion,
    COUNT(fj.id_enemigo) AS cantidad_jefes,
    SUM(fj.recompensa_runas) AS runas_acumuladas,
    ROUND(AVG(e.hp_base), 0) AS hp_promedio_jefes
FROM faccion f
INNER JOIN enemigo e ON f.id_faccion = e.id_faccion
INNER JOIN ficha_jefe fj ON e.id_enemigo = fj.id_enemigo
GROUP BY f.id_faccion, f.nombre_faccion
ORDER BY cantidad_jefes DESC;

-- Facciones con más tropas normales
SELECT
    f.nombre_faccion,
    COUNT(e.id_enemigo) AS cantidad_tropas,
    ROUND(AVG(e.hp_base), 0) AS hp_promedio_tropas
FROM faccion f
INNER JOIN enemigo e ON f.id_faccion = e.id_faccion
INNER JOIN categoria_enemigo c ON e.id_categoria = c.id_categoria
WHERE c.nombre_categoria NOT IN (
    'Minijefe', 'Jefe de Mazmorra', 'Jefe Mayor',
    'Jefe de Remembranza', 'Jefe Final', 'Jefe Opcional'
)
GROUP BY f.id_faccion, f.nombre_faccion
ORDER BY cantidad_tropas DESC;


/*
ZONA DE TESTEO
*/


-- Probar el STORE PROCEDURE 1
CALL sp_registrar_enemigo_completo(
    'Acólito de Mohgwyn', 380, 95,
    1, 7, 22, 1,
    FALSE,
    NULL, NULL, NULL, NULL, NULL, NULL,
    @nuevo_id
);

-- Probar el STORE PROCEDURE 2
CALL sp_reporte_runas_por_region('Caelid');
CALL sp_reporte_runas_por_region('Scadu Altus');
CALL sp_reporte_runas_por_region('Inexistente');



-- Probar trigger 1 (debe FALLAR con mensaje claro)
INSERT INTO ficha_jefe (id_enemigo, titulo_jefe, recompensa_runas)
VALUES (36, 'Oveja Lord of the Pasture', 99999);



-- Probar trigger 2 (debe registrar en auditoria_enemigo)
UPDATE enemigo SET hp_base = 33500 WHERE id_enemigo = 7;
SELECT * FROM auditoria_enemigo;



-- Verificar el evento programado
SHOW VARIABLES LIKE 'event_scheduler';
SHOW EVENTS FROM Elden_Ring;
