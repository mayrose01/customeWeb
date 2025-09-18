-- MySQL dump 10.13  Distrib 9.3.0, for macos14.7 (arm64)
--
-- Host: localhost    Database: enterprise_dev
-- ------------------------------------------------------
-- Server version	9.3.0

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

--
-- Table structure for table `carousel_images`
--

DROP TABLE IF EXISTS `carousel_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carousel_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `caption` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sort_order` int DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_carousel_images_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carousel_images`
--

LOCK TABLES `carousel_images` WRITE;
/*!40000 ALTER TABLE `carousel_images` DISABLE KEYS */;
INSERT INTO `carousel_images` VALUES (1,'http://localhost:8000/uploads/7adcc645-3745-43e8-9ffc-c5b9c25105d3.jpg','配图','文章配图',2,1),(2,'http://localhost:8000/uploads/6576a6b4-afff-41cc-85e1-997802d3cddd.jpg','视频服务','视频服务',3,1),(6,'http://localhost:8000/uploads/306b2bfe-9f43-4896-ab61-5887f4572ddc.jpg','开发轮播图','',0,1);
/*!40000 ALTER TABLE `carousel_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cart_user_id` (`user_id`),
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (1,15,'2025-08-13 04:17:37','2025-08-13 04:17:37');
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_item`
--

