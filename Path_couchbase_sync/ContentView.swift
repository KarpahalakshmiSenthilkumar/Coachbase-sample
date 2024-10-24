//
//  ContentView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
