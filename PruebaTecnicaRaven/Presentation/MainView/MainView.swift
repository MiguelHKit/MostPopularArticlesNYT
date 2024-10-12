//
//  ContentView.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import SwiftUI

struct MainView: View {
    @State var vm: MainViewModel = .init()
    @State var selecedArticle: ArticleModel?
    
    var body: some View {
        NavigationStack {
            //            Button("diplay Alert") {
            //                AlertManager.shared.displayExampleAlert()
            //            }
            List(vm.articles) { article in
                Button(
                    action: {
                        self.selecedArticle = article
                    },
                    label: { self.articleRow(article) })
                .buttonStyle(.plain)
                //                    NavigationLink(
                //                        destination: { EmptyView() },
                //                        label: { self.articleRow(article) }
                //                    )
            }
            .animation(.default, value: vm.isLoading)
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .contentMargins(0)
            .refreshable(action: vm.refreshArticles)
            .toolbar(content: self.toolbarContent)
            .navigationTitle(Text(String(localized: "articles")))
            .navigationBarTitleDisplayMode(.inline)
            .loading(isLoading: $vm.isLoading)
            .navigationDestination(item: $selecedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
    }
    @ViewBuilder
    func articleRow(_ article: ArticleModel) -> some View {
        HStack(alignment: .center) {
            // Content
            VStack(alignment: .leading, spacing: 10) {
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
                Text(article.updatedDate.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .lineLimit(nil)
            }
            Spacer()
            // image
            AsyncImage(
                url: article.media.first?.thumnailImageUrl,
                scale: 1) { image in
                    image
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(.gray)
                }
                .frame(width: 50, height: 50)
                .padding(.trailing,10)
        }
        .id(article.id)
        //                .multilineTextAlignment(.leading)
    }
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu(String(localized: "sortBy")) {
                Picker("", selection: $vm.periodSelection) {
                    ForEach(ArticlePeriod.allCases, id: \.self) {
                        Text($0.getName())
                            .tag($0)
                    }
                }
            }
            .onChange(of: vm.periodSelection) {
                Task { await vm.initData() }
            }
        }
    }
}

#Preview {
    MainView(vm: .init(articlesService: ArticlesMockService()))
}

struct ArticleDetailView: View {
    @State var article: ArticleModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(.title)
                Text(article.updatedDate.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                ForEach(article.media, id: \.id) { media in
                    if let imageURL = URL(string: media.images.first(where: { $0.format == .mediumThreeByTwo440 })?.url ?? "") {
                        AsyncImage(url: imageURL)
                            .scaledToFit()
                    } else if let imageURL = URL(string: media.images.first(where: { $0.format == .mediumThreeByTwo440 })?.url ?? "") {
                        AsyncImage(url: imageURL)
                            .scaledToFit()
                    }
                }
            }
            .padding()
            // image
        }
    }
}
