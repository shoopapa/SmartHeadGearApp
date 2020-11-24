//
//  ContentView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 10/24/20.
//

import SwiftUI
import SwiftUICharts

struct MainView:  View {
    var body: some View {
        VStack {
            ConnectionView().padding(8)
            Divider()
            StreamingView()
            Divider()
            StreamingControllView().padding(8)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
