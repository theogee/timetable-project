-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 11, 2021 at 04:39 AM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.2.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `theophilusarieldb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteScheduleCDTSM` (IN `parDelCourseID` INT, IN `parDelDate` DATE, IN `parDelTimeID` INT, IN `parSemesterID` INT, IN `parMajorID` INT)  MODIFIES SQL DATA
BEGIN

DELETE FROM schedule WHERE course_id = parDelCourseID AND date_desc = parDelDate AND timeslot_id = parDelTimeID AND semester_id = parSemesterID AND major_id = parMajorID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllMajor` ()  READS SQL DATA
BEGIN

	SELECT major_name FROM major;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllSemester` ()  READS SQL DATA
BEGIN

	SELECT semester_desc FROM semester;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllWeek` ()  READS SQL DATA
BEGIN

	SELECT week_desc FROM week ORDER BY week_id ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAttendingMajor` (IN `parCourseID` INT)  READS SQL DATA
BEGIN

SELECT major.major_name FROM msc, major WHERE msc.major_id = major.major_id AND course_id = parCourseID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCourseInfoMSC` (IN `parMajorID` INT, IN `parSemesterID` INT, IN `parCourseID` INT)  READS SQL DATA
BEGIN

SELECT c.course_name, c.course_id, c.room_number FROM msc, course c WHERE msc.course_id = c.course_id AND c.course_id = parCourseID AND major_id = parMajorID AND semester_id = parSemesterID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCourseLecturer` (IN `parCourseID` INT)  READS SQL DATA
BEGIN

SELECT l.lecturer_name FROM lecturer l, teaches tc WHERE l.lecturer_id = tc.lecturer_id AND tc.course_id = parCourseID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCourseMS` (IN `parMajorID` INT, IN `parSemesterID` INT)  READS SQL DATA
BEGIN

SELECT msc.course_id, c.course_name FROM msc, course c WHERE msc.course_id = c.course_id AND msc.major_id = parMajorID AND msc.semester_id = parSemesterID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDateForHeadline` (IN `parWeekID` INT)  READS SQL DATA
BEGIN

SELECT DATE_FORMAT(date_desc, "%d.%m.%Y") FROM date WHERE week_id = parWeekID ORDER BY day_id ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getExistingCourseMSW` (IN `parMajorID` INT, IN `parSemesterID` INT, IN `parWeekID` INT)  READS SQL DATA
BEGIN

SELECT DISTINCT sch.course_id, c.course_name FROM schedule sch, `date`, course c WHERE sch.date_desc = `date`.`date_desc` AND sch.course_id = c.course_id AND sch.major_id = parMajorID AND sch.semester_id = parSemesterID AND `date`.`week_id` = parWeekID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getScheduleMSW` (IN `parMajorID` INT, IN `parSemesterID` INT, IN `parWeekID` INT)  READS SQL DATA
    COMMENT 'to show the schedule'
SELECT CONCAT(TIME_FORMAT(timeslotSub.start, "%H:%i"), " - ", TIME_FORMAT(timeslotSub.end, "%H:%i")) as `TIME`, IFNULL(mondaySch.course_name, "-") as Monday, IFNULL(tuesdaySch.course_name, "-") as Tuesday, IFNULL(wednesdaySch.course_name, "-") as Wednesday, IFNULL(thursdaySch.course_name, "-") as Thursday, IFNULL(fridaySch.course_name, "-") as Friday

FROM (
SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end` FROM timeslot ts
) as timeslotSub LEFT JOIN (
    SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end`, course.course_name as course_name		
    FROM `schedule` sch, `date`, timeslot ts, course
    WHERE sch.date_desc IN (
    SELECT `date`.`date_desc` FROM `date` WHERE `date`.week_id = parWeekID
    ) AND sch.date_desc = `date`.`date_desc` AND sch.timeslot_id = ts.timeslot_id AND sch.course_id = course.course_id AND `date`.`day_id` = 1 AND sch.semester_id = parSemesterID AND sch.major_id = parMajorID
) as mondaySch ON timeslotSub.start = mondaySch.start AND timeslotSub.end = mondaySch.end LEFT JOIN (
	SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end`, course.course_name as course_name		
    FROM `schedule` sch, `date`, timeslot ts, course
    WHERE sch.date_desc IN (
    SELECT `date`.`date_desc` FROM `date` WHERE `date`.week_id = parWeekID
    ) AND sch.date_desc = `date`.`date_desc` AND sch.timeslot_id = ts.timeslot_id AND sch.course_id = course.course_id AND `date`.`day_id` = 2 AND sch.semester_id = parSemesterID AND sch.major_id = parMajorID
) as tuesdaySch ON timeslotSub.start = tuesdaySch.start AND timeslotSub.end = tuesdaySch.end LEFT JOIN (
	SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end`, course.course_name as course_name		
    FROM `schedule` sch, `date`, timeslot ts, course
    WHERE sch.date_desc IN (
    SELECT `date`.`date_desc` FROM `date` WHERE `date`.week_id = parWeekID
    ) AND sch.date_desc = `date`.`date_desc` AND sch.timeslot_id = ts.timeslot_id AND sch.course_id = course.course_id AND `date`.`day_id` = 3 AND sch.semester_id = parSemesterID AND sch.major_id = parMajorID
) as wednesdaySch ON timeslotSub.start = wednesdaySch.start AND timeslotSub.end = wednesdaySch.end LEFT JOIN (
	SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end`, course.course_name as course_name		
    FROM `schedule` sch, `date`, timeslot ts, course
    WHERE sch.date_desc IN (
    SELECT `date`.`date_desc` FROM `date` WHERE `date`.week_id = parWeekID
    ) AND sch.date_desc = `date`.`date_desc` AND sch.timeslot_id = ts.timeslot_id AND sch.course_id = course.course_id AND `date`.`day_id` = 4 AND sch.semester_id = parSemesterID AND sch.major_id = parMajorID
) as thursdaySch ON timeslotSub.start = thursdaySch.start AND timeslotSub.end = thursdaySch.end LEFT JOIN (
SELECT ts.timeslot_start as `start`, ts.timeslot_end as `end`, course.course_name as course_name		
    FROM `schedule` sch, `date`, timeslot ts, course
    WHERE sch.date_desc IN (
    SELECT `date`.`date_desc` FROM `date` WHERE `date`.week_id = parWeekID
    ) AND sch.date_desc = `date`.`date_desc` AND sch.timeslot_id = ts.timeslot_id AND sch.course_id = course.course_id AND `date`.`day_id` = 5 AND sch.semester_id = parSemesterID AND sch.major_id = parMajorID
) as fridaySch ON timeslotSub.start = fridaySch.start AND timeslotSub.end = fridaySch.end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getTime` ()  READS SQL DATA
BEGIN

SELECT ts.timeslot_id, CONCAT(TIME_FORMAT(ts.timeslot_start, "%H:%i"), " - ", TIME_FORMAT(ts.timeslot_end, "%H:%i")) as timeslot FROM timeslot ts;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertScheduleCDTSM` (IN `parCourseID` INT, IN `parDateDesc` DATE, IN `parTimeID` INT, IN `parSemesterID` INT, IN `parMajorID` INT)  MODIFIES SQL DATA
BEGIN

INSERT INTO schedule VALUE (parCourseID, parDateDesc, parTimeID, parSemesterID, parMajorID);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertSemesterDate` (IN `start_date` DATE, IN `day_count` INT)  MODIFIES SQL DATA
    COMMENT 'requires 7 day_id'
BEGIN

	DECLARE i int;
	DECLARE j int;
	DECLARE k int;
	SET i = 1;
	SET j = 1;
	SET k = 1;

	WHILE i <= day_count DO

		IF j > 7 THEN
			SET j = 1;
			SET k = k + 1;
		END IF;

		INSERT INTO `date` VALUE(DATE_ADD(start_date, INTERVAL i DAY), j, k);
		
		
		SET i = i + 1;
		SET j = j + 1;
		
	END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateSchedule` (IN `parNewCourseID` INT, IN `parNewDate` DATE, IN `parNewTimeID` INT, IN `parOldCourseID` INT, IN `parOldDate` DATE, IN `parOldTimeID` INT, IN `parSemesterID` INT, IN `parMajorID` INT)  MODIFIES SQL DATA
BEGIN

UPDATE `schedule` SET course_id = parNewCourseID, date_desc = parNewDate, timeslot_id = parNewTimeID WHERE course_id = parOldCourseID AND date_desc = parOldDate AND timeslot_id = parOldTimeID AND semester_id = parSemesterID AND major_id = parMajorID;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `course_id` int(11) NOT NULL,
  `room_number` int(11) NOT NULL,
  `course_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`course_id`, `room_number`, `course_name`) VALUES
(1050, 120, 'Algorithm & OOP'),
(1060, 101, 'Algo. & Data Struc.'),
(1234, 2093, 'Discrete Math'),
(1872, 514, 'Data Science'),
(2099, 514, 'German Language 1'),
(2730, 2093, 'Electrical Eng. 1'),
(3313, 100, 'Database Theory'),
(3501, 101, 'Web Design'),
(4358, 514, 'Technical Drawing'),
(4981, 100, 'Database Lab'),
(5634, 101, 'Linux & Comp.Network'),
(5889, 100, 'Eng. Statics'),
(6038, 3128, 'Physics 1'),
(7123, 3128, 'ACT'),
(7569, 120, 'Statistics 1'),
(9072, 2093, 'English 1');

-- --------------------------------------------------------

--
-- Table structure for table `date`
--

CREATE TABLE `date` (
  `date_desc` date NOT NULL,
  `day_id` int(11) NOT NULL,
  `week_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `date`
--

INSERT INTO `date` (`date_desc`, `day_id`, `week_id`) VALUES
('2021-01-04', 1, 1),
('2021-01-05', 2, 1),
('2021-01-06', 3, 1),
('2021-01-07', 4, 1),
('2021-01-08', 5, 1),
('2021-01-11', 1, 2),
('2021-01-12', 2, 2),
('2021-01-13', 3, 2),
('2021-01-14', 4, 2),
('2021-01-15', 5, 2),
('2021-01-18', 1, 3),
('2021-01-19', 2, 3),
('2021-01-20', 3, 3),
('2021-01-21', 4, 3),
('2021-01-22', 5, 3),
('2021-01-25', 1, 4),
('2021-01-26', 2, 4),
('2021-01-27', 3, 4),
('2021-01-28', 4, 4),
('2021-01-29', 5, 4),
('2021-02-01', 1, 5),
('2021-02-02', 2, 5),
('2021-02-03', 3, 5),
('2021-02-04', 4, 5),
('2021-02-05', 5, 5),
('2021-02-08', 1, 6),
('2021-02-09', 2, 6),
('2021-02-10', 3, 6),
('2021-02-11', 4, 6),
('2021-02-12', 5, 6),
('2021-02-15', 1, 7),
('2021-02-16', 2, 7),
('2021-02-17', 3, 7),
('2021-02-18', 4, 7),
('2021-02-19', 5, 7),
('2021-02-22', 1, 8),
('2021-02-23', 2, 8),
('2021-02-24', 3, 8),
('2021-02-25', 4, 8),
('2021-02-26', 5, 8),
('2021-03-01', 1, 9),
('2021-03-02', 2, 9),
('2021-03-03', 3, 9),
('2021-03-04', 4, 9),
('2021-03-05', 5, 9),
('2021-03-08', 1, 10),
('2021-03-09', 2, 10),
('2021-03-10', 3, 10),
('2021-03-11', 4, 10),
('2021-03-12', 5, 10),
('2021-03-15', 1, 11),
('2021-03-16', 2, 11),
('2021-03-17', 3, 11),
('2021-03-18', 4, 11),
('2021-03-19', 5, 11),
('2021-03-22', 1, 12),
('2021-03-23', 2, 12),
('2021-03-24', 3, 12),
('2021-03-25', 4, 12),
('2021-03-26', 5, 12),
('2021-03-29', 1, 13),
('2021-03-30', 2, 13),
('2021-03-31', 3, 13),
('2021-04-01', 4, 13),
('2021-04-02', 5, 13),
('2021-04-05', 1, 14),
('2021-04-06', 2, 14),
('2021-04-07', 3, 14),
('2021-04-08', 4, 14),
('2021-04-09', 5, 14);

-- --------------------------------------------------------

--
-- Table structure for table `day`
--

CREATE TABLE `day` (
  `day_id` int(11) NOT NULL,
  `day_desc` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `day`
--

INSERT INTO `day` (`day_id`, `day_desc`) VALUES
(5, 'Friday'),
(1, 'Monday'),
(4, 'Thursday'),
(2, 'Tuesday'),
(3, 'Wednesday');

-- --------------------------------------------------------

--
-- Table structure for table `lecturer`
--

CREATE TABLE `lecturer` (
  `lecturer_id` int(11) NOT NULL,
  `lecturer_name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `lecturer`
--

INSERT INTO `lecturer` (`lecturer_id`, `lecturer_name`) VALUES
(10101, 'Boris Manurung'),
(12121, 'Kho I Eng'),
(13246, 'Erikson Sinaga'),
(15151, 'Irawan'),
(17171, 'Yunita Umniyati'),
(22222, 'Randy Anthony'),
(23412, 'Cepi Hanah'),
(32343, 'Moch. Riyadh R. Addam'),
(33456, 'Wilbert Adiputra'),
(33551, 'Dena Hendriana'),
(45565, 'James Purnama'),
(57701, 'Rusman Rusyadi'),
(58583, 'Maulahikmah Galinium'),
(76543, 'Michael D. Mcneil'),
(83821, 'James Hunt'),
(98345, 'Eka Budiarto');

-- --------------------------------------------------------

--
-- Table structure for table `major`
--

CREATE TABLE `major` (
  `major_id` int(11) NOT NULL,
  `major_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `major`
--

INSERT INTO `major` (`major_id`, `major_name`) VALUES
(1, 'Information Technology'),
(2, 'Mechatronics'),
(3, 'Industrial Engineering'),
(4, 'Business & Management'),
(5, 'Accounting'),
(6, 'PR & Communications'),
(7, 'Hotel & Tourism Mgt.'),
(8, 'Intl. Culinary Business'),
(9, 'Biomedical Engineering'),
(10, 'Pharmaceutical Eng.'),
(11, 'Food Technology'),
(12, 'Sustainable Energy & Envi.');

-- --------------------------------------------------------

--
-- Table structure for table `msc`
--

CREATE TABLE `msc` (
  `major_id` int(11) NOT NULL,
  `semester_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `msc`
--

INSERT INTO `msc` (`major_id`, `semester_id`, `course_id`) VALUES
(1, 1, 1050),
(1, 1, 1234),
(1, 1, 1872),
(1, 1, 2099),
(1, 1, 3313),
(1, 1, 3501),
(1, 1, 4981),
(1, 1, 5634),
(1, 1, 7123),
(1, 1, 7569),
(1, 1, 9072),
(2, 1, 1060),
(2, 1, 1234),
(2, 1, 2099),
(2, 1, 2730),
(2, 1, 4358),
(2, 1, 5889),
(2, 1, 6038),
(2, 1, 9072);

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `room_number` int(11) NOT NULL,
  `room_level` int(11) DEFAULT NULL,
  `room_capacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `room`
--

INSERT INTO `room` (`room_number`, `room_level`, `room_capacity`) VALUES
(100, 31, 10),
(101, 7, 50),
(120, 34, 30),
(514, 15, 20),
(2093, 20, 100),
(3128, 7, 70);

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `course_id` int(11) NOT NULL,
  `date_desc` date NOT NULL,
  `timeslot_id` int(11) NOT NULL,
  `semester_id` int(11) NOT NULL,
  `major_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`course_id`, `date_desc`, `timeslot_id`, `semester_id`, `major_id`) VALUES
(1050, '2021-01-07', 3, 1, 1),
(1050, '2021-01-07', 4, 1, 1),
(1050, '2021-01-07', 5, 1, 1),
(1050, '2021-01-07', 9, 1, 1),
(1050, '2021-01-07', 10, 1, 1),
(1050, '2021-01-13', 9, 1, 1),
(1234, '2021-01-04', 4, 1, 1),
(1234, '2021-01-04', 5, 1, 1),
(1872, '2021-01-06', 8, 1, 1),
(1872, '2021-01-06', 9, 1, 1),
(1872, '2021-01-13', 8, 1, 1),
(2099, '2021-01-05', 4, 1, 1),
(2099, '2021-01-05', 5, 1, 1),
(2099, '2021-01-12', 4, 1, 1),
(2099, '2021-01-12', 5, 1, 1),
(3313, '2021-01-07', 7, 1, 1),
(3313, '2021-01-07', 8, 1, 1),
(3501, '2021-01-05', 7, 1, 1),
(3501, '2021-01-05', 8, 1, 1),
(3501, '2021-01-12', 7, 1, 1),
(4981, '2021-01-06', 5, 1, 1),
(4981, '2021-01-06', 6, 1, 1),
(5634, '2021-01-04', 8, 1, 1),
(5634, '2021-01-04', 9, 1, 1),
(5634, '2021-01-11', 6, 1, 1),
(5634, '2021-01-11', 7, 1, 1),
(7123, '2021-01-08', 9, 1, 1),
(7123, '2021-01-08', 10, 1, 1),
(7123, '2021-01-08', 11, 1, 1),
(7123, '2021-01-12', 8, 1, 1),
(7123, '2021-01-12', 9, 1, 1),
(7123, '2021-01-12', 10, 1, 1),
(7569, '2021-01-08', 7, 1, 1),
(7569, '2021-01-08', 8, 1, 1),
(9072, '2021-01-08', 4, 1, 1),
(9072, '2021-01-08', 5, 1, 1),
(1234, '2021-01-05', 4, 1, 2),
(2099, '2021-01-07', 11, 1, 2),
(2099, '2021-01-07', 12, 1, 2),
(2730, '2021-01-04', 4, 1, 2),
(4358, '2021-01-06', 6, 1, 2),
(4358, '2021-01-06', 8, 1, 2),
(6038, '2021-01-04', 5, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `semester_id` int(11) NOT NULL,
  `semester_desc` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`semester_id`, `semester_desc`) VALUES
(1, 'SEM 1'),
(2, 'SEM 2'),
(3, 'SEM 3'),
(4, 'SEM 4'),
(5, 'SEM 5'),
(6, 'SEM 6'),
(7, 'SEM 7'),
(8, 'SEM 8');

-- --------------------------------------------------------

--
-- Table structure for table `teaches`
--

CREATE TABLE `teaches` (
  `lecturer_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `teaches`
--

INSERT INTO `teaches` (`lecturer_id`, `course_id`) VALUES
(10101, 1234),
(12121, 5634),
(13246, 2730),
(15151, 2099),
(17171, 6038),
(22222, 3501),
(23412, 4358),
(32343, 7123),
(33456, 4981),
(33551, 5889),
(45565, 1050),
(45565, 1872),
(57701, 1060),
(58583, 3313),
(76543, 9072),
(83821, 9072),
(98345, 7569);

-- --------------------------------------------------------

--
-- Table structure for table `timeslot`
--

CREATE TABLE `timeslot` (
  `timeslot_id` int(11) NOT NULL,
  `timeslot_start` time NOT NULL,
  `timeslot_end` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `timeslot`
--

INSERT INTO `timeslot` (`timeslot_id`, `timeslot_start`, `timeslot_end`) VALUES
(1, '07:00:00', '07:50:00'),
(2, '08:00:00', '08:50:00'),
(3, '09:00:00', '09:50:00'),
(4, '10:00:00', '10:50:00'),
(5, '11:00:00', '11:50:00'),
(6, '12:00:00', '12:50:00'),
(7, '13:00:00', '13:50:00'),
(8, '14:00:00', '14:50:00'),
(9, '15:00:00', '15:50:00'),
(10, '16:00:00', '16:50:00'),
(11, '17:00:00', '17:50:00'),
(12, '18:00:00', '18:50:00');

-- --------------------------------------------------------

--
-- Table structure for table `week`
--

CREATE TABLE `week` (
  `week_id` int(11) NOT NULL,
  `week_desc` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `week`
--

INSERT INTO `week` (`week_id`, `week_desc`) VALUES
(1, 'WEEK 1'),
(10, 'WEEK 10'),
(11, 'WEEK 11'),
(12, 'WEEK 12'),
(13, 'WEEK 13'),
(14, 'WEEK 14'),
(2, 'WEEK 2'),
(3, 'WEEK 3'),
(4, 'WEEK 4'),
(5, 'WEEK 5'),
(6, 'WEEK 6'),
(7, 'WEEK 7'),
(8, 'WEEK 8'),
(9, 'WEEK 9');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`course_id`),
  ADD UNIQUE KEY `course_id` (`course_id`),
  ADD UNIQUE KEY `course_name` (`course_name`),
  ADD KEY `room_number` (`room_number`);

--
-- Indexes for table `date`
--
ALTER TABLE `date`
  ADD PRIMARY KEY (`date_desc`),
  ADD UNIQUE KEY `date` (`date_desc`),
  ADD KEY `day_id` (`day_id`),
  ADD KEY `week_id` (`week_id`);

--
-- Indexes for table `day`
--
ALTER TABLE `day`
  ADD PRIMARY KEY (`day_id`),
  ADD UNIQUE KEY `day_id` (`day_id`),
  ADD UNIQUE KEY `day_desc` (`day_desc`);

--
-- Indexes for table `lecturer`
--
ALTER TABLE `lecturer`
  ADD PRIMARY KEY (`lecturer_id`),
  ADD UNIQUE KEY `lecturer_id` (`lecturer_id`);

--
-- Indexes for table `major`
--
ALTER TABLE `major`
  ADD PRIMARY KEY (`major_id`),
  ADD UNIQUE KEY `major_id` (`major_id`);

--
-- Indexes for table `msc`
--
ALTER TABLE `msc`
  ADD PRIMARY KEY (`major_id`,`course_id`),
  ADD KEY `course_id` (`course_id`),
  ADD KEY `semester_id` (`semester_id`),
  ADD KEY `major_id` (`major_id`),
  ADD KEY `major_id_2` (`major_id`,`semester_id`,`course_id`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_number`),
  ADD UNIQUE KEY `room_number` (`room_number`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`date_desc`,`timeslot_id`,`semester_id`,`major_id`),
  ADD KEY `timeslot_id` (`timeslot_id`),
  ADD KEY `msc` (`major_id`,`semester_id`,`course_id`) USING BTREE;

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`semester_id`),
  ADD UNIQUE KEY `semester_id` (`semester_id`),
  ADD UNIQUE KEY `semester_desc` (`semester_desc`);

