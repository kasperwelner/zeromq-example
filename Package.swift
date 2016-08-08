import PackageDescription

let package = Package(
    name: "zerocli",
    dependencies: [
        .Package(url: "https://github.com/KelvinJin/SwiftZMQ.git", majorVersion: 1)
        ]
)
