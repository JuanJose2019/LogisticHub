import SwiftUI

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.separator), lineWidth: 0.5)
                )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Status Badge

struct StatusBadgeView: View {
    let status: HubStatus
    
    private var color: Color {
        switch status {
        case .active:       return .green
        case .inactive:     return .red
        case .maintenance:  return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(status.localizedName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.bottom, 4)
            .padding(.leading, 4)
    }
}

// MARK: - Info Card

struct InfoCardView<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(AppConfiguration.cornerRadius)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Hub Map Annotation

struct HubMapAnnotationView: View {
    let item: HubAnnotationItem
    @State private var showCallout = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showCallout {
                calloutBubble
                    .transition(.scale.combined(with: .opacity))
            }
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showCallout.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 40, height: 40)
                        .shadow(color: .accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                    Image(systemName: item.type.systemIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Map pin tail
            Triangle()
                .fill(Color.accentColor)
                .frame(width: 12, height: 8)
        }
    }
    
    private var calloutBubble: some View {
        VStack(spacing: 2) {
            Text(item.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            Text(item.subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .fixedSize()
    }
}

// MARK: - Triangle Shape (for map pin)

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

// MARK: - Previews

#Preview("Filter Chip") {
    HStack {
        FilterChip(title: "Activo", isSelected: true) {}
        FilterChip(title: "Inactivo", isSelected: false) {}
    }
    .padding()
}

#Preview("Info Row") {
    InfoRow(icon: "mappin.fill", label: "Dirección", value: "Calle Industrial 45, San Salvador")
        .padding()
}
