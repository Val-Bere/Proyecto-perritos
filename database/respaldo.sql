-- MySQL dump 10.13  Distrib 9.7.0, for macos15 (arm64)
--
-- Host: localhost    Database: perritos_db
-- ------------------------------------------------------
-- Server version	9.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'a57fe52c-ba02-11f1-a67e-b798d56064d1:1-75';

--
-- Table structure for table `colores`
--

DROP TABLE IF EXISTS `colores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `colores`
--

LOCK TABLES `colores` WRITE;
/*!40000 ALTER TABLE `colores` DISABLE KEYS */;
INSERT INTO `colores` VALUES (7,'Atigrado'),(8,'Beige'),(2,'Blanco'),(3,'Cafe'),(10,'Crema'),(4,'Dorado'),(5,'Gris'),(1,'Negro'),(6,'Pinto / Manchado'),(9,'Rojizo');
/*!40000 ALTER TABLE `colores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perrito_colores`
--

DROP TABLE IF EXISTS `perrito_colores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perrito_colores` (
  `id_perrito` int NOT NULL,
  `id_color` int NOT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_perrito`,`id_color`),
  KEY `id_color` (`id_color`),
  CONSTRAINT `perrito_colores_ibfk_1` FOREIGN KEY (`id_perrito`) REFERENCES `perritos` (`id`),
  CONSTRAINT `perrito_colores_ibfk_2` FOREIGN KEY (`id_color`) REFERENCES `colores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perrito_colores`
--

LOCK TABLES `perrito_colores` WRITE;
/*!40000 ALTER TABLE `perrito_colores` DISABLE KEYS */;
INSERT INTO `perrito_colores` VALUES (7,2,0),(7,3,0),(7,6,1),(8,3,1),(9,4,1),(9,5,0),(10,2,1),(11,1,0),(11,3,1),(12,2,1),(12,5,0),(13,1,1),(14,3,0),(14,9,1),(15,2,0),(15,3,1),(16,10,1),(17,1,1),(17,3,0),(18,4,0),(18,8,1),(19,3,1),(20,1,0),(20,7,1);
/*!40000 ALTER TABLE `perrito_colores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perritos`
--

DROP TABLE IF EXISTS `perritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perritos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `foto_archivo` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `id_raza` int DEFAULT NULL,
  `latitud` decimal(10,7) NOT NULL,
  `longitud` decimal(10,7) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `clave_idempotencia` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clave_idempotencia` (`clave_idempotencia`),
  KEY `id_raza` (`id_raza`),
  CONSTRAINT `perritos_ibfk_1` FOREIGN KEY (`id_raza`) REFERENCES `razas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perritos`
--

LOCK TABLES `perritos` WRITE;
/*!40000 ALTER TABLE `perritos` DISABLE KEYS */;
INSERT INTO `perritos` VALUES (7,'Manchas','7959b544a71d4074999eb5a363ca34e2.jpg',1,25.4237000,-101.0053000,'2026-09-28 11:26:36','seed-002'),(8,'Canela','7a564b0bdb8b46328fe74429b376ab33.jpg',13,25.4300000,-101.0100000,'2026-09-28 11:26:36','seed-003'),(9,'Rex','a3b32b724fc14288aede44393e2344b9.jpg',14,25.4150000,-100.9900000,'2026-09-28 11:26:36','seed-004'),(10,'Luna','b5b2c6fe7ef044ec876cbcf85182d3b0.jpg',15,25.4450000,-101.0200000,'2026-09-28 11:26:37','seed-005'),(11,'Toby','a1811500041648e2b083e8b333b02c35.jpg',13,25.4100000,-101.0000000,'2026-09-28 11:26:37','seed-006'),(12,'Nube','e95eb50312824eb9a8a5ad394bf3cc7c.jpg',19,25.4350000,-100.9800000,'2026-09-28 11:26:37','seed-007'),(13,'Max','dd381daa59c44f83ba57caa606feca1c.jpg',16,25.4200000,-101.0300000,'2026-09-28 11:26:37','seed-008'),(14,'Bella','04530b2bce8641a5acd8038c2e80d3c4.jpg',13,25.4500000,-100.9950000,'2026-09-28 11:26:37','seed-009'),(15,'Coco','2bd722d5cbf04ab6a7610b2b70ea5e06.jpg',21,25.4050000,-101.0150000,'2026-09-28 11:26:37','seed-010'),(16,'Pelusa','e01c83061d10442490fe7c58ae10e404.jpg',13,25.4320000,-101.0250000,'2026-09-28 11:26:37','seed-011'),(17,'Thor','8812ec49573f458290eba535c9fd1a9e.jpg',17,25.4180000,-100.9850000,'2026-09-28 11:26:37','seed-012'),(18,'Kira','bfd7485db8e041c1a708e9c0cdf265de.jpg',18,25.4420000,-101.0080000,'2026-09-28 11:26:37','seed-013'),(19,'Bruno','b8ec3c3f48a5420dbedfb3389d06d4c8.jpg',13,25.4270000,-100.9700000,'2026-09-28 11:26:37','seed-014'),(20,'Chispa','735c92dae08449859eb53c267066c02b.jpg',20,25.4090000,-100.9950000,'2026-09-28 11:26:37','seed-015');
/*!40000 ALTER TABLE `perritos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `razas`
--

DROP TABLE IF EXISTS `razas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `razas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `razas`
--

LOCK TABLES `razas` WRITE;
/*!40000 ALTER TABLE `razas` DISABLE KEYS */;
INSERT INTO `razas` VALUES (20,'Boxer'),(1,'chihuahua'),(18,'Golden Retriver'),(22,'husky'),(14,'Labrador Retriver'),(15,'Pastor Aleman'),(16,'Pitbull'),(19,'Poodle / Caniche'),(21,'Schnauzer'),(17,'Siberian Husky'),(13,'Sin raza definida / criollo');
/*!40000 ALTER TABLE `razas` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-28 11:28:30
