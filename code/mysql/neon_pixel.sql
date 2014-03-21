CREATE DATABASE  IF NOT EXISTS `neon` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `neon`;
-- MySQL dump 10.13  Distrib 5.5.35, for debian-linux-gnu (i686)
--
-- Host: 127.0.0.1    Database: neon
-- ------------------------------------------------------
-- Server version	5.5.35-0ubuntu0.12.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `pixel`
--

DROP TABLE IF EXISTS `pixel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pixel` (
  `pixel_id` int(11) NOT NULL AUTO_INCREMENT,
  `northing` float NOT NULL,
  `easting` float NOT NULL,
  `zone` int(11) NOT NULL,
  `elevation` float NOT NULL COMMENT 'Last return in Lidar',
  `height` float NOT NULL COMMENT 'First return in lidar',
  `burn_date` date NOT NULL,
  `specie_id` int(11) DEFAULT NULL COMMENT 'unbounded needs to be grounded based on information.',
  `west_neighbor_pixel_id` int(11) DEFAULT NULL,
  `north_neighbor_pixel_id` int(11) DEFAULT NULL,
  `east_neighbor_pixel_id` int(11) DEFAULT NULL,
  `south_neighbor_pixel_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`pixel_id`),
  KEY `fk_specie_id` (`specie_id`),
  KEY `fk_pixel_pixel_west` (`west_neighbor_pixel_id`),
  KEY `fk_pixel_pixel_north` (`north_neighbor_pixel_id`),
  KEY `fk_pixel_pixel_east` (`east_neighbor_pixel_id`),
  KEY `fk_pixel_pixel_south` (`south_neighbor_pixel_id`),
  CONSTRAINT `fk_pixel_pixel_east` FOREIGN KEY (`east_neighbor_pixel_id`) REFERENCES `pixel` (`pixel_id`),
  CONSTRAINT `fk_pixel_pixel_north` FOREIGN KEY (`north_neighbor_pixel_id`) REFERENCES `pixel` (`pixel_id`),
  CONSTRAINT `fk_pixel_pixel_south` FOREIGN KEY (`south_neighbor_pixel_id`) REFERENCES `pixel` (`pixel_id`),
  CONSTRAINT `fk_pixel_pixel_west` FOREIGN KEY (`west_neighbor_pixel_id`) REFERENCES `pixel` (`pixel_id`),
  CONSTRAINT `fk_specie_id` FOREIGN KEY (`specie_id`) REFERENCES `specie` (`specie_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COMMENT='An entry per pixel of map';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pixel`
--

LOCK TABLES `pixel` WRITE;
/*!40000 ALTER TABLE `pixel` DISABLE KEYS */;
INSERT INTO `pixel` VALUES (1,3285000,405001,17,0,20,'2007-05-10',2,1,1,1,1),(2,3285000,405000,17,0,20,'2007-05-10',2,1,1,1,1),(3,3285000,405000,17,12,19,'2014-02-03',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `pixel` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-02-18  9:04:05
