//
//  PatientDetails.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import Foundation

struct PatientDetails {
    let type: String = "patient"
    var email: String?
    var mrn: String?
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var gender: String?
    var dateOfBirth: Date?
    var admissionNo: String?
    var admitDate: Date?
}
