//
//  MoveDetail.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 1/3/21.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUICharts

struct MoveDetail: View {
    var id: String
    
    @ObservedObject var get:GetMoveManager = GetMoveManager()

    var body: some View {

        ScrollView {
            VStack(alignment: .leading) {
                Text(self.get.move.moveName)
                    .font(.title)
                    .foregroundColor(.primary)
                Divider()
                HStack {
                    let accx = self.get.move.accerationX.count
                    let accy = self.get.move.accerationY.count
                    let accz = self.get.move.accerationZ.count
           

                    Text("acceration (x,y,z)")
                    Spacer()
                    Text("(\(accx),\(accy),\(accz))")
                }
                HStack {
                    let gryox = self.get.move.gyroX.count
                    let gryoy = self.get.move.gyroY.count
                    let gryoz = self.get.move.gyroZ.count
                    Text("Gryo (x,y,z)")
                    Spacer()
                    Text("(\(gryox),\(gryoy),\(gryoz))")

                }



//                Text(self.get.move.description)
            }
            .padding()
            .onAppear() {
                self.get.getMove(id: self.id)
            }
        }
        .navigationTitle(self.get.move.moveName )
        .navigationBarTitleDisplayMode(.inline)
    }
}



class GetMoveManager: ObservableObject {
    
    @Published var move:Move = Move()
    @Published var loading = true

    let db = Firestore.firestore()

    // good example of workin
    func getMove(id:String) {
        self.loading = true
        let docRef = db.collection("moves").document(id)
        
        docRef.getDocument { doc, error in
            if let doc = doc,doc.exists {
                print("it exits")
                if let ween = try? doc.data(as: Move.self) {
                    print("it should be set")
                    self.move = ween
                }
            } else {
                print("jawn fucked up")
            }
            self.loading = false
        }
    }
}


struct Move: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    // if it fails to parse it because somthing in here is spelled wrong
    var email: String = ""
    var moveName: String = ""
    var time: Float = 0
    var accerationX: [Float] = []
    var accerationY: [Float] = []
    var accerationZ: [Float] = []
    var gyroX:[Float] = []
    var gyroY:[Float] = []
    
    var gyroZ:[Float] = []
}


