import SwiftUI

struct TokenSelectionView: View {
    let chainDetailView: ChainDetailView
    let vault: Vault
    @ObservedObject var group: GroupedChain
    
    @StateObject var tokenViewModel = TokenSelectionViewModel()
    @EnvironmentObject var coinViewModel: CoinSelectionViewModel
    
    @Environment(\.dismiss) var dismiss
    
    // Focus state for the search field to force layout update
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            Background()
            VStack(spacing: 0) {
                addCustomTokenButton.background(Color.clear).padding()
                Separator()
                view
            }
            
            if let error = tokenViewModel.error {
                errorView(error: error)
            }
            
            if tokenViewModel.isLoading {
                Loader()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(NSLocalizedString("chooseTokens", comment: "Choose Tokens"))
        .toolbar {
            ToolbarItem(placement: Placement.topBarLeading.getPlacement()) {
                Button(action: {
                    self.chainDetailView.sheetType = nil
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
#if os(iOS)
                        .font(.body18MenloBold)
#elseif os(macOS)
                        .font(.body18Menlo)
#endif
                        .foregroundColor(Color.neutral0)
                }
            }
#if os(iOS)
            ToolbarItem(placement: Placement.topBarTrailing.getPlacement()) {
                Button(action: {
                    self.chainDetailView.sheetType = nil
                }) {
                    Text("Save")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: Placement.principal.getPlacement()) {
                searchBar
            }
#endif
        }
        .task {
            await tokenViewModel.loadData(groupedChain: group)
        }
        .onAppear {
            isSearchFieldFocused = true
        }
        .onDisappear {
            saveAssets()
        }
        .onReceive(tokenViewModel.$searchText) {newVault in
            tokenViewModel.updateSearchedTokens(groupedChain: group)
        }
    }
    
    var addCustomTokenButton: some View {
        Button {
            chainDetailView.sheetType = .customToken
        } label: {
            chainDetailView.chooseTokensButton(NSLocalizedString("customToken", comment: "Custom Token"))
        }
#if os(macOS)
        .padding(.top, 10)
#endif
    }
    
    var view: some View {
        VStack(alignment: .leading,spacing: 24){
#if os(macOS)
            searchBar
                .padding(.vertical, 18)
#endif
            List {
                let selected = tokenViewModel.selectedTokens
                if !selected.isEmpty {
                    Section(header: Text(NSLocalizedString("Selected", comment:"Selected"))) {
                        ForEach(selected, id: \.self) { token in
                            TokenSelectionCell(chain: group.chain, address: address, asset: token, tokenSelectionViewModel: tokenViewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                
                if tokenViewModel.searchText.isEmpty {
                    Section(header: Text(NSLocalizedString("tokens", comment:"Tokens"))) {
                        ForEach(tokenViewModel.preExistTokens, id: \.self) { token in
                            TokenSelectionCell(chain: group.chain, address: address, asset: token, tokenSelectionViewModel: tokenViewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                } else {
                    Section(header: Text(NSLocalizedString("searchResult", comment:"Search Result"))) {
                        let filtered = tokenViewModel.searchedTokens
                        if !filtered.isEmpty {
                            ForEach(filtered, id: \.self) { token in
                                TokenSelectionCell(chain: group.chain, address: address, asset: token, tokenSelectionViewModel: tokenViewModel)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                
            }
            .scrollContentBackground(.hidden)
#if os(iOS)
            .listStyle(.grouped)
#endif
        }
        .padding(.bottom, 50)
    }
    
    var searchBar: some View {
        HStack(spacing: 0) {
            TextField(NSLocalizedString("Search", comment: "Search").toFormattedTitleCase(), text: $tokenViewModel.searchText)
                .font(.body16Menlo)
                .foregroundColor(.neutral0)
                .submitLabel(.next)
                .disableAutocorrection(true)
                .textContentType(.oneTimeCode)
                .padding(.horizontal, 8)
                .borderlessTextFieldStyle()
#if os(iOS)
                .focused($isSearchFieldFocused)
                .textInputAutocapitalization(.never)
                .keyboardType(.default)
#endif
            
            if isSearching {
                Button("Cancel") {
                    tokenViewModel.searchText = ""
                    isSearchFieldFocused = false
                    isSearching = false
                }
                .foregroundColor(.blue)
                .font(.body12Menlo)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .padding(.horizontal, 12)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .onChange(of: tokenViewModel.searchText) { oldValue, newValue in
            isSearching = !newValue.isEmpty
        }
        .background(Color.blue600)
        .cornerRadius(12)
    }
    
    func errorView(error: Error) -> some View {
        return VStack(spacing: 16) {
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .font(.body16Menlo)
                .foregroundColor(.neutral0)
                .padding(.horizontal, 16)
            
            if tokenViewModel.showRetry {
                Button {
                    Task { await tokenViewModel.loadData(groupedChain: group) }
                } label: {
                    FilledButton(title: "Retry")
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var address: String {
        return vault.coins.first(where: { $0.chain == group.chain })?.address ?? .empty
    }
    
    private func saveAssets() {
        Task {
            await coinViewModel.saveAssets(for: vault)
        }
    }
}
