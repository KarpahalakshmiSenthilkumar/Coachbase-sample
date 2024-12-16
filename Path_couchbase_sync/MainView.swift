//
//  MainView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 30/10/24.
//

import SwiftUI

struct MainView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            ContentView(isLoggedIn: $isLoggedIn)
        } else {
            SigninView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    MainView()
}
