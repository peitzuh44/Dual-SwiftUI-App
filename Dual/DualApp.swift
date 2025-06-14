//
//  DualApp.swift
//  Dual
//
//  Created by RD-Pei_Hung on 2025/6/14.
//

import SwiftUI

@main
struct DualApp: App {
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseManager)
        }
    }
}
