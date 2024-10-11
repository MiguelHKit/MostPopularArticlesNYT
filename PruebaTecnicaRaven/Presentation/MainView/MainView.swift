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
//            Button("diplay Alert") {
//                AlertManager.shared.displayExampleAlert()
//            }
            List(vm.articles) { article in
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(article.section)
                                    .font(.caption)
                                if !article.byline.isEmpty {
                                    Divider()
                                        .frame(height: 15)
                                }
                                Text(article.byline)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            Text(article.title)
                                .font(.title)
                        }
                        Spacer()
                        Rectangle()
                            .frame(width: 75,height: 75)
                            .foregroundStyle(.gray)
                    }
//                    Text(article.updatedDate, style: .date)
                    Text(article.updatedDate.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
//                    HStack {
//                        Text(article.abstract)
//                            .font(.body)
//                    }
                }
//                .multilineTextAlignment(.leading)
            }
            .listStyle(.grouped)
            .refreshable(action: vm.refreshArticles)
            .navigationTitle(Text(String(localized: "articles")))
            .toolbar(content: self.toolbarContent)
        }
    }
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Picker("Sort by", selection: $vm.periodSelection) {
                ForEach(ArticlePeriod.allCases, id: \.self) {
                    Text($0.getName())
                        .tag($0)
                }
            }
            .onChange(of: vm.periodSelection) {
                Task { await vm.getArticles() }
            }
        }
    }
}

#Preview {
    MainView(vm: .init(articlesService: ArticlesMockService()))
}
