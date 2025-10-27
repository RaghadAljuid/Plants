//
//  ContentView.swift
//  Plants
//
//  Created by Raghad Aljuid on 27/04/1447 AH.
//
import SwiftUI

struct ContentView: View {
    @State private var showReminderSheet = false
    @StateObject private var viewModel = PlantViewModel()   // ← ربط بالـ ViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // إذا ما فيه نباتات: أعرض شاشة البداية
            if viewModel.plants.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        Text("My Plants 🌱")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        Divider()
                            .overlay(Color.white.opacity(0.08))
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        VStack(spacing: 24) {
                            Image("Plant")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 260)
                                .shadow(radius: 12, y: 6)
                                .padding(.top, 48)

                            Text("Start your plant journey!")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)

                            Text("Now all your plants will be in one place and we will help you take care of them :) 🪴")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.70))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .frame(maxWidth: 320)
                                .padding(.horizontal, 24)

                            Button {
                                showReminderSheet = true
                            } label: {
                                Text("Set Plant Reminder")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "#28E0A8"), Color(hex: "#1EBE8E")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)

                            Spacer(minLength: 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    }
                }
                .sheet(isPresented: $showReminderSheet) {
                    // عند الحفظ: أضف النبتة وانتقل تلقائيًا لقائمة النباتات
                    SetReminderView { newPlant in
                        viewModel.addPlant(plant: newPlant)   // ← عبر الـ ViewModel
                    }
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
                    .presentationBackground(.clear)
                }

            } else {
                // إذا فيه نباتات: أعرض شاشة MyPlants
                MyPlantsView(viewModel: viewModel)   // ← تمرير الـ ViewModel
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}

#Preview { ContentView() }
