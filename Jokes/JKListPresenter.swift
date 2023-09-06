import Foundation

protocol JokesListViewDelegate: NSObjectProtocol {
    func show(loader: Bool)
    func updateListView()
    func showError(message: String?)
}

class JKListPresenter {
    
    // MARK: - Constants
    private let fileName = "Jokes"
    private let repeatInterval: Double = 60 // seconds
    let maxDisplayCount = 10
    let errorTitle = "Error"
    let errorActionButtonTitle = "OK"
    
    // MARK: - Variables
    private let serviceHandler: JKServiceHandler
    private var timer: Timer?
    weak private var jokesListViewDelegate : JokesListViewDelegate?
    
    var allJokes: [String] { readJokes() }
    
    // MARK: - Initilization
    init(serviceHandler: JKServiceHandler){
        self.serviceHandler = serviceHandler
        startFetchingJokes()
    }
    
    // MARK: - Setup Delegate
    func setViewDelegate(jokesListViewDelegate: JokesListViewDelegate?){
        self.jokesListViewDelegate = jokesListViewDelegate
    }
    
    // MARK: - Methods
    func retry() {
        startFetchingJokes()
    }
    
    deinit {
        killTimer()
    }
}

// MARK: - Private Methods
extension JKListPresenter {
    @objc private func fetchJokes() {
        jokesListViewDelegate?.show(loader: true)
        serviceHandler.fetchJokes(completionHandler: { [weak self] joke, error in
            guard let weakSelf = self, let joke = joke else {
                self?.killTimer()
                self?.jokesListViewDelegate?.showError(message: error?.localizedDescription)
                return
            }
            weakSelf.updateJokesList(withJoke: joke)
            weakSelf.jokesListViewDelegate?.show(loader: false)
            weakSelf.jokesListViewDelegate?.updateListView()
        })
    }
    
    private func startFetchingJokes() {
        self.fetchJokes()
        timer = Timer.scheduledTimer(timeInterval: repeatInterval, target: self, selector: #selector(fetchJokes), userInfo: nil, repeats: true)
    }
    
    private func killTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Read & Update Jokes List
extension JKListPresenter {
    
    private func readJokes() -> [String] {
        do {
            let jokesList = try JKFileManager.standard.read(fileName, from: .documents, as: [String].self)
            return jokesList
        } catch {
            return []
        }
    }
    
    private func updateJokesList(withJoke joke: String) {
        do {
            var jokesList = try JKFileManager.standard.read(fileName, from: .documents, as: [String].self)
            if !jokesList.isEmpty, jokesList.count == maxDisplayCount {
                jokesList.remove(at: jokesList.count - 1)
            }
            jokesList.insert(joke, at: Int.zero)
            saveJokes(jokesList)
        } catch { saveJokes([joke]) }
    }
    
    private func saveJokes(_ jokes: [String]) {
        do {
            try JKFileManager.standard.save(jokes, to: .documents, as: fileName)
        } catch { }
    }
}


