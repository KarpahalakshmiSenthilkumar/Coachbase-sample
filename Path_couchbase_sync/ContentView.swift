//
//  ContentView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import SwiftUI
import CouchbaseLiteSwift

struct ContentView: View {
    fileprivate var dbMgr: DatabaseManager = DatabaseManager.shared
    @State private var mrn = ""
    @State private var firstname = ""
    @State private var middlename = ""
    @State private var lastname = ""
    @State private var gender: String = "Male"
    @State private var dobDate = Date.now
    @State private var admitDate = Date.now
    @State private var admissionNumber = ""
    let genderList = ["Male", "Female"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Medical Record Number(MRN)", text:$mrn)
                    Section(header: Text("Patient Details")) {
                        TextField("Patient First Name", text: $firstname)
                        TextField("Patient Middle Name", text: $middlename)
                        TextField("Patient Last Name", text: $lastname)
                    }
                    Picker("Gender", selection: $gender) {
                        ForEach(genderList, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    DatePicker("DOB", selection: $dobDate, displayedComponents: .date)
                    TextField("Admission/Encounter Number", text: $admissionNumber)
                    DatePicker("Admit Date", selection: $admitDate, displayedComponents: .date)
                }
                
                Button {
                    print("")
                    save()
                } label: {
                    Text("Save")
                }
                .padding()

            }
            .onAppear {
                login()
            }
            .navigationTitle("Demographics")
        }
    }
    
    func login() {
        dbMgr.openOrCreateDatabaseForUser("demo@example.com", password: "password") { error in
            print("-------------")
            print(error?.localizedDescription)
            print("-------------")
        }
    }
    
    func save() {
        let mutableDoc = MutableDocument.init(id: "demo@example.com")
        var patientRecord = PatientDetails()
        patientRecord.mrn = "12345"
        patientRecord.firstName = "Ezhil"
        patientRecord.lastName = "Adhavan"
        patientRecord.gender = "Male"
        patientRecord.dateOfBirth = "21/09/1991"
        patientRecord.admitDate = "24/10/2024"
        patientRecord.admissionNo = "9999"
        
        mutableDoc.setString(patientRecord.type, forKey: "type")
        
        if let mrn = patientRecord.mrn {
            mutableDoc.setString(mrn, forKey: "mrn")
        }
        if let firstName = patientRecord.firstName {
            mutableDoc.setString(firstName, forKey: "firstName")
        }
        if let lastName = patientRecord.lastName {
            mutableDoc.setString(lastName, forKey: "lastName")
        }
        if let gender = patientRecord.gender {
            mutableDoc.setString(gender, forKey: "gender")
        }
        if let dateOfBirth = patientRecord.dateOfBirth {
            mutableDoc.setString(dateOfBirth, forKey: "dateOfBirth")
        }
        if let admitDate = patientRecord.admitDate {
            mutableDoc.setString(admitDate, forKey: "admitDate")
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
        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
