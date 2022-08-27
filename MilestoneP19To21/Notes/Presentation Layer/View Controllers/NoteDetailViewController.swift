//
//  DetailViewController.swift
//  Notes
//
//  Created by Pham Anh Tuan on 8/27/22.
//

import UIKit

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var noteIndex: Int?
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadNote()
        
        setupNavigationItems()
        
        setupToolbars()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Extra Funcs
    private func setupNavigationItems() {
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareButtonTapped))
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButtonTapped))
        
        //navigationItem.rightBarButtonItems = [shareButton, doneButton]
        
        // hide doneButton as default
        navigationItem.rightBarButtonItems = [shareButton]
    }
    
    private func setupToolbars() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleDeleteNoteButtonTapped))
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleCreateNewNoteButtonTapped))

        setToolbarItems([deleteButton, space, composeButton], animated: true)
        navigationController?.isToolbarHidden = false
    }
    
    @objc private func handleShareButtonTapped() {
        let sharedItems = [textView.text ?? ""]
        let ac = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        
        present(ac, animated: true)
    }
    
    @objc private func handleDoneButtonTapped() {
        // save the current note
    }
    
    @objc private func handleDeleteNoteButtonTapped() {
        // ask for confirmation
        // redirect to Note List
    }
    
    
    @objc private func handleCreateNewNoteButtonTapped() {
        // display empty detail and ready to create new Note
    }
    
    private func loadNote() {
        guard
            let index = noteIndex,
            let note = getNoteByIndex(index)
        else { return }
        
        textView.text = note.text
    }
    
    private func getNoteByIndex(_ index: Int) -> Note? {
        return nil
    }
}
