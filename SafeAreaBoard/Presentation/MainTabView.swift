//
//  MainTabView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    private var boardViewModel: BoardViewModel
    private var settingViewModel: SettingViewModel
    
    init(
        boardViewModel: BoardViewModel,
        settingViewModel: SettingViewModel
    ) {
        self.boardViewModel = boardViewModel
        self.settingViewModel = settingViewModel
    }
    
    var body: some View {
        TabView {
            Tab("보드", systemImage: "square.stack") {
                BoardContainerView(viewModel: boardViewModel)
            }
            
            Tab("설정", systemImage: "gearshape") {
                SettingView(viewModel: settingViewModel)
            }
        }
        .tint(CustomColors.primaryDarker2)
    }
}
