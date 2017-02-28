import Foundation
import Kitura
import SwiftyJSON
import LoggerAPI
import BluemixObjectStorage

public class Controller {
    
    let router: Router
    var objstorage : ObjectStorage!
    var container : ObjectStorageContainer?
    
    var containerName : String {
        get {
            return Controller.getVar("container") ?? "bluecompute"
        }
    }
    
    var port: String {
        get {
            return Controller.getVar("PORT") ?? "8090"
        }
    }
    
    var region : String {
        get {
            return Controller.getVar("region")?.uppercased() ?? "DALLAS"
        }
    }
    
    var projectId : String {
        get {
            return Controller.getVar("projectId") ?? ""
        }
    }
    
    var userId : String {
        get {
            return Controller.getVar("userId") ?? ""
        }
    }
    
    var password : String {
        get {
            return Controller.getVar("password") ?? ""
        }
    }
    
    static func getVar(_ envVar: String) -> String? {
        var value:String? = nil
        Log.info("Getting var \(envVar)")

        if ((envVar != "projectId" && envVar != "userId" && envVar != "password") ||
            ProcessInfo.processInfo.environment["VCAP_SERVICES"] == nil) {
            Log.info("Getting optional var")
            value = ProcessInfo.processInfo.environment[envVar]

        } else {
            let json = JSON.parse(string: ProcessInfo.processInfo.environment["VCAP_SERVICES"]!)
            Log.info("VCAP json: \(json)")
            if let creds = json["Object-Storage"][0]["credentials"].dictionary {
                value = creds[envVar]?.string
            } else {
                Log.info("No VCAP_SERVICES or could not get credentials")
                value = ProcessInfo.processInfo.environment[envVar]
            }
        }

        Log.info("\(envVar) = \(value)\n\n")
        return value
    }

    init() throws {
        Log.info("\n\n\n Environment variables:")
        for (key, value) in ProcessInfo.processInfo.environment {
            Log.info("\(key): \(value)")
        }
        Log.info("\n\n\n")
        // All web apps need a Router instance to define routes
        router = Router()

        // Set up the image route
        router.get("/image/:name", handler: getImage)

        // Initialize Object Storage
        objstorage = ObjectStorage(projectId:projectId)
        objstorage.connect( userId: userId,
                            password: password,
                            region: region) { (error) in
                                if let error = error {
                                    Log.error("connect error :: \(error)")
                                    exit(1)
                                } else {
                                    Log.info("connect success")
                                }
        }
        
        // Get container
        Log.debug("getContainer - Getting container \"\(containerName)\"...")
        objstorage.retrieveContainer(name: containerName) { (error, cont) in
            if error != nil {
                Log.error("retrieveContainer error :: \(error)")
                exit(1)
            }
            
            self.container = cont!
            
            Log.info("retrieveContainer success :: \(self.container?.name)")
        }
    }
    
    // Get image handler
    public func getImage(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let name = request.parameters["name"] ?? ""
        
        container?.retrieveObject(name: name) { (error, object) in
            if error != nil {
                Log.error("retrieveObject error :: \(error)")
                do {
                    try response.status(.notFound).send("").end()
                } catch {
                    Log.info("error getting all items: \(error)")
                }
                return
            }
            
            Log.info("retrieveObject success :: \(object?.name)")
            
            do {
                response.headers["Content-Type"] = "image/jpeg"
                try response.status(.OK).send(data: object!.data!).end()
            } catch {
                Log.info("error getting all items: \(error)")
            }
        }
    }
}