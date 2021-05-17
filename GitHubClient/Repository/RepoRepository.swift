import Foundation
import Combine

//MVVMのModel部分
//Repositoryは、Webやlocal DBで処理した結果をViewModelへ返す役割
//これにより、ViewModelは与えられたデータがWeb or DBからの値かを意識せずに、Viewの状態管理に専念できる

protocol RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error>
}


struct RepoDataRepository : RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo],Error> {
        RepoAPIClient().getRepos()
    }
}
