//
//  SigninViewModel.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 29/10/24.
//

import Foundation

class SigninViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    var dbMgr:DatabaseManager = DatabaseManager.shared
    
    func login() {
        // Initiate user creation or verification in Sync Gateway
        verifyOrCreateUserInSyncGateway(username: username, password: password) { success, error in
            if success {
                print("User is available in Sync Gateway.")
                // Open or create the database for the user
                self.dbMgr.openOrCreateDatabaseForUser(self.username, password: self.password) { error in
                    if let error = error {
                        print("Failed to open database after user verification: \(error.localizedDescription)")
                    } else {
                        print("Database opened successfully for user.")
                        // Start replication only after the database opens successfully
                        DatabaseManager.shared.startPushAndPullReplicationForCurrentUser()
                    }
                }
            } else {
                // Handle any errors during user verification or creation
                print("Error verifying or creating user: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func verifyOrCreateUserInSyncGateway(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        // Check if the user exists
        guard let url = URL(string: "http://localhost:4985/patientprofile/_user/\(username)") else {
            print("Invalid URL")
            completion(false, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set the admin credentials for authorization
        let adminUsername = "Administrator"
        let adminPassword = "Pheonix@123"
        let loginString = "\(adminUsername):\(adminPassword)"
        if let loginData = loginString.data(using: .utf8) {
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }

        // Check if the user already exists
        let checkUserTask = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response)
            if let error = error {
                print("Network error while checking user existence: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response received")
                completion(false, NSError(domain: "NoHTTPResponse", code: -1, userInfo: nil))
                return
            }

            if httpResponse.statusCode == 200 {
                // User already exists
                print("User \(username) already exists.")
                completion(true, nil) // Proceed to open/create database
            } else if httpResponse.statusCode == 404 {
                // User does not exist, so create the user
                self.createUserInSyncGateway(username: username, password: password, completion: completion)
            } else {
                print("Failed to check user existence with status code \(httpResponse.statusCode)")
                completion(false, NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to check user existence"]))
            }
        }
        
        checkUserTask.resume()
        print("Checking user existence - Request sent")
    }

    func createUserInSyncGateway(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "http://localhost:4985/patientprofile/_user/") else {
            print("Invalid URL")
            completion(false, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set the admin credentials for authorization
        let adminUsername = "Administrator"
        let adminPassword = "Pheonix@123"
        let loginString = "\(adminUsername):\(adminPassword)"
        if let loginData = loginString.data(using: .utf8) {
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "name": username,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("Received server response") // Checkpoint 1: Server response received
            
            print(response)
            
            if let error = error {
                print("Error occurred: \(error)")
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                let statusError = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
                print("Failed to create user: Status code not 201")
                completion(false, statusError)
                return
            }
            
            print("User created successfully on server")
            completion(true, nil) // Notify success
        }
        task.resume()
        print("User creation request sent - Waiting for server response")
    }

}
