//
//  SigninViewModel.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 29/10/24.
//

import Foundation
import Supabase

class SigninViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    let supabase = SupabaseClient(supabaseURL: Secrets.projectURL, supabaseKey: Secrets.apiKey)
    
    func signIn() async throws {
        _ = try await supabase.auth.signIn(email: username, password: password)
    }
}
