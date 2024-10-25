//
//  SigninView.swift
//  Path_couchbase_sync
//
//  Created by Karpahalakshmi on 24/10/24.
//

import SwiftUI

struct SigninView: View {
    @State private var username = ""
    @State private var password = ""
    var body: some View {
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
            TextField("Email, phone & username", text: $username)
                .padding()
                .frame(width: 700, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray)
                )
            TextField("Password", text: $password)
                .padding()
                .frame(width: 700, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray)
                )
            Button("Sign in"){
                    
            }
            .foregroundColor(.white)
            .frame(width: 700, height: 50)
            .background(Color.blue)
            .cornerRadius(6)
            .padding(.bottom,20)
            .padding(.top, 50)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SigninView()
}
