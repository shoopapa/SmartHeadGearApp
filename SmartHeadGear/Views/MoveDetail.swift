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
                Text(self.get.move!.moveName)
                    .font(.title)
                    .foregroundColor(.primary)
                HStack {
                    Text("park")
                    Spacer()
                    Text("state")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

//                Text(self.get.move.description)
            }
            .padding()
            .onAppear() {
                self.get.getMove(id: self.id)
            }
        }
        .navigationTitle(self.get.move!.moveName )
        .navigationBarTitleDisplayMode(.inline)
    }
}



class GetMoveManager: ObservableObject {
    
    @Published var move:Move? = Move(email: "loading@loading.com", moveName: "String", time: 0)
    @Published var loading = false

    let db = Firestore.firestore()

    // good example of workin
    func getMove(id:String) {
        let docRef = db.collection("moves").document(id)
        
        docRef.getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                   print("Error fetching document: \(error!)")
                   return
            }
            
            self.move = try! document.data(as: Move.self)
        }
    }
}


struct Move: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    var email: String
    var moveName: String
    var time: Float
//    var accerationX: [Float] = []
//    var accerationY: [Float] = []
//    var accerationZ: [Float] = []
//    var GryoX:[Float] = []
//    var GryoY:[Float] = []
//    var GryoZ:[Float] = []
    enum CodingKeys: String, CodingKey {
        case email
        case moveName
        case time
    }
}


