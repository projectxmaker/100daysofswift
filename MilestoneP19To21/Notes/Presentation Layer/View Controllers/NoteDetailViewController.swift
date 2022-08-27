//
//  DetailViewController.swift
//  Notes
//
//  Created by Pham Anh Tuan on 8/27/22.
//

import UIKit

class NoteDetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    var noteIndex: Int?
    var doneButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    private var isDoneButtonHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadNote()
        
        setupNavigationItems()
        
        setupToolbars()
        
        addObserverForKeyboardNotification()
        
        textView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Keyboards
    private func addObserverForKeyboardNotification() {
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        hideDoneButton(false)
        makeTextViewSelectionVisible(notification: notification)
    }
    
    // MARK: - Text View
    func textViewDidChange(_ textView: UITextView) {
        hideDoneButton(false)
    }
    
    private func makeTextViewSelectionVisible(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: - Extra Funcs
    private func hideDoneButton(_ isHide: Bool = true) {
        if isHide {
            if !isDoneButtonHidden {
                // hide doneButton
                navigationItem.rightBarButtonItems = [shareButton]
                isDoneButtonHidden = true
            }
        } else {
            if isDoneButtonHidden {
                // show doneButton
                navigationItem.rightBarButtonItems = [doneButton, shareButton]
                isDoneButtonHidden = false
            }
        }
    }
    
    private func setupNavigationItems() {
        
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareButtonTapped))
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButtonTapped))
        
        // hide doneButton
        hideDoneButton()
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
        hideDoneButton()
        
        // save the current note
        saveNote()
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
        let notes = loadNoteList()
        
        if index >= 0 && index < notes.count {
            return notes[index]
        }
        
        return nil
    }
    
    private func saveNote() {
        let textValue = textView.text ?? ""
        let firstLine = textValue.components(separatedBy: "\n")[0]
        let titleValue = firstLine
        
        let tmpNoteIndex = noteIndex ?? 0
        var note = Note(title: titleValue, text: textValue, index: tmpNoteIndex)
        
        if noteIndex == nil {
            addNoteToNoteList(note)
            
            noteIndex = note.index
            
            let userInfo: [String: Note] = ["note": note]
            postNotification(name: "com.projectxmaker.notes.newNote", userInfo: userInfo)
        } else {
            note.updatedAt = Date.now
            updateNoteToNoteList(note)
            
            let userInfo: [String: Note] = ["note": note]
            postNotification(name: "com.projectxmaker.notes.updateNote", userInfo: userInfo)
        }
    }
    
    private func addNoteToNoteList(_ note: Note) {
        var noteList = loadNoteList()
        noteList.insert(note, at: 0)
        saveNoteList(noteList)
    }
    
    private func updateNoteToNoteList(_ note: Note) {
        var noteList = loadNoteList()
        noteList[note.index] = note
        saveNoteList(noteList)
    }
    
    private func loadNoteList() -> [Note] {
        guard
            let data = UserDefaults.standard.object(forKey: "NoteList") as? Data,
            let decodedData = try? JSONDecoder().decode([Note].self, from: data)
        else {
            return [Note]()
        }
        
        return decodedData
    }
    
    private func saveNoteList(_ noteList: [Note]) {
        guard let encodedData = try? JSONEncoder().encode(noteList) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: "NoteList")
    }
    
    private func postNotification(name: String, userInfo: [AnyHashable: Any]) {
        let center = NotificationCenter.default
        center.post(name: Notification.Name(name), object: nil, userInfo: userInfo)
    }
}
