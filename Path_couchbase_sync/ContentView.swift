//
//  ContentView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import SwiftUI
import CouchbaseLiteSwift

struct ContentView: View {
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var signinViewModel = SigninViewModel()
    let genderList = ["Male", "Female"]
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
               Form {
                    TextField("Medical Record Number(MRN)", text:$contentViewModel.mrn)
                    Section(header: Text("Patient Details")) {
                        TextField("Patient First Name", text: $contentViewModel.firstname)
                        TextField("Patient Middle Name", text: $contentViewModel.middlename)
                        TextField("Patient Last Name", text: $contentViewModel.lastname)
                    }
                    Picker("Gender", selection: $contentViewModel.gender) {
                        ForEach(genderList, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    DatePicker("DOB", selection: $contentViewModel.dobDate, displayedComponents: .date)
                    TextField("Admission/Encounter Number", text: $contentViewModel.admissionNumber)
                    DatePicker("Admit Date", selection: $contentViewModel.admitDate, displayedComponents: .date)
                }
                
                Button {
                    print("")
                    contentViewModel.save()
                } label: {
                    Text("Save")
                }
                .padding()
                    
            }
            .navigationTitle("Demographics")
            .toolbar {
                Button("LogOff") {
                    contentViewModel.logOffUser()
                    isLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    ContentView(isLoggedIn: .constant(true))
}
