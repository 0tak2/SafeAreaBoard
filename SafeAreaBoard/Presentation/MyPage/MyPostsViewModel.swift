//
//  MyPostsViewModel.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/18/25.
//

import Foundation
import os.log

final class MyPostsViewModel: ObservableObject {
    @Published var myPosts: [PostWithQuestion] = []
    @Published var selectedPost: PostWithQuestion?
    @Published var showingEditSheet: Bool = false
    @Published var showingDetailsSheet: Bool = false
    @Published var showingDeleteConfirmAlert: Bool = false
    @Published var errorMessage: String?
    
    private let getAllMyPostsUseCase: any GetAllMyPostsUseCaseProtocol
    private let removePostUseCase: any RemovePostUseCaseProtocol
    private let addReactionUseCase: any AddReactionUseCaseProtocol
    private let removeReactionUseCase: any RemoveReactionUseCaseProtocol
    
    private let log = Logger.of("MyPostsViewModel")
    
    init(
        getAllMyPostsUseCase: any GetAllMyPostsUseCaseProtocol,
        removePostUseCase: any RemovePostUseCaseProtocol,
        addReactionUseCase: any AddReactionUseCaseProtocol,
        removeReactionUseCase: any RemoveReactionUseCaseProtocol
    ) {
        self.getAllMyPostsUseCase = getAllMyPostsUseCase
        self.removePostUseCase = removePostUseCase
        self.addReactionUseCase = addReactionUseCase
        self.removeReactionUseCase = removeReactionUseCase
    }
    
    private func fetchMyPosts() async throws -> [PostWithQuestion] {
        return try await getAllMyPostsUseCase.execute(command: ())
    }
    
    private func removePost(postId: Int) {
        Task {
            do {
                try await removePostUseCase.execute(command: postId)
                log.debug("deleted post \(postId)")
                
                let posts = try await fetchMyPosts()
                await MainActor.run {
                    myPosts = posts
                }
            } catch {
                log.error("removePostUseCase error: \(error)")
                
                await MainActor.run {
                    errorMessage = ErrorMessages.removePostError
                }
            }
        }
    }
    
    private func addReaction(postId: Int) {
        Task {
            do {
                try await addReactionUseCase.execute(command: postId)
                log.debug("added reaction to post \(postId)")
                
                let posts = try await fetchMyPosts()
                await MainActor.run {
                    myPosts = posts
                }
            } catch {
                log.error("addReactionUseCase error: \(error)")
                
                await MainActor.run {
                    errorMessage = ErrorMessages.addReactionError
                }
            }
        }
    }
    
    private func removeReaction(postId: Int) {
        Task {
            do {
                try await removeReactionUseCase.execute(command: postId)
                log.debug("revoked reaction from post \(postId)")
                
                let posts = try await fetchMyPosts()
                await MainActor.run {
                    myPosts = posts
                }
            } catch {
                log.error("removeReactionUseCase error: \(error)")
                
                await MainActor.run {
                    errorMessage = ErrorMessages.revokeReactionError
                }
            }
        }
    }
    
    func loadPosts() async {
        do {
            let posts = try await fetchMyPosts()
            await MainActor.run {
                myPosts = posts
            }
        } catch {
            log.error("failed to load my posts: \(error)")
            errorMessage = ErrorMessages.fetchPostError
        }
    }
    
    func deleteButtonTapped() {
        showingDeleteConfirmAlert = true
    }
    
    func deletePostConfirmed() {
        guard let selectedPost = selectedPost,
        let id = selectedPost.id else { return }
        
        removePost(postId: id)
    }
    
    func menuButtonTapped(_ postId: Int) {
        showingEditSheet = true
        selectedPost = myPosts
            .first(where: { $0.id == postId })
    }
    
    func cardViewTapped(post: PostWithQuestion) {
        selectedPost = post
        showingDetailsSheet = true
    }
    
    func heartButtonTapped(postId: Int, isLiked: Bool) {
        if isLiked {
            addReaction(postId: postId)
        } else {
            removeReaction(postId: postId)
        }
    }
}
