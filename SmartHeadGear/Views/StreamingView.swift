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
    let chartStyle = ChartStyle(formSize: ChartForm.small)
    
    var body: some View {
        VStack {
            MultiLineChartView(data: [([8,32,11,23,40,28], GradientColors.green)], title: "Acceration", form:ChartForm.large)
            Divider()
            MultiLineChartView(data: [([8,32,11,23,40,28], GradientColors.orange)], title: "Gryo", form:ChartForm.large)
        }
    }
}

