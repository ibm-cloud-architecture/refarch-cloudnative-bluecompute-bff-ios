import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import CloudFoundryEnv

do {
    // HeliumLogger disables all buffering on stdout
    HeliumLogger.use(LoggerMessageType.info)
    let controller = try Controller()
    Log.info("Server will be started on port '\(controller.url):\(controller.port)'.")

    // Start Kitura-Starter server
    Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
    Kitura.run()

} catch let error {
    Log.error(error.localizedDescription)
    Log.error("Oops... something went wrong. Server did not start!")
}