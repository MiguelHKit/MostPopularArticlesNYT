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
            VStack(spacing: 0.0) {
                Divider()
                if !vm.hasInternet {
                    self.noInternetBanner
                        .task { await vm.onInternetLost() }
                        .onDisappear { Task { await vm.onInternetRestored() } }
                }
                List(vm.articles) { article in
                    Button(
                        action: {
                            self.selecedArticle = article
                        },
                        label: { self.articleRow(article) }
                    )
//                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .listRowSeparator(vm.articles.first == article ? .hidden : .visible, edges: .top)
                }
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .contentMargins(0)
                .refreshable(action: vm.refreshArticles)
                .navigationDestination(item: $selecedArticle) { article in
                    ArticleDetailView(article: article)
                }
            }
            .animation(.default, value: vm.isLoading)
            .animation(.default, value: vm.hasInternet)
            .toolbar(content: self.toolbarContent)
            .navigationTitle(Text(String(localized: "articles")))
            //            .navigationBarTitleDisplayMode(.large)
            .task(vm.monitorInternetConectionTask)
            .loading(isLoading: $vm.isLoading)
            .emptyDataViewModifier(onCondition: { vm.articles.isEmpty && !vm.isLoading })
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
                        Text(article.byline)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                Text(article.title)
                    .font(.title)
                Text(article.updatedDate.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .lineLimit(nil)
            }
            Spacer()
            // Tries load image from its data
            if let mediaItem = article.media.first(where: { $0.thumbnailImageData != nil }), let imageData = mediaItem.thumbnailImageData, let uiimage = UIImage(data: imageData) {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
                    .padding(.trailing,10)
            } else { // else load using async image
                if let mediaItem = article.media.first(where: { $0.thumbnailImageURL != nil }) {
                    AsyncImage(
                        url: mediaItem.thumbnailImageURL,
                        transaction: Transaction(animation: .linear),
                        content: { image in
                            switch image {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75, height: 75)
                            default:
                                Rectangle()
                                    .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                    .frame(width: 75, height: 75)
                            }
                        }
                    )
                    .padding(.trailing,10)
                }
            }
        }
        .id(article.id)
        //                .multilineTextAlignment(.leading)
    }
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu(String(localized: "options")) {
                let controlGroupTitle = vm.apiKeyFromKeychain.isNotNil ? "API Key: \(vm.apiKeyFromKeychain.unwrapped)" : String(localized: "noApiKey")
                ControlGroup(controlGroupTitle) {
                    // set/update
                    let buttonOneTitle = vm.apiKeyFromKeychain.isNotNil ? String(localized:"update") : String(localized: "set")
                    Button(buttonOneTitle, systemImage: vm.apiKeyFromKeychain.isNotNil ? "pencil" : "plus") {
                        AlertManager.shared.displayTextFieldAlert(
                            title: String(localized: "advice"),
                            message: String(localized: "AlertAPIKeyMessage"),
                            onTextfieldSubmit: { submitedValue in
                                Task {
                                    await vm.saveAPIKeyOnKeychan(submitedValue)
                                    await vm.initData()
                                }
                            }
                        )
                    }
                    // remove apikey
                    Button(String(localized: "remove"), systemImage: "trash") {
                        AlertManager.shared.displayAlert(
                            title: String(localized: "advice"),
                            message: String(localized: "AlertRemoveAPIKeyMessage"),
                            confirmAction: {
                                Task {
                                    await vm.removeAPIKeyFromKeychan()
                                    await vm.resetData()
                                }
                            },
                            cancelAction: { }
                        )
                    }
                    .disabled(vm.apiKeyFromKeychain == nil)
                }
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
    @ViewBuilder
    var noInternetBanner: some View {
        HStack {
            Spacer()
            Text(String(localized: "noInternetConection"))
                .foregroundStyle(.background)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(15)
        .background(.gray)
    }
}

#Preview {
    MainView(vm: .init(articlesService: ArticlesMockService()))
}

struct ArticleDetailView: View {
    @State var article: ArticleModel
    
    var body: some View {
        ScrollView {
            ScrollView(.horizontal) {
                ForEach(article.media, id: \.id) { media in
                    if let imageURL = media.largeImageURL {
                        AsyncImage(
                            url: imageURL,
                            //                            transaction: nil,
                            content: { image in
                                switch image {
                                case .success(let image):
                                    image.resizable()
                                default: EmptyView()
                                }
                            }
                        )
                        .aspectRatio(contentMode: .fit)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            // Head
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.title)
                        .font(.title)
                    HStack {
                        Text(article.section)
                            .font(.subheadline)
                        if !article.byline.isEmpty {
                            Divider()
                                .frame(height: 15)
                            Text(article.byline)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                    Text(article.updatedDate.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
                Spacer()
            }
            // Content
            HStack {
                VStack(alignment: .leading) {
                    Text(article.abstract)
                    if let url = URL(string: article.url) {
                        Link(String(localized: "Link to full article"), destination: url)
                            .padding(.vertical)
                    }
                }
                .padding([.top, .horizontal])
                Spacer()
            }
        }
        //        .ignoresSafeArea(edges: .top)
    }
}
