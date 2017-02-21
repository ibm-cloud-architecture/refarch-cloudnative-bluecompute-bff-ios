import Foundation
import Kitura
import KituraRequest
import SwiftyJSON
import HeliumLogger
import LoggerAPI

let logger = HeliumLogger()
Log.logger = logger

// Initialize HeliumLogger
HeliumLogger.use()

// Create a new router
let router = Router()

// Getting zuul/catalog URL
let env = ProcessInfo.processInfo.environment
let microserviceBaseUrl = env["ZUUL_URL"] != nil ? env["ZUUL_URL"] : "http://localhost:8081/micro"
Log.info("zuul URL: \(microserviceBaseUrl)")


// Serve all the static images
// Contents is stored in the public folder
// Path to an image would look like /static/api/image/image_name.jpg
router.all("/static", middleware: StaticFileServer())

router.get("/api/items") { request, response, next in
    KituraRequest.request(.get, microserviceBaseUrl! + "/items").response {
        req, res, data, error in
        // do something with data
        Log.info("Status code: \(res?.status)")
        
        if (error != nil) {
            Log.error("Error: \(error)")
            response.status(.internalServerError)
            response.error = error
            
        } else if (data == nil || res?.status == 404) {
            Log.error("Received no data")
            response.status(.notFound)
            response.error = NSError(domain: "Router", code: 404, userInfo: [:])
            
        } else {
            Log.info("Data: \(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))")
            response.send(json: JSON(data: data!))
        }
    }
}

router.get("/api/items/:id") { request, response, next in
    let id = request.parameters["id"] ?? ""
    KituraRequest.request(.get, microserviceBaseUrl! + "/items/" + id).response {
        req, res, data, error in
        // do something with data
        Log.info("Status code: \(res?.status)")
        
        if (error != nil) {
            Log.error("Error: \(error)")
            response.status(.internalServerError)
            response.error = error
            
        } else if (data == nil || res?.status == 404) {
            Log.error("Received no data")
            response.status(.notFound)
            response.error = NSError(domain: "Router", code: 404, userInfo: [:])
            
        } else {
            Log.info("Data: \(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))")
            response.send(json: JSON(data: data!))
        }
    }
}


// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
