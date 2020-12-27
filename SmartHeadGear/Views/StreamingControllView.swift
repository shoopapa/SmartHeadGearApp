//
//  StreamingControllView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/24/20.
//

import Foundation
import SwiftUI


struct StreamingControllView:  View {
    @EnvironmentObject var connection: MetawearConnection
    @State var saving: Bool = false
    @State var text: String = "test"
    @State var name: String = ""
   
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
                self.saving = true
            }.frame(width:100)
            if saving {
                AlertControlView(textString: $text,
                                    showAlert: $saving,
                                    title: "Data Set Name",
                                    message: self.name).frame(width:0, height: 0, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
        }.frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}


