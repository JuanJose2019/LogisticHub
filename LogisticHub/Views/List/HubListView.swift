import SwiftUI

// MARK: - Hub List View

struct HubListView: View {
    
    @StateObject private var viewModel = HubListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                listContent
                loadingOverlay
                emptyStateView
            }
            .navigationTitle(L10n.hubListTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: L10n.searchPrompt
            )
            .refreshable { viewModel.loadHubs() }
            .alert(
                L10n.errorTitle,
                isPresented: .constant(viewModel.hasError),
                actions: {
                    Button(L10n.retry) { viewModel.loadHubs() }
                    Button(L10n.dismiss, role: .cancel) { viewModel.dismissError() }
                },
                message: {
                    Text(viewModel.error?.localizedDescription ?? "")
                }
            )
        }
        .task { viewModel.loadHubs() }
    }
    
    // MARK: - Subviews
    
    private var listContent: some View {
        List {
            filterChipsSection
            
            ForEach(viewModel.filteredHubs) { hub in
                NavigationLink(value: hub) {
                    HubRowView(hub: hub)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Hub.self) { hub in
            HubDetailView(hub: hub)
        }
    }
    
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: L10n.filterAll,
                    isSelected: viewModel.selectedFilter == nil
                ) {
                    viewModel.selectedFilter = nil
                }
                
                ForEach(HubStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.localizedName,
                        isSelected: viewModel.selectedFilter == status
                    ) {
                        viewModel.selectedFilter = viewModel.selectedFilter == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading && viewModel.hubs.isEmpty {
            ProgressView(L10n.loading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        if viewModel.isEmpty {
            EmptyStateView(
                icon: "shippingbox",
                title: L10n.emptyTitle,
                subtitle: L10n.emptySubtitle
            )
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Preview

#Preview {
    HubListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
