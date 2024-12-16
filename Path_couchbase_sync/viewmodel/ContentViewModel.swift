//
//  ContentViewModel.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 27/10/24.
//

import Foundation
import CouchbaseLiteSwift

class ContentViewModel: ObservableObject {
    
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    fileprivate var userQueryToken:ListenerToken?
    fileprivate var userQuery:Query?
    fileprivate var record:PatientDetails?
    fileprivate var isObservingForLoginEvents:Bool = false

    @Published var mrn = ""
    @Published var firstname = ""
    @Published var middlename = ""
    @Published var lastname = ""
    @Published var gender: String = "Male"
    @Published var dobDate = Date.now
    @Published var admitDate = Date.now
    @Published var admissionNumber = ""
    
    private var isDatabaseReady = false {
        didSet {
            if isDatabaseReady {
                fetchRecordForCurrentUserWithLiveModeEnabled(__: true)
            }
        }
    }
        
    init() {
        initializeDatabase()
    }
        
    private func initializeDatabase() {
        DispatchQueue.global().async {
            // Simulate database initialization delay
            sleep(1) // Replace with actual database setup logic
                
            DispatchQueue.main.async {
                self.isDatabaseReady = true
            }
        }
    }
    
    enum AppNotifications {
        enum loginInSuccess : String{
            case name = "LoginSuccess"
            enum userInfoKeys : String{
                case user = "user"
            }
        }
        enum loginInFailure :String {
            case name = "LoginFailure"
            enum userInfoKeys : String {
                case user = "user"
            }
        }
        
        enum logout:String {
            case name = "LogOut"
        }
    }
    
    lazy var userProfileDocId: String = {
        let userId = dbMgr.currentUserCredentials?.user
        return "user::\(userId ?? "")"
    }()
    
