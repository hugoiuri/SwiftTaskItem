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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].isCompleted.toggle()
        tableView.reloadData()
    }
}
