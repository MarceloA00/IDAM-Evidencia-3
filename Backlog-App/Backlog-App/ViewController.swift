//
//  ViewController.swift
//  Backlog-App
//
//  Created by Alumno on 14/11/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var backlogTable: UITableView!
    
    var backlogList = [Media]()
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        backlogTable.delegate = self
        backlogTable.dataSource = self
        
        read()
    }
    
    @IBAction func newBacklogItem(_ sender: UIBarButtonItem) {
        var title = UITextField()
        //var synopsis = UITextField()
        
        let alert = UIAlertController(title: "New Backlog Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { textFieldAlert in
            textFieldAlert.placeholder = "Write title here..."
            title = textFieldAlert
        }
        
        //alert.addTextField { textFieldAlert in
            //textFieldAlert.placeholder = "Write synopsis here..."
            //synopsis = textFieldAlert
        //}
        
        let acceptAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let newMedia = Media(context: self.contexto)
            newMedia.title = title.text
            //newMedia.synopsis = synopsis.text
            newMedia.completed = false
            
            self.backlogList.append(newMedia)
            self.save()
        }
        
        alert.addAction(acceptAction)
        
        present(alert, animated: true)
        
    }
    
    func save() {
        do {
            try contexto.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.backlogTable.reloadData()
    }
    
    func read() {
        let request : NSFetchRequest<Media> = Media.fetchRequest()
        
        do {
            backlogList = try contexto.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backlogList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = backlogTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let media = backlogList[indexPath.row]
        
        cell.textLabel?.text = media.title
        cell.textLabel?.textColor = media.completed ? .black : .blue
        cell.detailTextLabel?.text =  media.completed ? "Completed" : "In Backlog"
        
        cell.accessoryType = media.completed ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Check if completed
        if (backlogTable.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
            backlogTable.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            backlogTable.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Edit core data
        backlogList[indexPath.row].completed = !backlogList[indexPath.row].completed
        
        save()
        
        //Unselect Item
        backlogTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Eliminar") { _, _, _ in
            self.contexto.delete(self.backlogList[indexPath.row])
            self.backlogList.remove(at: indexPath.row)
            self.save()
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
}

