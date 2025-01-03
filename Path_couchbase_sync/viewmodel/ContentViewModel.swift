//
//  ContentViewModel.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 27/10/24.
//

import Foundation
import CouchbaseLiteSwift
import Supabase

enum Table {
    static let demographics = "Demographics"
}

@MainActor
class ContentViewModel: ObservableObject {

    @Published var mrn = ""
    @Published var firstname = ""
    @Published var middlename = ""
    @Published var lastname = ""
    @Published var gender: String = "Male"
    @Published var dobDate = Date.now
    @Published var admitDate = Date.now
    @Published var admissionNumber = ""
    
    let supabase = SupabaseClient(supabaseURL: Secrets.projectURL, supabaseKey: Secrets.apiKey)
    
    init() {
        Task {
            try await fetchUserData()
        }
    }
    
    func fetchUserData() async throws {
        do {
            print("Inside fetch method")
            let currentUser = try await supabase.auth.session.user
            print("Value stored into currentUser variable")
            let data: PatientDetails = try await supabase
                .from(Table.demographics)
                .select()
                .eq("user_id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            print("Value stored into data variable")
            print(data)
            
            self.mrn = data.mrn ?? ""
            self.firstname = data.firstName ?? ""
            self.middlename = data.middleName ?? ""
            self.lastname = data.lastName ?? ""
            self.gender = data.gender ?? "Male"
            self.dobDate = data.dobDate ?? Date.now
            self.admissionNumber = data.admissionNumber ?? ""
            self.admitDate = data.admitDate ?? Date.now
        } catch {
            debugPrint(error)
        }
    }
    
    func saveUserDate() async throws {
        let currentUser = try await supabase.auth.session.user
        let data = PatientDetails(createdAt: Date(), mrn: mrn, firstName: firstname, middleName: middlename, lastName: lastname, gender: gender, dobDate: dobDate, admissionNumber: admissionNumber, admitDate: admitDate, userID: currentUser.id)
        do {
                // Step 1: Check if the record exists
                let existingRecord: [PatientDetails] = try await supabase
                    .from(Table.demographics)
                    .select()
                    .eq("user_id", value: currentUser.id)
                    .execute()
                    .value

                if existingRecord.isEmpty {
                    // Step 2: Insert new record if not present
                    try await supabase
                        .from(Table.demographics)
                        .insert(data)
                        .execute()
                    print("Record inserted successfully")
                } else {
                    // Step 3: Update existing record
                    try await supabase
                        .from(Table.demographics)
                        .update(data)
                        .eq("user_id", value: currentUser.id)
                        .execute()
                    print("Record updated successfully")
                }
            } catch {
                print("Error saving user data: \(error)")
                throw error
            }
    }
    
//    func insertUserData(mrn: String, firstName: String, middleName: String, lastName: String, gender:String, dobDate: Date, admissionNumber: String, admitDate: Date) async throws {
//        let currentUser = try await supabase.auth.session.user
//        let data = PatientDetails(createdAt: Date(), mrn: mrn, firstName: firstName, middleName: middleName, lastName: lastName, gender: gender, dobDate: dobDate, admissionNumber: admissionNumber, admitDate: admitDate, userID: currentUser.id)
//        
//        try await supabase
//            .from(Table.demographics)
//            .insert(data)
//            .eq("user_id", value: currentUser.id)
//            .single()
//            .execute()
//    }
    
    func logOff() async throws {
        try await supabase.auth.signOut()
    }
}
