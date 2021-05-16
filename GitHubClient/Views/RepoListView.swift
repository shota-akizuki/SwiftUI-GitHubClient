import SwiftUI
import Combine

enum Stateful<Value> {
    case idle // まだデータを取得しにいっていない
    case loading // 読み込み中
    case failed(Error) // 読み込み失敗、遭遇したエラーを保持
    case loaded(Value) // 読み込み完了、読み込まれたデータを保持
}


//コンテンツをList表示するView
//RepoListViewModelのStateをバインドしてリポジトリ一覧を表示

struct RepoListView: View {
    @StateObject private var viewModel = RepoListViewModel()
    var body: some View {
        NavigationView {
            //Groupで複数のViewをまとめる
            Group{
                switch viewModel.repos{
                case .idle, .loading:ProgressView("loading...")
                case .failed :
                    VStack{
                        Group{
                            Image("GitHubMark")
                                .resizable()
                                .frame(width: 120, height: 120 )
                            Text("Failed to load repositories")
                                .padding(.top, 4.0)
                        }.opacity(0.4)
                        Button(action: {
                            viewModel.onRetryTapped()
                        }, label: {
                            Text("Retry")
                                .fontWeight(.bold)
                        })
                        .padding(.top, 8.0)
                    }       
                case let .loaded(repos):
                    if repos.isEmpty {
                        Text("No repositires")
                            .fontWeight(.bold)
                        
                    } else {
                        List(repos) { repo in
                            NavigationLink(
                                destination: RepoDetailView(repo: repo)) {
                                RepoRow(repo: repo)
                            }
                        }
                    }
                }
            }.navigationTitle("Repositories")
            
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