DROP TABLE IF EXISTS `cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `sku_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sku_id` (`sku_id`),
  KEY `idx_cart_item_cart_id` (`cart_id`),
  CONSTRAINT `cart_item_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_item_ibfk_2` FOREIGN KEY (`sku_id`) REFERENCES `product_sku` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
INSERT INTO `cart_item` VALUES (5,1,14,1,'2025-08-17 09:42:01','2025-08-17 09:42:01'),(8,1,45,1,'2025-08-17 09:45:42','2025-08-19 14:42:53');
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `parent_id` int DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` int DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (20,'品牌宣传',NULL,NULL,21,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(21,'品牌策划',NULL,20,24,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(22,'新媒体',NULL,NULL,10,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(23,'公众号文章',NULL,22,11,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(24,'小红书图文',NULL,22,12,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(25,'视频剪辑',NULL,22,13,1,'2025-09-04 09:22:38','2025-09-04 09:22:38',''),(26,'自媒体',NULL,NULL,0,1,'2025-09-04 09:22:38','2025-09-04 09:22:38','');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_id` int DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `ix_category_id` (`id`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (18,'品牌文案',20,'http://localhost:8000/uploads/31af71ec-67ad-4831-9cfa-0f1b2ec1041c.jpg',22),(19,'品牌设计',20,'',23),(20,'品牌宣传',NULL,'',21),(21,'品牌策划',20,'',24),(22,'新媒体',NULL,'',10),(23,'公众号文章',22,'',11),(24,'小红书图文',22,'',12),(25,'视频剪辑',22,'',13),(26,'自媒体',NULL,'',0);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_info`
--

DROP TABLE IF EXISTS `company_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `main_business` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `main_pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `working_hours` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_company_info_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_info`
--

LOCK TABLES `company_info` WRITE;
/*!40000 ALTER TABLE `company_info` DISABLE KEYS */;
INSERT INTO `company_info` VALUES (1,'915356588@qq.com','15112371234','dev卡图福托','http://localhost:8000/uploads/614733ff-f0c5-4667-a8b1-15ae3b021a76.jpg','个性化定制服务，文章，商品图片，文章配图，视频，品牌策划。','http://localhost:8000/uploads/6f09c28d-5a9d-4006-9b34-0d2a5abd9b6a.jpg',' 非常优秀的几位达人组成的公司联盟，专注于为品宣服务。\n','深圳市龙岗区龙城街道如意路322号','周一至周五9:00-18:00','http://localhost:8000/uploads/7fcb26eb-0cbd-43f4-913d-73458ecfa0ed.jpg');
/*!40000 ALTER TABLE `company_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_fields`
--

DROP TABLE IF EXISTS `contact_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_fields` (
  `id` int NOT NULL AUTO_INCREMENT,
  `field_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_required` int DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_contact_fields_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_fields`
--

LOCK TABLES `contact_fields` WRITE;
/*!40000 ALTER TABLE `contact_fields` DISABLE KEYS */;
INSERT INTO `contact_fields` VALUES (1,'name','姓名','text',1,1),(2,'email','邮箱','email',1,2),(3,'phone','电话','tel',0,3),(4,'message','留言内容','textarea',1,4);
/*!40000 ALTER TABLE `contact_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_contact_messages_id` (`id`),
  KEY `fk_contact_messages_user` (`user_id`),
  CONSTRAINT `fk_contact_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES (2,'miss黄','915356588@qq.com','15111112222','测试邮件2','2025-07-27 14:55:59','联系我们的咨询',NULL),(8,'miss黄','1047753553@qq.com','15111112222','测试联系我们邮件','2025-07-28 03:43:24','联系我们的咨询',NULL),(9,'黄女士','mayrose01@163.com','15111112222','联系我们','2025-07-28 13:35:30','联系我们的咨询',NULL),(10,'黄女士','test04@163.com','13422223333','测试联系我们','2025-07-29 20:13:48','联系我们的咨询',13),(11,'miss黄','test04@163.com','13422223333','test email','2025-07-29 20:23:48','联系我们的咨询',13),(12,'张三','test05@163.com','13112341235','测试dev','2025-08-02 13:18:43','联系我们的咨询',14);
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inquiry`
--

DROP TABLE IF EXISTS `inquiry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inquiry` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `product_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inquiry_subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inquiry_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int DEFAULT NULL,
  `product_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `ix_inquiry_id` (`id`),
  KEY `fk_inquiry_user` (`user_id`),
  CONSTRAINT `fk_inquiry_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inquiry_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry`
--

LOCK TABLES `inquiry` WRITE;
/*!40000 ALTER TABLE `inquiry` DISABLE KEYS */;
/*!40000 ALTER TABLE `inquiry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_cart_items`
--

DROP TABLE IF EXISTS `mall_cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_cart_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `product_id` int NOT NULL,
  `sku_id` int DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cart_id` (`cart_id`),
  KEY `product_id` (`product_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `mall_cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `mall_carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mall_cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `mall_products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mall_cart_items_ibfk_3` FOREIGN KEY (`sku_id`) REFERENCES `mall_product_skus` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_cart_items`
--

LOCK TABLES `mall_cart_items` WRITE;
/*!40000 ALTER TABLE `mall_cart_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `mall_cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_carts`
--

DROP TABLE IF EXISTS `mall_carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_carts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `mall_carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_carts`
--

LOCK TABLES `mall_carts` WRITE;
/*!40000 ALTER TABLE `mall_carts` DISABLE KEYS */;
/*!40000 ALTER TABLE `mall_carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_categories`
--

DROP TABLE IF EXISTS `mall_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `parent_id` int DEFAULT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `mall_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `mall_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_categories`
--

LOCK TABLES `mall_categories` WRITE;
/*!40000 ALTER TABLE `mall_categories` DISABLE KEYS */;
INSERT INTO `mall_categories` VALUES (1,'电子产品','手机、电脑、配件等数码产品',NULL,NULL,1,'active','2025-09-02 09:27:50','2025-09-02 12:54:20'),(2,'服装鞋帽','男装、女装、童装、鞋帽等',NULL,NULL,2,'active','2025-09-02 09:27:50','2025-09-02 12:54:23'),(3,'家居用品','家具、装饰、厨具等家居产品',NULL,NULL,3,'active','2025-09-02 09:27:50','2025-09-02 12:54:25'),(4,'美妆护肤','护肤品、彩妆、香水等',NULL,NULL,4,'active','2025-09-02 09:27:50','2025-09-02 12:54:28'),(5,'运动户外','运动装备、户外用品等',NULL,NULL,5,'active','2025-09-02 09:27:50','2025-09-02 12:54:30');
/*!40000 ALTER TABLE `mall_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_order_items`
--

DROP TABLE IF EXISTS `mall_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `sku_id` int DEFAULT NULL,
  `product_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku_specifications` json DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `mall_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `mall_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mall_order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `mall_products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mall_order_items_ibfk_3` FOREIGN KEY (`sku_id`) REFERENCES `mall_product_skus` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_order_items`
--

LOCK TABLES `mall_order_items` WRITE;
/*!40000 ALTER TABLE `mall_order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `mall_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_orders`
--

DROP TABLE IF EXISTS `mall_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `payment_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'unpaid',
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_time` timestamp NULL DEFAULT NULL,
  `shipping_address` text COLLATE utf8mb4_unicode_ci,
  `shipping_company` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_time` timestamp NULL DEFAULT NULL,
  `remark` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `mall_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_orders`
--

LOCK TABLES `mall_orders` WRITE;
/*!40000 ALTER TABLE `mall_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `mall_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_product_skus`
--

DROP TABLE IF EXISTS `mall_product_skus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_product_skus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `sku_code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int DEFAULT '0',
  `weight` decimal(8,3) DEFAULT '0.000',
  `specifications` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku_code` (`sku_code`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `mall_product_skus_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `mall_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_product_skus`
--

LOCK TABLES `mall_product_skus` WRITE;
/*!40000 ALTER TABLE `mall_product_skus` DISABLE KEYS */;
INSERT INTO `mall_product_skus` VALUES (7,6,'ipad_128G',999.00,20,0.000,'{\"内存\": \"128G\"}','2025-09-02 14:08:16','2025-09-02 14:08:16'),(8,6,'ipad_256G',1499.00,10,0.000,'{\"内存\": \"256G\"}','2025-09-02 14:08:16','2025-09-02 14:08:16'),(9,1,'智能手机iphone14_黑色_256G',3999.00,50,0.000,'{\"内存\": \"256G\", \"颜色\": \"黑色\"}','2025-09-02 14:13:50','2025-09-02 14:13:50'),(10,1,'智能手机iphone14_黑色_512G',2999.00,60,0.000,'{\"内存\": \"512G\", \"颜色\": \"黑色\"}','2025-09-02 14:13:50','2025-09-02 14:13:50'),(11,1,'智能手机iphone14_白色_256G',3999.00,50,0.000,'{\"内存\": \"256G\", \"颜色\": \"白色\"}','2025-09-02 14:13:50','2025-09-02 14:13:50'),(12,1,'智能手机iphone14_白色_512G',2999.00,60,0.000,'{\"内存\": \"512G\", \"颜色\": \"白色\"}','2025-09-02 14:13:50','2025-09-02 14:13:50'),(13,2,'无线耳机_黑色',309.00,100,0.000,'{\"颜色\": \"黑色\"}','2025-09-02 14:14:47','2025-09-02 14:14:47'),(14,2,'无线耳机_白色',299.00,105,0.000,'{\"颜色\": \"白色\"}','2025-09-02 14:14:47','2025-09-02 14:14:47'),(15,5,'女士连衣裙_M',199.00,50,0.000,'{\"尺寸\": \"M\"}','2025-09-02 14:15:46','2025-09-02 14:15:46'),(16,5,'女士连衣裙_L',209.00,60,0.000,'{\"尺寸\": \"L\"}','2025-09-02 14:15:46','2025-09-02 14:15:46');
/*!40000 ALTER TABLE `mall_product_skus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_product_specification_values`
--

DROP TABLE IF EXISTS `mall_product_specification_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_product_specification_values` (
  `id` int NOT NULL AUTO_INCREMENT,
  `specification_id` int NOT NULL,
  `value` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `specification_id` (`specification_id`),
  CONSTRAINT `mall_product_specification_values_ibfk_1` FOREIGN KEY (`specification_id`) REFERENCES `mall_product_specifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_product_specification_values`
--

LOCK TABLES `mall_product_specification_values` WRITE;
/*!40000 ALTER TABLE `mall_product_specification_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `mall_product_specification_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_product_specifications`
--

DROP TABLE IF EXISTS `mall_product_specifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_product_specifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `mall_product_specifications_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `mall_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_product_specifications`
--

LOCK TABLES `mall_product_specifications` WRITE;
/*!40000 ALTER TABLE `mall_product_specifications` DISABLE KEYS */;
INSERT INTO `mall_product_specifications` VALUES (1,6,'内存',0,'2025-09-02 13:36:00'),(2,6,'内存',0,'2025-09-02 13:36:35'),(3,6,'内存',0,'2025-09-02 13:37:06'),(4,6,'内存',0,'2025-09-02 13:38:06'),(5,6,'内存',0,'2025-09-02 13:43:44'),(6,6,'颜色',0,'2025-09-02 13:53:27'),(7,6,'内存',0,'2025-09-02 13:57:59'),(8,6,'内存',0,'2025-09-02 14:02:48'),(9,6,'内存',0,'2025-09-02 14:03:58'),(10,6,'内存',0,'2025-09-02 14:08:16'),(11,1,'颜色',0,'2025-09-02 14:13:50'),(12,1,'内存',0,'2025-09-02 14:13:50'),(13,2,'颜色',0,'2025-09-02 14:14:47'),(14,5,'尺寸',0,'2025-09-02 14:15:46');
/*!40000 ALTER TABLE `mall_product_specifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mall_products`
--

DROP TABLE IF EXISTS `mall_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mall_products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `images` json DEFAULT NULL,
  `category_id` int NOT NULL,
  `base_price` decimal(10,2) DEFAULT '0.00',
  `stock` int DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `mall_products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `mall_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mall_products`
--

LOCK TABLES `mall_products` WRITE;
/*!40000 ALTER TABLE `mall_products` DISABLE KEYS */;
INSERT INTO `mall_products` VALUES (1,'智能手机iphone14','最新款智能手机，性能强劲iphone14','[\"/uploads/747ed915-80f7-4d87-8473-01202597d4d4.jpg\"]',1,2999.00,50,'active',1,'2025-09-02 09:27:50','2025-09-02 14:13:50'),(2,'无线耳机','高品质无线蓝牙耳机','[\"/uploads/a045cf97-9da0-4316-a2c3-f48b333b5f5d.jpg\"]',1,299.00,100,'active',2,'2025-09-02 09:27:50','2025-09-02 14:14:47'),(5,'女士连衣裙','时尚连衣裙','[\"/uploads/3b6fa881-07a8-45bb-bef5-8c6e5963aad3.jpg\"]',2,199.00,60,'active',2,'2025-09-02 09:27:50','2025-09-02 14:15:46'),(6,'ipad','ipad平板','[\"/uploads/ba388ee3-42c7-4e47-bddd-19d7ca114d24.jpg\"]',1,999.00,10,'active',0,'2025-09-02 09:43:33','2025-09-02 14:08:16');
/*!40000 ALTER TABLE `mall_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_no` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `total_amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(20) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'unpaid',
  `payment_time` timestamp NULL DEFAULT NULL,
  `shipping_address` text,
  `shipping_contact` varchar(100) DEFAULT NULL,
  `shipping_phone` varchar(50) DEFAULT NULL,
  `shipping_company` varchar(100) DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `shipping_time` timestamp NULL DEFAULT NULL,
  `delivery_time` timestamp NULL DEFAULT NULL,
  `remark` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `idx_order_user_id` (`user_id`),
  KEY `idx_order_order_no` (`order_no`),
  CONSTRAINT `order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
/*!40000 ALTER TABLE `order` DISABLE KEYS */;
INSERT INTO `order` VALUES (1,'ORD202508200C57A3C8',15,'pending',1.00,'alipay','unpaid',NULL,'广东省 深圳市 龙岗区 测试街道门牌号6号','测试六','13100010006',NULL,NULL,NULL,NULL,'测试订单备注信息自定义内容，规格颜色等。','2025-08-19 16:19:27','2025-08-19 16:19:27'),(2,'ORD20250820ACA6DCDC',15,'pending',1.00,'wechat','unpaid',NULL,'广东省 深圳市 龙岗区 测试街道门牌号6号','测试六','13100010006',NULL,NULL,NULL,NULL,'测试订单2','2025-08-19 16:35:52','2025-08-19 16:35:52'),(3,'ORD2025082025C26030',15,'pending',1.00,'alipay','unpaid',NULL,'广东省 深圳市 龙岗区 测试街道门牌号6号','测试六','13100010006',NULL,NULL,NULL,NULL,'','2025-08-20 03:33:04','2025-08-20 03:33:04');
/*!40000 ALTER TABLE `order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `sku_id` int DEFAULT NULL,
  `product_title` varchar(255) NOT NULL,
  `sku_code` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `specifications` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sku_id` (`sku_id`),
  KEY `idx_order_item_order_id` (`order_id`),
  CONSTRAINT `order_item_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_item_ibfk_2` FOREIGN KEY (`sku_id`) REFERENCES `product_sku` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,1,45,'微信公众号文章','DOC1-否-002',1.00,1,1.00,'{}','2025-08-19 16:19:27'),(2,2,45,'微信公众号文章','DOC1-否-002',1.00,1,1.00,'{}','2025-08-19 16:35:52'),(3,3,45,'微信公众号文章','DOC1-否-002',1.00,1,1.00,'{}','2025-08-20 03:33:03');
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `short_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `category_id` int DEFAULT NULL,
  `images` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `base_price` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `ix_product_id` (`id`),
  CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (14,'微信公众号文章','DOC1','<p>微信公众号文章、头条号文章、其他文案等。</p>','<p><img src=\"http://localhost:8000/uploads/afe0bf57-f67f-417d-8788-20dcd36c28dc.jpg\" alt=\"\" data-href=\"\" style=\"\"/></p>',18,'[\"/uploads/074065eb-b708-4f6a-8ea1-2615d3f0c4f8.jpg\", \"/uploads/78881527-fb59-41f7-83d0-50e514d2b87f.jpg\"]','2025-07-27 08:43:15','2025-08-12 10:44:56',0.00,1),(15,'宣传图片','IMG2','<p>文章配图。</p><p>商品宣传图片。</p>','<p><img src=\"http://localhost:8000/uploads/b46e42cb-dfb4-41b4-abae-bdcc3724ac24.png\" alt=\"\" data-href=\"\" style=\"\"/></p>',19,'[\"/uploads/4fea8a85-af1c-40d7-a081-dd95f6e62a8a.png\"]','2025-07-27 08:44:14','2025-08-02 02:28:02',0.00,1),(16,'品牌策划','PL3','<p>品牌策划相关内容。定制化服务。</p>','<p><img src=\"http://localhost:8000/uploads/4ad558b1-e166-4bc8-aee5-4a3d2c4d67a9.jpg\" alt=\"\" data-href=\"\" style=\"\"/></p>',21,'[\"/uploads/c8679f7c-68f1-4cf9-bbf0-3773f2249ef7.jpg\"]','2025-07-27 08:45:23','2025-08-12 10:44:16',0.00,0),(17,'web','web1','<p>web网站相关内容。定制化服务。</p>','<p><img src=\"http://localhost:8000/uploads/2d5152b8-2531-4118-a073-c909792b1e7a.jpg\" alt=\"\" data-href=\"\" style=\"\"/></p>',21,'[\"/uploads/426343e2-081b-4984-809e-b531363e0ae9.jpg\"]','2025-08-02 02:35:56','2025-08-02 02:36:35',0.00,1);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_sku`
--

DROP TABLE IF EXISTS `product_sku`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_sku` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `sku_code` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku_code` (`sku_code`),
  KEY `idx_product_sku_product_id` (`product_id`),
  KEY `idx_product_sku_code` (`sku_code`),
  CONSTRAINT `product_sku_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_sku`
--

LOCK TABLES `product_sku` WRITE;
/*!40000 ALTER TABLE `product_sku` DISABLE KEYS */;
INSERT INTO `product_sku` VALUES (14,15,'IMG2-ai-001',100.00,10,1,'2025-08-11 09:06:27','2025-08-11 09:06:27'),(15,15,'IMG2-实拍图修改设计-002',200.00,10,1,'2025-08-11 09:06:27','2025-08-11 09:06:27'),(16,16,'PL3-方案大纲-001',1000.00,0,1,'2025-08-11 09:07:35','2025-08-11 09:07:35'),(17,16,'PL3-方案大概+拓展-002',5000.00,0,1,'2025-08-11 09:07:35','2025-08-11 09:07:35'),(42,17,'web1-定制-001',50000.00,10,1,'2025-08-17 09:44:34','2025-08-17 09:44:34'),(43,17,'web1-模板-002',20000.00,10,1,'2025-08-17 09:44:34','2025-08-17 09:44:34'),(44,14,'DOC1-是-001',500.00,0,1,'2025-08-17 09:44:53','2025-08-17 09:44:53'),(45,14,'DOC1-否-002',1.00,2,1,'2025-08-17 09:44:53','2025-08-20 03:33:04');
/*!40000 ALTER TABLE `product_sku` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_specification`
--

DROP TABLE IF EXISTS `product_specification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_specification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_product_spec_product_id` (`product_id`),
  CONSTRAINT `product_specification_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_specification_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `product_specification` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_specification`
--

LOCK TABLES `product_specification` WRITE;
/*!40000 ALTER TABLE `product_specification` DISABLE KEYS */;
INSERT INTO `product_specification` VALUES (14,15,'图片',NULL,0,'2025-08-11 09:06:27','2025-08-11 09:06:27'),(15,16,'策划',NULL,0,'2025-08-11 09:07:34','2025-08-11 09:07:34'),(28,17,'网站',NULL,0,'2025-08-17 09:44:33','2025-08-17 09:44:33'),(29,14,'是否需要配图',NULL,0,'2025-08-17 09:44:53','2025-08-17 09:44:53');
/*!40000 ALTER TABLE `product_specification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_specification_value`
--

DROP TABLE IF EXISTS `product_specification_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_specification_value` (
  `id` int NOT NULL AUTO_INCREMENT,
  `specification_id` int NOT NULL,
  `value` varchar(100) NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_spec_value_spec_id` (`specification_id`),
  CONSTRAINT `product_specification_value_ibfk_1` FOREIGN KEY (`specification_id`) REFERENCES `product_specification` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_specification_value`
--

LOCK TABLES `product_specification_value` WRITE;
/*!40000 ALTER TABLE `product_specification_value` DISABLE KEYS */;
INSERT INTO `product_specification_value` VALUES (27,14,'ai',0,'2025-08-11 09:06:27','2025-08-11 09:06:27'),(28,14,'实拍图修改设计',0,'2025-08-11 09:06:27','2025-08-11 09:06:27'),(29,15,'方案大纲',0,'2025-08-11 09:07:34','2025-08-11 09:07:34'),(30,15,'方案大概+拓展',0,'2025-08-11 09:07:34','2025-08-11 09:07:34'),(55,28,'定制',0,'2025-08-17 09:44:33','2025-08-17 09:44:33'),(56,28,'模板',0,'2025-08-17 09:44:33','2025-08-17 09:44:33'),(57,29,'是',0,'2025-08-17 09:44:53','2025-08-17 09:44:53'),(58,29,'否',0,'2025-08-17 09:44:53','2025-08-17 09:44:53');
/*!40000 ALTER TABLE `product_specification_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `model` varchar(255) DEFAULT NULL,
  `description` text,
  `price` decimal(10,2) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` int DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (2,'测试产品','TEST-001','这是一个测试产品',99.99,'https://example.com/image.jpg',21,1,1,'2025-09-12 08:28:04','2025-09-12 08:28:04');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_services_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (2,'商品图片','拍照，文章配图。','http://localhost:8000/uploads/4e831fa6-8945-48dd-b1de-b635c53ba53d.jpg',1,1),(3,'品牌策划','品牌策划一条龙服务。','http://localhost:8000/uploads/89c03455-1e08-4a35-9c9d-d7834b12fafc.png',3,1),(6,'小程序','小程序','http://localhost:8000/uploads/d6b29077-9bc7-40fd-ab72-ab6811b32795.png',3,1),(7,'web','','http://localhost:8000/uploads/708f2e67-a094-40ec-a813-17ca6f714bb7.jpg',4,1);
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_specification`
--

DROP TABLE IF EXISTS `sku_specification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_specification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sku_id` int NOT NULL,
  `spec_value_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `spec_value_id` (`spec_value_id`),
  KEY `idx_sku_spec_sku_id` (`sku_id`),
  CONSTRAINT `sku_specification_ibfk_1` FOREIGN KEY (`sku_id`) REFERENCES `product_sku` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sku_specification_ibfk_2` FOREIGN KEY (`spec_value_id`) REFERENCES `product_specification_value` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_specification`
--

LOCK TABLES `sku_specification` WRITE;
/*!40000 ALTER TABLE `sku_specification` DISABLE KEYS */;
INSERT INTO `sku_specification` VALUES (16,14,27,'2025-08-11 09:06:27'),(17,15,28,'2025-08-11 09:06:27'),(18,16,29,'2025-08-11 09:07:34'),(19,17,30,'2025-08-11 09:07:34');
/*!40000 ALTER TABLE `sku_specification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_address`
--

DROP TABLE IF EXISTS `user_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_address` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `contact_name` varchar(100) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `province` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `detail_address` varchar(500) NOT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_user_address_id` (`id`),
  CONSTRAINT `user_address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_address`
--

LOCK TABLES `user_address` WRITE;
/*!40000 ALTER TABLE `user_address` DISABLE KEYS */;
INSERT INTO `user_address` VALUES (1,15,'测试六','13100010006','广东省','深圳市','龙岗区','测试街道门牌号6号',1,'2025-08-20 00:04:28','2025-08-20 00:04:28');
/*!40000 ALTER TABLE `user_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL COMMENT '用户名/昵称（可选）',
  `password_hash` varchar(255) DEFAULT NULL COMMENT '密码Hash（如果有密码则存储）',
  `email` varchar(255) DEFAULT NULL COMMENT '邮箱（可选）',
  `phone` varchar(255) DEFAULT NULL COMMENT '手机号（可选，便于手机号注册登录）',
  `role` varchar(255) DEFAULT NULL COMMENT '用户角色：admin/customer/app_user/wx_user',
  `status` varchar(255) DEFAULT NULL COMMENT '状态：1启用，0禁用',
  `created_at` varchar(255) DEFAULT NULL COMMENT '注册时间',
  `updated_at` varchar(255) DEFAULT NULL COMMENT '更新时间',
  `wx_openid` varchar(50) DEFAULT NULL COMMENT '微信OpenID（小程序用户唯一标识）',
  `wx_unionid` varchar(50) DEFAULT NULL COMMENT '微信UnionID（同一微信账号下唯一）',
  `app_openid` varchar(50) DEFAULT NULL COMMENT 'App端第三方登录openid',
  `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像地址',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `wx_openid` (`wx_openid`),
  UNIQUE KEY `app_openid` (`app_openid`),
  KEY `idx_users_wx_openid` (`wx_openid`),
  KEY `idx_users_app_openid` (`app_openid`),
  KEY `idx_users_role` (`role`),
  KEY `idx_users_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2b$12$iwUIRJcULo4iFIMLivO3X.It7Cbmk.JzeWPdsFkYTNuVMLXJh8yk2',NULL,NULL,'admin','1','2025-07-27 00:57:00','2025-07-26 17:24:10',NULL,NULL,NULL,NULL),(2,'operation','$2b$12$w2HmNa3Sbm/FbojMbQxVaO0ahuOBSwf2UTDqSxfLzyXS5j/iCuR3q','test01@163.com','','admin','1','2025-07-27 11:06:52','2025-07-27 11:06:52',NULL,NULL,NULL,NULL),(3,'operation2','$2b$12$E/OSW/l5YCijwtn0ScN8BeA8i/sJ6Qu68ZmI4M1OZ4mEjRBNmrGju','test02@163.com','','customer','1','2025-07-27 11:07:27','2025-07-29 01:13:38.723090',NULL,NULL,NULL,NULL),(4,'testuser','$2b$12$t.x08Ud2jKQN5Vi/OVC.Huq8.P8egYDX4gWg8qY30GSf.GVW15a.e','test@example.com','13800138000','customer','1','2025-07-28 14:04:59.286403','2025-07-29 01:13:39.009838',NULL,NULL,NULL,NULL),(5,'wx_user_code_123',NULL,NULL,NULL,'wx_user','1','2025-07-28 14:05:45.239542','2025-07-28 14:05:45.239554','wx_openid_test_wx_code_123',NULL,NULL,NULL),(6,'app_user_enid_123',NULL,NULL,NULL,'app_user','1','2025-07-28 14:05:45.259435','2025-07-28 14:05:45.259450',NULL,NULL,'test_app_openid_123',NULL),(7,'testuser2','$2b$12$FglwVzVyNCCYz9Yph1YRv.LMM9otyPjoUgVKQu5XTwln5LLE5zKS.','updated@example.com','13900139000','customer','1','2025-07-28 14:06:44.272745','2025-07-29 01:13:39.270938',NULL,NULL,NULL,NULL),(8,'wx_user_code_456',NULL,NULL,NULL,'wx_user','1','2025-07-28 14:06:44.714335','2025-07-28 14:06:44.714343','wx_openid_test_wx_code_456',NULL,NULL,NULL),(9,'app_user_enid_456',NULL,NULL,NULL,'app_user','1','2025-07-28 14:06:44.729006','2025-07-28 14:06:44.729014',NULL,NULL,'test_app_openid_456',NULL),(10,'test','$2b$12$mtKprMS9H1EsejspqDtawe41Uw6e/fKKw03BpI6.DT/.LpKO2.L6S','test01@163.com',NULL,'customer','1','2025-07-28 16:14:22.070237','2025-07-29 01:13:39.536920',NULL,NULL,NULL,NULL),(11,'test02','$2b$12$dZRtvlr3UnGRY38xxbxZhuIzDBsKgvYbgqrwkj4/5nI79yAbdEvxy','test02@163.com','13112223333','customer','1','2025-07-28 16:30:49.842434','2025-07-29 01:13:39.789963',NULL,NULL,NULL,NULL),(12,'test03','$2b$12$AyIoUAy1bQ25vh/Xs4SMw.z2iURVGhPtIiAIJoa31TRCIWk.zMJBS','test03@163.com','13112341234','customer','1','2025-07-28 16:51:11.548890','2025-07-29 01:13:40.040817',NULL,NULL,NULL,NULL),(13,'test04','$2b$12$GSr6v21XwK4KofNX0DbP6.UmJMMGIQVNkBM.LodlsmPrYQyB1LTy.','test04@163.com','13422223333','customer','1','2025-07-28 16:59:33.193010','2025-07-29 01:13:40.290180',NULL,NULL,NULL,NULL),(14,'test05','$2b$12$VjLKU8F3FqRIMLWfaSE6vetiJwsAUOjqSVgQJrJzr1qiDx/1A1sIG','test05@163.com','13112341235','customer','1','2025-07-29 20:50:50.717373','2025-07-29 20:50:50.717380',NULL,NULL,NULL,NULL),(15,'test06','$2b$12$.0KatTJQ4jDbB8fXFVhEf.XlTvp.JUhfhydovMmcLflB3vlJ8Z4t6','test06@163.com','13112341236','customer','1','2025-07-29 20:56:02.109046','2025-07-29 20:56:02.109053',NULL,NULL,NULL,NULL),(16,'test07','$2b$12$TKfHbovisGUSWbrhAhpQjeEMd5ULfmKLIUonxkxUZ.3Vym1kEILgq','test07@163.com','13112341237','customer','1','2025-07-29 21:02:07.274147','2025-07-29 21:02:07.274153',NULL,NULL,NULL,NULL),(17,'test08','$2b$12$HLXQgBljMkE3Kfr2VFr/VOwQBX6wrZxETsjXcqd59NbWa5pu2UH5a','test08@163.com','13100010008','customer','1','2025-09-08 16:48:59.992002','2025-09-08 16:49:17.566126',NULL,NULL,NULL,'http://localhost:8000/uploads/87ab2d01-18bf-44f3-a36e-f63cf3d59df0.jpg');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-12 16:34:14
