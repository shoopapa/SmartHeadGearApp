//
//  ContentView.swift
//  Shared
//dis is mine now
//  Created on 19/7/2020.
//
import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    
    @ObservedObject var info : AppDelegate
    
    var body: some View {
        VStack{
         
            Text("Smart Head Gear")
                .font(.largeTitle)
                .fontWeight(.bold)
            // Email ID Display
            Text(info.email)
                    .padding(25)
            // Google Login Button
            Button(action: {
                GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
                GIDSignIn.sharedInstance()?.signIn()
            }) {
                Text(" Sign in with Google ")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 45)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }.frame(width: 300, height: 500, alignment: .center)
    }
}


