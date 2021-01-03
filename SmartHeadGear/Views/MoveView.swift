//
//  MoveView.swift
//  SmartHeadGear
//
//  Created by Joe Davis on 12/27/20.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift


struct MoveView: View {
    
    @ObservedObject var info : AppDelegate
    
    @ObservedObject var networkManager:NetworkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List(self.networkManager.moveList) { move in
                VStack(alignment: .leading) {
                    Text(move.moveName)
                    Text(move.email)
                }
            }
            .navigationBarTitle("Moves")
            .onAppear() {
                self.networkManager.getList(email: self.info.email)
            }
        }
    }
}
       




class NetworkManager: ObservableObject {

    @Published var moveList = [MoveInfo]()
    @Published var move = Move()
    @Published var loading = false
    @Published var moveName:String = ""

    let db = Firestore.firestore()

    init(){
        loading = true
    }
    
    func getList(email:String) {
        print("Qing with email: ",email)
        db.collection("moves").whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                self.loading = false
                guard let documents = querySnapshot?.documents else {
                    print("no documents")
                    return
                }
               
                self.moveList = documents.compactMap { queryDocumentSnapshot -> MoveInfo? in
//                    let data = queryDocumentSnapshot.data()
//                    let moveName = data["moveName"] as? String ?? ""
//                    print(moveName)
                    return try? queryDocumentSnapshot.data(as: MoveInfo.self)
                }
            }
    }
    
    func getMove(id:String) {
        db.collection("moves").document(id)
            .getDocument { (document, err) in
                if let document = document, document.exists {
                    self.move = try! document.data(as: Move.self)!
                } else {
                    print("Document does not exist")
                }
            }
    }
}

struct MoveInfo: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString

    var email: String
    var moveName: String
}

struct Move: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    var email: String?
    var moveName: String?
    var time: Int?
    var accerationX: [Float]?
    var accerationY: [Float]?
    var accerationZ: [Float]?
    var GryoX:[Float]?
    var GryoY:[Float]?
    var GryoZ:[Float]?
}
