//
//  ContentView.swift
//  Dual
//
//  Created by RD-Pei_Hung on 2025/6/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var connectionStatus = "Not tested"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Dual App")
                .font(.title)
            
            VStack {
                Text("Supabase Connection:")
                    .font(.headline)
                Text(connectionStatus)
                    .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                
                Button("Test Connection") {
                    testConnection()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func testConnection() {
        connectionStatus = "Testing..."
        
        Task {
            do {
                _ = try await supabaseManager.client.auth.session
                await MainActor.run {
                    connectionStatus = "Connected"
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "Connection failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseManager.shared)
}
