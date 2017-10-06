// Generated automatically by Perfect Assistant Application
// Date: 2017-04-01 20:14:44 +0000
import PackageDescription
let package = Package(
    name: "SwiftFSChina",
    targets: [],
    dependencies: [
         .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
         .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", majorVersion: 3),
         .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 3),
         .Package(url:"https://github.com/PerfectlySoft/Perfect-Session.git", majorVersion: 3),
         .Package(url: "https://github.com/novi/mysql-swift.git", majorVersion: 0),
                 .Package(url: "https://github.com/vapor/bcrypt.git", majorVersion: 1),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-OAuth2.git", majorVersion: 3),
         .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-SMTP.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Redis.git", majorVersion: 3),
         .Package(url: "https://github.com/PerfectlySoft/Perfect-Markdown.git", majorVersion: 3)
    ]
)
