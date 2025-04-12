//
//  MainTabView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var tabRouter: TabRouter
    
    init(tabRouter: TabRouter) {
        self._tabRouter = StateObject(wrappedValue: tabRouter)
    }
    
    var body: some View {
        TabView(selection: $tabRouter.currentTab) {
            Tab("보드", systemImage: "square.stack", value: .board) {
                BoardView()
            }
            
            Tab("작성", systemImage: "bubble.and.pencil", value: .new) {
                WriteView()
            }
            
            Tab("설정", systemImage: "gearshape", value: .setting) {
                SettingView()
            }
        }
        .tint(CustomColors.primaryDarker2)
    }
}

#Preview {
    MainTabView(tabRouter: TabRouter())
}
