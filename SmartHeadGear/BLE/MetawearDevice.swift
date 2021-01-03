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
    var currentDevice: MetaWear = MetaWear.spoof() // used for reconnecting to remembered device
    
    @Published var loggers: [String: OpaquePointer] = [:] //used for logging
    var streamingCleanup: [OpaquePointer: () -> Void] = [:]

    @Published var accerometorLines: [[Double]] = [[0],[0],[0]]
    @Published var gyroLines: [[Double]] = [[0],[0],[0]]
    
    var logProgress:[Bool] = [false,true]
    
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
//                print(String( device.mac! ))
                MetaWearScanner.shared.stopScan()
                // Connect to the board we found
                device.connectAndSetup().continueWith { t in
                    if let error = t.error {
                        cancelConnectionTimeout()
                        // Sorry we couldn't connect
                        print(error)
                    } else {
                        t.result?.continueWith { t in
                            print("lost connection event")
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
        self.device.cancelConnection()
        self.connectionLost()
    }
    
    func reset() {
        self.device.connectAndSetup().continueWith(.mainThread) { t in
            self.device.clearAndReset() // this handles everything for you
            print("Clear and Reset the board")
        }
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7, execute: cancel )
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
                            print("disconnect event")
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
        print("connectionLost", message)
        DispatchQueue.main.async {
            self.connected = String( message )
//            self.device = MetaWear.spoof()
            self.setLoading(loading: false)
        }
    }
    
    func ConnectionSuccessful(device: MetaWear) {
        device.remember()
        mbl_mw_logging_clear_entries(device.board)
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
    //end connection functions
    
    
    // Logging functions
    func accelerometerStartLog() {
        self.accerometorLines = [[],[],[]]
        self.gyroLines = [[],[],[]]
        
        print("start log")
        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
        mbl_mw_acc_set_odr(device.board, 800)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MetawearConnection = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            DispatchQueue.main.async {
                _self.loggers[identifier] = logger!
            }
        }
    
        
        
        mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_125dps)
        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_800Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)


       let gryoSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        mbl_mw_datasignal_log(gryoSignal, bridge(obj: self)) { (context, logger) in
            let _self: MetawearConnection = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            DispatchQueue.main.async {
                _self.loggers[identifier] = logger!
            }
       }
        
        mbl_mw_logging_start(device.board, 0)
        
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
    }
    
    //not sure what the best method to build this is, I want high frequency streaming to get head impacts, but Logging requires breaks, I theory I could stop and reset logging every minute or so
    //I could stream high frequency but that will kill the battery in a few hours, pheraps this is the best method, We just have to bite the bullet a buy batteries.
    //Maybe 5 minutes is long enough for high freqeuncy logging?
    //2 modes? training mode and safty mode? ie low frequency logging for long training sessions, high freq, short durations for head impact analysis.
    //automatic logging with gaps in training, hopfully not more than that few seconds need to run tests on how long it takes to offload data
    
    // most of this code just needs to run once, we are duplicating the subscirbe and handlers, I Should be run once on initialization, the should just be able to run start and stop.
    func accelerometerStopLog() {
        print("stop Acc log")
        let device:MetaWear = self.device
        guard let logger = loggers.removeValue(forKey: "acceleration") else {
            return
        }
        
        
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
      
        
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: MetawearConnection = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accerometorLines[0].append( Double(acceleration.x) )
                _self.accerometorLines[1].append( Double(acceleration.y) )
                _self.accerometorLines[2].append( Double(acceleration.z) )
            }
        }
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: MetawearConnection = bridge(ptr: context!)
//            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            if remainingEntries == 0 {
                _self.logProgress[0] = true
                _self.logCleanup()
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry-Acc")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry-Acc")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)

    }
    
    func gryoStopLog() {
        print("stop Gryo log")
        let device:MetaWear = self.device
  
        guard let logger = loggers.removeValue(forKey: "angular-velocity") else {
            return
        }
        
        mbl_mw_gyro_bmi160_stop(device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(device.board)
        
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            print(Double(acceleration.x))
            let _self: MetawearConnection = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.gyroLines[0].append( Double(acceleration.x) )
                _self.gyroLines[1].append( Double(acceleration.y) )
                _self.gyroLines[2].append( Double(acceleration.z) )
            }
        }
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: MetawearConnection = bridge(ptr: context!)
//            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            if remainingEntries == 0 {
                _self.logProgress[1] = true
                _self.logCleanup()
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry-Gryo")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry-Gryo")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)

    }
    
    func logCleanup() {
        if (self.logProgress[0] && self.logProgress[1]) {
            self.logProgress=[false,true]
           // In order for the device to actaully erase the flash memory we can't be in a connection
           // so temporally disconnect to allow flash to erase.
            self.device.connectAndSetup().continueOnSuccessWithTask { t -> Task<MetaWear> in
               self.reset()
               return t
            }.continueOnSuccessWith() {xd in
                self.connectToRemembered()
            }
        }
    }
}

