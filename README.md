# SwiftFS China



![截图](https://segmentfault.com/img/bVShiH?w=1842&h=1256)

-------

### 项目概述

* 一个运行在SwiftWeb上的基于Perfect的BBS系统。
* 主要页面直接采用了ruby on china的样式
* 采用的MySQL，文件本地存储
* 本项目只是骨架,未完全完成。


### 运行环境
* swift 3.1
* ubuntu 16.04
* Mysql 5.76+ (最新版即可)

### 安装
#### 第一部分 
##### 在mac
1. 需要安装Xcode
2. swift >= 3.0
###### 在linux
1. 需要安装语言环境
2. 可参考 [perfect](https://www.perfect.org/docs/) 或 [vapor](https://docs.vapor.codes/2.0/getting-started/install-on-ubuntu/) 官网
3. 本项目在Linux直接使用 vapor (Install Toolbox)[https://docs.vapor.codes/2.0/getting-started/toolbox/]
4. 执行swift build 或 vpaor build 时会提示 未安装的环境，按提示安装即可

#### 第二部分
* 安装redis
* 将仓库中提供的SQL文件导入
* 修改文件目录下PerfectChina/ApplicationConfiguration 配置信息，有数据库连接，白名单等
* webroot/avatar 为图片本地地址
* 日志输出在更目录 ./webLog.log"


### 计划
<!--1.  ~~全文索引~~
2.  ~~图片上传~~
3.  ~~完成github登录~~
4.  ~~邮箱验证~~
5.  ~~集成redis和redis-session~~ 弃坑
6.  集成用openresty 做redis 管理
7.  集成nginx 
8.  修改UI/优化
9.  graphQL-->
10. 
## TODO
* [ ] 用户相关
  * [x] 用户注册
  * [x] 用户登录
  * [x] 用户退出登录
  * [x] 找回密码
  * [ ] 邮箱验证
  * [ ] github登录
  * [ ] 个人主页
  * [ ] 个人资料修改
  * [ ] 修改密码
  * [ ] 用户关注
* [ ] 帖子相关
  * [ ] 发帖
  * [ ] 可以在帖子中@用户
  * [ ] 编辑帖子
  * [ ] 关闭帖子(帖子关闭之后不再接受任何回复，允许再次打开)
  * [ ] 关注帖子(关注后会对用户推送帖子动态)
  * [ ] 收藏帖子(帖子出现在个人主页的收藏面板中)
  * [ ] 点赞帖子(奖励积分)
  * [ ] 置顶帖子
* [ ] 帖子评论相关
  * [ ] 创建评论(不可编辑)
  * [ ] 删除评论
  * [ ] 点赞评论(奖励积分，并高亮优秀评论)
  * [ ] 回复评论(@功能)
* [ ] 通知系统(接受 用户关注、关注的用户发帖和评论、关注的帖子有回帖、发布的帖子被置顶、被其他用户@ 等消息)
  * [ ] 通知阅读
  * [ ] 通知单条删除和全部删除
* [ ] 后台系统
  * [ ] 管理用户
  * [ ] 管理帖子
  * [ ] 管理评论
* [ ] GraphQL接口
* [x] Build & CI
  * [x] Travis
  * [x] Docker

 
 



#### License
[MIT](https://github.com/sumory/openresty-china/blob/master/LICENSE)



