import Foundation
import Kitura
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv
import BluemixObjectStorage

public class Controller {
    
    let router: Router
    let cfEnv: AppEnv
    var objstorage : ObjectStorage!
    var container : ObjectStorageContainer?
    
    var containerName : String {
        get {
            return ProcessInfo.processInfo.environment["container"] ?? "bluecompute"
        }
    }
    
    var port: Int {
        get {
            return cfEnv.isLocal ? 8090 : cfEnv.port
        }
    }
    
    var url: String {
        get {
            return cfEnv.isLocal ? "http://localhost" : cfEnv.url
        }
    }
    
    var region : String {
        get {
            let reg = Controller.getEnvVariable(envVar: "region", cfEnv: cfEnv).uppercased()
            return reg.isEmpty == true ? "DALLAS" : reg
        }
    }
    
    var projectId : String {
        get {
            return Controller.getEnvVariable(envVar: "projectId", cfEnv: cfEnv)
        }
    }
    
    var userId : String {
        get {
            return Controller.getEnvVariable(envVar: "userId", cfEnv: cfEnv)
        }
    }
    
    var password : String {
        get {
            return Controller.getEnvVariable(envVar: "password", cfEnv: cfEnv)
        }
    }
    
    static func getEnvVariable(envVar: String, cfEnv: AppEnv) -> String {
        if cfEnv.isLocal {
            Log.info("Getting \(envVar) localhost/docker")
            return ProcessInfo.processInfo.environment[envVar] ?? ""
        } else {
            Log.info("Getting \(envVar) from VCAP_SERVICES")
            let json: [String:Any] = cfEnv.getServiceCreds(spec: "Object-Storage")!
            return json[envVar] as! String
        }
    }
    
    init() throws {
        cfEnv = try CloudFoundryEnv.getAppEnv()
        
        // All web apps need a Router instance to define routes
        router = Router()
        
        // Serve static content from "public"
        router.all("/static", middleware: StaticFileServer())
        
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
