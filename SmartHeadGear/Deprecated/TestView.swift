//
//  TestView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/22/20.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct TestView:  View {
    @ObservedObject var ble = BLEMetaWear()
    

    var body: some View {
        HStack{
            Button.init(action:{
                ble.connect()
            }, label:{
                Text("connect BLE")
            }).padding(10)
            Button.init(action:{
                ble.stopStreaming(self)
            }, label: {
                Text("Stop Streaming")
            }).padding(10)
            Button.init(action:{
                ble.remem()
            },label: {
                Text("remem")
            }).padding(10)
        }
        HStack{
            Button.init(action:{
                ble.streamAcc(self)
            }, label: {
                Text("Start Acc")
            }).padding(10)

            Button.init(action:{
                ble.streamGryo(self)
            },label: {
                Text("Start Gryo")
            }).padding(10)
        }
        HStack{
            Button.init(action:{
                ble.accelerometerStartLog(self)
            }, label: {
                Text("Start Logging Acc")
            }).padding(10)

            Button.init(action:{
                ble.accelerometerStopLog(self)
            },label: {
                Text("Stop Logging Acc")
            }).padding(10)
           

        }
        HStack {
            Button.init(action:{
                ble.reset()
            },label: {
                Text("Reset")
            }).padding(10)
            
        }
        HStack{
            MultiLineChartView(
                data: [
                    (ble.accerometorLines[0], GradientColors.orange),
                    (ble.accerometorLines[1], GradientColors.green),
                    (ble.accerometorLines[2], GradientColors.blue)
                ],
                title: "Acceration"
            )
            MultiLineChartView(
                data: [
                    (ble.gyroLines[0], GradientColors.orngPink),
                    (ble.gyroLines[1], GradientColors.green),
                    (ble.gyroLines[2], GradientColors.bluPurpl)
                ],
                title: "Gyro"
            )
        }
    }
}
