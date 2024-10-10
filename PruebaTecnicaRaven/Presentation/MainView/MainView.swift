//
//  ContentView.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import SwiftUI

struct MainView: View {
    @State var vm: MainViewModel = .init()
    
    var body: some View {
        NavigationStack {
            List(vm.articles) { article in
                
            }
        }
    }
}

#Preview {
    MainView(vm: .init(articlesService: ArticlesMockService()))
}
