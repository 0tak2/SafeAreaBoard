//
//  MainTabView.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    private var boardViewModel: BoardViewModel
    
    init(boardViewModel: BoardViewModel) {
        self.boardViewModel = boardViewModel
    }
    
    var body: some View {
        TabView {
            Tab("보드", systemImage: "square.stack") {
                BoardView(viewModel: boardViewModel)
            }
            
            Tab("설정", systemImage: "gearshape") {
                SettingView()
            }
        }
        .tint(CustomColors.primaryDarker2)
    }
}
