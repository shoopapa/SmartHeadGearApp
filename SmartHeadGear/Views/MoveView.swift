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
                NavigationLink(destination: MoveDetail(id: move.id!)) {
                    VStack(alignment: .leading) {
                        Text(move.moveName)
                        Text(move.email)
                    }
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
    @Published var loading = false

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
}

struct MoveInfo: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString

    var email: String
    var moveName: String
}

