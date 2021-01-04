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
    
    let userDefault = UserDefaults.standard

    
    var body: some View {
        VStack{
         
            Text("Smart Head Gear")
                .font(.largeTitle)
                .fontWeight(.bold)
            // Email ID Display
            Text(info.email)
                    .padding(25)
            // Google Login Button
            if (info.email == "") {
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
            } else {
                Button(action: {
                    self.info.email = ""
                    self.userDefault.set(false, forKey: "usersignedin")
                    self.userDefault.set("", forKey: "email")
                }) {
                    Text(" Sign Out ")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 45)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
        }.frame(width: 300, height: 500, alignment: .center)
        .onAppear() {
            if  let pastEmail = userDefault.string(forKey: "email") {
                print("past email: ", pastEmail)
                self.info.email = pastEmail
            }
            
        }
    }
}


