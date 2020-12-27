//
//  StreamingView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 11/24/20.
//

import Foundation
import SwiftUI
import SwiftUICharts
import MetaWear

struct StreamingView:  View {
    @EnvironmentObject var connection: MetawearConnection
    
    let chartStyle = ChartStyle(formSize: ChartForm.small)
    
    var body: some View {
        HStack {
            MultiLineChartView(data: [
                (connection.accerometorLines[0], GradientColors.orange),
                (connection.accerometorLines[1], GradientColors.green),
                (connection.accerometorLines[2], GradientColors.bluPurpl)
            ], title: "Acceration", form:ChartForm.medium, dropShadow: false)
            
            MultiLineChartView(data: [
                (connection.gyroLines[0], GradientColors.orange),
                (connection.gyroLines[1], GradientColors.green),
                (connection.gyroLines[2], GradientColors.bluPurpl)
            ], title: "Gryo", form:ChartForm.medium, dropShadow: false)
        }
    }
}

