//
//  HomeViewController.swift
//  NewYeolpumtaClone
//
//  Created by 김태균 on 2021/07/04.
//

import SnapKit
import UIKit
import SQLite3

class HomeViewController: UIViewController {
    // MARK: - Property
    
    static let homeViewController = HomeViewController()

    var objectList = [ObjectForAdd]() {
        didSet { tableView.reloadData() }
    }
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: Constants.ImageName.plus), for: .normal)
        button.backgroundColor = .tintColor
        button.tintColor = .white
        button.addTarget(self, action: #selector(addObject), for: .touchUpInside)
        return button
    }()
    
    private let totalTimerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tintColor
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        // 금일 날짜 표시
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy . M . d"
        label.text = dateFormatter.string(from: now)
        return label
    }()
    
    private let totalTimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.text = "00:00:00"
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // for SQLite
    var db: OpaquePointer?
    
    // for reloadData 참고 블로그 https://42kchoi.tistory.com/261
    let DidDismissTimerController: Notification.Name = Notification.Name("DidDismissTimerController")

    let DidDismissAddObjectController: Notification.Name = Notification.Name("DidDismissAddObjectController")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()

        // for reloadData
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissTimerController(_:)), name: DidDismissTimerController, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissAddObjectController(_:)), name: DidDismissAddObjectController, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        makeQuery()
        readValues()
    }

    // MARK: - Helper

    fileprivate func setupUI() {
        setupTotalTimerView()
        setupTableView()
        setupAddButton()
    }

    fileprivate func setupAddButton() {
        view.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(48)
            $0.right.equalToSuperview().offset(-32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        addButton.layer.cornerRadius = 48 / 2
    }
    
    fileprivate func setupTotalTimerView() {
        view.addSubview(totalTimerView)
        totalTimerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        let stack = UIStackView(arrangedSubviews: [dateLabel, totalTimerLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        
        totalTimerView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(totalTimerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(HomeSectionCell.self, forCellReuseIdentifier: HomeSectionCell.cellIdentifier)
        tableView.register(HomeTimerCell.self, forCellReuseIdentifier: HomeTimerCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - SQLite
    
    func makeQuery() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                   .appendingPathComponent("ObjectsDatabase.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                    print("error opening database")
        }

        let createTableString = """
        CREATE TABLE IF NOT EXISTS Objects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT)
        """

        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error creating table: \(errmsg)")
        }
    }

    func readValues(){

          objectList.removeAll()

          let queryString = "SELECT * FROM Objects"

          var stmt:OpaquePointer?

          if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
              let errmsg = String(cString: sqlite3_errmsg(db)!)
              print("error preparing insert: \(errmsg)")
              return
          }

          while(sqlite3_step(stmt) == SQLITE_ROW){
              let id = sqlite3_column_int(stmt, 0)
              let name = String(cString: sqlite3_column_text(stmt, 1))

              objectList.append(ObjectForAdd(id: Int(id), name: String(describing: name)))
          }
    }
    
    // SQLite내 table의 name을 추적해서 삭제하는 형태입니다.
    // name을 추적해 삭제하므로, 동일한 name일경우 데이터가 중복삭제됩니다, 디버깅이 필요합니다.
    func delete(name: String) {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM Objects WHERE name = ?;"

        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
            
            sqlite3_bind_text(deleteStatement, 1, name, -1, nil)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("\nSuccessfully deleted row.")
            } else {
                print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }
    }
    
    // MARK: - Actions
    
    @objc func addObject() {
        let controller = AddObjectController()
        navigationController?.pushViewController(controller, animated: true)
        controller.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func didDismissTimerController(_ noti: Notification) {
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
        }
    }
    
    @objc func didDismissAddObjectController(_ noti: Notification) {
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + objectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeSectionCell.cellIdentifier, for: indexPath) as? HomeSectionCell else {
                fatalError("tableView에서 HomeSectionCell을 dequeue하던 과정에서 에러가 발생하였습니다")
            }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTimerCell.cellIdentifier, for: indexPath) as? HomeTimerCell else {
                fatalError("tableView에서 HomeTimerCell을 dequeue하던 과정에서 에러가 발생하였습니다")
            }
            cell.goalLabel.text = "\(objectList[indexPath.row - 1].name)"
            print("id \(objectList[indexPath.row - 1].id) + name \(objectList[indexPath.row - 1].name)")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            if editingStyle == .delete {
                tableView.beginUpdates()
                
                // SQLite의 name을 추적해서 삭제하는 형태입니다.
                delete(name: objectList[indexPath.row - 1].name)
                
                objectList.remove(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                readValues()
                tableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            let vc = TimerController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}
