//
//  DetailViewController.swift
//  Custom Notes
//
//  Created by Danny Tsang on 7/13/21.
//

import UIKit

protocol DetailViewControllerDelegate {
    func didDeletNote(note:Note)
}

class DetailViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    var note: Note?
    var delegate:DetailViewControllerDelegate?
    
    var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Handle Keyboard Notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(startEditing), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(adjustKeyboard), name:UIResponder.keyboardDidHideNotification, object: nil)
        center.addObserver(self, selector: #selector(adjustKeyboard), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
       
        // Lock textview from editing.
        textView.isEditable = true
                
        // Edit BarButtonItem
//        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))

        // Delete BarButtonItem
        doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))

        // Share BarButtonItem
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        
        // Delete BarButtonItem
        let deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))


        navigationItem.rightBarButtonItems = [shareBarButtonItem, deleteBarButtonItem]
        
        // Set the note parameters on to the screen.
        if let noteUnwrapped = note {
            title = noteUnwrapped.title
            textView.text = noteUnwrapped.text
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save the note back to user defaults.
        note?.text = textView.text
    }
    
    @objc func editButtonPressed() {
        guard var rightBarButtons = navigationItem.rightBarButtonItems else { return }
        
        if rightBarButtons.contains(doneBarButtonItem) { return }
        
        rightBarButtons.insert(doneBarButtonItem, at: 0)
        navigationItem.setRightBarButtonItems(rightBarButtons, animated: false)
    }
    
    @objc func doneButtonPressed() {
        textView.resignFirstResponder()
        
        guard var rightBarButtons = navigationItem.rightBarButtonItems else { return }
        rightBarButtons.removeFirst()
        navigationItem.setRightBarButtonItems(rightBarButtons, animated: false)
    }
    
    @objc func startEditing(notification: Notification) {
        guard var rightBarButtons = navigationItem.rightBarButtonItems else { return }
        
        if rightBarButtons.contains(doneBarButtonItem) { return }
        
        rightBarButtons.insert(doneBarButtonItem, at: 0)
        navigationItem.setRightBarButtonItems(rightBarButtons, animated: false)
    }
    

    @objc func shareButtonPressed() {
        // Share Action
        let title = title ?? "New Note"
        let text = textView.text ?? ""
        
        let shareController = UIActivityViewController(activityItems: [title, text], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }
    
    @objc func deleteButtonPressed() {
        // Delete Action
        let ac = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] action in
            // Call delegate to delete note.
            if let delegate = self?.delegate {
                if let note = self?.note {
                    delegate.didDeletNote(note: note)
                }
            }
        }))
        present(ac, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @objc func adjustKeyboard(notification: Notification) {
        // NSValue -> Wrapper around CGRect in OBJC
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // Get the correct end frame in our rotated view window
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from:view.window)
        
        // Set the inset based on the notification type.
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else if notification.name == UIResponder.keyboardWillChangeFrameNotification {
    //            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)

            // Subtract the Safe Area Inset for any phone with a notch.
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        // Add insets to the scroll indicators.
        textView.scrollIndicatorInsets = textView.contentInset
            
        // Scroll to the visable Range
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}
