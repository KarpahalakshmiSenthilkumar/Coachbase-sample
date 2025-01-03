//
//  PatientDetails.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import Foundation

struct PatientDetails: Codable, Identifiable, Hashable {
    var id: Int?
    var createdAt: Date
    var mrn: String?
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var gender: String?
    var dobDate: Date?
    var admissionNumber: String?
    var admitDate: Date?
    var userID: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case mrn
        case firstName
        case middleName
        case lastName
        case gender
        case dobDate
        case admissionNumber
        case admitDate
        case createdAt = "created_at"
        case userID = "user_id"
    }
    
    init(id: Int? = nil, createdAt: Date, mrn: String?, firstName: String?, middleName: String?, lastName: String?, gender: String?, dobDate: Date? = nil, admissionNumber: String?, admitDate: Date?, userID: UUID) {
        self.id = id
        self.createdAt = createdAt
        self.mrn = mrn
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.gender = gender
        self.dobDate = dobDate
        self.admissionNumber = admissionNumber
        self.admitDate = admitDate
        self.userID = userID
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.mrn = try container.decodeIfPresent(String.self, forKey: .mrn)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.admissionNumber = try container.decodeIfPresent(String.self, forKey: .admissionNumber)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.userID = try container.decode(UUID.self, forKey: .userID)
        
        if let dobString = try container.decodeIfPresent(String.self, forKey: .dobDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.dobDate = dateFormatter.date(from: dobString)
        } else {
            self.dobDate = nil
        }
        
        if let dobString = try container.decodeIfPresent(String.self, forKey: .admitDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.admitDate = dateFormatter.date(from: dobString)
        } else {
            self.admitDate = nil
        }
    }
}
