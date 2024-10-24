//
//  DatabaseManager.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseManager {
    
    // public
    var db:Database? {
        get {
            return _db
        }
    }
    var dbChangeListenerToken:ListenerToken?
    
    // For demo purposes only. In prod apps, credentials must be stored in keychain
    public fileprivate(set) var currentUserCredentials:(user:String,password:String)?
    
    var lastError:Error?

    // db name
    fileprivate let kDBName:String = "patientprofile"
    fileprivate let kPrebuiltDBFolder:String = "prebuilt"
    fileprivate var _db:Database?
    
    // replication related
    fileprivate var _pushPullRepl:Replicator?
    fileprivate var _pushPullReplListener:ListenerToken?
    fileprivate var kRemoteSyncUrl = "ws://localhost:4984/"
    
    fileprivate var _applicationDocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    fileprivate var _applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    
    static let shared:DatabaseManager = {
        
        let instance = DatabaseManager()
        instance.initialize()
        return instance
    }()
    
    func initialize() {
        //  enableCrazyLevelLogging()
    }
    // Don't allow instantiation . Enforce singleton
    private init() {
        
    }
    
    deinit {
        // Stop observing changes to the database that affect the query
        do {
            try self._db?.close()
        }
        catch  {
        }
    }
}

// MARK: Public
extension DatabaseManager {
    func openOrCreateDatabaseForUser(_ user:String, password:String, handler:(_ error:Error?)->Void) {
        do {
            var options = DatabaseConfiguration()
            guard let defaultDBPath = _applicationSupportDirectory else {
                fatalError("Could not open Application Support Directory for app!")
            }
            // Create a folder for the logged in user if one does not exist
            let userFolderUrl = defaultDBPath.appendingPathComponent(user, isDirectory: true)
            let userFolderPath = userFolderUrl.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: userFolderPath) {
                try fileManager.createDirectory(atPath: userFolderPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                
            }
            // Set the folder path for the CBLite DB
            options.directory = userFolderPath
   
            print("Will open/create DB  at path \(userFolderPath)")
            // Create a new DB or get handle to existing DB at specified path
            _db = try Database(name: kDBName, config: options)
            
            // register for DB change notifications
            self.registerForDatabaseChanges()
            
            currentUserCredentials = (user,password)
            handler(nil)
        }catch {
            
            lastError = error
            handler(lastError)
        }
    }
    
    func closeDatabaseForCurrentUser() -> Bool {
        do {
            print(#function)
            // Get handle to DB  specified path
            if let db = self.db {
                deregisterForDatabaseChanges()
                
                try db.close()
                _db = nil
            }
            
            return true
        }
        catch {
            return false
        }
    }
    
    fileprivate func registerForDatabaseChanges() {
        
        // Add database change listener
        dbChangeListenerToken = db?.addChangeListener({ [weak self](change) in
            guard let `self` = self else {
                return
            }
            for docId in change.documentIDs   {
                if let docString = docId as String? {
                    let doc = self._db?.document(withID: docString)
                    if doc == nil {
                        print("Document was deleted")
                    }
                    else {
                        print("Document was added/updated")
                    }
                }
            }
        })
    }
    
    fileprivate func deregisterForDatabaseChanges() {
        
        // Add database change listener
        if let dbChangeListenerToken = self.dbChangeListenerToken {
            db?.removeChangeListener(withToken: dbChangeListenerToken)
        }
    }
}

// MARK: Replication
extension DatabaseManager {
    func startPushAndPullReplicationForCurrentUser() {
        guard let remoteUrl = URL.init(string: kRemoteSyncUrl) else {
//            lastError = UserProfileError.RemoteDatabaseNotReachable
            return
        }

        guard let user = self.currentUserCredentials?.user,let password = self.currentUserCredentials?.password  else {
            lastError = UserProfileError.UserCredentialsNotProvided
            return
        }

        guard let db = db else {
            lastError = UserProfileError.DatabaseNotInitialized
            return
        }

        if _pushPullRepl != nil {
            // Replication is already started
            return
        }

        let dbUrl = remoteUrl.appendingPathComponent(kDBName)
        var config = ReplicatorConfiguration.init(database: db, target: URLEndpoint.init(url:dbUrl))

        config.replicatorType = .pushAndPull
        config.continuous =  true
        config.authenticator =  BasicAuthenticator(username: user, password: password)


        // This should match what is specified in the sync gateway config
        // Only pull documents from this user's channel
        let userChannel = "channel.\(user)"
        config.channels = [userChannel]

        _pushPullRepl = Replicator.init(config: config)

        _pushPullReplListener = _pushPullRepl?.addChangeListener({ (change) in
            let s = change.status
            switch s.activity {
            case .busy:
                print("Busy transferring data")
            case .connecting:
                print("Connecting to Sync Gateway")
            case .idle:
                print("Replicator in Idle state")
            case .offline:
                print("Replicator in offline state")
            case .stopped:
                print("Completed syncing documents")
            default:
                print("activity unkown")
            }

            if s.progress.completed == s.progress.total {
                print("All documents synced")
            }
            else {
                 print("Documents \(s.progress.total - s.progress.completed) still pending sync")
            }
        })
        _pushPullRepl?.start()
    }


    func stopAllReplicationForCurrentUser() {
        if let pushPullReplListener = _pushPullReplListener{
            print(#function)
            _pushPullRepl?.removeChangeListener(withToken:  pushPullReplListener)
            _pushPullRepl = nil
            _pushPullReplListener = nil
        }
        _pushPullRepl?.stop()
    }
}

// MARK: Utils
extension DatabaseManager {
    
    fileprivate func enableCrazyLevelLogging() {
        Database.log.console.domains = .all
        Database.log.console.level = .debug
    }
}
