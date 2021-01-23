CREATE TABLE IF NOT EXISTS `gangs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gangName` varchar(65) DEFAULT NULL,
  `expireTime` date DEFAULT NULL,
  `gangColor` tinyint(1) DEFAULT 1,
  `blipRadius` int(11) NOT NULL DEFAULT 100,
  `coords` text DEFAULT NULL,
  `accountMoney` varchar(10) NOT NULL DEFAULT '0',
  `canSearch` tinyint(4) NOT NULL DEFAULT 1,
  `canCuff` tinyint(4) NOT NULL DEFAULT 1,
  `canMove` tinyint(4) NOT NULL DEFAULT 1,
  `canOpenCarsDoor` tinyint(4) NOT NULL DEFAULT 1,
  `haveGPS` tinyint(4) NOT NULL DEFAULT 1,
  `slotPlayer` int(11) NOT NULL DEFAULT 0,
  `maxArmor` int(11) NOT NULL DEFAULT 0,
  `inventory` longtext DEFAULT NULL,
  `discordHook` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `gangs_grade` (
  `gradeId` int(11) NOT NULL AUTO_INCREMENT,
  `gangId` int(11) NOT NULL,
  `grade` int(11) NOT NULL DEFAULT 0,
  `name` varchar(65) DEFAULT NULL,
  `salary` int(11) NOT NULL DEFAULT 0,
  `maleSkin` text DEFAULT NULL,
  `femaleSkin` text DEFAULT NULL,
  `accessVehicle` tinyint(1) NOT NULL DEFAULT 1,
  `accessArmory` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`gradeId`),
  KEY `gangId` (`gangId`),
  CONSTRAINT `gangs_grade_ibfk_1` FOREIGN KEY (`gangId`) REFERENCES `gangs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `gangs_member` (
  `playerIdentifiers` varchar(250) DEFAULT NULL,
  `gangId` int(11) NOT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL,
  KEY `gangId` (`gangId`),
  CONSTRAINT `gangs_member_ibfk_1` FOREIGN KEY (`gangId`) REFERENCES `gangs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `gangs_vehicle` (
  `gangId` int(11) NOT NULL,
  `plate` varchar(10) NOT NULL,
  `vehicle` longtext NOT NULL,
  `type` varchar(20) NOT NULL,
  `stored` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ;