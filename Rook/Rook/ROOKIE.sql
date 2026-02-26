-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 21, 2024 at 01:58 PM
-- Server version: 10.6.16-MariaDB-0ubuntu0.22.04.1
-- PHP Version: 8.1.2-1ubuntu2.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ots`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `password` char(40) NOT NULL,
  `secret` char(16) DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT 1,
  `premium_ends_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL DEFAULT '',
  `created` int(11) NOT NULL DEFAULT 0,
  `rlname` varchar(255) NOT NULL DEFAULT '',
  `location` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(3) NOT NULL DEFAULT '',
  `web_lastlogin` int(11) NOT NULL DEFAULT 0,
  `web_flags` int(11) NOT NULL DEFAULT 0,
  `email_hash` varchar(32) NOT NULL DEFAULT '',
  `email_new` varchar(255) NOT NULL DEFAULT '',
  `email_new_time` int(11) NOT NULL DEFAULT 0,
  `email_code` varchar(255) NOT NULL DEFAULT '',
  `email_next` int(11) NOT NULL DEFAULT 0,
  `premium_points` int(11) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `key` varchar(64) NOT NULL DEFAULT '',
  `creation` int(11) NOT NULL DEFAULT 0,
  `vote` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`id`, `name`, `password`, `secret`, `type`, `premium_ends_at`, `email`, `created`, `rlname`, `location`, `country`, `web_lastlogin`, `web_flags`, `email_hash`, `email_new`, `email_new_time`, `email_code`, `email_next`, `premium_points`, `email_verified`, `key`, `creation`, `vote`) VALUES
(1, '121211', '111111111111111', NULL, 6, 1718469271, '11111335@gmail.com', 0, '', '', 'us', 0, 3, '', '', 0, '', 0, 44600, 0, '', 1705151983, 0);
-- --------------------------------------------------------

--
-- Table structure for table `account_bans`
--

