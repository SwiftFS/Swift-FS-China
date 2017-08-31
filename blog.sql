# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 127.0.0.1 (MySQL 5.6.15)
# Database: blog
# Generation Time: 2016-02-27 14:50:30 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;



# Dump of table category
# ------------------------------------------------------------

DROP TABLE IF EXISTS `category`;

CREATE TABLE `category` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(15) NOT NULL DEFAULT '',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;

INSERT INTO `category` (`id`, `name`, `create_time`)
VALUES
	(1,'分享','2016-02-17 16:22:04'),
	(2,'问答','2016-02-17 16:22:04');

/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table collect
# ------------------------------------------------------------

DROP TABLE IF EXISTS `collect`;

CREATE TABLE `collect` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_topic` (`user_id`,`topic_id`),
  KEY `index_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;



# Dump of table comment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `comment`;

CREATE TABLE `comment` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `content` TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_topic_id` (`topic_id`),
  KEY `index_user_id` (`user_id`),
  FULLTEXT (content) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table follow
# ------------------------------------------------------------

DROP TABLE IF EXISTS `follow`;

CREATE TABLE `follow` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `from_id` int(11) NOT NULL,
  `to_id` int(11) NOT NULL,
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_relation` (`from_id`,`to_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table like
# ------------------------------------------------------------

DROP TABLE IF EXISTS `like`;

CREATE TABLE `like` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `topic_id` int(11) NOT NULL DEFAULT '0',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_topic` (`user_id`,`topic_id`),
  KEY `index_user_id` (`user_id`),
  KEY `index_topic_id` (`topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table notification
# ------------------------------------------------------------

DROP TABLE IF EXISTS `notification`;

CREATE TABLE `notification` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '接收用户id',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型：0评论了你的文章 1评论中提到了你, 2某人关注了你',
  `from_id` int(11) NOT NULL DEFAULT '0' COMMENT '来自用户的id',
  `content` varchar(2000) NOT NULL COMMENT '内容',
  `topic_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '1已读，0未读',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `index_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table topic
# ------------------------------------------------------------

DROP TABLE IF EXISTS `topic`;

CREATE TABLE `topic` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `content` TEXT NOT NULL DEFAULT '',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '创建者id',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT NULL,
  `user_name` varchar(255) NOT NULL DEFAULT '' COMMENT '创建者用户名',
  `like_num` int(11) NOT NULL DEFAULT '0' COMMENT '赞个数',
  `collect_num` int(11) NOT NULL DEFAULT '0' COMMENT '收藏数',
  `reply_num` int(11) NOT NULL DEFAULT '0' COMMENT '评论数',
  `follow` int(11) NOT NULL DEFAULT '0' COMMENT '关注数',
  `view_num` int(11) NOT NULL DEFAULT '0' COMMENT '阅读数',
  `last_reply_id` int(11) NOT NULL DEFAULT '0' COMMENT '最后回复者id',
  `last_reply_name` varchar(255) NOT NULL DEFAULT '' COMMENT '最后回复者用户名',
  `last_reply_time` timestamp NOT NULL DEFAULT '2000-01-01 00:00:00',
  `category_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属类',
  `is_good` int(11) NOT NULL DEFAULT '0' COMMENT '1精华帖，0普通帖',
  PRIMARY KEY (`id`),
  FULLTEXT (title,content) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `topic` WRITE;
/*!40000 ALTER TABLE `topic` DISABLE KEYS */;

INSERT INTO `topic` (`id`, `title`, `content`, `user_id`, `create_time`, `update_time`, `user_name`, `like_num`, `collect_num`, `reply_num`, `follow`, `view_num`, `last_reply_id`, `last_reply_name`, `last_reply_time`, `category_id`, `is_good`)
VALUES
	(31,'Hello World! Hello SwiftFS China!','Hello World! Hello SwiftFS China!',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','mubin',0,0,0,0,2,0,'','2016-02-27 22:44:23',1,0),
	(32,' Framework','\nA fast and minimalist web framework based on [SwiftFS](http://SwiftFS.org).\n\n[![https://travis-ci.org/mubin/.svg?branch=master](https://travis-ci.org/mubin/.svg?branch=master)](https://travis-ci.org/mubin/) [![Issue Stats](http://issuestats.com/github/mubin//badge/pr)](http://issuestats.com/github/mubin/) [![Issue Stats](http://issuestats.com/github/mubin//badge/issue)](http://issuestats.com/github/mubin/)\n\n\n\n```lua\nlocal  = require(\".index\")\nlocal app = ()\n\napp:get(\"/\", function(req, res, next)\n    res:send(\"hello world!\")\nend)\n\napp:run()\n```\n\n\n\n## Installation\n\n\n```\ngit clone https://github.com/mubin/\ncd \nsh install.sh /path/to/your/ \n```\n\n\n\n## Features\n\n- Routing like [Sinatra](http://www.sinatrarb.com/) which is a famous Ruby framework\n- Similar API with [Express](http://expressjs.com), good experience for Node.js or Javascript developers\n- Middleware support\n- Group router support\n- Session/Cookie/Views supported and could be redefined with `Middleware`\n- Easy to build HTTP APIs, web site, or single page applications\n\n\n\n## Docs & Community\n\n- [Website and Documentation](http://.mubin.com).\n- [Github Organization](https://github.com/labs) for Official Middleware & Modules.\n\n\n\n\n## Quick Start\n\nA quick way to get started with  is to utilize the executable cli tool `d` to generate an scaffold application.\n\n`d` is installed with `` framework. it looks like:\n\n```bash\n$ d -h\n ${version}, a Lua web framework based on SwiftFS.\n\nUsage:  COMMAND [OPTIONS]\n\nCommands:\n new [name]             Create a new application\n start                  Starts the server\n stop                   Stops the server\n restart                Restart the server\n version                Show version of \n help                   Show help tips\n```\n\nCreate the app:\n\n```\n$ d new _demo\n```\n\nStart the server:\n\n```\n$ cd _demo & d start\n```\n\nVisit [http://localhost:8888](http://localhost:8888).\n\n\n\n## Tests\n\nInstall [busted](http://olivinelabs.com/busted/), then run test\n\n```\nbusted test/*.test.lua\n```\n\n\n\n## License\n\n[MIT](./LICENSE)',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','mubin',0,0,0,0,4,0,'','2016-02-27 22:44:23',1,0),
	(35,'关于SwiftFS China','这里是 SwiftFS 中文社区\n\n - 分享SwiftFS相关技术\n - 欢迎原创文章，也欢迎各种技术交流\n - 本站基于 Framework构建，是一个基于SwiftFS的开发框架\n\nSwiftFS相对于其它语言或是平台来说，它的社区规模还较小，不过已在高速发展中。本社区致力于推广和普及SwiftFS相关技术，并提供给开发者一个好用的技术交流平台。',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','mubin',0,0,0,0,13,0,'','2016-02-27 22:44:23',2,0),
	(38,'如何实现一个Upload中间件','SwiftFS上传文件可以使用官方提供的lua-resty-upload，[](https://github.com/mubin/)提供了灵活的中间件机制，在上实现上传的中间件实现如下：\n\n```lua\nlocal upload = require(\"resty.upload\")\nlocal uuid = require(\"app.libs.uuid.uuid\")\n\nlocal sfind = string.find\nlocal match = string.match\nlocal ngx_var = ngx.var\nlocal get_headers = ngx.req.get_headers()\n\n\nlocal function getextension(filename)\n	return filename:match(\".+%.(%w+)$\")\nend\n\n\nlocal function _multipart_formdata(config)\n	local form, err = upload:new(config.chunk_size)\n	if not form then\n		ngx.log(ngx.ERR, \"failed to new upload: \", err)\n		ngx.exit(500)\n	end\n	form:set_timeout(config.recieve_timeout)\n\n	local unique_name = uuid()\n	local file, origin_filename, filename, path, extname\n	while true do\n		local typ, res, err = form:read()\n\n		if not typ then\n			ngx.log(ngx.ERR, \"failed to read: \", err)\n			ngx.exit(500)\n		end\n\n		if typ == \"header\" then\n			if res[1] == \"Content-Disposition\" then\n				key = match(res[2], \"name=\\\"(.-)\\\"\")\n				origin_filename = match(res[2], \"filename=\\\"(.-)\\\"\")\n			elseif res[1] == \"Content-Type\" then\n				filetype = res[2]\n			end\n\n			if origin_filename and filetype then\n				if not extname then\n					extname = getextension(origin_filename)\n				end\n\n				filename = unique_name .. \".\" .. extname\n				path = config.dir.. \"/\" .. filename\n				\n				file = io.open(path, \"w+\")\n			end\n	\n		elseif typ == \"body\" then\n			if file then\n				file:write(res)\n			else\n				ngx.log(ngxERR, path, \" not exist\")\n			end\n		elseif typ == \"part_end\" then\n            file:close()\n            file = nil\n		elseif typ == \"eof\" then\n			break\n		else\n			-- do nothing\n		end\n	end\n\n	return filename, extname, path, unique_name .. \".\" .. extname\nend\n\nlocal function _check_post(config)\n	local filename = nil\n	local extname = nil\n	local path = nil\n\n\n	if ngx_var.request_method == \"POST\" then\n		local header = get_headers[\'Content-Type\']\n		local is_multipart = sfind(header, \"multipart\")\n		if is_multipart and is_multipart>0 then\n			origin_filename, extname, path, filename= _multipart_formdata(config)\n		end\n	end\n\n\n	return origin_filename, extname, path, filename\nend\n\nlocal function uploader(config)\n	config = config or {}\n	config.dir = config.dir or \"/tmp\"\n	config.chunk_size = config.chunk_size or 4096\n	config.recieve_timeout = config.recieve_timeout or 20000 -- 20s\n\n	return function(req, res, next)\n		local origin_filename, extname, path, filename = _check_post(config)\n		req.file = req.file or {}\n		req.file.origin_filename = origin_filename\n		req.file.extname = extname\n		req.file.path = path\n		req.file.filename = filename\n		next()\n	end\nend\n\nreturn uploader\n```\n\n使用该中间件的方式也非常简单：\n\n```lua\napp:use(uploader_middleware({\n	dir = \"app/static/avatar\"\n}))\n```\n\n然后在后续的处理路由中，即可通过req.file对象来获取已经上传的文件信息。\n',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','momo',0,0,0,0,33,0,'','2016-02-27 22:44:23',2,0),
	(39,'Markdown语法说明','# Guide\n\n这是一篇讲解如何正确使用SwiftFS China 的 **Markdown** 的排版示例，学会这个很有必要，能让你的文章有更佳清晰的排版。\n\n> 引用文本：Markdown is a text formatting syntax inspired\n\n## 语法指导\n\n### 普通内容\n\n这段内容展示了在内容里面一些小的格式，比如：\n\n- **加粗** - `**加粗**`\n- *倾斜* - `*倾斜*`\n- ~~删除线~~ - `~~删除线~~`\n- `Code 标记` - ``Code 标记``\n- [超级链接](http://github.com) - `[超级链接](http://github.com)`\n- [mubin.wu@gmail.com](mailto:mubin.wu@gmail.com) - `[mubin.wu@gmail.com](mailto:mubin.wu@gmail.com)`\n\n### 评论文章时提及用户\n\n@mubin  ... 通过 @ 可以在评论里面提及用户，信息提交以后，被提及的用户将会收到系统通知。以便让他来关注这个帖子或回帖。\n\n### 表情符号 Emoji\n\nSwiftFS China 支持表情符号，你可以用系统默认的 Emoji 符号。\n也可以用图片的表情，输入 `:` 将会出现智能提示。\n\n#### 一些表情例子\n\n:smile: :laughing: :dizzy_face: :sob: :cold_sweat: :sweat_smile:  :cry: :triumph: :heart_eyes:  :satisfied: :relaxed: :sunglasses: :weary:\n\n:+1: :-1: :100: :clap: :bell: :gift: :question: :bomb: :heart: :coffee: :cyclone: :bow: :kiss: :pray: :shit: :sweat_drops: :exclamation: :anger:\n\n对应字符串表示如下：\n\n```\n:smile: :laughing: :dizzy_face: :sob: :cold_sweat: :sweat_smile:  :cry: :triumph: :heart_eyes:  :satisfied: :relaxed: :sunglasses: :weary:\n:+1: :-1: :100: :clap: :bell: :gift: :question: :bomb: :heart: :coffee: :cyclone: :bow: :kiss: :pray: :shit: :sweat_drops: :exclamation: :anger:\n```\n\n更多表情请访问：[http://www.emoji-cheat-sheet.com](http://www.emoji-cheat-sheet.com)\n\n### 大标题 - Heading 3\n\n你可以选择使用 H2 至 H6，使用 ##(N) 打头，H1 不能使用，会自动转换成 H2。\n\n> NOTE: 别忘了 # 后面需要有空格！\n\n#### Heading 4\n\n##### Heading 5\n\n###### Heading 6\n\n### 代码块\n\n#### 普通\n\n```\n*emphasize*    **strong**\n_emphasize_    __strong__\n@a = 1\n```\n\n#### 语法高亮支持\n\n如果在 ``` 后面更随语言名称，可以有语法高亮的效果哦，比如:\n\n##### 演示 Lua 代码高亮\n\n```lua\nlocal  = require(\".index\")\nlocal app = ()\n\napp:get(\"/\", function(req, res, next)\n    res:send(\"hello world!\")\nend)\n\napp:run()\n```\n\n##### 演示 Javascript 高亮\n\n```js\n(function (L) {\n    var _this = null;\n    L.Common = L.Common || {};\n    _this = L.Common = {\n        data: {},\n \n        init: function () {\n            console.log(\"init function\");\n        },\n\n        formatDate: function (now) {\n            var year = now.getFullYear();\n            var month = now.getMonth() + 1;\n            var date = now.getDate();\n            var hour = now.getHours();\n            var minute = now.getMinutes();\n            var second = now.getSeconds();\n            if (second < 10) second = \"0\" + second;\n            return year + \"-\" + month + \"-\" + date + \" \" + hour + \":\" + minute + \":\" + second;\n        }\n    };\n}(APP));\n```\n\n##### 演示 YAML 文件\n\n```yml\nzh-CN:\n  name: 姓名\n  age: 年龄\n```\n\n> Tip: 语言名称支持下面这些: `ruby`, `python`, `js`, `html`, `erb`, `css`, `coffee`, `bash`, `json`, `yml`, `xml` ...\n\n### 有序、无序列表\n\n#### 无序列表\n\n- Ruby\n  - Rails\n    - ActiveRecord\n- Go\n  - Gofmt\n  - Revel\n- Node.js\n  - Koa\n  - Express\n\n#### 有序列表\n\n1. Node.js\n  1. Express\n  2. Koa\n  3. Sails\n2. Ruby\n  1. Rails\n  2. Sinatra\n3. Go\n\n### 表格\n\n如果需要展示数据什么的，可以选择使用表格哦\n\n| header 1 | header 3 |\n| -------- | -------- |\n| cell 1   | cell 2   |\n| cell 3   | cell 4   |\n| cell 5   | cell 6   |\n\n### 段落\n\n留空白的换行，将会被自动转换成一个段落，会有一定的段落间距，便于阅读。\n\n请注意后面 Markdown 源代码的换行留空情况。',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','mubin',0,0,0,0,188,0,'','2016-02-27 22:44:23',1,1);

/*!40000 ALTER TABLE `topic` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `avatar` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `city` varchar(11) NOT NULL DEFAULT '',
  `website` varchar(255) NOT NULL DEFAULT '',
  `company` varchar(100) NOT NULL DEFAULT '',
  `sign` varchar(255) NOT NULL DEFAULT '',
  `github` varchar(30) NOT NULL DEFAULT '',
  `github_name` varchar(30) NOT NULL DEFAULT '',
  `is_verify` int(2) NULL DEFAULT 0,
  `github_id` int(11)  NULL,
  `email` varchar(200) NOT NULL DEFAULT '',
  `email_public` int(11) NOT NULL DEFAULT '0' COMMENT '1公开，0私密',
  `is_admin` int(11) DEFAULT '0' COMMENT '1管理员，0普通用户',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username` (`username`),
  UNIQUE KEY `unique_email` (`email`),
  UNIQUE KEY `unique_github_id` (`github_id`),
  FULLTEXT (username) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- LOCK TABLES `user` WRITE;
-- /*!40000 ALTER TABLE `user` DISABLE KEYS */;

-- INSERT INTO `user` (`id`, `username`, `password`, `avatar`, `create_time`, `city`, `website`, `company`, `sign`, `github`,`github_name`,`github_id`, `email`, `email_public`, `is_mubin`)
-- VALUES
-- 	(3,'mubin','2d39682dbb53e8b7df86581b0e48a5f8a4f2815617360c4d9607945b5cdde4c5','m.png','2017-08-8 19:08:00','佛山','http://182.61.33.196/','swiffs','nothing at all.','mubin','mubin','12312232','mubin.wu@gmail.com',0,1);
-- -- /*!40000 ALTER TABLE `user` ENABLE KEYS */;
-- UNLOCK TABLES;
-- LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


-- insert into topic VALUES(42,'123','123😟',3,'2016-02-27 22:44:23','2016-02-27 22:44:23','mubin',0,0,0,0,0,0,'','2016-02-27 22:44:23',1,0);