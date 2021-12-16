//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Daichi Morihara on 2021/12/16.
//

import Foundation

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        
        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()
                
        enum LoadingState {
            case loading, loaded, failed
        }

        
    }
    
}
