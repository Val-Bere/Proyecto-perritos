-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-09-2026 a las 18:30:15
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `perritos_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `colores`
--

CREATE TABLE `colores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `colores`
--

INSERT INTO `colores` (`id`, `nombre`) VALUES
(2, 'Blanco'),
(3, 'Cafe'),
(4, 'Dorado'),
(5, 'Gris'),
(1, 'Negro'),
(6, 'Pinto / Manchado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perritos`
--

CREATE TABLE `perritos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `foto_archivo` varchar(255) NOT NULL,
  `id_raza` int(11) DEFAULT NULL,
  `latitud` decimal(10,7) NOT NULL,
  `longitud` decimal(10,7) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp(),
  `clave_idempotencia` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `perritos`
--

INSERT INTO `perritos` (`id`, `nombre`, `foto_archivo`, `id_raza`, `latitud`, `longitud`, `fecha_registro`, `clave_idempotencia`) VALUES
(3, 'Manchas Grises', '1790481657_manchas.jpg', 1, 25.4176949, -101.0026360, '2026-09-26 22:00:57', 'perrito_6ab894f98013e4.46811031'),
(5, 'Puppy', '1790573808_manchas.jpg', 22, 25.4152142, -101.0014343, '2026-09-27 23:36:48', 'perrito_6ab9fcf0d73af9.03983283'),
(6, 'Peluso', '1790574170_manchas.jpg', 1, 25.4158343, -101.0012627, '2026-09-27 23:42:50', 'perrito_6ab9fe5a1f33d1.13138277');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perrito_colores`
--

CREATE TABLE `perrito_colores` (
  `id_perrito` int(11) NOT NULL,
  `id_color` int(11) NOT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `razas`
--

CREATE TABLE `razas` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `razas`
--

INSERT INTO `razas` (`id`, `nombre`) VALUES
(20, 'Boxer'),
(1, 'chihuahua'),
(18, 'Golden Retriver'),
(22, 'husky'),
(14, 'Labrador Retriver'),
(15, 'Pastor Aleman'),
(16, 'Pitbull'),
(19, 'Poodle / Caniche'),
(21, 'Schnauzer'),
(17, 'Siberian Husky'),
(13, 'Sin raza definida / criollo ');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `colores`
--
ALTER TABLE `colores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `perritos`
--
ALTER TABLE `perritos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `clave_idempotencia` (`clave_idempotencia`),
  ADD KEY `id_raza` (`id_raza`);

--
-- Indices de la tabla `perrito_colores`
--
ALTER TABLE `perrito_colores`
  ADD PRIMARY KEY (`id_perrito`,`id_color`),
  ADD KEY `id_color` (`id_color`);

--
-- Indices de la tabla `razas`
--
ALTER TABLE `razas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `colores`
--
ALTER TABLE `colores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `perritos`
--
ALTER TABLE `perritos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `razas`
--
ALTER TABLE `razas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `perritos`
--
ALTER TABLE `perritos`
  ADD CONSTRAINT `perritos_ibfk_1` FOREIGN KEY (`id_raza`) REFERENCES `razas` (`id`);

--
-- Filtros para la tabla `perrito_colores`
--
ALTER TABLE `perrito_colores`
  ADD CONSTRAINT `perrito_colores_ibfk_1` FOREIGN KEY (`id_perrito`) REFERENCES `perritos` (`id`),
  ADD CONSTRAINT `perrito_colores_ibfk_2` FOREIGN KEY (`id_color`) REFERENCES `colores` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
