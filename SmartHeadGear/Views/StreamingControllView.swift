//
//  StreamingControllView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/24/20.
//

import Foundation
import SwiftUI
import Firebase

struct StreamingControllView:  View {
    @EnvironmentObject var connection: MetawearConnection
    @ObservedObject var info : AppDelegate
    @State var saving: Bool = false
    @State var LoginPlease: Bool = false
    @State var text: String = ""
    let db = Firestore.firestore()

    
    func saveMove() {
        self.db.collection("moves").addDocument(data: [
            "moveName": self.text,
            "time": NSDate().timeIntervalSince1970,
            "email": self.info.email,
            "accerationX": self.connection.accerometorLines[0],
            "accerationY":self.connection.accerometorLines[1],
            "accerationZ":self.connection.accerometorLines[2],
            "gyroX": self.connection.gyroLines[0],
            "gyroY":self.connection.gyroLines[1],
            "gyroZ":self.connection.gyroLines[2]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
   
    var body: some View {
        HStack {
            ConnectButton(text:"Stop") {
                connection.accelerometerStopLog()
                connection.gryoStopLog()
            }.frame(width:100)
            ConnectButton(text:"Start") {
                connection.accelerometerStartLog()
            }.frame(width:100)
            ConnectButton(text:"Save") {
                if !(info.email == "") {
                    self.saving = true
                } else {
                    self.LoginPlease = true
                }
            }.frame(width:100)
            .alert(isPresented: $LoginPlease) {
                       Alert(title: Text("Login Frist"), dismissButton: .default(Text("Okay")))
                   }
            AlertControlView(textString: $text,
                            showAlert: $saving,
                            title: "Name This Move",
                            message: "") {
                print("Saving")
                self.saveMove()
            }.frame(width:0, height: 0, alignment: .center)
                                
                            
            
           
        }.frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
    }
}


