//
//  ViewController.swift
//  TaskList
//
//  Created by user151705 on 4/2/19.
//  Copyright © 2019 hugoiuri. All rights reserved.
//

import UIKit

struct Todo {
    var task: String
    var isCompleted: Bool
    
    init(task: String) {
        self.task = task
        self.isCompleted = false
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var items: [Todo] = [
        Todo(task: "Terminar exercícios de IOS"),
        Todo(task: "Trocar Android por um IPhone"),
        Todo(task: "Comprar um Macbook")
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoItem", for: indexPath) as? TodoItemCell else { fatalError() }
        
        let todo = items[indexPath.row]
        cell.isCompleted = todo.isCompleted
        cell.textLabel?.text = todo.task
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.register(TodoItemCell.self, forCellReuseIdentifier: "todoItem")
        tableView.dataSource = self
        tableView.delegate = self
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(
            style: .destructive,
            title: "Remover",
            handler: { (action, view, completionHandler) in
                self.items.remove(at: indexPath.row)
                tableView.reloadData()
                completionHandler(true)
        })
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [removeAction])
            return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let concludeAction = UIContextualAction(
            style: .normal,
            title: "Concluir",
            handler: { (action, view, completionHandler) in
                self.items[indexPath.row].isCompleted.toggle()
                tableView.reloadData()
                completionHandler(true)
        })
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [concludeAction])
        return swipeConfiguration
    }
    
    @IBAction func addNewTodo(_ sender: Any) {
        let alertController = UIAlertController(title: "Nova tarefa", message: "Digite a nova tarefa", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in textField.placeholder = "Tarefa" }
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let task = alertController.textFields?.first?.text else { return }
            self.items.append(Todo(task: task))
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
