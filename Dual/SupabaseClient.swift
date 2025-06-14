import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: "https://wkhionokmlpeupfrdcmn.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        
        let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndraGlvbm9rbWxwZXVwZnJkY21uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4NzY2MzYsImV4cCI6MjA2NTQ1MjYzNn0.OW6cmM2dUaMhIlGwuLfpqnGdgi4XsXlKuPGlIh3Blss"
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }
}