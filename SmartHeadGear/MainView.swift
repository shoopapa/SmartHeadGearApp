//
//  ContentView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 10/24/20.
//

import SwiftUI
import SwiftUICharts
import MetaWear

struct MainView:  View {
    let connection = MetawearConnection()
    let info: AppDelegate
    
    
    var body: some View {
        VStack {
            TabView {
                ConnectionTab()
                    .tabItem {
                      Image(systemName: "video.fill")
                      Text("Connection")
                    }
                
                Text("Moves AI Screen")
                    .tabItem {
                      Image(systemName: "icloud.fill")
                      Text("Simulations")
                    }
        
                ProfileView(info: self.info)
                  .tabItem {
                      Image(systemName: "person.fill")
                      Text("Profile")
                }
            }
        }
    }
}

