import PackageDescription

let package = Package(
    name: "bluecompute-bff-ios",
  	targets: [
      Target(name: "bluecompute-bff-ios", dependencies: [])
    ],
    dependencies: [
      // Latest is 1.6
      .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 1),

      // Latest is 1.6.0
      .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 1),
      
      // Using latest
      .Package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-objectstorage-serversdk-swift.git", majorVersion: 0, minor: 6),
    ],
    exclude: ["Makefile", "Package-Builder"])
