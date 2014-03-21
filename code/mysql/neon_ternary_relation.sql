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
-- Table structure for table `ternary_relation`
--

DROP TABLE IF EXISTS `ternary_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ternary_relation` (
  `id` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `var_id1` int(11) NOT NULL,
  `var_id2` int(11) NOT NULL,
  `var_id3` int(11) NOT NULL,
  `rule_id` int(11) NOT NULL,
  `negation` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`,`var_id1`,`var_id2`,`var_id3`),
  KEY `fk_ternary_relation_var1` (`var_id1`),
  KEY `fk_ternary_relation_var2` (`var_id2`),
  KEY `fk_ternary_relation_var3` (`var_id3`),
  KEY `fk_ternary_relation_rule` (`rule_id`),
  CONSTRAINT `fk_ternary_relation_rule` FOREIGN KEY (`rule_id`) REFERENCES `rule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ternary_relation_var1` FOREIGN KEY (`var_id1`) REFERENCES `var` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ternary_relation_var2` FOREIGN KEY (`var_id2`) REFERENCES `var` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ternary_relation_var3` FOREIGN KEY (`var_id3`) REFERENCES `var` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ternary_relation`
--

LOCK TABLES `ternary_relation` WRITE;
/*!40000 ALTER TABLE `ternary_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `ternary_relation` ENABLE KEYS */;
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
