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
-- Table structure for table `binary_relation`
--

DROP TABLE IF EXISTS `binary_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `binary_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `var_id1` int(11) NOT NULL,
  `var_id2` int(11) NOT NULL,
  `rule_id` int(11) NOT NULL COMMENT 'The rule this binary relation belongs to',
  `negation` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`,`var_id1`,`var_id2`),
  KEY `fk_binary_relation_var1` (`var_id1`),
  KEY `fk_binary_relation_var2` (`var_id2`),
  KEY `fk_binary_relation_rule` (`rule_id`),
  CONSTRAINT `fk_binary_relation_rule` FOREIGN KEY (`rule_id`) REFERENCES `rule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_binary_relation_var1` FOREIGN KEY (`var_id1`) REFERENCES `var` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_binary_relation_var3` FOREIGN KEY (`var_id2`) REFERENCES `var` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `binary_relation`
--

LOCK TABLES `binary_relation` WRITE;
/*!40000 ALTER TABLE `binary_relation` DISABLE KEYS */;
INSERT INTO `binary_relation` VALUES (3,'plant_neighbor',4,5,1,1),(4,'plant_height_lessThan',4,5,1,1),(5,'plant_neighbor',6,7,3,1);
/*!40000 ALTER TABLE `binary_relation` ENABLE KEYS */;
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
