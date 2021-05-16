import Foundation
import Combine

//MVVMのViewModel部分
//主な処理は...
//UserからViewModelの単方向のデータ（User Interaction）を受け取る
//Viewとの双方向のデータのやり取り（StateとBindig）
//StateをViewに加工してアウトプット
//WebやDBとは直接やり取りせず、Viewのインプットに応じてModelを呼び出しViewのStateを管理する

class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    
    func onAppear() {
        loadRepos()
    }
    
    func onRetryTapped(){
        loadRepos()
    }
    
    private func loadRepos (){
        RepoRepository().fetchRepos()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .sink(receiveCompletion: { [weak self ]completion in
                switch completion {
                case .failure(let error):
                    self?.repos = .failed(error)
                case .finished: print("Finished")
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            }
            ).store(in: &cancellables)
    }
}
