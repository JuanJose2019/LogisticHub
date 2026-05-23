import SwiftUI

// MARK: - Hub Row View

struct HubRowView: View {
    
    let hub: Hub
    
    var body: some View {
        HStack(spacing: 14) {
            typeIcon
            hubInfo
            Spacer()
            statusBadge
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(AppConfiguration.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: AppConfiguration.shadowRadius, x: 0, y: 2)
    }
    
    // MARK: - Subviews
    
    private var typeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 50, height: 50)
            Image(systemName: hub.type.systemIcon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.accentColor)
        }
    }
    
    private var hubInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(hub.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text("\(hub.city), \(hub.country)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(hub.formattedCapacity + " " + L10n.capacityUnit)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusBadge: some View {
        Text(hub.status.localizedName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.12))
            .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch hub.status {
        case .active:       return .green
        case .inactive:     return .red
        case .maintenance:  return .orange
        }
    }
}

// MARK: - Preview

#Preview {
    HubRowView(hub: MockHubFactory.make())
        .padding()
        .background(Color(.systemBackground))
}
