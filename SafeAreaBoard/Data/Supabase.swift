//
//  Supabase.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation
import Supabase

final class SupabaseProvider {
    private static let defaultUrlString: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as! String
    private static let defaultKey: String = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as! String
    static var shared: SupabaseProvider = .init(url: URL(string: defaultUrlString)!, key: defaultKey)
    
    private let url: URL
    private let key: String
    
    private(set) lazy var supabase: SupabaseClient = {
        let supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
        return supabase
    }()
    
    init(url: URL, key: String) {
        self.url = url
        self.key = key
    }
}
