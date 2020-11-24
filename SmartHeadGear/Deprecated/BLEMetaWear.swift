//
//  BLEMetaWear.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/7/20.
//

import Foundation
import MetaWear
import MetaWearCpp

import MessageUI
import BoltsSwift
import iOSDFULibrary

open class BLEMetaWear: ObservableObject {
    var device: MetaWear = MetaWear.spoof()
    @Published var accerometorLines: [[Double]] = [[0],[0],[0]]
    @Published var gyroLines: [[Double]] = [[0],[0],[0]]
    @Published var loggers: [String: OpaquePointer] = [:]

    var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    
    func reset() {
        self.device.connectAndSetup().continueWith(.mainThread) { t in
            self.device.clearAndReset() // this handles everything for you
            print("Clear and Reset the board")
        }
    }
    
    func connect() {
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            // Hooray! We found a MetaWear board, so stop scanning for more
            MetaWearScanner.shared.stopScan()
            // Connect to the board we found
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Sorry we couldn't connect
                    print(error)
                } else {
                    t.result?.continueWith { t in
                           print("Lost connection")
                    }
                    device.remember()
                    DispatchQueue.main.async {
                        self.device = device
                    }
                }
            }
        }
    }
    
    func remem() {
        MetaWearScanner.shared.retrieveSavedMetaWearsAsync().continueOnSuccessWith { array in
            let savedDevice = array.first
            print("rememered")
            DispatchQueue.main.async {
                self.device = savedDevice!
            }
        }
    }
    
    
    func accelerometerStartLog(_ sender: Any) {
        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
        mbl_mw_acc_set_odr(device.board, 10)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: BLEMetaWear = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            DispatchQueue.main.async {
                _self.loggers[identifier] = logger!
            }
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }

    func accelerometerStopLog(_ sender: Any) {
        let device:MetaWear = self.device
        guard let logger = loggers.removeValue(forKey: "acceleration") else {
            return
        }
        self.accerometorLines[0] = [0]
        self.accerometorLines[1] = [0]
        self.accerometorLines[2] = [0]
        
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: BLEMetaWear = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accerometorLines[0].append( Double(acceleration.x) )
                _self.accerometorLines[1].append( Double(acceleration.y) )
                _self.accerometorLines[2].append( Double(acceleration.z) )   
            }
        }
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: BLEMetaWear = bridge(ptr: context!)
            if remainingEntries == 0 {
                _self.logCleanup()
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }
    
    func logCleanup() {
      // In order for the device to actaully erase the flash memory we can't be in a connection
      // so temporally disconnect to allow flash to erase.
      device.connectAndSetup().continueOnSuccessWithTask { t -> Task<MetaWear> in
        self.device.cancelConnection()
        return t
      }.continueOnSuccessWithTask { t -> Task<Task<MetaWear>> in
        return self.device.connectAndSetup()
      }
    }
    

    
    @IBAction func streamAcc(_ sender: Any) {
        
        mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
        mbl_mw_acc_set_odr(device.board, 10)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
        
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: BLEMetaWear = bridge(ptr: context!)
            DispatchQueue.main.async {
                if ( _self.accerometorLines[0].count > 50) {
                    _self.accerometorLines[0].remove(at: 0)
                    _self.accerometorLines[1].remove(at: 0)
                    _self.accerometorLines[2].remove(at: 0)
                }
                _self.accerometorLines[0].append( Double(acceleration.x) )
                _self.accerometorLines[1].append( Double(acceleration.y) )
                _self.accerometorLines[2].append( Double(acceleration.z) )
            }
        
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
           mbl_mw_acc_stop(self.device.board)
           mbl_mw_acc_disable_acceleration_sampling(self.device.board)
           mbl_mw_datasignal_unsubscribe(signal)
       }
    }
    
    @IBAction func streamGryo(_ sender:Any) {
        let device:MetaWear = self.device
        mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_125dps)
        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_25Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)
        
       
       let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
       mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
           let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
           let _self: BLEMetaWear = bridge(ptr: context!)
           DispatchQueue.main.async {
                if ( _self.gyroLines[0].count > 50) {
                    _self.gyroLines[0].remove(at: 0)
                    _self.gyroLines[1].remove(at: 0)
                    _self.gyroLines[2].remove(at: 0)
                }
                _self.gyroLines[0].append( Double(acceleration.x) )
                _self.gyroLines[1].append( Double(acceleration.y) )
                _self.gyroLines[2].append( Double(acceleration.z) )
           }
       }
       mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
       mbl_mw_gyro_bmi160_start(device.board)
       
       streamingCleanup[signal] = {
           mbl_mw_gyro_bmi160_stop(self.device.board)
           mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
           mbl_mw_datasignal_unsubscribe(signal)
       }
    }
    
    
   
    
    @IBAction func stopStreaming(_ sender: Any) {
     
        let board = self.device.board
        mbl_mw_logging_clear_entries(board)
        let signal = mbl_mw_acc_get_acceleration_data_signal(board)
        mbl_mw_acc_stop(board)
        mbl_mw_acc_disable_acceleration_sampling(board)
        mbl_mw_datasignal_unsubscribe(signal)
        
        let signal2 = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        mbl_mw_gyro_bmi160_stop(self.device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
        mbl_mw_datasignal_unsubscribe(signal2)
    }

}