    func updateUIWithUserRecord(_ record: PatientDetails?, error: Error?) {
        guard let record = record else {
            print("Error fetching record: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
                
        mrn = record.mrn ?? ""
        firstname = record.firstName ?? ""
        middlename = record.middleName ?? ""
        lastname = record.lastName ?? ""
        gender = record.gender ?? ""
        dobDate = record.dateOfBirth ?? Date.now
        admissionNumber = record.admissionNo ?? ""
        admitDate = record.admitDate ?? Date.now
    }
    
    // Mock function to fetch a record
    func fetchRecord() -> PatientDetails {
        // Replace with actual fetch logic
        return PatientDetails(mrn: mrn, firstName: firstname, middleName: middlename, lastName: lastname, gender: gender, dateOfBirth: dobDate, admissionNo: admissionNumber, admitDate: admitDate)
    }
        
    deinit {
        if let userQueryToken = userQueryToken {
            userQuery?.removeChangeListener(withToken: userQueryToken)
        }
        userQuery = nil
    }
    
    func fetchRecordForCurrentUserWithLiveModeEnabled(__ enabled:Bool = false) {
        // Doing a live query for specific document
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        switch enabled {
        case true :
            userQuery = QueryBuilder
                .select(SelectResult.all())
                .from(DataSource.database(db))
                .where(Meta.id.equalTo(Expression.string(self.userProfileDocId)))
            //There should be only one document for a user.
            userQueryToken = userQuery?.addChangeListener { [weak self] (change) in
                guard let self = self else {return}
                switch change.error {
                case nil:
                    var patientDetails = PatientDetails.init()
                    patientDetails.email = self.dbMgr.currentUserCredentials?.user
                    
                    for (_, row) in (change.results?.enumerated())! {
                        // There should be only one user profile document for a user
                        print(row.toDictionary())
                        if let userVal = row.dictionary(forKey: "patientprofile") {
                        patientDetails.email  = userVal.string(forKey: "email")
                        patientDetails.mrn  = userVal.string(forKey: "mrn")
                        patientDetails.firstName = userVal.string(forKey: "firstName")
                        patientDetails.middleName = userVal.string(forKey: "middleName")
                        patientDetails.lastName = userVal.string(forKey: "lastName")
                        patientDetails.gender = userVal.string(forKey: "gender")
                        patientDetails.dateOfBirth = userVal.date(forKey: "dateOfBirth")
                        patientDetails.admissionNo = userVal.string(forKey: "admissionNo")
                        patientDetails.admitDate = userVal.date(forKey: "admitDate")
                        }
                    }
                    self.updateUIWithUserRecord(patientDetails, error: nil)
                default:
                    self.updateUIWithUserRecord(nil, error: UserProfileError.UserNotFound)
                }
            }
        case false:
            // Case when we are doing a one-time fetch for document
            guard let db = dbMgr.db else {
                fatalError("db is not initialized at this point!")
            }
            
            var profile = PatientDetails.init()
            profile.email = self.dbMgr.currentUserCredentials?.user
            
            // fetch document corresponding to the user Id
            if let doc = db.document(withID: self.userProfileDocId)  {
                profile.email  = doc.string(forKey: "email")
                profile.mrn = doc.string(forKey: "mrn")
                profile.firstName = doc.string(forKey: "firstName")
                profile.middleName = doc.string(forKey: "middleName")
                profile.lastName = doc.string(forKey: "lastName")
                profile.gender = doc.string(forKey: "gender")
                profile.dateOfBirth = doc.date(forKey: "dateOfBirth")
                profile.admissionNo = doc.string(forKey: "admissionNo")
                profile.admitDate = doc.date(forKey: "admitDate")
            }
            self.updateUIWithUserRecord(profile, error: nil)
        }
    }
    
    func deregisterNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppNotifications.loginInSuccess.name.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppNotifications.loginInFailure.name.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppNotifications.logout.name.rawValue), object: nil)
        isObservingForLoginEvents = false
    }
    
    func logOffUser() {   
        self.deregisterNotificationObservers()
        self.dbMgr.stopAllReplicationForCurrentUser()
        let _ = DatabaseManager.shared.closeDatabaseForCurrentUser()
//        let logged = DatabaseManager.shared.closeDatabaseForCurrentUser()
//        if logged{
//            print("User logged off.")
//        }
    }
    
    func save() {
        let mutableDoc = MutableDocument.init(id: userProfileDocId)
        var patientRecord = PatientDetails()
        patientRecord.email = dbMgr.currentUserCredentials?.user
        patientRecord.mrn = mrn
        patientRecord.firstName = firstname
        patientRecord.middleName = middlename
        patientRecord.lastName = lastname
        patientRecord.gender = gender
        patientRecord.dateOfBirth = dobDate
        patientRecord.admitDate = admitDate
        patientRecord.admissionNo = admissionNumber
        
        mutableDoc.setString(patientRecord.type, forKey: "type")
        
        if let email = patientRecord.email {
            mutableDoc.setString(email, forKey: "email")
        }
        
        if let mrn = patientRecord.mrn {
            mutableDoc.setString(mrn, forKey: "mrn")
        }
        if let firstName = patientRecord.firstName {
            mutableDoc.setString(firstName, forKey: "firstName")
        }
        if let middleName = patientRecord.middleName {
            mutableDoc.setString(middleName, forKey: "middleName")
        }
        if let lastName = patientRecord.lastName {
            mutableDoc.setString(lastName, forKey: "lastName")
        }
        if let gender = patientRecord.gender {
            mutableDoc.setString(gender, forKey: "gender")
        }
        if let dateOfBirth = patientRecord.dateOfBirth {
            mutableDoc.setDate(dateOfBirth, forKey: "dateOfBirth")
        }
        if let admitDate = patientRecord.admitDate {
            mutableDoc.setDate(admitDate, forKey: "admitDate")
        }
        if let admissionNo = patientRecord.admissionNo {
            mutableDoc.setString(admissionNo, forKey: "admissionNo")
        }
        
        
        do {
            // This will create a document if it does not exist and overrite it if it exists
            // Using default concurrency control policy of "writes always win"
            print(dbMgr.db)
            try dbMgr.db?.saveDocument(mutableDoc)
            print("Record Saved")
            print()
        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
