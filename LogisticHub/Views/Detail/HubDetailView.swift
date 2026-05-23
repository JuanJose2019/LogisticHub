import SwiftUI
import MapKit

// MARK: - Hub Detail View

struct HubDetailView: View {
    
    @StateObject private var viewModel: HubDetailViewModel
    
    init(hub: Hub) {
        _viewModel = StateObject(wrappedValue: HubDetailViewModel(hub: hub))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                mapSection
                detailContent
            }
        }
        .navigationTitle(viewModel.hub.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .ignoresSafeArea(edges: .top)
        .onAppear { viewModel.requestUserLocation() }
    }
    
    // MARK: - Map Section
    
    private var mapSection: some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.annotationItems) { item in
            MapAnnotation(coordinate: item.coordinate) {
                HubMapAnnotationView(item: item)
            }
        }
        .frame(height: 280)
        .overlay(alignment: .bottomTrailing) {
            mapControls
        }
    }
    
    private var mapControls: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.centerOnHub()
            } label: {
                Image(systemName: "scope")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
        .padding(12)
    }
    
    // MARK: - Detail Content
    
    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerCard
            infoSection
            contactSection
            actionButtons
        }
        .padding(16)
    }
    
    private var headerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: viewModel.hub.type.systemIcon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.hub.type.localizedName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                StatusBadgeView(status: viewModel.hub.status)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(AppConfiguration.cornerRadius)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: L10n.detailInfoTitle)
            
            InfoCardView {
                InfoRow(icon: "mappin.circle.fill",  label: L10n.detailAddress,     value: viewModel.hub.fullAddress)
                Divider().padding(.leading, 32)
                InfoRow(icon: "cube.box.fill",       label: L10n.detailCapacity,    value: "\(viewModel.hub.formattedCapacity) \(L10n.capacityUnit)")
                Divider().padding(.leading, 32)
                InfoRow(icon: "location.fill",       label: L10n.detailCoordinates, value: viewModel.formattedCoordinates)
                Divider().padding(.leading, 32)
                InfoRow(icon: "calendar",            label: L10n.detailCreated,     value: viewModel.hub.createdAt.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: L10n.detailContactTitle)
            
            InfoCardView {
                InfoRow(icon: "envelope.fill",    label: L10n.detailEmail,   value: viewModel.hub.contactEmail)
                Divider().padding(.leading, 32)
                InfoRow(icon: "phone.fill",       label: L10n.detailPhone,   value: viewModel.hub.phoneNumber)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.openInMaps()
            } label: {
                Label(L10n.openInMaps, systemImage: "map.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(AppConfiguration.cornerRadius)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            if let url = viewModel.wazeURL {
                Link(destination: url) {
                    Label(L10n.openInWaze, systemImage: "car.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(AppConfiguration.cornerRadius)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 24)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if let url = viewModel.googleMapsURL {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HubDetailView(hub: MockHubFactory.make())
    }
}
