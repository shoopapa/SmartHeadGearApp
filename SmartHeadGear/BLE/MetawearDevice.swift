//
//  MetawearDevice.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/24/20.
//

import Foundation
import MetaWear
import MetaWearCpp

import MessageUI
import BoltsSwift
import iOSDFULibrary


open class MetawearConnection: ObservableObject {
    @Published var device: MetaWear = MetaWear.spoof()
    @Published var connected: String = "Not Connected"
    @Published var loading: Bool = true
    var currentDevice: MetaWear = MetaWear.spoof()
    
    init() {
        self.connected = "Not Connected"
        self.connectToRemembered()
    }
    
    func connect() {
        setLoading(loading: true)
        let cancelConnectionTimeout = self.cancelConnection(message: "Connect Timed Out")
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            // Hooray! We found a MetaWear board, so stop scanning for more
            if device.rssi > -55 {
                print(String( device.mac! ))
                MetaWearScanner.shared.stopScan()
                // Connect to the board we found
                device.connectAndSetup().continueWith { t in
                    if let error = t.error {
                        cancelConnectionTimeout()
                        // Sorry we couldn't connect
                        print(error)
                    } else {
                        t.result?.continueWith { t in
                            cancelConnectionTimeout()
                            self.connectionLost()
                        }
                        cancelConnectionTimeout()
                        self.ConnectionSuccessful(device:device)
                    }
                }
            }
        }
    }
    
    func disconnect() {
        device.cancelConnection()
        self.connectionLost()
    }
    
    func cancelConnection(message: String) -> () -> Void {
        print("cancel Connection Started", "message: ", message)
        let savedDevice = self.currentDevice
        let cancel = DispatchWorkItem {
            savedDevice.cancelConnection()
            savedDevice.forget()
            MetaWearScanner.shared.stopScan()
            self.connectionLost(message: message)
            print("cancel called message: ", message)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: cancel )
        return {
            cancel.cancel()
        }
    }
    
    func forget() {
        MetaWearScanner.shared.retrieveSavedMetaWearsAsync().continueOnSuccessWith { array in
            array.first!.forget()
        }
        self.connectionLost(message: "Not Connected")
    }
    
    func connectToRemembered() {
        setLoading(loading: true)
        MetaWearScanner.shared.retrieveSavedMetaWearsAsync().continueOnSuccessWith { array in
            if array.first != nil {
                let savedDevice = array.first
                let cancelConnectionTimeout = self.cancelConnection(message: "Reconnection Failed")
                savedDevice!.connectAndSetup().continueWith { t in
                    if t.cancelled {
                        print("cancelConnection() called before connection completed")
                    } else if let error = t.error {
                        cancelConnectionTimeout()
                        self.connectionLost()
                        print(error)
                    } else {
                        t.result?.continueWith { t in
                            cancelConnectionTimeout()
                            self.connectionLost()
                        }
                        cancelConnectionTimeout()
                        self.ConnectionSuccessful(device:savedDevice!)
                    }
                }
            } else {
                self.connectionLost(message: "Not Connected")
            }
        }
    }
    
    func connectionLost(message:String = "Connection Lost") {
        DispatchQueue.main.async {
            self.connected = String( message )
            self.device = MetaWear.spoof()
            self.setLoading(loading: false)
        }
    }
    
    func ConnectionSuccessful(device: MetaWear) {
        device.remember()
        DispatchQueue.main.async {
            self.connected = String( device.mac! )
            self.device = device
            self.setLoading(loading: false)
        }
    }
    
    func testLed() {
        device.flashLED(color: .green, intensity: 1.0, _repeat: 2)
    }
    
    func setLoading(loading: Bool) {
        DispatchQueue.main.async {
            self.loading = loading
        }
    }
    
}
