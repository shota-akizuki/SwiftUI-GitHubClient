import SwiftUI
import Combine

enum Stateful<Value> {
    case idle // まだデータを取得しにいっていない
    case loading // 読み込み中
    case failed(Error) // 読み込み失敗、遭遇したエラーを保持
    case loaded(Value) // 読み込み完了、読み込まれたデータを保持
}

class ReposLoader: ObservableObject {
    @Published private(set) var repos :Stateful<[Repo]> = .idle
  
    private var cancellables = Set<AnyCancellable>()
    
    func call() {
        let url = URL(string:"https://api.github.com/orgs/mixigroup/repos")!
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "accept":"application/vnd.github.v3+json"
        ]
        
        let reposPublisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Repo].self, decoder: JSONDecoder())
        reposPublisher
            .receive(on: DispatchQueue.main)
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

struct RepoListView: View {
    @StateObject private var reposLoader = ReposLoader()
    var body: some View {
        NavigationView {
            //Groupで複数のViewをまとめる
            Group{
                switch reposLoader.repos{
                case .idle, .loading:        ProgressView("loading...")
                case .failed :
                    VStack{
                        Group{
                            Image("GitHubMark")
                                .resizable()
                                .frame(width: 120, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            Text("Failed to load repositories")
                                .padding(.top, 4.0)
                        }.opacity(0.4)
                        Button(action: {
                            reposLoader.call()
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
            reposLoader.call()
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}
