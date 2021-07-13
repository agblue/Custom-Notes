//
//  ViewController.swift
//  Custom Notes
//
//  Created by Danny Tsang on 7/13/21.
//

import UIKit

class ViewController: UITableViewController, DetailViewControllerDelegate {
    

    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Custom Notes"
        
        // Set Tint Color
        navigationController?.view.tintColor = UIColor(red: 252/255, green: 184/255, blue: 40/255, alpha: 1)
        self.view.backgroundColor = UIColor(red: 255/255, green: 252/255, blue: 214/255, alpha: 1)
        
        // Add New Note Button
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNote))
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        // Load all the notes from user defaults.
        loadNotes()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        saveNotes()
//    }
    override func viewWillAppear(_ animated: Bool) {
        saveNotes()
        tableView.reloadData()
    }

    func loadNotes() {
        let defaults = UserDefaults.standard
        guard let encodedData = defaults.object(forKey: "notes") as? Data else { return }
        
        let jsonDecoder = JSONDecoder()
        if let decodedNotes = try? jsonDecoder.decode([Note].self, from: encodedData) {
            notes = decodedNotes
        }
    }
    
    func saveNotes() {
        // Encode Notes
        let jsonEncoder = JSONEncoder()
        guard let encodedData = try? jsonEncoder.encode(notes) else { return }
        
        let defaults = UserDefaults.standard
        defaults.setValue(encodedData, forKey:"notes")
    }
    
    @objc func addNote() {
        // Prompt user for note title.
        let ac = UIAlertController(title: "Set Title", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.textFields?[0].text = "New Note"
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "New", style: .default, handler: { [weak self] action in
            guard let title = ac.textFields?[0].text else { return }
            // Add a new note to the array.
            let newNote = Note(id:UUID().uuidString, title: title, text: "")
            self?.notes.insert(newNote, at: 0)
            DispatchQueue.main.async {
                // Insert New Note
                self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                
                // Push Detail View Controller
                guard let detailViewController = self?.storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
                detailViewController.note = newNote
                self?.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.text
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailViewController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailViewController.note = notes[indexPath.row]
        detailViewController.delegate = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func didDeletNote(note: Note) {
        for (index, locatedNote) in notes.enumerated() {
            if locatedNote.id == note.id {
                notes.remove(at: index)

//                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                navigationController?.popViewController(animated: true)
                break
            }
        }
    }

}

