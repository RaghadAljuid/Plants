//
//  ContentView.swift
//  Plants
//
//  Created by Raghad Aljuid on 27/04/1447 AH.
//
import SwiftUI
import UIKit

//Create / Edit
struct SetReminderView: View {
    // لو جاي من التعديل
    var existing: Plant? = nil

    // القيم المختارة (نضبطها في init)
    @State private var plantName: String
    @State private var room: String
    @State private var light: String
    @State private var wateringDays: String
    @State private var waterAmount: String

    // شيتات الاختيار
    @State private var showRoomSheet = false
    @State private var showLightSheet = false
    @State private var showWateringDaysSheet = false
    @State private var showWaterAmountSheet = false

    // Callbacks
    var onSave: ((Plant) -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    // نهيّئ الـState بقيم existing إن وجدت
    init(
        existing: Plant? = nil,
        onSave: ((Plant) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.existing = existing
        self.onSave = onSave
        self.onDelete = onDelete

        _plantName    = State(initialValue: existing?.name ?? "")
        _room         = State(initialValue: existing?.room ?? "Bedroom")
        _light        = State(initialValue: existing?.light ?? "Full Sun")
        _wateringDays = State(initialValue: "Every day")
        _waterAmount  = State(initialValue: existing?.waterAmount ?? "20–50 ml")
    }

    var body: some View {
        ZStack {
            Color(hex: "#1C1C1E").ignoresSafeArea()

            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.06), Color.black.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.40), radius: 10, x: 0, y: 8)
                    }

                    Spacer()

                    Text("Set Reminder")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: saveTapped) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color(hex: "#20C997")))
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)

                // Name
                RoundedSection {
                    HStack(spacing: 12) {
                        Text("Plant Name")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        TextField("", text: $plantName)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white.opacity(0.95))
                            .placeholder(when: plantName.isEmpty, alignment: Alignment.leading) {
                                Text("Pothos").foregroundColor(.white.opacity(0.45))
                            }
                            .tint(Color(hex: "#20C997"))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }

                // Room + Light
                RoundedSection {
                    VStack(spacing: 0) {
                        RowButton(icon: "location", label: "Room", value: room) { showRoomSheet = true }
                        Divider().overlay(Color.white.opacity(0.12))
                        RowButton(icon: "sun.max", label: "Light", value: light) { showLightSheet = true }
                    }
                }

                // Watering + Amount
                RoundedSection {
                    VStack(spacing: 0) {
                        RowButton(icon: "drop", label: "Watering Days", value: wateringDays) { showWateringDaysSheet = true }
                        Divider().overlay(Color.white.opacity(0.12))
                        RowButton(icon: "drop", label: "Water", value: waterAmount) { showWaterAmountSheet = true }
                    }
                }

                // Delete (يظهر فقط إذا جاي تعديل)
                if onDelete != nil {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .glass(cornerRadius: 20)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        // Sheets نفسها
        .sheet(isPresented: $showRoomSheet) {
            OptionSheet(title: "Room", options: Rooms.all, selection: $room)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Color.clear)
        }
        .sheet(isPresented: $showLightSheet) {
            OptionSheet(title: "Light", options: Lights.all, selection: $light)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Color.clear)
        }
        .sheet(isPresented: $showWateringDaysSheet) {
            OptionSheet(title: "Watering Days", options: WateringDays.all, selection: $wateringDays)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Color.clear)
        }
        .sheet(isPresented: $showWaterAmountSheet) {
            OptionSheet(title: "Water", options: WaterAmounts.all, selection: $waterAmount)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Color.clear)
        }
    }

    private func saveTapped() {
        let name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = name.isEmpty ? (existing?.name ?? "Plant") : name
        var updated = existing ?? Plant(name: finalName, room: room, light: light, waterAmount: waterAmount)
        updated.name = finalName
        updated.room = room
        updated.light = light
        updated.waterAmount = waterAmount
        onSave?(updated)
        dismiss()
    }
}

// MARK: - Rounded Card (Solid 2C2C2E)
struct RoundedSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .glass(cornerRadius: 20)
    }
}

// MARK: - Row Button
struct RowButton: View {
    var icon: String
    var label: String
    var value: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 22)
                Text(label)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(value)
                    .foregroundColor(.white.opacity(0.85))
                    .font(.system(size: 15))
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.white.opacity(0.35))
                    .font(.system(size: 12, weight: .semibold))
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Generic Option Sheet (Glass)
struct OptionSheet: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1C1C1E").ignoresSafeArea()
                List {
                    ForEach(options, id: \.self) { opt in
                        Button {
                            selection = opt
                            dismiss()
                        } label: {
                            HStack {
                                Text(opt).foregroundColor(.white)
                                Spacer()
                                if opt == selection {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "#20C997"))
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(.white)
                }
            }
        }
        .tint(.green)
    }
}

// MARK: - Data
enum Rooms { static let all = ["Bedroom","Living Room","Kitchen","Balcony","Bathroom"] }
enum Lights { static let all = ["Full Sun","Partial Sun","Low Light"] }
enum WateringDays { static let all = ["Every day","Every 2 days","Every 3 days","Once a week","Every 10 days","Every 2 weeks"] }
enum WaterAmounts { static let all = ["20–50 ml","50–100 ml","100–200 ml","200–300 ml"] }

// MARK: - Helpers
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .trailing,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(hex: "#2C2C2E"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.06)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 8)
    }
}
extension View {
    func glass(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}

// MARK: - Preview
#Preview {
    SetReminderView()
}
