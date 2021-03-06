//
//  ConnectionTab.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 12/20/20.
//

import Foundation
import SwiftUI

struct ConnectionTab:  View {
    let connection = MetawearConnection()
    @ObservedObject var info : AppDelegate
    
    var body: some View {

        VStack {
          
            ConnectionView().environmentObject(connection)
            StreamingView().environmentObject(connection)
            StreamingControllView(info: self.info).environmentObject(connection)
                   
        }
    }
}

