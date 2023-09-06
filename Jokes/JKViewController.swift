import UIKit

class JKViewController: UIViewController {
    
    // MARK: - Constants
    private let cellIdentifier = "cell"
    
    // MARK: - Variables
    private let tableView = UITableView()
    private var safeArea: UILayoutGuide!
    private let jokesListPresenter = JKListPresenter(serviceHandler: JKServiceHandler())
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        setupTableView()
        jokesListPresenter.setViewDelegate(jokesListViewDelegate: self)
    }
    
    // MARK: - Setup Methods
    func setupTableView() {
        view.addSubview(tableView)
        // Set Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        // Set Data Source
        tableView.dataSource = self
        // Register Cell
        registerCell()
        // Set Activity Indicator
        setupActivityIndicator()
    }
    
    func registerCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func setupActivityIndicator() {
        tableView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
}

// MARK: - UITableViewDataSource
extension JKViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokesListPresenter.allJokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = jokesListPresenter.allJokes[indexPath.row]
        cell.textLabel?.numberOfLines = Int.zero
        return cell
    }
}

// MARK: - JokesListViewDelegate
extension JKViewController: JokesListViewDelegate {
    func show(loader: Bool) {
        DispatchQueue.main.async {
            loader ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    func updateListView() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: Int.zero, section: Int.zero)],
                                      with: .automatic)
            if self.tableView.numberOfRows(inSection: Int.zero) == self.jokesListPresenter.maxDisplayCount {
                self.tableView.deleteRows(at: [IndexPath(row: self.jokesListPresenter.allJokes.count - 1, section: Int.zero)],
                                          with: .automatic)
            }
            self.tableView.endUpdates()
        }
    }
    
    func showError(message: String?) {
        DispatchQueue.main.async {
            let dialogMessage = UIAlertController(title: self.jokesListPresenter.errorTitle, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: self.jokesListPresenter.errorActionButtonTitle, style: .default, handler: { (action) -> Void in
                self.jokesListPresenter.retry()
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
}
