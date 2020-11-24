//
//  BLEMetaWear.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/7/20.
//
import Foundation
import SwiftUI


struct ConnectionView:  View {
    @ObservedObject var ble = MetawearConnection()
    
    var body: some View {
        HStack {
            if (ble.loading) {
                ProgressView().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 100, maxWidth: 100, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: .center)
            } else {
                if (ble.connected == "Connection Lost") {
                    Button.init(action:{
                        ble.connectToRemembered()
                    },label: {
                        Text("Reconnect")
                    }).frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 100, maxWidth: 100, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: .center)
                    Button.init(action:{
                        ble.forget()
                    },label: {
                        Text("Forget")
                    }).padding(8)
                } else if (ble.connected.contains(":")) {
                    Button.init(action:{
                        ble.disconnect()
                    },label: {
                        Text("Disconnect")
                    }).frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 100, maxWidth: 100, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: .center)
                    Button.init(action:{
                        ble.testLed()
                    },label: {
                        Text("Test")
                    }).padding(8)
                } else {
                    Button.init(action:{
                        ble.connect()
                    },label: {
                        Text("Connect")
                    }).frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 100, maxWidth: 100, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: .center)
                }
            }
            Text(ble.connected).padding(10)
            Circle().frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 10, maxWidth: 20, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: .center).foregroundColor( (ble.connected.contains(":")) ? .green : .red)
            
        }
    }
}



