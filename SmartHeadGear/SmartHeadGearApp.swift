//
//  SmartHeadGearApp.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 10/24/20.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct SmartHeadGearApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView(info: self.delegate)
        }
    }
    
}


class AppDelegate: NSObject,UIApplicationDelegate,GIDSignInDelegate,ObservableObject{
    
    @Published var email = ""
    
    let userDefault = UserDefaults.standard

    let launchedBefore = UserDefaults.standard.bool(forKey: "usersignedin")
    let launchedBeforeEmail = UserDefaults.standard.string(forKey: "email")
    
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Intial Firebase
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
      }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let user = user else{
            print(error.localizedDescription)
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        
        // Signing into Firebase
        
        Auth.auth().signIn(with: credential) { (result,err) in
      
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            self.email = (result?.user.email)!
            self.userDefault.set(true, forKey: "usersignedin")
            self.userDefault.set(self.email, forKey: "email")
            self.userDefault.synchronize()
            
            print(self.email)
      }
    }
}
