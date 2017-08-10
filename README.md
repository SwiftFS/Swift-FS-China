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
* 将仓库中提供的SQL文件导入
* 修改文件目录下PerfectChina/ApplicationConfiguration 配置信息，有数据库连接，白名单等
* webroot/avatar 为图片本地地址
* 日志输出在更目录 ./webLog.log"


### 计划
~~1.完成github登录~~
2.邮箱验证
###最近完成
1.图片上传
2.全文索引


#### 讨论交流
qq群：514517311

#### License
[MIT](https://github.com/sumory/openresty-china/blob/master/LICENSE)



