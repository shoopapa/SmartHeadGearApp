//
//  ConnectionView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/7/20.
//

import SwiftUI
import MetaWear

struct ConnectionView: View  {
    @EnvironmentObject var connection: MetawearConnection
    
    var body: some View {
        HStack {
            if (connection.loading) {
                ProgressView().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 100, maxWidth: 100, minHeight: 20, idealHeight: 20, maxHeight: 20, alignment: .center).padding(8)
            } else {
                if (connection.connected == "Connection Lost") {
                    ConnectButton(text:"Reconnect") {
                        connection.connectToRemembered()
                    }
                    ConnectButton(text:"Forget") {
                        connection.forget()
                    }
                } else if (connection.connected.contains(":")) {
                    ConnectButton(text:"Disconnect") {
                        connection.reset()
                    }
                    ConnectButton(text:"Test") {
                        connection.testLed()
                    }
                } else {
                    ConnectButton(text:"Connect") {
                        connection.connect()
                    }
                }
            }
            Text(connection.connected).padding(5)
            Circle().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 10, maxWidth: 20, minHeight: 20, idealHeight: 20, maxHeight: 20, alignment: .center).foregroundColor( (connection.connected.contains(":")) ? .green : .red)
            
        }.frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ConnectButton: View {
    let text: String
    var action: () -> Void
        
    var body: some View {
        Button.init(action:{
            self.action()
        },label: {
            Text(text)
        })
        .frame( minHeight: 20, idealHeight: 20, alignment: .center).accentColor(Color.blue).padding(8)
//        .foregroundColor(.white)
//        .background(Color.blue)
//        .cornerRadius(8)
//        .padding(5)
    }

}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}

