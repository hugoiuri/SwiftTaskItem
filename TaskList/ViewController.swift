//
//  ViewController.swift
//  TaskList
//
//  Created by user151705 on 4/2/19.
//  Copyright © 2019 hugoiuri. All rights reserved.
//

import UIKit

struct Todo: Codable {
    var id: Int?
    var task: String
    var isCompleted: Bool
    
    init(task: String) {
        self.task = task
        self.isCompleted = false
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let todoRepository = TodoRepository(
        network: NetworkService(baseUrl: "https://puc-dam-todolist.herokuapp.com/"),
        token: "rbDDpD6Lq0IfJH6oWup0AvdFfbrLwuFfo5bOlwcOKR0=")
    
    @IBOutlet weak var tableView: UITableView!
    var items: [Todo] = []
    
    func loadTodoItems(callback: @escaping () -> Void) {
        todoRepository.all { (result) in
            switch result {
            case .success(let todos):
                self.items = todos
            case .error:
                print("Error to get data!")
            }
            callback()
        }
    }
    
    func createItem(task: String, callback: @escaping () -> Void) {
        todoRepository.create(taskTitle: task) { (result) in
            switch result {
            case .success(let todo):
                self.items.append(todo)
            case .error:
                print("Error to create task!")
            }
            callback()
        }
    }
    
    func updateItem(id: Int?, index: Int, callback: @escaping () -> Void) {
        todoRepository.toggleComplete(id: id ?? 0) { (result) in
            switch result {
            case.success:
                self.items[index].isCompleted.toggle()
            case .error:
                print("Error to delete task")
            }
            callback()
        }
    }
    
    func removeItem(id: Int?, index: Int, callback: @escaping () -> Void) {
        todoRepository.delete(id: id ?? 0) { (result) in
            switch result {
            case.success:
                self.items.remove(at: index)
            case .error:
                print("Error to delete task")
            }
            callback()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoItem", for: indexPath) as? TodoItemCell else { fatalError() }
        
        let todo = items[indexPath.row]
        cell.textLabel?.text = todo.task
        cell.isCompleted = todo.isCompleted
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        	
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: "todoItem")
        
        loadTodoItems() {
            self.tableView.reloadData()
        }
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(
            style: .destructive,
            title: "Remover",
            handler: { (action, view, completionHandler) in
                self.removeItem(id: self.items[indexPath.row].id, index: indexPath.row) {
                    tableView.reloadData()
                    completionHandler(true)
                }
        })
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [removeAction])
            return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let concludeAction = UIContextualAction(
            style: .normal,
            title: "Concluir",
            handler: { (action, view, completionHandler) in
                self.updateItem(id: self.items[indexPath.row].id, index: indexPath.row) {
                    tableView.reloadData()
                    completionHandler(true)
                }
        })
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [concludeAction])
        return swipeConfiguration
    }
    
    @IBAction func addNewTodo(_ sender: Any) {
        let alertController = UIAlertController(title: "Nova tarefa", message: "Digite a nova tarefa", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in textField.placeholder = "Tarefa" }
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let task = alertController.textFields?.first?.text else { return }
            self.createItem(task: task) {
                self.tableView.reloadData()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
