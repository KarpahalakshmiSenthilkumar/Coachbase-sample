//
//  SigninView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 29/10/24.
//

import SwiftUI

struct SigninView: View {
    @StateObject private var signinViewModel = SigninViewModel()
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center){
                Spacer()
                Text("Lets Sign you in")
                    .bold()
                    .font(.largeTitle)
                    .padding([.bottom,.top],20)
                Text("Welcome Back,")
                    .bold()
                    .font(.title2)
                Text("You have been missed")
                    .bold()
                    .font(.title2)
                    .padding(.bottom,30)
                TextField("Email, phone & username", text: $signinViewModel.username)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 380, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray)
                    )
                TextField("Password", text: $signinViewModel.password)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 380, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray)
                    )
                Button {
                    Task {
                        try await signinViewModel.signIn()
                        isLoggedIn = true
                    }
                } label: {
                    Text("Signin")
                        .foregroundColor(.white)
                        .frame(width: 380, height: 50)
                        .background(Color.blue)
                        .cornerRadius(6)
                        .padding(.bottom,20)
                        .padding(.top, 50)
                }
//                Button(action: {
//                    signinViewModel.signIn()
////                    isLoggedIn = true
//                }) {
//                    Text("Signin")
//                        .foregroundColor(.white)
//                        .frame(width: 380, height: 50)
//                        .background(Color.blue)
//                        .cornerRadius(6)
//                        .padding(.bottom,20)
//                        .padding(.top, 50)
//                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SigninView(isLoggedIn: .constant(false))
}