CREATE TABLE `account_bans` (
  `account_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `account_ban_history`
--

CREATE TABLE `account_ban_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expired_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `account_ban_history`
--

INSERT INTO `account_ban_history` (`id`, `account_id`, `reason`, `banned_at`, `expired_at`, `banned_by`) VALUES
(1, 35, '', 1712520818, 1713125618, 45);

-- --------------------------------------------------------

--
-- Table structure for table `account_storage`
--

CREATE TABLE `account_storage` (
  `account_id` int(11) NOT NULL,
  `key` int(10) UNSIGNED NOT NULL,
  `value` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `account_viplist`
--

CREATE TABLE `account_viplist` (
  `account_id` int(11) NOT NULL COMMENT 'id of account whose viplist entry it is',
  `player_id` int(11) NOT NULL COMMENT 'id of target player of viplist entry',
  `description` varchar(128) NOT NULL DEFAULT '',
  `icon` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `notify` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guilds`
--

CREATE TABLE `guilds` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `creationdata` int(11) NOT NULL,
  `motd` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `logo_name` varchar(255) NOT NULL DEFAULT 'default.gif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Triggers `guilds`
--
DELIMITER $$
CREATE TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds` FOR EACH ROW BEGIN
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('the Leader', 3, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('a Vice-Leader', 2, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('a Member', 1, NEW.`id`);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `guildwar_kills`
--

CREATE TABLE `guildwar_kills` (
  `id` int(11) NOT NULL,
  `killer` varchar(50) NOT NULL,
  `target` varchar(50) NOT NULL,
  `killerguild` int(11) NOT NULL DEFAULT 0,
  `targetguild` int(11) NOT NULL DEFAULT 0,
  `warid` int(11) NOT NULL DEFAULT 0,
  `time` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guild_invites`
--

CREATE TABLE `guild_invites` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `guild_id` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guild_membership`
--

CREATE TABLE `guild_membership` (
  `player_id` int(11) NOT NULL,
  `guild_id` int(11) NOT NULL,
  `rank_id` int(11) NOT NULL,
  `nick` varchar(15) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guild_ranks`
--

CREATE TABLE `guild_ranks` (
  `id` int(11) NOT NULL,
  `guild_id` int(11) NOT NULL COMMENT 'guild',
  `name` varchar(255) NOT NULL COMMENT 'rank name',
  `level` int(11) NOT NULL COMMENT 'rank level - leader, vice, member, maybe something else'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guild_wars`
--

CREATE TABLE `guild_wars` (
  `id` int(11) NOT NULL,
  `guild1` int(11) NOT NULL DEFAULT 0,
  `guild2` int(11) NOT NULL DEFAULT 0,
  `name1` varchar(255) NOT NULL,
  `name2` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0,
  `started` bigint(20) NOT NULL DEFAULT 0,
  `ended` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `houses`
--

CREATE TABLE `houses` (
  `id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `paid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `warnings` int(11) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `rent` int(11) NOT NULL DEFAULT 0,
  `town_id` int(11) NOT NULL DEFAULT 0,
  `bid` int(11) NOT NULL DEFAULT 0,
  `bid_end` int(11) NOT NULL DEFAULT 0,
  `last_bid` int(11) NOT NULL DEFAULT 0,
  `highest_bidder` int(11) NOT NULL DEFAULT 0,
  `size` int(11) NOT NULL DEFAULT 0,
  `beds` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `houses`
--

INSERT INTO `houses` (`id`, `owner`, `paid`, `warnings`, `name`, `rent`, `town_id`, `bid`, `bid_end`, `last_bid`, `highest_bidder`, `size`, `beds`) VALUES
(1042, 0, 0, 0, 'Unnamed House #1042', 0, 1, 0, 0, 0, 0, 41, 0),
(1043, 0, 0, 0, 'Unnamed House #1043', 0, 1, 0, 0, 0, 0, 48, 4),
(1044, 0, 0, 0, 'Unnamed House #1044', 0, 1, 0, 0, 0, 0, 109, 2),
(1045, 0, 0, 0, 'Unnamed House #1045', 0, 1, 0, 0, 0, 0, 36, 1),
(1046, 0, 0, 0, 'Unnamed House #1046', 0, 1, 0, 0, 0, 0, 28, 1),
(1047, 0, 0, 0, 'Unnamed House #1047', 0, 1, 0, 0, 0, 0, 27, 1),
(1048, 0, 0, 0, 'Unnamed House #1048', 0, 1, 0, 0, 0, 0, 95, 4),
(1049, 0, 0, 0, 'Unnamed House #1049', 0, 1, 0, 0, 0, 0, 40, 1),
(1051, 0, 0, 0, 'Unnamed House #1051', 0, 1, 0, 0, 0, 0, 46, 0);

-- --------------------------------------------------------

--
-- Table structure for table `house_lists`
--

CREATE TABLE `house_lists` (
  `house_id` int(11) NOT NULL,
  `listid` int(11) NOT NULL,
  `list` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ip_bans`
--

CREATE TABLE `ip_bans` (
  `ip` int(10) UNSIGNED NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `live_casts`
--

CREATE TABLE `live_casts` (
  `player_id` int(11) NOT NULL,
  `cast_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `spectators` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `market_history`
--

CREATE TABLE `market_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(4) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL,
  `price` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `expires_at` bigint(20) UNSIGNED NOT NULL,
  `inserted` bigint(20) UNSIGNED NOT NULL,
  `state` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `market_offers`
--

CREATE TABLE `market_offers` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(4) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL,
  `created` bigint(20) UNSIGNED NOT NULL,
  `anonymous` tinyint(4) NOT NULL DEFAULT 0,
  `price` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_account_actions`
--

CREATE TABLE `myaac_account_actions` (
  `account_id` int(11) NOT NULL,
  `ip` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ipv6` binary(16) NOT NULL DEFAULT '0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `date` int(11) NOT NULL DEFAULT 0,
  `action` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_account_actions`
--

INSERT INTO `myaac_account_actions` (`account_id`, `ip`, `ipv6`, `date`, `action`) VALUES
(2, 0, 0x00000000000000000000000000000001, 1707652842, 'Account created.'),
(2, 0, 0x00000000000000000000000000000001, 1707652842, 'Created character <b>Suka</b>.'),
(2, 0, 0x00000000000000000000000000000001, 1707653426, 'Created character <b>Chui</b>.'),
(4, 0, 0x00000000000000000000000000000001, 1710179709, 'Account created.');

-- --------------------------------------------------------

--
-- Table structure for table `myaac_admin_menu`
--

CREATE TABLE `myaac_admin_menu` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `page` varchar(255) NOT NULL DEFAULT '',
  `ordering` int(11) NOT NULL DEFAULT 0,
  `flags` int(11) NOT NULL DEFAULT 0,
  `enabled` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_bugtracker`
--

CREATE TABLE `myaac_bugtracker` (
  `account` varchar(255) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 0,
  `text` text NOT NULL,
  `id` int(11) NOT NULL DEFAULT 0,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `reply` int(11) NOT NULL DEFAULT 0,
  `who` int(11) NOT NULL DEFAULT 0,
  `uid` int(11) NOT NULL,
  `tag` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_changelog`
--

CREATE TABLE `myaac_changelog` (
  `id` int(11) NOT NULL,
  `body` varchar(500) NOT NULL DEFAULT '',
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 - added, 2 - removed, 3 - changed, 4 - fixed',
  `where` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 - server, 2 - site',
  `date` int(11) NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_changelog`
--

INSERT INTO `myaac_changelog` (`id`, `body`, `type`, `where`, `date`, `player_id`, `hidden`) VALUES
(1, 'MyAAC installed. (:', 3, 2, 1707652453, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_config`
--

CREATE TABLE `myaac_config` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `value` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_config`
--

INSERT INTO `myaac_config` (`id`, `name`, `value`) VALUES
(1, 'database_version', '33'),
(2, 'status_online', '1'),
(3, 'status_players', '0'),
(4, 'status_playersMax', '0'),
(5, 'status_lastCheck', '1711888115'),
(6, 'status_uptime', '23'),
(7, 'status_monsters', '1142'),
(8, 'views_counter', '30'),
(9, 'status_uptimeReadable', '0h 0m'),
(10, 'status_motd', 'Welcome to The Forgotten Server!'),
(11, 'status_mapAuthor', 'FlowerMagma'),
(12, 'status_mapName', 'world'),
(13, 'status_mapWidth', '64000'),
(14, 'status_mapHeight', '64000'),
(15, 'status_server', 'Lushland Oasis'),
(16, 'status_serverVersion', '1.0)'),
(17, 'status_clientVersion', '7.72'),
(18, 'last_usage_report', '1711888117');

-- --------------------------------------------------------

--
-- Table structure for table `myaac_faq`
--

CREATE TABLE `myaac_faq` (
  `id` int(11) NOT NULL,
  `question` varchar(255) NOT NULL DEFAULT '',
  `answer` varchar(1020) NOT NULL DEFAULT '',
  `ordering` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_forum`
--

CREATE TABLE `myaac_forum` (
  `id` int(11) NOT NULL,
  `first_post` int(11) NOT NULL DEFAULT 0,
  `last_post` int(11) NOT NULL DEFAULT 0,
  `section` int(11) NOT NULL DEFAULT 0,
  `replies` int(11) NOT NULL DEFAULT 0,
  `views` int(11) NOT NULL DEFAULT 0,
  `author_aid` int(11) NOT NULL DEFAULT 0,
  `author_guid` int(11) NOT NULL DEFAULT 0,
  `post_text` text NOT NULL,
  `post_topic` varchar(255) NOT NULL DEFAULT '',
  `post_smile` tinyint(1) NOT NULL DEFAULT 0,
  `post_html` tinyint(1) NOT NULL DEFAULT 0,
  `post_date` int(11) NOT NULL DEFAULT 0,
  `last_edit_aid` int(11) NOT NULL DEFAULT 0,
  `edit_date` int(11) NOT NULL DEFAULT 0,
  `post_ip` varchar(32) NOT NULL DEFAULT '0.0.0.0',
  `sticked` tinyint(1) NOT NULL DEFAULT 0,
  `closed` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_forum_boards`
--

CREATE TABLE `myaac_forum_boards` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `ordering` int(11) NOT NULL DEFAULT 0,
  `guild` int(11) NOT NULL DEFAULT 0,
  `access` int(11) NOT NULL DEFAULT 0,
  `closed` tinyint(1) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_forum_boards`
--

INSERT INTO `myaac_forum_boards` (`id`, `name`, `description`, `ordering`, `guild`, `access`, `closed`, `hidden`) VALUES
(1, 'News', 'News commenting', 0, 0, 0, 1, 0),
(2, 'Trade', 'Trade offers.', 1, 0, 0, 0, 0),
(3, 'Quests', 'Quest making.', 2, 0, 0, 0, 0),
(4, 'Pictures', 'Your pictures.', 3, 0, 0, 0, 0),
(5, 'Bug Report', 'Report bugs there.', 4, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_gallery`
--

CREATE TABLE `myaac_gallery` (
  `id` int(11) NOT NULL,
  `comment` varchar(255) NOT NULL DEFAULT '',
  `image` varchar(255) NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `author` varchar(50) NOT NULL DEFAULT '',
  `ordering` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_gallery`
--

INSERT INTO `myaac_gallery` (`id`, `comment`, `image`, `thumb`, `author`, `ordering`, `hidden`) VALUES
(1, 'Demon', 'images/gallery/demon.jpg', 'images/gallery/demon_thumb.gif', 'MyAAC', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_menu`
--

CREATE TABLE `myaac_menu` (
  `id` int(11) NOT NULL,
  `template` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `blank` tinyint(1) NOT NULL DEFAULT 0,
  `color` varchar(6) NOT NULL DEFAULT '',
  `category` int(11) NOT NULL DEFAULT 1,
  `ordering` int(11) NOT NULL DEFAULT 0,
  `enabled` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_menu`
--

INSERT INTO `myaac_menu` (`id`, `template`, `name`, `link`, `blank`, `color`, `category`, `ordering`, `enabled`) VALUES
(1, 'kathrine', 'Latest News', 'news', 0, '', 1, 0, 1),
(2, 'kathrine', 'News Archive', 'news/archive', 0, '', 1, 1, 1),
(3, 'kathrine', 'Changelog', 'changelog', 0, '', 1, 2, 1),
(4, 'kathrine', 'Account Management', 'account/manage', 0, '', 2, 0, 1),
(5, 'kathrine', 'Create Account', 'account/create', 0, '', 2, 1, 1),
(6, 'kathrine', 'Lost Account?', 'account/lost', 0, '', 2, 2, 1),
(7, 'kathrine', 'Server Rules', 'rules', 0, '', 2, 3, 1),
(8, 'kathrine', 'Downloads', 'downloads', 0, '', 5, 4, 1),
(9, 'kathrine', 'Report Bug', 'bugtracker', 0, '', 2, 5, 1),
(10, 'kathrine', 'Who is Online?', 'online', 0, '', 3, 0, 1),
(11, 'kathrine', 'Characters', 'characters', 0, '', 3, 1, 1),
(12, 'kathrine', 'Guilds', 'guilds', 0, '', 3, 2, 1),
(13, 'kathrine', 'Highscores', 'highscores', 0, '', 3, 3, 1),
(14, 'kathrine', 'Last Deaths', 'lastkills', 0, '', 3, 4, 1),
(15, 'kathrine', 'Houses', 'houses', 0, '', 3, 5, 1),
(16, 'kathrine', 'Bans', 'bans', 0, '', 3, 6, 1),
(17, 'kathrine', 'Forum', 'forum', 0, '', 3, 7, 1),
(18, 'kathrine', 'Team', 'team', 0, '', 3, 8, 1),
(19, 'kathrine', 'Monsters', 'creatures', 0, '', 5, 0, 1),
(20, 'kathrine', 'Spells', 'spells', 0, '', 5, 1, 1),
(21, 'kathrine', 'Server Info', 'serverInfo', 0, '', 5, 2, 1),
(22, 'kathrine', 'Commands', 'commands', 0, '', 5, 3, 1),
(23, 'kathrine', 'Gallery', 'gallery', 0, '', 5, 4, 1),
(24, 'kathrine', 'Experience Table', 'experienceTable', 0, '', 5, 5, 1),
(25, 'kathrine', 'FAQ', 'faq', 0, '', 5, 6, 1),
(26, 'kathrine', 'Buy Points', 'points', 0, '', 6, 0, 1),
(27, 'kathrine', 'Shop Offer', 'gifts', 0, '', 6, 1, 1),
(28, 'kathrine', 'Shop History', 'gifts/history', 0, '', 6, 2, 1),
(29, 'tibiacom', 'Latest News', 'news', 0, '', 1, 0, 1),
(30, 'tibiacom', 'News Archive', 'news/archive', 0, '', 1, 1, 1),
(31, 'tibiacom', 'Changelog', 'changelog', 0, '', 1, 2, 1),
(32, 'tibiacom', 'Account Management', 'account/manage', 0, '', 2, 0, 1),
(33, 'tibiacom', 'Create Account', 'account/create', 0, '', 2, 1, 1),
(34, 'tibiacom', 'Lost Account?', 'account/lost', 0, '', 2, 2, 1),
(35, 'tibiacom', 'Server Rules', 'rules', 0, '', 2, 3, 1),
(36, 'tibiacom', 'Downloads', 'downloads', 0, '', 2, 4, 1),
(37, 'tibiacom', 'Report Bug', 'bugtracker', 0, '', 2, 5, 1),
(38, 'tibiacom', 'Characters', 'characters', 0, '', 3, 0, 1),
(39, 'tibiacom', 'Who Is Online?', 'online', 0, '', 3, 1, 1),
(40, 'tibiacom', 'Highscores', 'highscores', 0, '', 3, 2, 1),
(41, 'tibiacom', 'Last Kills', 'lastkills', 0, '', 3, 3, 1),
(42, 'tibiacom', 'Houses', 'houses', 0, '', 3, 4, 1),
(43, 'tibiacom', 'Guilds', 'guilds', 0, '', 3, 5, 1),
(44, 'tibiacom', 'Polls', 'polls', 0, '', 3, 6, 1),
(45, 'tibiacom', 'Bans', 'bans', 0, '', 3, 7, 1),
(46, 'tibiacom', 'Support List', 'team', 0, '', 3, 8, 1),
(47, 'tibiacom', 'Forum', 'forum', 0, '', 4, 0, 1),
(48, 'tibiacom', 'Creatures', 'creatures', 0, '', 5, 0, 1),
(49, 'tibiacom', 'Spells', 'spells', 0, '', 5, 1, 1),
(50, 'tibiacom', 'Commands', 'commands', 0, '', 5, 2, 1),
(51, 'tibiacom', 'Exp Stages', 'experienceStages', 0, '', 5, 3, 1),
(52, 'tibiacom', 'Gallery', 'gallery', 0, '', 5, 4, 1),
(53, 'tibiacom', 'Server Info', 'serverInfo', 0, '', 5, 5, 1),
(54, 'tibiacom', 'Experience Table', 'experienceTable', 0, '', 5, 6, 1),
(55, 'tibiacom', 'Buy Points', 'points', 0, '', 6, 0, 1),
(56, 'tibiacom', 'Shop Offer', 'gifts', 0, '', 6, 1, 1),
(57, 'tibiacom', 'Shop History', 'gifts/history', 0, '', 6, 2, 1),
(58, 'emma', 'Latest News', 'news', 0, '', 1, 0, 1),
(59, 'emma', 'News Archive', 'news/archive', 0, '', 1, 1, 1),
(60, 'emma', 'Account Management', 'account/manage', 0, '', 2, 0, 1),
(61, 'emma', 'Create Account', 'account/create', 0, '', 2, 1, 1),
(62, 'emma', 'Lost Account?', 'account/lost', 0, '', 2, 2, 1),
(63, 'emma', 'Server Rules', 'rules', 0, '', 2, 3, 1),
(64, 'emma', 'Downloads', 'downloads', 0, '', 2, 4, 1),
(65, 'emma', 'Report Bug', 'bugtracker', 0, '', 2, 5, 1),
(66, 'emma', 'Characters', 'characters', 0, '', 3, 0, 1),
(67, 'emma', 'Who is online', 'online', 0, '', 3, 1, 1),
(68, 'emma', 'Highscores', 'highscores', 0, '', 3, 2, 1),
(69, 'emma', 'Last Kills', 'lastkills', 0, '', 3, 3, 1),
(70, 'emma', 'Houses', 'houses', 0, '', 3, 4, 1),
(71, 'emma', 'Guilds', 'guilds', 0, '', 3, 5, 1),
(72, 'emma', 'Bans', 'bans', 0, '', 3, 6, 1),
(73, 'emma', 'Support List', 'team', 0, '', 3, 7, 1),
(74, 'emma', 'Forum', 'forum', 0, '', 3, 8, 1),
(75, 'emma', 'Monsters', 'creatures', 0, '', 5, 0, 1),
(76, 'emma', 'Spells', 'spells', 0, '', 5, 1, 1),
(77, 'emma', 'Commands', 'commands', 0, '', 5, 2, 1),
(78, 'emma', 'Server Info', 'serverInfo', 0, '', 5, 3, 1),
(79, 'emma', 'Gallery', 'gallery', 0, '', 5, 4, 1),
(80, 'emma', 'Experience Table', 'experienceTable', 0, '', 5, 5, 1),
(81, 'emma', 'Experience Stages', 'experienceStages', 0, '', 5, 6, 1),
(82, 'emma', 'FAQ', 'faq', 0, '', 5, 7, 1),
(83, 'emma', 'Buy Points', 'points', 0, '', 6, 0, 1),
(84, 'emma', 'Shop Offer', 'gifts', 0, '', 6, 1, 1),
(85, 'emma', 'Shop History', 'gifts/history', 0, '', 6, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_monsters`
--

CREATE TABLE `myaac_monsters` (
  `id` int(11) NOT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `mana` int(11) NOT NULL DEFAULT 0,
  `exp` int(11) NOT NULL,
  `health` int(11) NOT NULL,
  `speed_lvl` int(11) NOT NULL DEFAULT 1,
  `use_haste` tinyint(1) NOT NULL,
  `voices` text NOT NULL,
  `immunities` varchar(255) NOT NULL,
  `summonable` tinyint(1) NOT NULL,
  `convinceable` tinyint(1) NOT NULL,
  `race` varchar(255) NOT NULL,
  `loot` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_monsters`
--

INSERT INTO `myaac_monsters` (`id`, `hidden`, `name`, `mana`, `exp`, `health`, `speed_lvl`, `use_haste`, `voices`, `immunities`, `summonable`, `convinceable`, `race`, `loot`) VALUES
(1, 0, 'amazon', 390, 60, 110, 1, 0, '[\"Yeee ha!\",\"Your head will be mine!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2691\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"40000\"},{\"id\":\"2229\",\"count\":\"2\",\"chance\":\"80000\"},{\"id\":\"2147\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2125\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"80000\"},{\"id\":\"2385\",\"count\":1,\"chance\":\"23000\"},{\"id\":\"2526\",\"count\":1,\"chance\":\"5000\"}]'),
(2, 0, 'ancient scarab', 0, 720, 1000, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'venom', '[{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"44400\"},{\"id\":\"2148\",\"count\":\"66\",\"chance\":\"75700\"},{\"id\":\"2148\",\"count\":\"22\",\"chance\":\"99900\"},{\"id\":\"2150\",\"count\":\"4\",\"chance\":\"1200\"},{\"id\":\"2149\",\"count\":\"3\",\"chance\":\"600\"},{\"id\":\"2159\",\"count\":\"2\",\"chance\":\"5000\"},{\"id\":\"2159\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2135\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2142\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2162\",\"count\":1,\"chance\":\"10900\"},{\"id\":\"2440\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2540\",\"count\":1,\"chance\":\"500\"}]'),
(3, 0, 'assassin', 450, 105, 175, 2, 0, '[\"Die!\",\"Feel the hand of death!\",\"You are on my deathlist!\"]', '[\"invisible\"]', 0, 1, 'blood', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"15000\"},{\"id\":\"2148\",\"count\":\"40\",\"chance\":\"80000\"},{\"id\":\"2145\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"3969\",\"count\":1,\"chance\":\"200\"},{\"id\":\"3968\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2403\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2404\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2510\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"1000\"}]'),
(4, 0, 'badger', 200, 5, 23, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2666\",\"count\":1,\"chance\":\"40000\"}]'),
(5, 0, 'bandit', 450, 65, 245, 1, 0, '[\"Your money or your life!\",\"Hand me your purse!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"15000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2459\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2391\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2386\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2511\",\"count\":1,\"chance\":\"17000\"}]'),
(6, 0, 'banshee', 0, 900, 1000, 1, 0, '[\"Are you ready to rock?\",\"That\'s what I call easy listening!\",\"Let the music play!\",\"I will mourn your death!\",\"IIIIEEEeeeeeehhhHHHHH!\",\"Dance for me your dance of death!\",\"Feel my gentle kiss of death.\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"30000\"},{\"id\":\"2143\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2144\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2121\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2071\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2560\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2134\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2657\",\"count\":1,\"chance\":\"60000\"},{\"id\":\"2237\",\"count\":1,\"chance\":\"19900\"},{\"id\":\"2656\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2655\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2047\",\"count\":1,\"chance\":\"70000\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2197\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2170\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"500\"}]'),
(7, 0, 'bat', 250, 10, 30, 1, 0, '[\"Flap! Flap!\"]', '[]', 1, 1, 'blood', '[]'),
(8, 0, 'bear', 300, 23, 80, 1, 0, '[\"Grrrr\",\"Groar\"]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"40000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(9, 0, 'behemoth', 0, 2500, 4000, 60, 0, '[\"You\'re so little!\",\"Human flesh - delicious!\",\"Crush the intruders!\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2666\",\"count\":\"6\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"60\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"50000\"},{\"id\":\"2150\",\"count\":\"2\",\"chance\":\"4000\"},{\"id\":\"2231\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2553\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2023\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2125\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2489\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2645\",\"count\":1,\"chance\":\"400\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2393\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2416\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2174\",\"count\":1,\"chance\":\"800\"}]'),
(10, 0, 'beholder', 0, 170, 260, 1, 0, '[\"Eye for eye!\",\"Here\'s looking at you!\",\"Let me take a look at you!\",\"You\'ve got the look!\"]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"16\",\"chance\":\"80000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2181\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2518\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"5000\"}]'),
(11, 0, 'black knight', 0, 1600, 1800, 85, 0, '[\"By Bolg\'s Blood!\",\"You\'re no match for me!\",\"NO MERCY!\",\"NO PRISONERS!\",\"MINE!\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2691\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"60\",\"chance\":\"33300\"},{\"id\":\"2148\",\"count\":\"90\",\"chance\":\"22200\"},{\"id\":\"2120\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2133\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2490\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2489\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2475\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2476\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2477\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2381\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2417\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2414\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2430\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"10000\"}]'),
(12, 0, 'black sheep', 250, 0, 20, 1, 0, '[\"Maeh\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(13, 0, 'blue djinn', 0, 190, 330, 1, 0, '[\"Simsalabim\",\"Feel the power of my magic, tiny mortal!\",\"Be careful what you wish for.\",\"Wishes can come true.\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2684\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"70000\"},{\"id\":\"2146\",\"count\":\"4\",\"chance\":\"2500\"},{\"id\":\"2063\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2745\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"1978\",\"count\":1,\"chance\":\"2500\"}]'),
(14, 0, 'bonebeast', 0, 580, 515, 1, 0, '[\"Cccchhhhhhhhh!\",\"Knooorrrrr!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2796\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2148\",\"count\":\"90\",\"chance\":\"30000\"},{\"id\":\"2231\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2229\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2449\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2541\",\"count\":1,\"chance\":\"2000\"}]'),
(15, 0, 'bug', 250, 18, 29, 1, 0, '[]', '[]', 1, 1, 'venom', '[{\"id\":\"2148\",\"count\":\"6\",\"chance\":\"35000\"},{\"id\":\"2679\",\"count\":\"3\",\"chance\":\"3000\"}]'),
(16, 0, 'butterfly', 0, 0, 2, 50, 0, '[]', '[]', 0, 0, 'venom', '[]'),
(17, 0, 'carniphila', 490, 150, 255, 1, 0, '[]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'venom', '[{\"id\":\"2671\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"70000\"},{\"id\":\"2792\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"40000\"},{\"id\":\"2804\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"500\"}]'),
(18, 0, 'cave rat', 250, 10, 30, 1, 0, '[\"Meep!\",\"Meeeeep!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"3\",\"chance\":\"50000\"},{\"id\":\"2687\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2696\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"2\",\"chance\":\"85000\"}]'),
(19, 0, 'centipede', 335, 30, 70, 1, 0, '[]', '[]', 1, 1, 'venom', '[{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"80000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"4500\"}]'),
(20, 0, 'chicken', 220, 0, 15, 1, 0, '[\"Gokgoooook\",\"Cluck Cluck\"]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2695\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"2000\"}]'),
(21, 0, 'cobra', 275, 30, 65, 1, 0, '[\"Zzzzzz\"]', '[]', 1, 1, 'blood', '[]'),
(22, 0, 'crab', 305, 30, 55, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2667\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"}]'),
(23, 0, 'crocodile', 350, 40, 105, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"40000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"50000\"},{\"id\":\"3982\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"8000\"}]'),
(24, 0, 'crypt shambler', 580, 195, 330, 1, 0, '[\"Uhhhhhhh!\",\"Aaaaahhhh!\",\"Hoooohhh!\",\"Chhhhhhh!\"]', '[\"lifedrain\",\"paralyze\"]', 0, 1, 'undead', '[{\"id\":\"3976\",\"count\":\"10\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"40000\"},{\"id\":\"2145\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2399\",\"count\":\"3\",\"chance\":\"1000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2227\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2459\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2450\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2541\",\"count\":1,\"chance\":\"1000\"}]'),
(25, 0, 'cyclops', 490, 150, 260, 1, 0, '[\"Il lorstok human!\",\"Toks utat.\",\"Human, uh whil dyh!\",\"Youh ah trak!\",\"Let da mashing begin!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2666\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"2490\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2381\",\"count\":1,\"chance\":\"700\"},{\"id\":\"2510\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2209\",\"count\":1,\"chance\":\"100\"}]'),
(26, 0, 'dark monk', 480, 145, 190, 5, 0, '[\"This is where your path will end!\",\"Your end has come.\",\"You are no match for us!\"]', '[\"invisible\"]', 0, 1, 'blood', '[{\"id\":\"2689\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"18\",\"chance\":\"15000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2193\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2015\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1949\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2044\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"100\"}]'),
(27, 0, 'deer', 260, 0, 25, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":1,\"chance\":\"45000\"},{\"id\":\"2666\",\"count\":\"3\",\"chance\":\"80000\"}]'),
(28, 0, 'demon skeleton', 620, 240, 400, 1, 0, '[]', '[\"lifedrain\",\"paralyze\"]', 1, 1, 'undead', '[{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"30000\"},{\"id\":\"2399\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2194\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2178\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2459\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2417\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2515\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"100\"}]'),
(29, 0, 'demon', 0, 6000, 8200, 10, 0, '[\"MUHAHAHAHA!\",\"I SMELL FEEEEEAAAR!\",\"CHAMEK ATH UTHUL ARAK!\",\"Your resistance is futile!\",\"Your soul will be mine!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'fire', '[{\"id\":\"2795\",\"count\":\"6\",\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"50000\"},{\"id\":\"2151\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2149\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2176\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"1982\",\"count\":1,\"chance\":\"1300\"},{\"id\":\"2179\",\"count\":1,\"chance\":\"1100\"},{\"id\":\"2171\",\"count\":1,\"chance\":\"700\"},{\"id\":\"2462\",\"count\":1,\"chance\":\"1200\"},{\"id\":\"2470\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2472\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2432\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2393\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2396\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2418\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2520\",\"count\":1,\"chance\":\"700\"},{\"id\":\"2514\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2164\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2165\",\"count\":1,\"chance\":\"1400\"}]'),
(30, 0, 'dog', 220, 0, 20, 1, 0, '[\"Wuff wuff\"]', '[]', 1, 1, 'blood', '[]'),
(31, 0, 'dragon lord', 0, 2100, 1900, 1, 0, '[\"ZCHHHHH\",\"YOU WILL BURN!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2672\",\"count\":\"5\",\"chance\":\"60000\"},{\"id\":\"2796\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"60000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2547\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"600\"},{\"id\":\"1976\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2033\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2479\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2492\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2498\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2392\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2528\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"5000\"}]'),
(32, 0, 'dragon', 0, 700, 1000, 1, 0, '[\"GROOAAARRR\",\"FCHHHHH\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2672\",\"count\":\"3\",\"chance\":\"45000\"},{\"id\":\"2148\",\"count\":\"45\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"60\",\"chance\":\"50000\"},{\"id\":\"2145\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2546\",\"count\":\"10\",\"chance\":\"16000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2647\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2455\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2413\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2434\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2409\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2187\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2516\",\"count\":1,\"chance\":\"300\"}]'),
(33, 0, 'dwarf geomancer', 0, 245, 380, 1, 0, '[\"Hail Durin!\",\"Earth is the strongest element.\",\"Dust to dust.\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2673\",\"count\":\"2\",\"chance\":\"18000\"},{\"id\":\"2787\",\"count\":\"2\",\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"70000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2481\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2468\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2162\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2423\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2213\",\"count\":1,\"chance\":\"300\"}]'),
(34, 0, 'dwarf guard', 650, 165, 245, 1, 0, '[\"Hail Durin!\"]', '[\"invisible\"]', 1, 1, 'blood', '[{\"id\":\"2787\",\"count\":\"2\",\"chance\":\"55000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"50000\"},{\"id\":\"2150\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2417\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2208\",\"count\":1,\"chance\":\"200\"}]'),
(35, 0, 'dwarf soldier', 360, 70, 135, 1, 0, '[\"Hail Durin!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2787\",\"count\":\"2\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"35000\"},{\"id\":\"2543\",\"count\":\"4\",\"chance\":\"40000\"},{\"id\":\"2554\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2481\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2378\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2525\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2455\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2208\",\"count\":1,\"chance\":\"100\"}]'),
(36, 0, 'dwarf', 320, 45, 90, 1, 0, '[\"Hail Durin!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2787\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"8\",\"chance\":\"45000\"},{\"id\":\"2597\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2553\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2484\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2388\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2386\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2530\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2213\",\"count\":1,\"chance\":\"100\"}]'),
(37, 0, 'dworc fleshhunter', 300, 35, 85, 1, 0, '[\"Grak brrretz!\",\"Grow truk grrrrr.\",\"Prek tars, dekklep zurk.\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"},{\"id\":\"2229\",\"count\":\"3\",\"chance\":\"3000\"},{\"id\":\"2568\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"22000\"},{\"id\":\"3967\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"3964\",\"count\":1,\"chance\":\"100\"},{\"id\":\"3965\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2541\",\"count\":1,\"chance\":\"1000\"}]'),
(38, 0, 'dworc venomsniper', 300, 30, 80, 1, 0, '[\"Grak brrretz!\",\"Grow truk grrrrr.\",\"Prek tars, dekklep zurk.\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"},{\"id\":\"2229\",\"count\":\"2\",\"chance\":\"1000\"},{\"id\":\"2545\",\"count\":\"3\",\"chance\":\"5000\"},{\"id\":\"2410\",\"count\":\"2\",\"chance\":\"8000\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"3967\",\"count\":1,\"chance\":\"500\"},{\"id\":\"3983\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2172\",\"count\":1,\"chance\":\"100\"}]'),
(39, 0, 'dworc voodoomaster', 300, 50, 80, 1, 0, '[\"Grak brrretz!\",\"Grow truk grrrrr.\",\"Prek tars, dekklep zurk.\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"},{\"id\":\"2229\",\"count\":\"3\",\"chance\":\"3000\"},{\"id\":\"2231\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"3955\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"3967\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2174\",\"count\":1,\"chance\":\"500\"}]'),
(40, 0, 'efreet', 0, 300, 550, 7, 0, '[\"I grant you a deathwish!\",\"Muhahahaha!\",\"I wish you a merry trip to hell!\",\"Tell me your last wish!\",\"Good wishes are for fairytales\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2673\",\"count\":\"12\",\"chance\":\"25000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"50000\"},{\"id\":\"2149\",\"count\":\"2\",\"chance\":\"7000\"},{\"id\":\"2155\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1860\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2359\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2442\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2187\",\"count\":1,\"chance\":\"500\"}]'),
(41, 0, 'elder beholder', 0, 280, 500, 1, 0, '[\"653768764!\",\"Let me take a look at you!\",\"Inferior creatures, bow before my power!\",\"659978 54764!\"]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"24\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"32\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"35\",\"chance\":\"70000\"},{\"id\":\"3972\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2518\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"1000\"}]'),
(42, 0, 'elephant', 500, 160, 320, 1, 0, '[\"Hooooot-Toooooot!\",\"Tooooot.\",\"Troooooot!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"3\",\"chance\":\"60000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"90000\"},{\"id\":\"3956\",\"count\":\"2\",\"chance\":\"1000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"3973\",\"count\":1,\"chance\":\"100\"}]'),
(43, 0, 'elf arcanist', 0, 175, 220, 1, 0, '[\"Feel my wrath!\",\"For the Daughter of the Stars!\",\"I\'ll bring balance upon you!\",\"Tha\'shi Cenath!\",\"Vihil Ealuel!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2682\",\"count\":1,\"chance\":\"22000\"},{\"id\":\"2689\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2544\",\"count\":\"3\",\"chance\":\"6000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2600\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1949\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2032\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2154\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"26000\"},{\"id\":\"2652\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2047\",\"count\":1,\"chance\":\"22000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2189\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2198\",\"count\":1,\"chance\":\"2000\"}]'),
(44, 0, 'elf scout', 360, 75, 160, 1, 0, '[\"Tha\'shi Ab\'Dendriel!\",\"Feel the sting of my arrows!\",\"Thy blood will quench the soil\'s thirst!\",\"Evicor guide my arrow.\",\"Your existence will end here!\"]', '[\"invisible\"]', 1, 1, 'blood', '[{\"id\":\"2681\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2148\",\"count\":\"5\",\"chance\":\"30000\"},{\"id\":\"2544\",\"count\":\"12\",\"chance\":\"30000\"},{\"id\":\"2545\",\"count\":\"3\",\"chance\":\"15000\"},{\"id\":\"2031\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2482\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2484\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2456\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"6000\"}]'),
(45, 0, 'elf', 320, 42, 100, 1, 0, '[\"Ulathil beia Thratha!\",\"Bahaha aka!\",\"You are not welcome here.\",\"Flee as long as you can.\",\"Death to the defilers!\"]', '[\"invisible\"]', 1, 1, 'blood', '[{\"id\":\"2674\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2544\",\"count\":\"3\",\"chance\":\"7000\"},{\"id\":\"2482\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2484\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2511\",\"count\":1,\"chance\":\"13000\"}]'),
(46, 0, 'fire devil', 530, 110, 200, 1, 0, '[\"Hot, eh?\",\"Hell, oh hell!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2150\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2548\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2568\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2419\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2185\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2515\",\"count\":1,\"chance\":\"200\"}]'),
(47, 0, 'fire elemental', 690, 220, 280, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 1, 1, 'fire', '[]'),
(48, 0, 'flamingo', 250, 0, 25, 1, 0, '[]', '[]', 1, 1, 'blood', '[]'),
(49, 0, 'frost troll', 300, 23, 55, 1, 0, '[\"Brrrr\",\"Broar!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2667\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"50000\"},{\"id\":\"2245\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2651\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2384\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2382\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"15000\"}]'),
(50, 0, 'gargoyle', 0, 150, 250, 1, 0, '[\"Harrrr Harrrr!\",\"Stone sweet stone.\",\"Feel my claws, softskin.\",\"Chhhhhrrrrk!\",\"There is a stone in your shoe!\"]', '[\"lifedrain\"]', 0, 0, 'undead', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2666\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"1294\",\"count\":\"10\",\"chance\":\"10000\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2489\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2448\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2209\",\"count\":1,\"chance\":\"100\"}]'),
(51, 0, 'gazer', 0, 90, 120, 1, 0, '[\"Mommy!?\",\"Buuuuhaaaahhaaaaa!\",\"Me need mana!\"]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2148\",\"count\":\"6\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"8\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"}]'),
(52, 0, 'ghost', 0, 120, 150, 1, 0, '[\"Huh!\",\"Shhhhhh\",\"Buuuuuh\"]', '[\"lifedrain\",\"paralyze\"]', 0, 0, 'undead', '[{\"id\":\"2654\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2804\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2404\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2532\",\"count\":1,\"chance\":\"800\"},{\"id\":\"1977\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2165\",\"count\":1,\"chance\":\"200\"}]'),
(53, 0, 'ghoul', 450, 85, 100, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"6\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"75000\"},{\"id\":\"2229\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2460\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2473\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"60000\"},{\"id\":\"2403\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2168\",\"count\":1,\"chance\":\"200\"}]'),
(54, 0, 'giant spider', 0, 900, 1300, 10, 0, '[]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'venom', '[{\"id\":\"2148\",\"count\":\"55\",\"chance\":\"33300\"},{\"id\":\"2148\",\"count\":\"11\",\"chance\":\"99900\"},{\"id\":\"2148\",\"count\":\"33\",\"chance\":\"66600\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2477\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2476\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2171\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2169\",\"count\":1,\"chance\":\"700\"}]'),
(55, 0, 'goblin', 290, 25, 50, 1, 0, '[\"Me have him!\",\"Zig Zag! Gobo attack!\",\"Help! Goblinkiller!\",\"Bugga! Bugga!\",\"Me green, me mean!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2667\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2148\",\"count\":\"9\",\"chance\":\"50000\"},{\"id\":\"1294\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2235\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2559\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2449\",\"count\":1,\"chance\":\"5000\"}]'),
(56, 0, 'green djinn', 0, 190, 330, 1, 0, '[\"I grant you a deathwish!\",\"Muhahahaha!\",\"I wish you a merry trip to hell!\",\"Tell me your last wish!\",\"Good wishes are for fairytales\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2696\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"35000\"},{\"id\":\"2149\",\"count\":\"4\",\"chance\":\"2700\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2359\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"1980\",\"count\":1,\"chance\":\"2500\"}]'),
(57, 0, 'hero', 0, 1200, 1400, 30, 0, '[\"Let\'s have a fight!\",\"Welcome to my battleground.\",\"Have you seen princess Lumelia?\",\"I will sing a tune at your grave.\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"18000\"},{\"id\":\"2681\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"60000\"},{\"id\":\"2544\",\"count\":\"13\",\"chance\":\"27000\"},{\"id\":\"1949\",\"count\":1,\"chance\":\"45000\"},{\"id\":\"2744\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2071\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2121\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2120\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2661\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2652\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2491\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2487\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2488\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2456\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2392\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2391\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2519\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2164\",\"count\":1,\"chance\":\"500\"}]'),
(58, 0, 'hunter', 530, 150, 150, 1, 0, '[\"Guess who we are hunting, hahaha!\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2675\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2690\",\"count\":\"2\",\"chance\":\"11000\"},{\"id\":\"2147\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2544\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2544\",\"count\":\"12\",\"chance\":\"40000\"},{\"id\":\"2546\",\"count\":\"3\",\"chance\":\"5000\"},{\"id\":\"2460\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2456\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2201\",\"count\":1,\"chance\":\"3000\"}]'),
(59, 0, 'hyaena', 275, 20, 60, 1, 0, '[\"Grrrrrr\",\"Hou hou hou!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"3\",\"chance\":\"50000\"},{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"50000\"}]'),
(60, 0, 'hydra', 0, 2100, 2250, 1, 0, '[\"FCHHHHH\",\"HISSSS\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2671\",\"count\":\"3\",\"chance\":\"60000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"80000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"4850\",\"count\":1,\"chance\":\"900\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2476\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2475\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2498\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2536\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2197\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"1200\"}]'),
(61, 0, 'kongra', 0, 110, 340, 1, 0, '[\"Hugah!\",\"Ungh! Ungh!\",\"Huaauaauaauaa!\"]', '[]', 0, 0, 'blood', '[{\"id\":\"2676\",\"count\":\"2\",\"chance\":\"30000\"},{\"id\":\"2676\",\"count\":\"10\",\"chance\":\"5000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"80000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2200\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2209\",\"count\":1,\"chance\":\"200\"}]'),
(62, 0, 'larva', 355, 44, 70, 1, 0, '[]', '[\"paralyze\"]', 1, 1, 'venom', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"35000\"}]'),
(63, 0, 'lich', 0, 900, 880, 1, 0, '[\"Death awaits all!\",\"Doomed be the living!\",\"Death and Decay!\",\"You will endure agony beyond thy death!\",\"Come to me my children!\",\"Pain sweet pain!\",\"Thy living flesh offends me!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"40\",\"chance\":\"40000\"},{\"id\":\"2144\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2143\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2178\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2237\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2479\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2656\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2171\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"60000\"},{\"id\":\"2535\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"1000\"}]'),
(64, 0, 'lion', 320, 30, 80, 1, 0, '[\"Groarrr!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2666\",\"count\":\"3\",\"chance\":\"45000\"}]'),
(65, 0, 'lizard sentinel', 560, 105, 265, 1, 0, '[\"Tssss!\"]', '[\"invisible\"]', 0, 1, 'blood', '[{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"80000\"},{\"id\":\"2145\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2425\",\"count\":1,\"chance\":\"1200\"},{\"id\":\"2381\",\"count\":1,\"chance\":\"500\"},{\"id\":\"3974\",\"count\":1,\"chance\":\"300\"}]'),
(66, 0, 'lizard snakecharmer', 0, 210, 325, 1, 0, '[\"Shhhhhhhh.\",\"I ssssmell warm blood!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"80000\"},{\"id\":\"2150\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2154\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2817\",\"count\":1,\"chance\":\"70000\"},{\"id\":\"2237\",\"count\":1,\"chance\":\"19900\"},{\"id\":\"2654\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"3971\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2182\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2181\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2168\",\"count\":1,\"chance\":\"200\"}]'),
(67, 0, 'lizard templar', 0, 145, 410, 1, 0, '[\"Hissss!\"]', '[]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"80000\"},{\"id\":\"2149\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"700\"},{\"id\":\"3963\",\"count\":1,\"chance\":\"500\"},{\"id\":\"3975\",\"count\":1,\"chance\":\"100\"}]'),
(68, 0, 'marid', 0, 300, 550, 7, 0, '[\"Simsalabim\",\"Feel the power of my magic, tiny mortal!\",\"Be careful what you wish for.\",\"Wishes can come true.\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2677\",\"count\":\"25\",\"chance\":\"25000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"70000\"},{\"id\":\"2146\",\"count\":\"2\",\"chance\":\"7000\"},{\"id\":\"2158\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1872\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2070\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2359\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2442\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2183\",\"count\":1,\"chance\":\"500\"}]'),
(69, 0, 'merlkin', 0, 135, 230, 1, 0, '[\"Ugh! Ugh! Ugh!\",\"Holy banana!\",\"Chakka! Chakka!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2676\",\"count\":\"2\",\"chance\":\"30000\"},{\"id\":\"2676\",\"count\":\"10\",\"chance\":\"5000\"},{\"id\":\"2675\",\"count\":\"5\",\"chance\":\"1000\"},{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"80000\"},{\"id\":\"2150\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2188\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"3966\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2162\",\"count\":1,\"chance\":\"5000\"}]'),
(70, 0, 'minotaur archer', 390, 65, 100, 1, 0, '[\"Ruan Wihmpy!\",\"Kaplar!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"15000\"},{\"id\":\"2543\",\"count\":\"15\",\"chance\":\"50000\"},{\"id\":\"2543\",\"count\":\"5\",\"chance\":\"80000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2481\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2455\",\"count\":1,\"chance\":\"10000\"}]'),
(71, 0, 'minotaur guard', 550, 160, 185, 1, 0, '[\"Kirll Karrrl!\",\"Kaplar!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"60000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2648\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2388\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2580\",\"count\":1,\"chance\":\"5000\"}]'),
(72, 0, 'minotaur mage', 0, 150, 155, 1, 0, '[\"Learrn tha secrret uf deathhh!\",\"Kaplar!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2684\",\"count\":\"7\",\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"},{\"id\":\"2817\",\"count\":1,\"chance\":\"70000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2648\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2404\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2403\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2189\",\"count\":1,\"chance\":\"500\"}]'),
(73, 0, 'minotaur', 330, 50, 100, 1, 0, '[\"Kaplar!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"55000\"},{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"25000\"},{\"id\":\"2554\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2460\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2386\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2510\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2172\",\"count\":1,\"chance\":\"100\"}]'),
(74, 0, 'monk', 600, 200, 240, 10, 0, '[\"I will punish the sinners!\",\"A prayer to the almighty one.\",\"Repent Heretic!\"]', '[\"invisible\"]', 1, 0, 'blood', '[{\"id\":\"2689\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"18\",\"chance\":\"15000\"},{\"id\":\"2193\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"1949\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2015\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2467\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2044\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"100\"}]'),
(75, 0, 'Mummy', 0, 150, 240, 1, 0, '[\"I will ssswallow your sssoul!\",\"Mort ulhegh dakh visss.\",\"Flesssh to dussst!\",\"I will tassste life again!\",\"Ahkahra exura belil mort!\",\"Yohag Sssetham!\"]', '[\"earth\",\"drown\",\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"3976\",\"count\":\"3\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"40000\"},{\"id\":\"2144\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2134\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2162\",\"count\":1,\"chance\":\"16000\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2529\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2170\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2161\",\"count\":1,\"chance\":\"5000\"}]'),
(76, 0, 'necromancer', 0, 580, 580, 1, 0, '[\"Your corpse will be mine!\",\"Taste the sweetness of death!\"]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2796\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2148\",\"count\":\"90\",\"chance\":\"30000\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2436\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2423\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"15000\"}]'),
(77, 0, 'orc berserker', 590, 195, 210, 15, 0, '[\"KRAK ORRRRRRK!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":1,\"chance\":\"17000\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"55000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2044\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2381\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2378\",\"count\":1,\"chance\":\"6000\"}]'),
(78, 0, 'orc leader', 640, 270, 450, 5, 0, '[\"Ulderek futgyr human!\"]', '[\"invisible\"]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"15000\"},{\"id\":\"2667\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"35\",\"chance\":\"28000\"},{\"id\":\"2410\",\"count\":\"4\",\"chance\":\"10000\"},{\"id\":\"1988\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2475\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2647\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2413\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2419\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"23000\"},{\"id\":\"2510\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2207\",\"count\":1,\"chance\":\"4000\"}]');
INSERT INTO `myaac_monsters` (`id`, `hidden`, `name`, `mana`, `exp`, `health`, `speed_lvl`, `use_haste`, `voices`, `immunities`, `summonable`, `convinceable`, `race`, `loot`) VALUES
(79, 0, 'orc rider', 490, 110, 180, 20, 0, '[\"Grrrrrrr\",\"Orc arga Huummmak!\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"100\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1988\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2482\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"600\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2428\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2425\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"1000\"}]'),
(80, 0, 'orc shaman', 0, 110, 115, 1, 0, '[\"Grak brrretz gulu.\",\"Huumans stinkk!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2686\",\"count\":\"2\",\"chance\":\"11000\"},{\"id\":\"2148\",\"count\":\"5\",\"chance\":\"90000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2188\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"1973\",\"count\":1,\"chance\":\"4500\"}]'),
(81, 0, 'orc spearman', 310, 38, 105, 1, 0, '[\"Ugaar!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"7\",\"chance\":\"22000\"},{\"id\":\"2220\",\"count\":1,\"chance\":\"7700\"},{\"id\":\"2482\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2468\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":1,\"chance\":\"23000\"},{\"id\":\"2420\",\"count\":1,\"chance\":\"10000\"}]'),
(82, 0, 'orc warlord', 0, 670, 950, 7, 0, '[\"Ranat Ulderek!\",\"Orc buta bana!\",\"Ikem rambo zambo!\",\"Futchi maruk buta!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"20000\"},{\"id\":\"2667\",\"count\":\"2\",\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"45\",\"chance\":\"19000\"},{\"id\":\"2399\",\"count\":\"40\",\"chance\":\"30000\"},{\"id\":\"2490\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2497\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2647\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2428\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2434\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2419\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2200\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2165\",\"count\":1,\"chance\":\"100\"}]'),
(83, 0, 'orc warrior', 360, 50, 125, 1, 0, '[\"Grow truk grrrr.\",\"Trak grrrr brik.\",\"Alk!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"65000\"},{\"id\":\"2007\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2385\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2530\",\"count\":1,\"chance\":\"500\"}]'),
(84, 0, 'orc', 300, 25, 70, 1, 0, '[\"Grak brrretz!\",\"Grow truk grrrrr.\",\"Prek tars, dekklep zurk.\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"8\",\"chance\":\"85000\"},{\"id\":\"2482\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2484\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2386\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2385\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2526\",\"count\":1,\"chance\":\"10000\"}]'),
(85, 0, 'panda', 300, 23, 80, 1, 0, '[\"Grrrr\",\"Groar\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"40000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(86, 0, 'parrot', 250, 0, 25, 50, 0, '[\"BR? PL? SWE?\",\"Screeeeeeech!\",\"Neeeewbiiieee!\",\"You advanshed, you advanshed!\",\"Hope you die and loooosh it!\",\"Hunterrr ish PK!\"]', '[]', 1, 1, 'blood', '[]'),
(87, 0, 'pig', 255, 0, 25, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"65000\"}]'),
(88, 0, 'poison spider', 270, 22, 26, 1, 0, '[]', '[]', 1, 1, 'venom', '[{\"id\":\"2148\",\"count\":\"4\",\"chance\":\"25000\"}]'),
(89, 0, 'polar bear', 315, 28, 85, 1, 0, '[\"Grrrrrr\",\"GROARRR!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"50000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(90, 0, 'priestess', 0, 420, 390, 1, 0, '[\"Your energy is mine.\",\"Now, your life has come to an end, hahahha!\",\"Throw the soul on the altar!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2674\",\"count\":\"2\",\"chance\":\"7500\"},{\"id\":\"2791\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2151\",\"count\":1,\"chance\":\"700\"},{\"id\":\"2070\",\"count\":1,\"chance\":\"1400\"},{\"id\":\"2192\",\"count\":1,\"chance\":\"1200\"},{\"id\":\"2032\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2760\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2803\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2125\",\"count\":1,\"chance\":\"600\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"23000\"},{\"id\":\"2423\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2183\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2529\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1977\",\"count\":1,\"chance\":\"7000\"}]'),
(91, 0, 'rabbit', 220, 0, 15, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"85000\"},{\"id\":\"2684\",\"count\":1,\"chance\":\"10000\"}]'),
(92, 0, 'rat', 200, 5, 20, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"3\",\"chance\":\"50000\"},{\"id\":\"2696\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(93, 0, 'rotworm', 305, 40, 65, 1, 0, '[]', '[]', 0, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"5\",\"chance\":\"50000\"},{\"id\":\"2671\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2666\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"8\",\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"30000\"},{\"id\":\"2480\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"2412\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2530\",\"count\":1,\"chance\":\"1000\"}]'),
(94, 0, 'scarab', 395, 120, 320, 1, 0, '[]', '[\"paralyze\"]', 1, 1, 'venom', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"54000\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"70500\"},{\"id\":\"2148\",\"count\":\"40\",\"chance\":\"44500\"},{\"id\":\"2159\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2159\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2150\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2149\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2544\",\"count\":\"3\",\"chance\":\"5000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2439\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2442\",\"count\":1,\"chance\":\"500\"}]'),
(95, 0, 'scorpion', 310, 45, 45, 1, 0, '[]', '[]', 1, 1, 'venom', '[]'),
(96, 0, 'serpent spawn', 0, 2000, 3000, 7, 0, '[\"Ssssolus for the one\",\"HISSSS\",\"Tsssse one will risssse again\",\"I bring you deathhhh, mortalssss\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2796\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"60000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2547\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2033\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"1967\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1976\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2479\",\"count\":1,\"chance\":\"600\"},{\"id\":\"3971\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2498\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2492\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2392\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2182\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2528\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2168\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"3000\"}]'),
(97, 0, 'sheep', 250, 0, 20, 1, 0, '[\"Maeh\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(98, 0, 'sibang', 0, 105, 225, 1, 0, '[\"Eeeeek! Eeeeek\",\"Huh! Huh! Huh!\",\"Ahhuuaaa!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2676\",\"count\":\"2\",\"chance\":\"30000\"},{\"id\":\"2676\",\"count\":\"10\",\"chance\":\"5000\"},{\"id\":\"2675\",\"count\":\"5\",\"chance\":\"20000\"},{\"id\":\"2678\",\"count\":\"5\",\"chance\":\"20000\"},{\"id\":\"2682\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"25\",\"chance\":\"80000\"},{\"id\":\"1294\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"4000\"}]'),
(99, 0, 'skeleton', 300, 35, 50, 1, 0, '[]', '[\"lifedrain\"]', 1, 1, 'undead', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"45000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2473\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2388\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2511\",\"count\":1,\"chance\":\"12000\"}]'),
(100, 0, 'skunk', 200, 3, 20, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"1000\"}]'),
(101, 0, 'slime', 0, 0, 150, 1, 0, '[\"Blubb\"]', '[]', 0, 0, 'venom', '[]'),
(102, 0, 'smuggler', 390, 48, 130, 1, 0, '[\"I will silence you forever!\",\"You saw something you shouldn\'t!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2666\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"80000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2403\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2376\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2404\",\"count\":1,\"chance\":\"4000\"}]'),
(103, 0, 'snake', 205, 10, 15, 1, 0, '[\"Zzzzzzt\"]', '[]', 1, 1, 'blood', '[]'),
(104, 0, 'spider', 210, 12, 20, 1, 0, '[]', '[]', 1, 1, 'venom', '[{\"id\":\"2148\",\"count\":\"5\",\"chance\":\"35000\"}]'),
(105, 0, 'spit nettle', 0, 20, 150, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'venom', '[{\"id\":\"2148\",\"count\":\"5\",\"chance\":\"10000\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2804\",\"count\":1,\"chance\":\"10000\"}]'),
(106, 0, 'stalker', 0, 90, 120, 10, 0, '[]', '[\"lifedrain\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"8\",\"chance\":\"13000\"},{\"id\":\"2410\",\"count\":\"2\",\"chance\":\"11000\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1998\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2412\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2425\",\"count\":1,\"chance\":\"1200\"},{\"id\":\"2511\",\"count\":1,\"chance\":\"5500\"}]'),
(107, 0, 'stone golem', 590, 160, 270, 1, 0, '[]', '[\"paralyze\"]', 1, 1, 'undead', '[{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"16000\"},{\"id\":\"1294\",\"count\":\"4\",\"chance\":\"13000\"},{\"id\":\"2156\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2395\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"200\"}]'),
(108, 0, 'swamp troll', 320, 25, 55, 1, 0, '[\"Grrrr\",\"Groar!\",\"Me strong! Me ate spinach!\"]', '[]', 1, 1, 'venom', '[{\"id\":\"2667\",\"count\":1,\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"5\",\"chance\":\"50000\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2050\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2580\",\"count\":1,\"chance\":\"100\"}]'),
(109, 0, 'tarantula', 485, 120, 225, 1, 0, '[]', '[]', 1, 1, 'venom', '[{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"30\",\"chance\":\"30000\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2510\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2169\",\"count\":1,\"chance\":\"100\"}]'),
(110, 0, 'terror bird', 490, 150, 300, 1, 0, '[\"CRAAAHHH!\",\"Gruuuh Gruuuh.\",\"Carrah Carrah!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":\"1\",\"chance\":\"20000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"3970\",\"count\":1,\"chance\":\"100\"}]'),
(111, 0, 'tiger', 420, 40, 75, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"22000\"},{\"id\":\"2666\",\"count\":\"3\",\"chance\":\"55000\"}]'),
(112, 0, 'troll', 290, 20, 50, 1, 0, '[\"Grrrr\",\"Groar\",\"Gruntz!\",\"Hmmm, bugs.\",\"Hmmm, dogs.\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"60000\"},{\"id\":\"2120\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2461\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2380\",\"count\":1,\"chance\":\"36000\"},{\"id\":\"2448\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2170\",\"count\":1,\"chance\":\"100\"}]'),
(113, 0, 'valkyrie', 450, 85, 190, 1, 0, '[\"Stand still!\",\"One more head for me!\",\"Head off!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"3\",\"chance\":\"30000\"},{\"id\":\"2674\",\"count\":\"2\",\"chance\":\"7500\"},{\"id\":\"2148\",\"count\":\"12\",\"chance\":\"32000\"},{\"id\":\"2145\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2229\",\"count\":\"2\",\"chance\":\"80000\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2464\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"800\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2389\",\"count\":\"3\",\"chance\":\"60000\"},{\"id\":\"2379\",\"count\":1,\"chance\":\"25000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2200\",\"count\":1,\"chance\":\"1100\"}]'),
(114, 0, 'vampire', 0, 290, 450, 1, 0, '[\"BLOOD!\",\"Let me kiss your neck.\",\"I smell warm blood.\",\"I call you, my bats! Come!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"15000\"},{\"id\":\"2144\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2229\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2032\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"36000\"},{\"id\":\"2127\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2479\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2396\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2412\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2383\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2534\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2172\",\"count\":1,\"chance\":\"200\"}]'),
(115, 0, 'war wolf', 420, 55, 140, 22, 0, '[\"Grrrrrrr\",\"Yoooohhuuuu!\"]', '[]', 0, 1, 'blood', '[{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"40000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"}]'),
(116, 0, 'warlock', 0, 4000, 3200, 5, 0, '[\"Learn the secret of our magic! YOUR death!\",\"Even a rat is a better mage than you.\",\"We don\'t like intruders!\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2689\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2792\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2679\",\"count\":\"4\",\"chance\":\"20000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"30000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"2800\"},{\"id\":\"2151\",\"count\":1,\"chance\":\"1100\"},{\"id\":\"1986\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2600\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2178\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2123\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2466\",\"count\":1,\"chance\":\"300\"},{\"id\":\"2656\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2047\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2436\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2185\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2197\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"3000\"}]'),
(117, 0, 'wasp', 280, 24, 35, 50, 0, '[\"Bsssssss\"]', '[]', 1, 1, 'venom', '[]'),
(118, 0, 'wild warrior', 420, 60, 135, 1, 0, '[\"An enemy!\",\"Gimme your money!\"]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"15000\"},{\"id\":\"2110\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2458\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2459\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2649\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2386\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2398\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2391\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2511\",\"count\":1,\"chance\":\"17000\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"1000\"}]'),
(119, 0, 'winter wolf', 260, 20, 30, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"60000\"}]'),
(120, 0, 'witch', 0, 120, 300, 1, 0, '[\"Horax pokti!\",\"Hihihihi!\",\"Herba budinia ex!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2696\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2687\",\"count\":\"8\",\"chance\":\"30000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"10000\"},{\"id\":\"2800\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2551\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2643\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2654\",\"count\":1,\"chance\":\"50000\"},{\"id\":\"2651\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2405\",\"count\":1,\"chance\":\"40000\"},{\"id\":\"2402\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2185\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2199\",\"count\":1,\"chance\":\"2500\"}]'),
(121, 0, 'wolf', 255, 18, 25, 1, 0, '[]', '[]', 1, 1, 'blood', '[{\"id\":\"3976\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2666\",\"count\":\"2\",\"chance\":\"50000\"}]'),
(122, 0, 'yeti', 0, 460, 950, 15, 0, '[\"Yooodelaaahooohooo!\",\"Yooodelaaaheeeheee!\"]', '[\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2671\",\"count\":\"6\",\"chance\":\"35000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"75000\"},{\"id\":\"2148\",\"count\":\"10\",\"chance\":\"60000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"30000\"},{\"id\":\"2111\",\"count\":\"22\",\"chance\":\"50000\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2644\",\"count\":1,\"chance\":\"100\"}]'),
(123, 0, 'deathslicer', 0, 320, 2000, 1, 0, '[]', '[\"lifedrain\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[]'),
(124, 0, 'flamethrower', 0, 1200, 9950, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[]'),
(125, 0, 'plaguethrower', 0, 1300, 9950, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[]'),
(126, 0, 'Shredderthrower', 0, 18, 100, 1, 0, '[]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[]'),
(127, 0, 'Ashmunrah', 0, 3100, 5000, 105, 0, '[\"I might be trapped but not without power.\",\"Ahhhh all those long years.\",\"Ages come, ages go. Asmumrah remains.\",\"My traitorous son has sent thee.\",\"No mortal or undead will steal my secrets.\",\"You will be history soon.\",\"Come to me, my allys and underlings.\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2148\",\"count\":\"90\",\"chance\":\"40000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2134\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2487\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2140\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2164\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2444\",\"count\":1,\"chance\":\"100\"}]'),
(128, 0, 'Demodras', 0, 3100, 2200, 5, 0, '[\"ZCHHHHH\",\"I WILL SET THE WORLD IN FIRE!\",\"I WILL PROTECT MY BROOD!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2672\",\"count\":\"10\",\"chance\":\"75000\"},{\"id\":\"2796\",\"count\":\"7\",\"chance\":\"24000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"95000\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"50\",\"chance\":\"55000\"},{\"id\":\"2146\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2547\",\"count\":1,\"chance\":\"16000\"},{\"id\":\"2033\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"1976\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1200\"},{\"id\":\"2498\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2479\",\"count\":1,\"chance\":\"800\"},{\"id\":\"2492\",\"count\":1,\"chance\":\"300\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2392\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2528\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"10000\"}]'),
(129, 0, 'Dharalion', 0, 1200, 1200, 10, 0, '[\"You desecrated this temple!\",\"Noone will stop my ascension!\",\"My powers are divine!\",\"Muahahaha!\"]', '[\"lifedrain\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2689\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2682\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2154\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2032\",\"count\":1,\"chance\":\"6500\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1949\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2600\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2652\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2047\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2198\",\"count\":1,\"chance\":\"2000\"}]'),
(130, 0, 'Dipthrah', 0, 2900, 4200, 50, 0, '[\"Come closer to learn the final lesson.\",\"I sense the weakness of your akh.\",\"Mortality and fear are your fate and your doom.\",\"Undeath will shatter my shackles.\",\"You can\'t escape death forever.\",\"You don\'t need this magic anymore.\",\"Feel the powers of my mind.\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2354\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2146\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2158\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2178\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2193\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2436\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2446\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"5000\"}]'),
(131, 0, 'Fernfang', 0, 600, 400, 10, 0, '[\"You desecrated this place!\",\"I will cleanse this isle!\",\"Grrrrrrr\",\"Yoooohhuuuu!\"]', '[\"paralyze\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2689\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2148\",\"count\":\"18\",\"chance\":\"15000\"},{\"id\":\"2154\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2260\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2015\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2032\",\"count\":1,\"chance\":\"6500\"},{\"id\":\"2802\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2800\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2747\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2220\",\"count\":1,\"chance\":\"7700\"},{\"id\":\"2129\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2652\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2642\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2044\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2401\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"500\"}]'),
(132, 0, 'general murius', 0, 1300, 1200, 10, 0, '[\"Feel the power of the Mooh\'Tah!\",\"You will get what you deserve!\",\"For the king!\",\"Guards!\"]', '[\"lifedrain\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"50000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"28000\"},{\"id\":\"2648\",\"count\":1,\"chance\":\"35000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"18000\"},{\"id\":\"2580\",\"count\":1,\"chance\":\"5000\"}]'),
(133, 0, 'Grorlam', 0, 290, 310, 10, 0, '[]', '[\"paralyze\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"15\",\"chance\":\"16000\"},{\"id\":\"2150\",\"count\":\"2\",\"chance\":\"6500\"},{\"id\":\"2156\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1294\",\"count\":\"4\",\"chance\":\"13000\"},{\"id\":\"2553\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2645\",\"count\":1,\"chance\":\"500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2166\",\"count\":1,\"chance\":\"5500\"}]'),
(134, 0, 'The Halloween Hare', 0, 0, 2000, 45, 0, '[]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[]'),
(135, 0, 'Mahrdis', 0, 3050, 3900, 40, 0, '[\"Ashes to ashes!\",\"Fire, Fire!\",\"The eternal flame demands its due!\",\"Burnnnnnnnnn!\",\"May my flames engulf you!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2353\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2147\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2156\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2141\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2432\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2539\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2168\",\"count\":1,\"chance\":\"5000\"}]'),
(136, 0, 'Morguthis', 0, 3000, 4800, 105, 0, '[\"Vengeance!\",\"You will make a fine trophy.\",\"Come and fight me, cowards!\",\"I am the supreme warrior!\",\"Let me hear the music of battle.\",\"Anotherone to bite the dust!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2350\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2144\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2136\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2645\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2443\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2430\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2197\",\"count\":1,\"chance\":\"5000\"}]'),
(137, 0, 'necropharus', 0, 1100, 800, 10, 0, '[\"You will rise as my servant!\",\"Praise to my master Urgith!\"]', '[\"lifedrain\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2796\",\"count\":1,\"chance\":\"22500\"},{\"id\":\"2148\",\"count\":\"99\",\"chance\":\"67300\"},{\"id\":\"2229\",\"count\":1,\"chance\":\"16000\"},{\"id\":\"2230\",\"count\":1,\"chance\":\"30000\"},{\"id\":\"2231\",\"count\":1,\"chance\":\"6000\"},{\"id\":\"2663\",\"count\":1,\"chance\":\"1800\"},{\"id\":\"2483\",\"count\":1,\"chance\":\"8500\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2406\",\"count\":1,\"chance\":\"8600\"},{\"id\":\"2423\",\"count\":1,\"chance\":\"5700\"},{\"id\":\"2436\",\"count\":1,\"chance\":\"400\"},{\"id\":\"2449\",\"count\":1,\"chance\":\"19900\"},{\"id\":\"2186\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2541\",\"count\":1,\"chance\":\"7500\"}]'),
(138, 0, 'Omruc', 0, 2950, 4300, 45, 0, '[\"Now chhhou shhhee me ... Now chhhou don\'t!!\",\"Omruc is back!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2352\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2674\",\"count\":\"2\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2145\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2154\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2544\",\"count\":\"25\",\"chance\":\"20000\"},{\"id\":\"2545\",\"count\":\"20\",\"chance\":\"60000\"},{\"id\":\"2546\",\"count\":\"15\",\"chance\":\"40000\"},{\"id\":\"2547\",\"count\":\"5\",\"chance\":\"10000\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2165\",\"count\":1,\"chance\":\"5000\"}]'),
(139, 0, 'Orshabaal', 0, 9999, 22500, 80, 0, '[\"PRAISED BE MY MASTERS, THE RUTHLESS SEVEN!\",\"YOU ARE DOOMED!\",\"ORSHABAAL IS BACK!\",\"Be prepared for the day my masters will come for you!\",\"SOULS FOR ORSHABAAL!\"]', '[\"lifedrain\",\"paralyze\",\"invisible\"]', 0, 0, 'fire', '[{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"99900\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"88800\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"77700\"},{\"id\":\"2148\",\"count\":\"100\",\"chance\":\"66600\"},{\"id\":\"2150\",\"count\":\"20\",\"chance\":\"13500\"},{\"id\":\"2145\",\"count\":\"5\",\"chance\":\"9500\"},{\"id\":\"2149\",\"count\":\"10\",\"chance\":\"15500\"},{\"id\":\"2146\",\"count\":\"10\",\"chance\":\"13500\"},{\"id\":\"2144\",\"count\":\"15\",\"chance\":\"15000\"},{\"id\":\"2143\",\"count\":\"15\",\"chance\":\"12500\"},{\"id\":\"2151\",\"count\":\"7\",\"chance\":\"14000\"},{\"id\":\"2158\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2155\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2177\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2178\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2112\",\"count\":1,\"chance\":\"14500\"},{\"id\":\"3955\",\"count\":1,\"chance\":\"100\"},{\"id\":\"2033\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"1982\",\"count\":1,\"chance\":\"2600\"},{\"id\":\"2176\",\"count\":1,\"chance\":\"12000\"},{\"id\":\"2192\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"5500\"},{\"id\":\"2123\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2179\",\"count\":1,\"chance\":\"8000\"},{\"id\":\"2142\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2125\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2462\",\"count\":1,\"chance\":\"11000\"},{\"id\":\"2472\",\"count\":1,\"chance\":\"3000\"},{\"id\":\"2470\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2195\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2171\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2162\",\"count\":1,\"chance\":\"11500\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2418\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"2402\",\"count\":1,\"chance\":\"15500\"},{\"id\":\"2421\",\"count\":1,\"chance\":\"13500\"},{\"id\":\"2396\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2436\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2434\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"2432\",\"count\":1,\"chance\":\"17000\"},{\"id\":\"2393\",\"count\":1,\"chance\":\"12500\"},{\"id\":\"2186\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2182\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2185\",\"count\":1,\"chance\":\"3500\"},{\"id\":\"2188\",\"count\":1,\"chance\":\"2500\"},{\"id\":\"2520\",\"count\":1,\"chance\":\"15500\"},{\"id\":\"2514\",\"count\":1,\"chance\":\"7500\"},{\"id\":\"2167\",\"count\":1,\"chance\":\"13500\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2165\",\"count\":1,\"chance\":\"9500\"},{\"id\":\"2164\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2197\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2170\",\"count\":1,\"chance\":\"13000\"},{\"id\":\"2200\",\"count\":1,\"chance\":\"4500\"},{\"id\":\"2174\",\"count\":1,\"chance\":\"2500\"}]'),
(140, 0, 'Rahemos', 0, 3100, 3700, 30, 0, '[\"It\'s a kind of magic.\",\"Abrah Kadabrah!\",\"Nothing hidden in my warpings.\",\"It\'s not a trick, it\'s Rahemos.\",\"Meet my dear friend from hell.\",\"I will make you believe in magic.\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2348\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2150\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2323\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2153\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2176\",\"count\":1,\"chance\":\"500\"},{\"id\":\"2184\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2214\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2447\",\"count\":1,\"chance\":\"100\"}]'),
(141, 0, 'Tiquandas Revenge', 0, 2635, 1800, 110, 0, '[]', '[\"paralyze\",\"invisible\"]', 0, 0, 'venom', '[{\"id\":\"2792\",\"count\":\"5\",\"chance\":\"25000\"},{\"id\":\"2671\",\"count\":\"2\",\"chance\":\"50000\"},{\"id\":\"2666\",\"count\":\"4\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"28\",\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"90\",\"chance\":\"100000\"}]'),
(142, 0, 'Thalas', 0, 2950, 4100, 20, 0, '[\"You will become a feast for my maggots.\",\"Death and decay!\",\"Death awaits you.\",\"Your precious life will be wasted.\",\"Red is my favourite color.\",\"Flesssh to dussst!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2351\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2149\",\"count\":\"3\",\"chance\":\"10000\"},{\"id\":\"2155\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2169\",\"count\":1,\"chance\":\"5000\"},{\"id\":\"2409\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2411\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2451\",\"count\":1,\"chance\":\"1500\"}]'),
(143, 0, 'The Evil Eye', 0, 1500, 1200, 10, 0, '[\"653768764!\",\"Let me take a look at you!\",\"Inferior creatures, bow before my power!\",\"659978 54764!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"24\",\"chance\":\"90000\"},{\"id\":\"2148\",\"count\":\"32\",\"chance\":\"80000\"},{\"id\":\"2148\",\"count\":\"40\",\"chance\":\"70000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2397\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2394\",\"count\":1,\"chance\":\"7000\"},{\"id\":\"2377\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2509\",\"count\":1,\"chance\":\"4000\"},{\"id\":\"2518\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2512\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2175\",\"count\":1,\"chance\":\"5000\"}]'),
(144, 0, 'The Horned Fox', 0, 200, 265, 1, 0, '[\"You will never get me!\",\"I\'ll be back!\",\"Catch me, if you can!\",\"Help me, boys!\"]', '[\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2666\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2148\",\"count\":\"20\",\"chance\":\"60000\"},{\"id\":\"2502\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2465\",\"count\":1,\"chance\":\"14000\"},{\"id\":\"2648\",\"count\":1,\"chance\":\"15000\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2387\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2388\",\"count\":1,\"chance\":\"9000\"},{\"id\":\"2513\",\"count\":1,\"chance\":\"2000\"},{\"id\":\"2580\",\"count\":1,\"chance\":\"5000\"}]'),
(145, 0, 'The Old Widow', 0, 2800, 6000, 10, 1, '[]', '[\"lifedrain\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'blood', '[{\"id\":\"2148\",\"count\":\"66\",\"chance\":\"99900\"},{\"id\":\"2148\",\"count\":\"22\",\"chance\":\"99900\"},{\"id\":\"2148\",\"count\":\"77\",\"chance\":\"66600\"},{\"id\":\"2457\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2463\",\"count\":1,\"chance\":\"20000\"},{\"id\":\"2476\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2478\",\"count\":1,\"chance\":\"16000\"},{\"id\":\"2477\",\"count\":1,\"chance\":\"600\"},{\"id\":\"2171\",\"count\":1,\"chance\":\"200\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2169\",\"count\":1,\"chance\":\"1400\"}]'),
(146, 0, 'Vashresamun', 0, 2950, 4000, 45, 0, '[\"Heheheheee!\",\"Come my maidens, we have visitors!\",\"Are you enjoying my music?\",\"Dance a dance of death for me!\",\"If music is the food of death, drop dead.\",\"Chakka Chakka!\"]', '[\"lifedrain\",\"paralyze\",\"outfit\",\"drunk\",\"invisible\"]', 0, 0, 'undead', '[{\"id\":\"2349\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2148\",\"count\":\"80\",\"chance\":\"70000\"},{\"id\":\"2148\",\"count\":\"85\",\"chance\":\"50000\"},{\"id\":\"2148\",\"count\":\"95\",\"chance\":\"35000\"},{\"id\":\"2143\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2072\",\"count\":1,\"chance\":\"10000\"},{\"id\":\"2074\",\"count\":1,\"chance\":\"200\"},{\"id\":\"2124\",\"count\":1,\"chance\":\"1500\"},{\"id\":\"2656\",\"count\":1,\"chance\":\"1000\"},{\"id\":\"2139\",\"count\":1,\"chance\":\"100\"},{\"id\":\"1987\",\"count\":1,\"chance\":\"100000\"},{\"id\":\"2445\",\"count\":1,\"chance\":\"100\"}]');

-- --------------------------------------------------------

--
-- Table structure for table `myaac_news`
--

CREATE TABLE `myaac_news` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `body` text NOT NULL,
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 - news, 2 - ticker, 3 - article',
  `date` int(11) NOT NULL DEFAULT 0,
  `category` tinyint(1) NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL DEFAULT 0,
  `last_modified_by` int(11) NOT NULL DEFAULT 0,
  `last_modified_date` int(11) NOT NULL DEFAULT 0,
  `comments` varchar(50) NOT NULL DEFAULT '',
  `article_text` varchar(300) NOT NULL DEFAULT '',
  `article_image` varchar(100) NOT NULL DEFAULT '',
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_news`
--

INSERT INTO `myaac_news` (`id`, `title`, `body`, `type`, `date`, `category`, `player_id`, `last_modified_by`, `last_modified_date`, `comments`, `article_text`, `article_image`, `hidden`) VALUES
(1, 'Hello!', 'MyAAC is just READY to use!', 1, 1707652507, 2, 5, 0, 0, 'https://my-aac.org', '', '', 0),
(2, 'Hello tickets!', 'https://my-aac.org', 2, 1707652507, 4, 5, 0, 0, '', '', '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_news_categories`
--

CREATE TABLE `myaac_news_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '',
  `description` varchar(50) NOT NULL DEFAULT '',
  `icon_id` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_news_categories`
--

INSERT INTO `myaac_news_categories` (`id`, `name`, `description`, `icon_id`, `hidden`) VALUES
(1, '', '', 0, 0),
(2, '', '', 1, 0),
(3, '', '', 2, 0),
(4, '', '', 3, 0),
(5, '', '', 4, 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_notepad`
--

CREATE TABLE `myaac_notepad` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `content` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_pages`
--

CREATE TABLE `myaac_pages` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `title` varchar(30) NOT NULL,
  `body` text NOT NULL,
  `date` int(11) NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL DEFAULT 0,
  `php` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 - plain html, 1 - php',
  `enable_tinymce` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 - enabled, 0 - disabled',
  `access` tinyint(4) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_pages`
--

INSERT INTO `myaac_pages` (`id`, `name`, `title`, `body`, `date`, `player_id`, `php`, `enable_tinymce`, `access`, `hidden`) VALUES
(1, 'downloads', 'Downloads', '<p>&nbsp;</p>\n<p>&nbsp;</p>\n<div style=\"text-align: center;\">We\'re using official Tibia Client <strong>{{ config.client / 100 }}</strong><br />\n<p>Download Tibia Client <strong>{{ config.client / 100 }}</strong>&nbsp;for Windows <a href=\"https://drive.google.com/drive/folders/0B2-sMQkWYzhGSFhGVlY2WGk5czQ\" target=\"_blank\" rel=\"noopener\">HERE</a>.</p>\n<h2>IP Changer:</h2>\n<a href=\"https://static.otland.net/ipchanger.exe\" target=\"_blank\" rel=\"noopener\">HERE</a></div>', 0, 1, 0, 1, 1, 0),
(2, 'commands', 'Commands', '<table style=\"border-collapse: collapse; width: 87.8471%; height: 57px;\" border=\"1\">\n<tbody>\n<tr style=\"height: 18px;\">\n<td style=\"width: 33.3333%; background-color: #505050; height: 18px;\"><span style=\"color: #ffffff;\"><strong>Words</strong></span></td>\n<td style=\"width: 33.3333%; background-color: #505050; height: 18px;\"><span style=\"color: #ffffff;\"><strong>Description</strong></span></td>\n</tr>\n<tr style=\"height: 18px; background-color: #f1e0c6;\">\n<td style=\"width: 33.3333%; height: 18px;\"><em>!example</em></td>\n<td style=\"width: 33.3333%; height: 18px;\">This is just an example</td>\n</tr>\n<tr style=\"height: 18px; background-color: #d4c0a1;\">\n<td style=\"width: 33.3333%; height: 18px;\"><em>!buyhouse</em></td>\n<td style=\"width: 33.3333%; height: 18px;\">Buy house you are looking at</td>\n</tr>\n<tr style=\"height: 18px; background-color: #f1e0c6;\">\n<td style=\"width: 33.3333%; height: 18px;\"><em>!aol</em></td>\n<td style=\"width: 33.3333%; height: 18px;\">Buy AoL</td>\n</tr>\n</tbody>\n</table>', 0, 1, 0, 1, 1, 0),
(3, 'rules_on_the_page', 'Rules', '1. Names\na) Names which contain insulting (e.g. \"Bastard\"), racist (e.g. \"Nigger\"), extremely right-wing (e.g. \"Hitler\"), sexist (e.g. \"Bitch\") or offensive (e.g. \"Copkiller\") language.\nb) Names containing parts of sentences (e.g. \"Mike returns\"), nonsensical combinations of letters (e.g. \"Fgfshdsfg\") or invalid formattings (e.g. \"Thegreatknight\").\nc) Names that obviously do not describe a person (e.g. \"Christmastree\", \"Matrix\"), names of real life celebrities (e.g. \"Britney Spears\"), names that refer to real countries (e.g. \"Swedish Druid\"), names which were created to fake other players\' identities (e.g. \"Arieswer\" instead of \"Arieswar\") or official positions (e.g. \"System Admin\").\n\n2. Cheating\na) Exploiting obvious errors of the game (\"bugs\"), for instance to duplicate items. If you find an error you must report it to CipSoft immediately.\nb) Intentional abuse of weaknesses in the gameplay, for example arranging objects or players in a way that other players cannot move them.\nc) Using tools to automatically perform or repeat certain actions without any interaction by the player (\"macros\").\nd) Manipulating the client program or using additional software to play the game.\ne) Trying to steal other players\' account data (\"hacking\").\nf) Playing on more than one account at the same time (\"multi-clienting\").\ng) Offering account data to other players or accepting other players\' account data (\"account-trading/sharing\").\n\n3. Gamemasters\na) Threatening a gamemaster because of his or her actions or position as a gamemaster.\nb) Pretending to be a gamemaster or to have influence on the decisions of a gamemaster.\nc) Intentionally giving wrong or misleading information to a gamemaster concerning his or her investigations or making false reports about rule violations.\n\n4. Player Killing\na) Excessive killing of characters who are not marked with a \"skull\" on worlds which are not PvP-enforced. Please note that killing marked characters is not a reason for a banishment.\n\nA violation of the Tibia Rules may lead to temporary banishment of characters and accounts. In severe cases removal or modification of character skills, attributes and belongings, as well as the permanent removal of accounts without any compensation may be considered. The sanction is based on the seriousness of the rule violation and the previous record of the player. It is determined by the gamemaster imposing the banishment.\n\nThese rules may be changed at any time. All changes will be announced on the official website.', 0, 1, 0, 0, 1, 0),
(4, 'events', 'events', 'testevents', 0, 1, 0, 0, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `myaac_spells`
--

CREATE TABLE `myaac_spells` (
  `id` int(11) NOT NULL,
  `spell` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL,
  `words` varchar(255) NOT NULL DEFAULT '',
  `category` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 - attack, 2 - healing, 3 - summon, 4 - supply, 5 - support',
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 - instant, 2 - conjure, 3 - rune',
  `level` int(11) NOT NULL DEFAULT 0,
  `maglevel` int(11) NOT NULL DEFAULT 0,
  `mana` int(11) NOT NULL DEFAULT 0,
  `soul` tinyint(4) NOT NULL DEFAULT 0,
  `conjure_id` int(11) NOT NULL DEFAULT 0,
  `conjure_count` tinyint(4) NOT NULL DEFAULT 0,
  `reagent` int(11) NOT NULL DEFAULT 0,
  `item_id` int(11) NOT NULL DEFAULT 0,
  `premium` tinyint(1) NOT NULL DEFAULT 0,
  `vocations` varchar(100) NOT NULL DEFAULT '',
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_videos`
--

CREATE TABLE `myaac_videos` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL DEFAULT '',
  `youtube_id` varchar(20) NOT NULL,
  `author` varchar(50) NOT NULL DEFAULT '',
  `ordering` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_visitors`
--

CREATE TABLE `myaac_visitors` (
  `ip` varchar(45) NOT NULL,
  `lastvisit` int(11) NOT NULL DEFAULT 0,
  `page` varchar(2048) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `myaac_weapons`
--

CREATE TABLE `myaac_weapons` (
  `id` int(11) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 0,
  `maglevel` int(11) NOT NULL DEFAULT 0,
  `vocations` varchar(100) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `myaac_weapons`
--

INSERT INTO `myaac_weapons` (`id`, `level`, `maglevel`, `vocations`) VALUES
(1294, 0, 0, '[]'),
(2111, 0, 0, '[]'),
(2181, 26, 0, '{\"2\":true}'),
(2182, 7, 0, '{\"2\":true}'),
(2183, 33, 0, '{\"2\":true}'),
(2185, 19, 0, '{\"2\":true}'),
(2186, 13, 0, '{\"2\":true}'),
(2187, 33, 0, '{\"1\":true}'),
(2188, 19, 0, '{\"1\":true}'),
(2189, 26, 0, '{\"1\":true}'),
(2190, 7, 0, '{\"1\":true}'),
(2191, 13, 0, '{\"1\":true}'),
(2389, 0, 0, '[]'),
(2399, 0, 0, '[]'),
(2410, 0, 0, '[]'),
(2543, 0, 0, '[]'),
(2544, 0, 0, '[]'),
(2545, 0, 0, '[]'),
(2546, 0, 0, '[]'),
(2547, 55, 0, '[]');

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `group_id` int(11) NOT NULL DEFAULT 1,
  `account_id` int(11) NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 1,
  `vocation` int(11) NOT NULL DEFAULT 0,
  `health` int(11) NOT NULL DEFAULT 150,
  `healthmax` int(11) NOT NULL DEFAULT 150,
  `experience` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `looktype` int(11) NOT NULL DEFAULT 136,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `direction` tinyint(3) UNSIGNED NOT NULL DEFAULT 2,
  `maglevel` int(11) NOT NULL DEFAULT 0,
  `mana` int(11) NOT NULL DEFAULT 0,
  `manamax` int(11) NOT NULL DEFAULT 0,
  `manaspent` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `soul` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `town_id` int(11) NOT NULL DEFAULT 1,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  `conditions` blob DEFAULT NULL,
  `cap` int(11) NOT NULL DEFAULT 400,
  `sex` int(11) NOT NULL DEFAULT 0,
  `lastlogin` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `lastip` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `save` tinyint(4) NOT NULL DEFAULT 1,
  `skull` tinyint(4) NOT NULL DEFAULT 0,
  `skulltime` bigint(20) NOT NULL DEFAULT 0,
  `lastlogout` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `blessings` tinyint(4) NOT NULL DEFAULT 0,
  `onlinetime` bigint(20) NOT NULL DEFAULT 0,
  `deletion` bigint(20) NOT NULL DEFAULT 0,
  `balance` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `offlinetraining_time` smallint(5) UNSIGNED NOT NULL DEFAULT 43200,
  `offlinetraining_skill` int(11) NOT NULL DEFAULT -1,
  `stamina` smallint(5) UNSIGNED NOT NULL DEFAULT 2520,
  `skill_fist` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_fist_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_club` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_club_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_sword` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_sword_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_axe` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_axe_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_dist` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_dist_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_shielding` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_shielding_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `skill_fishing` int(10) UNSIGNED NOT NULL DEFAULT 10,
  `skill_fishing_tries` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `lookmount` int(11) DEFAULT 0,
  `created` int(11) NOT NULL DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0,
  `lookwings` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `lookaura` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `lookshader` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `name`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `direction`, `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `lastlogout`, `blessings`, `onlinetime`, `deletion`, `balance`, `offlinetraining_time`, `offlinetraining_skill`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`, `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`, `lookmount`, `created`, `hidden`, `lookwings`, `lookaura`, `lookshader`) VALUES
(45, 'Ramz', 6, 1, 45, 1, 498, 400, 1330839, 68, 76, 78, 58, 43, 3, 0, 0, 1325, 1325, 0, 100, 1, 32096, 32214, 7, 0x010000000202ffffffff03e80300001a001b000000001c00fe, 910, 1, 1713707653, 874163461, 1, 0, 0, 1713707656, 0, 714083, 0, 0, 43200, -1, 2520, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 16, 5, 0, 0, 0, 0, 0, 0);

--
-- Triggers `players`
--
DELIMITER $$
CREATE TRIGGER `ondelete_players` BEFORE DELETE ON `players` FOR EACH ROW BEGIN
    UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `players_online`
--

CREATE TABLE `players_online` (
  `player_id` int(11) NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_deaths`
--

CREATE TABLE `player_deaths` (
  `player_id` int(11) NOT NULL,
  `time` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 1,
  `killed_by` varchar(255) NOT NULL,
  `is_player` tinyint(4) NOT NULL DEFAULT 1,
  `mostdamage_by` varchar(100) NOT NULL,
  `mostdamage_is_player` tinyint(4) NOT NULL DEFAULT 0,
  `unjustified` tinyint(4) NOT NULL DEFAULT 0,
  `mostdamage_unjustified` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_depotitems`
--

CREATE TABLE `player_depotitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range eg 0-100 will be reserved for depot lockers and all > 100 will be then normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL,
  `count` smallint(6) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_depotlockeritems`
--

CREATE TABLE `player_depotlockeritems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range eg 0-100 will be reserved for depot lockers and all > 100 will be then normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` smallint(6) NOT NULL,
  `count` smallint(6) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_inboxitems`
--

CREATE TABLE `player_inboxitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL,
  `count` smallint(6) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_items`
--

CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `pid` int(11) NOT NULL DEFAULT 0,
  `sid` int(11) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `count` smallint(6) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `player_items`
--

INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES
(45, 3, 101, 1998, 1, ''),
(45, 4, 102, 2654, 1, 0x1f130000002202000000000000000a006974656d5f6c6576656c0252000000000000000c00756e6964656e7469666965640401),
(45, 6, 103, 2381, 1, 0x1c370100001d220100002207000000000000000a006974656d5f6c6576656c026f050000000000000600756e697175650201000000000000000500736c6f7432010400347c323906007261726974790201000000000000000500736c6f743301050031327c35390500736c6f7431010400317c39380500736c6f743401060033307c323537),
(45, 8, 104, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c022b000000000000000c00756e6964656e7469666965640401),
(45, 101, 105, 1998, 1, ''),
(45, 101, 106, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c02420000000000000006007261726974790201000000000000000500736c6f7431010300347c38),
(45, 101, 107, 2654, 1, 0x1f110000002203000000000000000a006974656d5f6c6576656c02480000000000000006007261726974790201000000000000000500736c6f743101040032327c33),
(45, 101, 108, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c023d0000000000000006007261726974790203000000000000000500736c6f7431010400327c3139),
(45, 101, 109, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c022d0000000000000006007261726974790201000000000000000500736c6f7431010300367c33),
(45, 101, 110, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c02590000000000000006007261726974790201000000000000000500736c6f7431010400317c3139),
(45, 101, 111, 2195, 1, 0x2204000000000000000a006974656d5f6c6576656c0244000000000000000500736c6f7432010300347c3906007261726974790202000000000000000500736c6f7431010300377c39),
(45, 101, 112, 2195, 1, 0x2204000000000000000a006974656d5f6c6576656c022a000000000000000500736c6f7432010300317c3806007261726974790202000000000000000500736c6f743101040031307c39),
(45, 101, 113, 2804, 1, 0x0f01),
(45, 101, 114, 1740, 1, 0x04ffff),
(45, 101, 115, 5545, 1, ''),
(45, 101, 116, 7953, 72, 0x0f48),
(45, 101, 117, 7094, 1, 0x2202000000000000000a006974656d5f6c6576656c0224000000000000000c00756e6964656e7469666965640401),
(45, 101, 118, 7872, 94, 0x0f5e),
(45, 101, 119, 7871, 93, 0x0f5d),
(45, 101, 120, 2800, 1, 0x0f01),
(45, 101, 121, 2554, 1, ''),
(45, 101, 122, 2457, 1, 0x1f0e0000002204000000000000000500736c6f743101040031397c3706007261726974790201000000000000000a006974656d5f6c6576656c022b000000000000000c00756e6964656e7469666965640401),
(45, 101, 123, 2000, 1, ''),
(45, 105, 124, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c02470000000000000006007261726974790202000000000000000500736c6f743101050032337c3130),
(45, 114, 125, 2654, 1, 0x1f100000002202000000000000000a006974656d5f6c6576656c0245000000000000000c00756e6964656e7469666965640401),
(45, 114, 126, 2654, 1, 0x1f110000002202000000000000000a006974656d5f6c6576656c024c000000000000000c00756e6964656e7469666965640401),
(45, 114, 127, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c0243000000000000000c00756e6964656e7469666965640401),
(45, 114, 128, 2654, 1, 0x1f110000002202000000000000000a006974656d5f6c6576656c0248000000000000000c00756e6964656e7469666965640401),
(45, 114, 129, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c022b000000000000000c00756e6964656e7469666965640401),
(45, 114, 130, 2195, 1, 0x22040000000000000006007261726974790201000000000000000500736c6f743101040032347c360a006974656d5f6c6576656c0242000000000000000c00756e6964656e7469666965640401),
(45, 114, 131, 2195, 1, 0x22040000000000000006007261726974790201000000000000000500736c6f7431010400327c34300a006974656d5f6c6576656c0247000000000000000c00756e6964656e7469666965640401),
(45, 114, 132, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c0243000000000000000c00756e6964656e7469666965640401),
(45, 114, 133, 2654, 1, 0x1f110000002202000000000000000a006974656d5f6c6576656c024c000000000000000c00756e6964656e7469666965640401),
(45, 114, 134, 2654, 1, 0x1f100000002202000000000000000a006974656d5f6c6576656c0245000000000000000c00756e6964656e7469666965640401),
(45, 114, 135, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c022c000000000000000c00756e6964656e7469666965640401),
(45, 114, 136, 2195, 1, 0x22040000000000000006007261726974790201000000000000000500736c6f7431010400327c34300a006974656d5f6c6576656c024b000000000000000c00756e6964656e7469666965640401),
(45, 114, 137, 2195, 1, 0x22040000000000000006007261726974790201000000000000000500736c6f743101040032347c360a006974656d5f6c6576656c025a000000000000000c00756e6964656e7469666965640401),
(45, 114, 138, 2195, 1, 0x2202000000000000000a006974656d5f6c6576656c023b000000000000000c00756e6964656e7469666965640401),
(45, 114, 139, 2654, 1, 0x1f100000002202000000000000000a006974656d5f6c6576656c0243000000000000000c00756e6964656e7469666965640401),
(45, 123, 140, 2195, 1, 0x2204000000000000000a006974656d5f6c6576656c023b000000000000000500736c6f7432010300337c3406007261726974790202000000000000000500736c6f743101040032337c32),
(45, 123, 141, 2195, 1, 0x2205000000000000000a006974656d5f6c6576656c025a000000000000000500736c6f7432010300347c3606007261726974790204000000000000000500736c6f7433010400367c31310500736c6f7431010400327c3930),
(45, 123, 142, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c024b0000000000000006007261726974790201000000000000000500736c6f743101040032367c36),
(45, 123, 143, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c022c0000000000000006007261726974790203000000000000000500736c6f7431010400317c3330),
(45, 123, 144, 2195, 1, 0x2203000000000000000a006974656d5f6c6576656c02370000000000000006007261726974790201000000000000000500736c6f743101040032337c34),
(45, 123, 145, 2654, 1, 0x1f130000002205000000000000000a006974656d5f6c6576656c0254000000000000000500736c6f7432010400317c363406007261726974790203000000000000000500736c6f7433010300347c340500736c6f743101040032327c31),
(45, 123, 146, 2654, 1, 0x1f130000002203000000000000000a006974656d5f6c6576656c02500000000000000006007261726974790201000000000000000500736c6f7431010400377c3133),
(45, 123, 147, 2654, 1, 0x1f140000002203000000000000000a006974656d5f6c6576656c02580000000000000006007261726974790201000000000000000500736c6f743101050032347c3130),
(45, 123, 148, 2456, 1, 0x1c110000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c025a0000000000000006007261726974790202000000000000000500736c6f743101050031347c3131),
(45, 123, 149, 2456, 1, 0x1c0d0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c023b0000000000000006007261726974790201000000000000000500736c6f7431010400327c3332),
(45, 123, 150, 2456, 1, 0x1c0a0000002204000000000000000a006974656d5f6c6576656c0228000000000000000500736c6f743201040031357c3806007261726974790202000000000000000500736c6f7431010400327c3131),
(45, 123, 151, 2456, 1, 0x1c110000002204000000000000000a006974656d5f6c6576656c024b000000000000000500736c6f7432010300347c3506007261726974790203000000000000000500736c6f743101040031387c32),
(45, 123, 152, 2456, 1, 0x1c0a0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c022d0000000000000006007261726974790203000000000000000500736c6f743101040031357c38),
(45, 123, 153, 2456, 1, 0x1c0d0000002204000000000000000a006974656d5f6c6576656c0244000000000000000500736c6f743201040031307c3606007261726974790202000000000000000500736c6f743101040031397c38),
(45, 123, 154, 2456, 1, 0x1c0d0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c02380000000000000006007261726974790201000000000000000500736c6f743101050033307c3430),
(45, 123, 155, 2456, 1, 0x1c0d0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c02410000000000000006007261726974790201000000000000000500736c6f743101050033347c3335),
(45, 123, 156, 2456, 1, 0x1c120000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c02530000000000000006007261726974790203000000000000000500736c6f743101040031377c33),
(45, 123, 157, 2456, 1, 0x1c0e0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c02490000000000000006007261726974790201000000000000000500736c6f7431010300397c32),
(45, 123, 158, 2456, 1, 0x1c0c0000002204000000000000000500736c6f7432010300357c350a006974656d5f6c6576656c02320000000000000006007261726974790201000000000000000500736c6f7431010300397c38),
(45, 123, 159, 2456, 1, 0x1c0b0000002204000000000000000a006974656d5f6c6576656c022a000000000000000500736c6f7432010300367c3306007261726974790202000000000000000500736c6f7431010400317c3337);

-- --------------------------------------------------------

--
-- Table structure for table `player_namelocks`
--

CREATE TABLE `player_namelocks` (
  `player_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `namelocked_at` bigint(20) NOT NULL,
  `namelocked_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_spells`
--

CREATE TABLE `player_spells` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_storage`
--

CREATE TABLE `player_storage` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `key` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `value` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `player_storage`
--

INSERT INTO `player_storage` (`player_id`, `key`, `value`) VALUES
(45, 0, 415),
(45, 2580, 18),
(45, 8124, 1),
(45, 8125, 1),
(45, 20090, 3),
(45, 20197, 6),
(45, 55650, 0),
(45, 65541, 1),
(45, 65542, 1),
(45, 65543, 1),
(45, 65546, 1),
(45, 65547, 1),
(45, 65568, 1),
(45, 65615, 1),
(45, 65625, 1),
(45, 65630, 1),
(45, 65633, 1),
(45, 65634, 1),
(45, 65635, 1),
(45, 65638, 1),
(45, 65641, 1),
(45, 65642, 1),
(45, 65643, 1),
(45, 65644, 1),
(45, 65645, 1),
(45, 65646, 1),
(45, 65660, 1),
(45, 65663, 1),
(45, 65664, 1),
(45, 65665, 1),
(45, 65668, 1),
(45, 65669, 1),
(45, 65670, 1),
(45, 65671, 1),
(45, 65672, 1),
(45, 65795, 1),
(45, 65796, 1),
(45, 65798, 1),
(45, 65803, 1),
(45, 65806, 1),
(45, 65810, 1),
(45, 65811, 1),
(45, 65812, 1),
(45, 65813, 1),
(45, 65814, 1),
(45, 65815, 1),
(45, 65830, 1),
(45, 65831, 1),
(45, 65896, 1),
(45, 1010001, 204),
(45, 1010006, 1),
(45, 1010010, 15),
(45, 1010029, 5),
(45, 1010032, 1),
(45, 1010040, 1),
(45, 1010059, 2),
(45, 1010064, 2),
(45, 1010088, 1),
(45, 1010096, 107),
(45, 1010103, 202),
(45, 1010108, 8),
(45, 1010109, 4),
(45, 1010117, 1116),
(45, 1010123, 1),
(45, 1010126, 2),
(45, 1150001, 1712638348),
(45, 10001001, 8781827),
(45, 10001002, 9306115),
(45, 10002011, 7);

-- --------------------------------------------------------

--
-- Table structure for table `player_storeinboxitems`
--

CREATE TABLE `player_storeinboxitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` smallint(5) UNSIGNED NOT NULL,
  `count` smallint(6) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `server_config`
--

CREATE TABLE `server_config` (
  `config` varchar(50) NOT NULL,
  `value` varchar(256) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `server_config`
--

INSERT INTO `server_config` (`config`, `value`) VALUES
('db_version', '30'),
('motd_hash', 'bd746a8e830237f7a1380be98802a0483741cff8'),
('motd_num', '6'),
('players_record', '10');

-- --------------------------------------------------------

--
-- Table structure for table `shop_history`
--

CREATE TABLE `shop_history` (
  `id` int(11) NOT NULL,
  `account` int(11) NOT NULL,
  `player` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `title` varchar(100) NOT NULL,
  `price` int(11) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 0,
  `target` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `shop_history`
--

INSERT INTO `shop_history` (`id`, `account`, `player`, `date`, `title`, `price`, `count`, `target`) VALUES
(31, 1, 45, '2024-04-06 11:36:51', 'Warrior', 1500, 0, NULL),
(32, 1, 45, '2024-04-06 18:24:54', 'Warrior', 1500, 0, 'Dawn'),
(33, 1, 45, '2024-04-06 18:25:10', 'Wizard', 1500, 0, 'Ziemniak'),
(34, 1, 45, '2024-04-06 18:25:41', 'Druid', 1500, 0, 'Nydiron'),
(35, 1, 45, '2024-04-06 19:24:37', 'Citizen', 1500, 0, 'Glaszcz'),
(36, 1, 45, '2024-04-07 14:49:51', 'Krakoloss', 900, 0, 'Grzybiusz'),
(37, 1, 45, '2024-04-07 14:49:59', 'Mage', 1500, 0, 'Grzybiusz'),
(38, 1, 45, '2024-04-07 14:50:41', 'Moo Moo', 1000, 0, 'Grzybiusz'),
(39, 1, 45, '2024-04-08 16:38:58', 'Pirate', 1500, 0, 'Small Bolt'),
(40, 1, 45, '2024-04-11 19:18:30', 'Wizard', 1500, 0, 'Shan Alad'),
(41, 1, 45, '2024-04-11 19:18:48', 'Krakoloss', 900, 0, 'Shan Alad'),
(42, 1, 45, '2024-04-16 15:51:55', 'Weekly Premium Scroll', 200, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tile_store`
--

CREATE TABLE `tile_store` (
  `house_id` int(11) NOT NULL,
  `data` longblob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `tile_store`
--

INSERT INTO `tile_store` (`house_id`, `data`) VALUES
(1042, 0x537dde7d0701000000c30400),
(1043, 0x537dcf7d0701000000c50400),
(1043, 0x507dd07d0701000000da0600),
(1043, 0x507dd17d0701000000db0600),
(1043, 0x507dd27d0701000000da0600),
(1043, 0x507dd37d0701000000db0600),
(1043, 0x557dd07d0701000000da0600),
(1043, 0x557dd17d0701000000db0600),
(1043, 0x557dd27d0701000000da0600),
(1043, 0x557dd37d0701000000db0600),
(1044, 0x4a7dc57d0701000000da0600),
(1044, 0x4a7dc67d0701000000db0600),
(1044, 0x4e7dc57d0701000000da0600),
(1044, 0x4e7dc67d0701000000db0600),
(1044, 0x4f7dc77d0701000000c30400),
(1045, 0x527dcb7d0601000000c30400),
(1045, 0x567dc97d0601000000da0600),
(1045, 0x567dca7d0601000000db0600),
(1046, 0x5d7d9d7d0701000000da0600),
(1046, 0x5d7d9e7d0701000000db0600),
(1046, 0x5f7d9f7d0701000000c30400),
(1047, 0x7e7da37d0701000000da0600),
(1047, 0x7e7da47d0701000000db0600),
(1047, 0x807da17d0701000000c50400),
(1048, 0x817da87d0701000000da0600),
(1048, 0x817da97d0701000000db0600),
(1048, 0x837da87d0701000000da0600),
(1048, 0x837da97d0701000000db0600),
(1048, 0x857da87d0701000000da0600),
(1048, 0x857da97d0701000000db0600),
(1048, 0x877da87d0701000000da0600),
(1048, 0x877da97d0701000000db0600),
(1048, 0x8d7dab7d0701000000c30400),
(1048, 0x837dad7d0701000000c50400),
(1049, 0x8d7daf7d0701000000da0600),
(1049, 0x8d7db07d0701000000db0600),
(1049, 0x8f7db57d0701000000c50400),
(1051, 0x917d9d7d0701000000c50400);

-- --------------------------------------------------------

--
-- Table structure for table `towns`
--

CREATE TABLE `towns` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `towns`
--

INSERT INTO `towns` (`id`, `name`, `posx`, `posy`, `posz`) VALUES
(1, 'Rook', 32097, 32219, 7);

-- --------------------------------------------------------

--
-- Table structure for table `znote`
--

CREATE TABLE `znote` (
  `id` int(11) NOT NULL,
  `version` varchar(30) NOT NULL COMMENT 'Znote AAC version',
  `installed` int(11) NOT NULL,
  `cached` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote`
--

INSERT INTO `znote` (`id`, `version`, `installed`, `cached`) VALUES
(1, '1.6', 1705100400, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `znote_accounts`
--

CREATE TABLE `znote_accounts` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `ip` bigint(20) UNSIGNED NOT NULL,
  `created` int(11) NOT NULL,
  `points` int(11) DEFAULT 0,
  `cooldown` int(11) DEFAULT 0,
  `active` tinyint(4) NOT NULL DEFAULT 0,
  `active_email` tinyint(4) NOT NULL DEFAULT 0,
  `activekey` int(11) NOT NULL DEFAULT 0,
  `flag` varchar(20) NOT NULL,
  `secret` char(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote_accounts`
--

INSERT INTO `znote_accounts` (`id`, `account_id`, `ip`, `created`, `points`, `cooldown`, `active`, `active_email`, `activekey`, `flag`, `secret`) VALUES
(1, 1, 2130706433, 1705151983, 77777, 0, 1, 0, 942659139, 'pl', NULL),
(2, 3, 0, 1708787909, 0, 0, 1, 0, 637209780, 'pl', NULL),
(3, 5, 0, 1711890061, 0, 0, 1, 0, 722127028, 'pl', NULL),
(4, 6, 0, 1711971638, 0, 0, 1, 0, 872955513, 'om', NULL),
(5, 7, 0, 1712050964, 0, 0, 1, 0, 630250884, 'pl', NULL),
(6, 8, 1441956866, 1712066988, 0, 0, 1, 0, 259560251, 'aq', NULL),
(7, 9, 2323050066, 1712068025, 0, 0, 1, 0, 731455566, 'br', NULL),
(8, 10, 1593743826, 1712071151, 0, 0, 1, 0, 440315239, 'ng', NULL),
(9, 11, 1486654327, 1712073538, 0, 0, 1, 0, 349937523, 'pl', NULL),
(10, 12, 2845230165, 1712081961, 0, 0, 1, 0, 130157519, 'us', NULL),
(11, 13, 1498313813, 1712082601, 0, 0, 1, 0, 464858836, 'us', NULL),
(12, 14, 2972025961, 1712083518, 0, 0, 1, 0, 937256178, 'br', NULL),
(13, 15, 2890173298, 1712091662, 0, 0, 1, 0, 563752895, 'dz', NULL),
(14, 16, 2728308380, 1712091698, 0, 0, 1, 0, 999235354, 'mx', NULL),
(15, 17, 3178988007, 1712096835, 0, 0, 1, 0, 751895135, 'br', NULL),
(16, 18, 3216447027, 1712152904, 0, 0, 1, 0, 142838654, 'br', NULL),
(17, 19, 3216447027, 1712153018, 0, 0, 1, 0, 780322690, 'br', NULL),
(18, 20, 2728291844, 1712167729, 0, 0, 1, 0, 297629483, 'se', NULL),
(19, 21, 1498313813, 1712307986, 0, 0, 1, 0, 150764795, 'se', NULL),
(20, 22, 1841590797, 1712313659, 0, 0, 1, 0, 600793563, 'pl', NULL),
(21, 23, 2890322636, 1712357416, 0, 0, 1, 0, 678435812, 'us', NULL),
(22, 24, 2890322651, 1712357597, 0, 0, 1, 0, 174974329, 'us', NULL),
(23, 25, 2890173298, 1712400329, 0, 0, 1, 0, 358098588, 'ar', NULL),
(24, 26, 1498313813, 1712420378, 0, 0, 1, 0, 415910068, 'gb', NULL),
(25, 27, 1498313813, 1712422993, 0, 0, 1, 0, 157911900, 'br', NULL),
(26, 28, 2890173316, 1712430007, 0, 0, 1, 0, 482264109, 'pl', NULL),
(27, 29, 2728273466, 1712435350, 0, 0, 1, 0, 133859788, 'es', NULL),
(28, 30, 2728273444, 1712448394, 0, 0, 1, 0, 890338911, 'gi', NULL),
(29, 31, 2890258115, 1712489109, 0, 0, 1, 0, 585647468, 'ca', NULL),
(30, 32, 2890173073, 1712493944, 0, 0, 1, 0, 695514784, 'pl', NULL),
(31, 33, 2728290045, 1712494134, 0, 0, 1, 0, 623473224, 'pl', NULL),
(32, 34, 520116163, 1712494407, 0, 0, 1, 0, 468993775, 'pl', NULL),
(33, 35, 3000616227, 1712502208, 0, 0, 1, 0, 161151678, 'pl', NULL),
(34, 36, 2372233493, 1712521986, 0, 0, 1, 0, 389046133, 'pl', NULL),
(35, 37, 2372233319, 1712522602, 0, 0, 1, 0, 373251984, 'pl', NULL),
(36, 38, 2890253084, 1712522712, 0, 0, 1, 0, 537832789, 'pl', NULL),
(37, 39, 2372233576, 1712603625, 0, 0, 1, 0, 547328005, 'pl', NULL),
(38, 40, 3180084150, 1712606327, 0, 0, 1, 0, 311554963, 'mx', NULL),
(39, 41, 2890358372, 1712693393, 0, 0, 1, 0, 753791082, 'pl', NULL),
(40, 42, 2890219736, 1712772940, 0, 0, 1, 0, 225419446, 'br', NULL),
(41, 43, 2890173072, 1712927333, 0, 0, 1, 0, 966035862, 'pl', NULL),
(42, 44, 2890173072, 1712928043, 0, 0, 1, 0, 193358333, 'pl', NULL),
(43, 45, 2890280626, 1712946170, 0, 0, 1, 0, 912474332, 'se', NULL),
(44, 46, 2890359684, 1712946332, 0, 0, 1, 0, 747575455, 'se', NULL),
(45, 47, 2890280657, 1712946435, 0, 0, 1, 0, 483807349, 'se', NULL),
(46, 48, 2890359541, 1712946519, 0, 0, 1, 0, 231574455, 'se', NULL),
(47, 49, 3113821824, 1713031521, 0, 0, 1, 0, 167570914, 'bb', NULL),
(48, 50, 2728289834, 1713124885, 0, 0, 1, 0, 765384178, 'pl', NULL),
(49, 51, 2890253248, 1713207282, 0, 0, 1, 0, 565432024, 'pl', NULL),
(50, 52, 2728298007, 1713213810, 0, 0, 1, 0, 190345873, 'se', NULL),
(51, 53, 2372233319, 1713375369, 0, 0, 1, 0, 300114091, 'pl', NULL),
(52, 54, 2372233494, 1713376012, 0, 0, 1, 0, 236143659, 'pl', NULL),
(53, 55, 2890206016, 1713378656, 0, 0, 1, 0, 882873257, 'br', NULL),
(54, 56, 3216097576, 1713549651, 0, 0, 1, 0, 101268232, 'br', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `znote_auction_player`
--

CREATE TABLE `znote_auction_player` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `original_account_id` int(11) NOT NULL,
  `bidder_account_id` int(11) NOT NULL,
  `time_begin` int(11) NOT NULL,
  `time_end` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `bid` int(11) NOT NULL,
  `deposit` int(11) NOT NULL,
  `sold` tinyint(4) NOT NULL,
  `claimed` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_changelog`
--

CREATE TABLE `znote_changelog` (
  `id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_deleted_characters`
--

CREATE TABLE `znote_deleted_characters` (
  `id` int(11) NOT NULL,
  `original_account_id` int(11) NOT NULL,
  `character_name` varchar(255) NOT NULL,
  `time` datetime NOT NULL,
  `done` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote_deleted_characters`
--

INSERT INTO `znote_deleted_characters` (`id`, `original_account_id`, `character_name`, `time`, `done`) VALUES
(1, 32, 'Black  Knight', '2024-04-10 12:48:23', 0);

-- --------------------------------------------------------

--
-- Table structure for table `znote_forum`
--

CREATE TABLE `znote_forum` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `access` tinyint(4) NOT NULL,
  `closed` tinyint(4) NOT NULL,
  `hidden` tinyint(4) NOT NULL,
  `guild_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote_forum`
--

INSERT INTO `znote_forum` (`id`, `name`, `access`, `closed`, `hidden`, `guild_id`) VALUES
(1, 'Staff Board', 4, 0, 0, 0),
(2, 'Tutors Board', 2, 0, 0, 0),
(3, 'Discussion', 1, 0, 0, 0),
(4, 'Feedback', 1, 0, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `znote_forum_posts`
--

CREATE TABLE `znote_forum_posts` (
  `id` int(11) NOT NULL,
  `thread_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(50) NOT NULL,
  `text` text NOT NULL,
  `created` int(11) NOT NULL,
  `updated` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_forum_threads`
--

CREATE TABLE `znote_forum_threads` (
  `id` int(11) NOT NULL,
  `forum_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `text` text NOT NULL,
  `created` int(11) NOT NULL,
  `updated` int(11) NOT NULL,
  `sticky` tinyint(4) NOT NULL,
  `hidden` tinyint(4) NOT NULL,
  `closed` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_global_storage`
--

CREATE TABLE `znote_global_storage` (
  `key` varchar(32) NOT NULL,
  `value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_guild_wars`
--

CREATE TABLE `znote_guild_wars` (
  `id` int(11) NOT NULL,
  `limit` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_images`
--

CREATE TABLE `znote_images` (
  `id` int(11) NOT NULL,
  `title` varchar(30) NOT NULL,
  `desc` text NOT NULL,
  `date` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `image` varchar(50) NOT NULL,
  `delhash` varchar(30) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_news`
--

CREATE TABLE `znote_news` (
  `id` int(11) NOT NULL,
  `title` varchar(30) NOT NULL,
  `text` text NOT NULL,
  `date` int(11) NOT NULL,
  `pid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote_news`
--

INSERT INTO `znote_news` (`id`, `title`, `text`, `date`, `pid`) VALUES
(1, '', '<div><a href=\"https://discord.gg/6ZZvkVuRkd\">Discord</a></div>', 1712167941, 5),
(2, '', '<br><div><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a></div><div><br></div><div><img src=\"https://i.imgur.com/wie2c8K.png\" width=\"673\"><br></div>', 1712411198, 45),
(3, '', 'map update<div><br><div><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a><br><div><br><div><br></div></div></div></div><div><img src=\"https://i.imgur.com/OJ4a3xq.png\" width=\"647\"><br></div>', 1712596858, 45),
(4, 'map update', '<div><br></div><div>map update<div><br><div><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a></div></div></div><div><br></div><img src=\"https://i.imgur.com/NXHm8io.png\" width=\"654\"><br><div><br></div>', 1712596879, 45),
(5, '', 'map update<div><br><div><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a></div></div><div><br></div><div><img src=\"https://i.imgur.com/BOY9IQ8.png\" width=\"758\"><br></div>', 1712596979, 45),
(6, '', 'map update<div><br><div><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a></div></div><div><img src=\"https://i.imgur.com/KvkUSrE.png\" width=\"755\"><br></div>', 1712596991, 45),
(7, '', '<blockquote style=\"margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><img src=\"https://i.imgur.com/8lOFKA9.png\" alt=\"\" align=\"none\"><br></blockquote></blockquote>', 1712685048, 45),
(8, '', '<blockquote style=\"margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\">Welcome to the&nbsp;<b>Tibia74</b>&nbsp;Experience where rook meets mainland.</blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><br></blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><b>Make sure to hop on to our :&nbsp; ~</b><a href=\"https://discord.gg/rpdh79TYAj\">Discord</a>~</blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><br></blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\">Between your actions there is always a delay.</blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\">&nbsp;unlike many popular bot servers.</blockquote><blockquote style=\"text-align: center; margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><br></blockquote><div style=\"text-align: center;\">This is a&nbsp;<b>PVP</b>&nbsp;server.</div><div style=\"text-align: center;\">protection zones are only in Temple, Houses, and within 1 sqm of deposit.</div><div style=\"text-align: center;\"><br></div><div style=\"text-align: center;\">Experience: x3 until level 8 and x2 then</div><div style=\"text-align: center;\">Skills: x4</div><div style=\"text-align: center;\">Magic: x1 (7.4 cost) classic regen</div></blockquote><div style=\"text-align: center;\"><br></div><div style=\"text-align: center;\"><div><b>Botting and Macro</b></div><div>Heavily forbidden.</div><div>Okay to train on MC.</div></div><div style=\"text-align: center;\"><div><br></div><div><br></div><b>Promotion and Vocations</b><b>Sorcerers and druids.</b><div>Incremented the mana cost of spells due to the fact they start at level 1 and get way more mana.</div></div><div style=\"text-align: center;\">Blank runes cost 10 soul points and 50 mana (Soul regen is 30 ticks).</div><div style=\"text-align: center;\">exevo pan costs 5 soul points(Available to all vocations).</div><div style=\"text-align: center;\">Wands and Rods damage and mana cost lowered.</div><div style=\"text-align: center;\"><b>Palladins and Knights</b></div><div style=\"text-align: center;\"><div>Included all melee and distance bonuses for items that drop from monsters.</div><div>*WIP*</div></div><blockquote style=\"margin: 0px 0px 0px 40px; border: none; padding: 0px;\"><div style=\"text-align: center;\"><br></div></blockquote>', 1713379344, 45);

-- --------------------------------------------------------

--
-- Table structure for table `znote_paygol`
--

CREATE TABLE `znote_paygol` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `points` int(11) NOT NULL,
  `message_id` varchar(255) NOT NULL,
  `service_id` varchar(255) NOT NULL,
  `shortcode` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `sender` varchar(255) NOT NULL,
  `operator` varchar(255) NOT NULL,
  `country` varchar(255) NOT NULL,
  `currency` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_paypal`
--

CREATE TABLE `znote_paypal` (
  `id` int(11) NOT NULL,
  `txn_id` varchar(30) NOT NULL,
  `email` varchar(255) NOT NULL,
  `accid` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_players`
--

CREATE TABLE `znote_players` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `created` int(11) NOT NULL,
  `hide_char` tinyint(4) NOT NULL,
  `comment` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

--
-- Dumping data for table `znote_players`
--

INSERT INTO `znote_players` (`id`, `player_id`, `created`, `hide_char`, `comment`) VALUES
(1, 1, 1705152009, 0, ''),
(8, 17, 1712051325, 0, ''),
(9, 18, 1712051709, 0, ''),
(10, 19, 1712051778, 0, ''),
(11, 20, 1712051782, 0, ''),
(12, 21, 1712051785, 0, ''),
(13, 22, 1712051790, 0, ''),
(14, 23, 1712052136, 0, ''),
(15, 24, 1712053700, 0, ''),
(16, 25, 1712054186, 0, ''),
(17, 26, 1712067004, 0, ''),
(18, 27, 1712068057, 0, ''),
(19, 28, 1712071254, 0, ''),
(20, 29, 1712073708, 0, ''),
(21, 30, 1712081981, 0, ''),
(22, 31, 1712082631, 0, ''),
(23, 32, 1712083549, 0, ''),
(24, 33, 1712091673, 0, ''),
(25, 34, 1712091717, 0, ''),
(26, 35, 1712096860, 0, ''),
(27, 36, 1712152945, 0, ''),
(28, 37, 1712153066, 0, ''),
(29, 38, 1712167744, 0, ''),
(30, 39, 1712264395, 0, ''),
(31, 40, 1712308109, 0, ''),
(32, 41, 1712317248, 0, ''),
(33, 42, 1712357500, 0, ''),
(34, 43, 1712357627, 1, ''),
(35, 44, 1712400340, 0, ''),
(36, 45, 1712402561, 0, ''),
(37, 46, 1712404576, 1, ''),
(38, 47, 1712420396, 0, ''),
(39, 48, 1712423051, 1, ''),
(40, 49, 1712423053, 0, ''),
(41, 50, 1712423087, 1, ''),
(42, 51, 1712430024, 0, ''),
(43, 52, 1712430773, 0, ''),
(44, 53, 1712435678, 0, ''),
(45, 54, 1712448417, 0, ''),
(46, 55, 1712489139, 0, ''),
(47, 56, 1712493995, 0, ''),
(48, 57, 1712494151, 0, ''),
(49, 58, 1712494430, 0, ''),
(50, 59, 1712494677, 0, ''),
(52, 61, 1712502295, 0, ''),
(54, 63, 1712522017, 0, ''),
(55, 64, 1712522619, 0, ''),
(56, 65, 1712522829, 0, ''),
(57, 66, 1712524566, 0, ''),
(58, 67, 1712603923, 0, ''),
(59, 68, 1712606350, 0, ''),
(60, 69, 1712681875, 0, ''),
(61, 70, 1712693416, 0, ''),
(62, 71, 1712766716, 0, ''),
(63, 72, 1712772973, 0, ''),
(64, 73, 1712927372, 0, ''),
(65, 74, 1712927382, 0, ''),
(66, 75, 1712927396, 0, ''),
(67, 76, 1712927404, 0, ''),
(68, 77, 1712928057, 0, ''),
(69, 78, 1712928987, 0, ''),
(70, 79, 1712929016, 0, ''),
(71, 80, 1712929057, 0, ''),
(72, 81, 1712946201, 0, ''),
(73, 82, 1712946344, 0, ''),
(74, 83, 1712946457, 0, ''),
(75, 84, 1712946531, 0, ''),
(76, 85, 1713020933, 0, ''),
(77, 86, 1713020942, 0, ''),
(78, 87, 1713031533, 0, ''),
(79, 88, 1713124902, 0, ''),
(80, 89, 1713164829, 0, ''),
(81, 90, 1713207297, 0, ''),
(82, 91, 1713213819, 0, ''),
(83, 92, 1713221192, 0, ''),
(84, 93, 1713221346, 0, ''),
(85, 94, 1713367826, 0, ''),
(86, 95, 1713375436, 0, ''),
(87, 96, 1713375446, 0, ''),
(88, 97, 1713375452, 0, ''),
(89, 98, 1713375473, 0, ''),
(90, 99, 1713375482, 0, ''),
(91, 100, 1713375488, 0, ''),
(92, 101, 1713375495, 0, ''),
(93, 102, 1713376029, 0, ''),
(94, 103, 1713378675, 0, ''),
(95, 104, 1713549677, 0, '');

-- --------------------------------------------------------

--
-- Table structure for table `znote_player_reports`
--

CREATE TABLE `znote_player_reports` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `posx` int(11) NOT NULL,
  `posy` int(11) NOT NULL,
  `posz` int(11) NOT NULL,
  `report_description` varchar(255) NOT NULL,
  `date` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_shop`
--

CREATE TABLE `znote_shop` (
  `id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) DEFAULT NULL,
  `count` int(11) NOT NULL DEFAULT 1,
  `description` varchar(255) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_shop_logs`
--

CREATE TABLE `znote_shop_logs` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `points` int(11) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_shop_orders`
--

CREATE TABLE `znote_shop_orders` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `time` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_tickets`
--

CREATE TABLE `znote_tickets` (
  `id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `subject` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `message` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` bigint(20) NOT NULL,
  `creation` int(11) NOT NULL,
  `status` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_tickets_replies`
--

CREATE TABLE `znote_tickets_replies` (
  `id` int(11) NOT NULL,
  `tid` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `message` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `created` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_visitors`
--

CREATE TABLE `znote_visitors` (
  `id` int(11) NOT NULL,
  `ip` bigint(20) NOT NULL,
  `value` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `znote_visitors_details`
--

CREATE TABLE `znote_visitors_details` (
  `id` int(11) NOT NULL,
  `ip` bigint(20) NOT NULL,
  `time` int(11) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- --------------------------------------------------------

--
-- Table structure for table `z_polls`
--

CREATE TABLE `z_polls` (
  `id` int(11) NOT NULL,
  `question` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `end` int(11) NOT NULL DEFAULT 0,
  `start` int(11) NOT NULL DEFAULT 0,
  `answers` int(11) NOT NULL DEFAULT 0,
  `votes_all` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `z_polls_answers`
--

CREATE TABLE `z_polls_answers` (
  `poll_id` int(11) NOT NULL,
  `answer_id` int(11) NOT NULL,
  `answer` varchar(255) NOT NULL,
  `votes` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `account_bans`
--
ALTER TABLE `account_bans`
  ADD PRIMARY KEY (`account_id`),
  ADD KEY `banned_by` (`banned_by`);

--
-- Indexes for table `account_ban_history`
--
ALTER TABLE `account_ban_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `banned_by` (`banned_by`);

--
-- Indexes for table `account_storage`
--
ALTER TABLE `account_storage`
  ADD PRIMARY KEY (`account_id`,`key`);

--
-- Indexes for table `account_viplist`
--
ALTER TABLE `account_viplist`
  ADD UNIQUE KEY `account_player_index` (`account_id`,`player_id`),
  ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `guilds`
--
ALTER TABLE `guilds`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `ownerid` (`ownerid`);

--
-- Indexes for table `guildwar_kills`
--
ALTER TABLE `guildwar_kills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `warid` (`warid`);

--
-- Indexes for table `guild_invites`
--
ALTER TABLE `guild_invites`
  ADD PRIMARY KEY (`player_id`,`guild_id`),
  ADD KEY `guild_id` (`guild_id`);

--
-- Indexes for table `guild_membership`
--
ALTER TABLE `guild_membership`
  ADD PRIMARY KEY (`player_id`),
  ADD KEY `guild_id` (`guild_id`),
  ADD KEY `rank_id` (`rank_id`);

--
-- Indexes for table `guild_ranks`
--
ALTER TABLE `guild_ranks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guild_id` (`guild_id`);

--
-- Indexes for table `guild_wars`
--
ALTER TABLE `guild_wars`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guild1` (`guild1`),
  ADD KEY `guild2` (`guild2`);

--
-- Indexes for table `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `owner` (`owner`),
  ADD KEY `town_id` (`town_id`);

--
-- Indexes for table `house_lists`
--
ALTER TABLE `house_lists`
  ADD KEY `house_id` (`house_id`);

--
-- Indexes for table `ip_bans`
--
ALTER TABLE `ip_bans`
  ADD PRIMARY KEY (`ip`),
  ADD KEY `banned_by` (`banned_by`);

--
-- Indexes for table `live_casts`
--
ALTER TABLE `live_casts`
  ADD PRIMARY KEY (`player_id`);

--
-- Indexes for table `market_history`
--
ALTER TABLE `market_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`,`sale`);

--
-- Indexes for table `market_offers`
--
ALTER TABLE `market_offers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sale` (`sale`,`itemtype`),
  ADD KEY `created` (`created`),
  ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `myaac_account_actions`
--
ALTER TABLE `myaac_account_actions`
  ADD KEY `account_id` (`account_id`);

--
-- Indexes for table `myaac_admin_menu`
--
ALTER TABLE `myaac_admin_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_bugtracker`
--
ALTER TABLE `myaac_bugtracker`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `myaac_changelog`
--
ALTER TABLE `myaac_changelog`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_config`
--
ALTER TABLE `myaac_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `myaac_faq`
--
ALTER TABLE `myaac_faq`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_forum`
--
ALTER TABLE `myaac_forum`
  ADD PRIMARY KEY (`id`),
  ADD KEY `section` (`section`);

--
-- Indexes for table `myaac_forum_boards`
--
ALTER TABLE `myaac_forum_boards`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_gallery`
--
ALTER TABLE `myaac_gallery`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_menu`
--
ALTER TABLE `myaac_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_monsters`
--
ALTER TABLE `myaac_monsters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_news`
--
ALTER TABLE `myaac_news`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_news_categories`
--
ALTER TABLE `myaac_news_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_notepad`
--
ALTER TABLE `myaac_notepad`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_pages`
--
ALTER TABLE `myaac_pages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `myaac_spells`
--
ALTER TABLE `myaac_spells`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `myaac_videos`
--
ALTER TABLE `myaac_videos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `myaac_visitors`
--
ALTER TABLE `myaac_visitors`
  ADD UNIQUE KEY `ip` (`ip`);

--
-- Indexes for table `myaac_weapons`
--
ALTER TABLE `myaac_weapons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `vocation` (`vocation`);

--
-- Indexes for table `players_online`
--
ALTER TABLE `players_online`
  ADD PRIMARY KEY (`player_id`);

--
-- Indexes for table `player_deaths`
--
ALTER TABLE `player_deaths`
  ADD KEY `player_id` (`player_id`),
  ADD KEY `killed_by` (`killed_by`),
  ADD KEY `mostdamage_by` (`mostdamage_by`);

--
-- Indexes for table `player_depotitems`
--
ALTER TABLE `player_depotitems`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`);

--
-- Indexes for table `player_depotlockeritems`
--
ALTER TABLE `player_depotlockeritems`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`);

--
-- Indexes for table `player_inboxitems`
--
ALTER TABLE `player_inboxitems`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`);

--
-- Indexes for table `player_items`
--
ALTER TABLE `player_items`
  ADD KEY `player_id` (`player_id`),
  ADD KEY `sid` (`sid`);

--
-- Indexes for table `player_namelocks`
--
ALTER TABLE `player_namelocks`
  ADD PRIMARY KEY (`player_id`),
  ADD KEY `namelocked_by` (`namelocked_by`);

--
-- Indexes for table `player_spells`
--
ALTER TABLE `player_spells`
  ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `player_storage`
--
ALTER TABLE `player_storage`
  ADD PRIMARY KEY (`player_id`,`key`);

--
-- Indexes for table `player_storeinboxitems`
--
ALTER TABLE `player_storeinboxitems`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`);

--
-- Indexes for table `server_config`
--
ALTER TABLE `server_config`
  ADD PRIMARY KEY (`config`);

--
-- Indexes for table `shop_history`
--
ALTER TABLE `shop_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account` (`account`),
  ADD KEY `player` (`player`);

--
-- Indexes for table `tile_store`
--
ALTER TABLE `tile_store`
  ADD KEY `house_id` (`house_id`);

--
-- Indexes for table `towns`
--
ALTER TABLE `towns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `znote`
--
ALTER TABLE `znote`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_accounts`
--
ALTER TABLE `znote_accounts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_auction_player`
--
ALTER TABLE `znote_auction_player`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_changelog`
--
ALTER TABLE `znote_changelog`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_deleted_characters`
--
ALTER TABLE `znote_deleted_characters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_forum`
--
ALTER TABLE `znote_forum`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_forum_posts`
--
ALTER TABLE `znote_forum_posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_forum_threads`
--
ALTER TABLE `znote_forum_threads`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_global_storage`
--
ALTER TABLE `znote_global_storage`
  ADD UNIQUE KEY `key` (`key`);

--
-- Indexes for table `znote_guild_wars`
--
ALTER TABLE `znote_guild_wars`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_images`
--
ALTER TABLE `znote_images`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_news`
--
ALTER TABLE `znote_news`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_paygol`
--
ALTER TABLE `znote_paygol`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_paypal`
--
ALTER TABLE `znote_paypal`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_players`
--
ALTER TABLE `znote_players`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_player_reports`
--
ALTER TABLE `znote_player_reports`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_shop`
--
ALTER TABLE `znote_shop`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_shop_logs`
--
ALTER TABLE `znote_shop_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_shop_orders`
--
ALTER TABLE `znote_shop_orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_tickets`
--
ALTER TABLE `znote_tickets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_tickets_replies`
--
ALTER TABLE `znote_tickets_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_visitors`
--
ALTER TABLE `znote_visitors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `znote_visitors_details`
--
ALTER TABLE `znote_visitors_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `z_polls`
--
ALTER TABLE `z_polls`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `account_ban_history`
--
ALTER TABLE `account_ban_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `guilds`
--
ALTER TABLE `guilds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guildwar_kills`
--
ALTER TABLE `guildwar_kills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guild_ranks`
--
ALTER TABLE `guild_ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guild_wars`
--
ALTER TABLE `guild_wars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `houses`
--
ALTER TABLE `houses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1055;

--
-- AUTO_INCREMENT for table `market_history`
--
ALTER TABLE `market_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `market_offers`
--
ALTER TABLE `market_offers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_admin_menu`
--
ALTER TABLE `myaac_admin_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_bugtracker`
--
ALTER TABLE `myaac_bugtracker`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_changelog`
--
ALTER TABLE `myaac_changelog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `myaac_config`
--
ALTER TABLE `myaac_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `myaac_faq`
--
ALTER TABLE `myaac_faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_forum`
--
ALTER TABLE `myaac_forum`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_forum_boards`
--
ALTER TABLE `myaac_forum_boards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `myaac_gallery`
--
ALTER TABLE `myaac_gallery`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `myaac_menu`
--
ALTER TABLE `myaac_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `myaac_monsters`
--
ALTER TABLE `myaac_monsters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT for table `myaac_news`
--
ALTER TABLE `myaac_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `myaac_news_categories`
--
ALTER TABLE `myaac_news_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `myaac_notepad`
--
ALTER TABLE `myaac_notepad`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `myaac_pages`
--
ALTER TABLE `myaac_pages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `myaac_spells`
--
ALTER TABLE `myaac_spells`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- AUTO_INCREMENT for table `myaac_videos`
--
ALTER TABLE `myaac_videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `shop_history`
--
ALTER TABLE `shop_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `towns`
--
ALTER TABLE `towns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `znote`
--
ALTER TABLE `znote`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `znote_accounts`
--
ALTER TABLE `znote_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `znote_auction_player`
--
ALTER TABLE `znote_auction_player`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_changelog`
--
ALTER TABLE `znote_changelog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_deleted_characters`
--
ALTER TABLE `znote_deleted_characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `znote_forum`
--
ALTER TABLE `znote_forum`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `znote_forum_posts`
--
ALTER TABLE `znote_forum_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_forum_threads`
--
ALTER TABLE `znote_forum_threads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_guild_wars`
--
ALTER TABLE `znote_guild_wars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_images`
--
ALTER TABLE `znote_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_news`
--
ALTER TABLE `znote_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `znote_paygol`
--
ALTER TABLE `znote_paygol`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_paypal`
--
ALTER TABLE `znote_paypal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_players`
--
ALTER TABLE `znote_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT for table `znote_player_reports`
--
ALTER TABLE `znote_player_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_shop`
--
ALTER TABLE `znote_shop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_shop_logs`
--
ALTER TABLE `znote_shop_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_shop_orders`
--
ALTER TABLE `znote_shop_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_tickets`
--
ALTER TABLE `znote_tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_tickets_replies`
--
ALTER TABLE `znote_tickets_replies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_visitors`
--
ALTER TABLE `znote_visitors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `znote_visitors_details`
--
ALTER TABLE `znote_visitors_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `z_polls`
--
ALTER TABLE `z_polls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `account_bans`
--
ALTER TABLE `account_bans`
  ADD CONSTRAINT `account_bans_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `account_bans_ibfk_2` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `account_ban_history`
--
ALTER TABLE `account_ban_history`
  ADD CONSTRAINT `account_ban_history_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `account_ban_history_ibfk_2` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `account_storage`
--
ALTER TABLE `account_storage`
  ADD CONSTRAINT `account_storage_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `account_viplist`
--
ALTER TABLE `account_viplist`
  ADD CONSTRAINT `account_viplist_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `account_viplist_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guilds`
--
ALTER TABLE `guilds`
  ADD CONSTRAINT `guilds_ibfk_1` FOREIGN KEY (`ownerid`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guildwar_kills`
--
ALTER TABLE `guildwar_kills`
  ADD CONSTRAINT `guildwar_kills_ibfk_1` FOREIGN KEY (`warid`) REFERENCES `guild_wars` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guild_invites`
--
ALTER TABLE `guild_invites`
  ADD CONSTRAINT `guild_invites_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_invites_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guild_membership`
--
ALTER TABLE `guild_membership`
  ADD CONSTRAINT `guild_membership_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `guild_membership_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `guild_membership_ibfk_3` FOREIGN KEY (`rank_id`) REFERENCES `guild_ranks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `guild_ranks`
--
ALTER TABLE `guild_ranks`
  ADD CONSTRAINT `guild_ranks_ibfk_1` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `house_lists`
--
ALTER TABLE `house_lists`
  ADD CONSTRAINT `house_lists_ibfk_1` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `ip_bans`
--
ALTER TABLE `ip_bans`
  ADD CONSTRAINT `ip_bans_ibfk_1` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `market_history`
--
ALTER TABLE `market_history`
  ADD CONSTRAINT `market_history_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `market_offers`
--
ALTER TABLE `market_offers`
  ADD CONSTRAINT `market_offers_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `players`
--
ALTER TABLE `players`
  ADD CONSTRAINT `players_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_deaths`
--
ALTER TABLE `player_deaths`
  ADD CONSTRAINT `player_deaths_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_depotitems`
--
ALTER TABLE `player_depotitems`
  ADD CONSTRAINT `player_depotitems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_depotlockeritems`
--
ALTER TABLE `player_depotlockeritems`
  ADD CONSTRAINT `player_depotlockeritems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_inboxitems`
--
ALTER TABLE `player_inboxitems`
  ADD CONSTRAINT `player_inboxitems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_items`
--
ALTER TABLE `player_items`
  ADD CONSTRAINT `player_items_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_namelocks`
--
ALTER TABLE `player_namelocks`
  ADD CONSTRAINT `player_namelocks_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `player_namelocks_ibfk_2` FOREIGN KEY (`namelocked_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `player_spells`
--
ALTER TABLE `player_spells`
  ADD CONSTRAINT `player_spells_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_storage`
--
ALTER TABLE `player_storage`
  ADD CONSTRAINT `player_storage_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `player_storeinboxitems`
--
ALTER TABLE `player_storeinboxitems`
  ADD CONSTRAINT `player_storeinboxitems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shop_history`
--
ALTER TABLE `shop_history`
  ADD CONSTRAINT `shop_history_ibfk_1` FOREIGN KEY (`account`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shop_history_ibfk_2` FOREIGN KEY (`player`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tile_store`
--
ALTER TABLE `tile_store`
  ADD CONSTRAINT `tile_store_ibfk_1` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