--
-- Indexes for table `teaches`
--
ALTER TABLE `teaches`
  ADD PRIMARY KEY (`lecturer_id`,`course_id`),
  ADD KEY `course_id` (`course_id`),
  ADD KEY `lecturer_id` (`lecturer_id`);

--
-- Indexes for table `timeslot`
--
ALTER TABLE `timeslot`
  ADD PRIMARY KEY (`timeslot_id`),
  ADD UNIQUE KEY `timeslot_id` (`timeslot_id`);

--
-- Indexes for table `week`
--
ALTER TABLE `week`
  ADD PRIMARY KEY (`week_id`),
  ADD UNIQUE KEY `week_id` (`week_id`),
  ADD UNIQUE KEY `week_desc` (`week_desc`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`room_number`) REFERENCES `room` (`room_number`);

--
-- Constraints for table `date`
--
ALTER TABLE `date`
  ADD CONSTRAINT `date_ibfk_1` FOREIGN KEY (`day_id`) REFERENCES `day` (`day_id`),
  ADD CONSTRAINT `date_ibfk_2` FOREIGN KEY (`week_id`) REFERENCES `week` (`week_id`);

--
-- Constraints for table `msc`
--
ALTER TABLE `msc`
  ADD CONSTRAINT `msc_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `major` (`major_id`),
  ADD CONSTRAINT `msc_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`),
  ADD CONSTRAINT `msc_ibfk_3` FOREIGN KEY (`semester_id`) REFERENCES `semester` (`semester_id`);

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`date_desc`) REFERENCES `date` (`date_desc`),
  ADD CONSTRAINT `schedule_ibfk_2` FOREIGN KEY (`timeslot_id`) REFERENCES `timeslot` (`timeslot_id`),
  ADD CONSTRAINT `schedule_ibfk_3` FOREIGN KEY (`major_id`,`semester_id`,`course_id`) REFERENCES `msc` (`major_id`, `semester_id`, `course_id`);

--
-- Constraints for table `teaches`
--
ALTER TABLE `teaches`
  ADD CONSTRAINT `teaches_ibfk_1` FOREIGN KEY (`lecturer_id`) REFERENCES `lecturer` (`lecturer_id`),
  ADD CONSTRAINT `teaches_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
