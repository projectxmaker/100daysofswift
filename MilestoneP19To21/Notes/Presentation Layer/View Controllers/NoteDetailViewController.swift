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
    var currentNote: Note?
    var doneButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    var space: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    var composeButton: UIBarButtonItem!
    
    private var isDoneButtonHidden = false
    private var isDeleteButtonHidden = false
    
    private var currentSharedNoteUrl: URL?
    
    let maximumCharsOfNoteTitle = 20
    
    private var firstLineRange = NSRange()
    private var attributedText = NSAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        setupToolbars()
        
        // Do any additional setup after loading the view.
        loadNote()

        addObserverForKeyboardNotification()
        
        textView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentNote == nil {
            textView.becomeFirstResponder()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Handlers
    
    @objc private func handleDoneButtonTapped() {
        hideDoneButton()
        
        // save the current note
        saveNote()
    }
    
    @objc private func handleDeleteNoteButtonTapped() {
        guard let tmpCurrentNote = currentNote else { return }

        // ask for confirmation
        let ac = UIAlertController(title: "Delete Note", message: "Do you want to delete Note: \(tmpCurrentNote.title)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            
            let userInfo: [String: Note] = ["note": tmpCurrentNote]

            self?.postNotification(name: "com.projectxmaker.com.notes.deleteNote", userInfo: userInfo)
            
            self?.navigationController?.popViewController(animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    
    @objc private func handleCreateNewNoteButtonTapped() {
        // display empty detail and ready to create new Note
        
        noteIndex = nil
        textView.text = ""
        textView.becomeFirstResponder()
        loadNote()
    }
    
    
    @objc private func handleShareButtonTapped() {
        let textValue = textView.text ?? ""
        let titleValue = getTitleOfNote(textValue)
        let textFileUrl = getDocumentDirectory().appendingPathComponent(titleValue)
        currentSharedNoteUrl = textFileUrl
        
        try? textValue.write(to: textFileUrl, atomically: true, encoding: .utf8)

        let sharedItems = [textFileUrl]
        let ac = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        
        ac.completionWithItemsHandler = executeAtActivityViewControllerCompleted

        present(ac, animated: true)
    }
    
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
    
    // MARK: - Text View
    func textViewDidChange(_ textView: UITextView) {
        hideDoneButton(false)
        
        boldFirstLineOfNote()
    }
    
    private func boldFirstLineOfNote() {
        let newAttributedText = textView.attributedText ?? NSAttributedString()

        if attributedText != newAttributedText {
            attributedText = newAttributedText

            // reset style of attributed text
            let currentSelectedRange = textView.selectedRange
            let attributedText = attributedText.string
            let regularStyle = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
            let attributedString = NSMutableAttributedString(string: attributedText, attributes: regularStyle)
            textView.attributedText = attributedString
            
            // bold it
            let textNote = textView.text ?? ""
            let lineBreakIndex = textNote.firstIndex(of: "\n") ?? textNote.endIndex
            let firstLine = String(textNote[..<lineBreakIndex])
            
            let range = NSRange(location: 0, length: firstLine.count)

            let attributeOfBold = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)
            ]

            attributedString.addAttributes(attributeOfBold, range: range)

            textView.attributedText = attributedString
            textView.selectedRange = currentSelectedRange
        }
    }
    
    // MARK: - Extra Funcs
    private func hideDoneButton(_ isHide: Bool = true) {
        if isHide {
            if !isDoneButtonHidden {
                // hide doneButton
                navigationItem.setRightBarButtonItems([shareButton], animated: true)
                isDoneButtonHidden = true
            }
        } else {
            if isDoneButtonHidden {
                // show doneButton
                navigationItem.setRightBarButtonItems([doneButton, shareButton], animated: true)
                isDoneButtonHidden = false
            }
        }
    }
    
    private func hideDeleteButton(_ isHide: Bool = true) {
        guard let buttons = toolbarItems else { return }
        
        if isHide {
            if buttons.contains(deleteButton) {
                setToolbarItems([space, composeButton], animated: true)
            }
        } else {
            if !buttons.contains(deleteButton) {
                setToolbarItems([deleteButton, space, composeButton], animated: true)
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
        toolbarItems = [UIBarButtonItem]()
        
        space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        space.tag = 1
        
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleDeleteNoteButtonTapped))
        deleteButton.tag = 1
        
        composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleCreateNewNoteButtonTapped))
        composeButton.tag = 3

        hideDeleteButton(false)
        navigationController?.isToolbarHidden = false
    }
    
    private func executeAtActivityViewControllerCompleted (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) -> Void {
        if completed {
            // delete file that previously used to share
            guard let tmpNoteURL = currentSharedNoteUrl else { return }
            
            let textFilePath = tmpNoteURL.path
            let fm = FileManager.default
            
            if fm.fileExists(atPath: textFilePath) {
                try? fm.removeItem(atPath: textFilePath)
            }
            
            currentSharedNoteUrl = nil
        }
    }
    
    
    private func loadNote() {
        guard
            let index = noteIndex,
            var note = getNoteByIndex(index)
        else {
            hideDeleteButton(true)
            return
        }
        
        note.index = index
        
        currentNote = note
        
        textView.text = note.text
        
        hideDeleteButton(false)
        
        boldFirstLineOfNote()
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
        let titleValue = getTitleOfNote(textValue)
        
        let tmpNoteIndex = noteIndex ?? 0
        var note = Note(title: titleValue, text: textValue, index: tmpNoteIndex)
        
        if noteIndex == nil {
            addNoteToNoteList(note)
            
            noteIndex = note.index
            
            currentNote = note
            
            let userInfo: [String: Note] = ["note": note]
            postNotification(name: "com.projectxmaker.notes.newNote", userInfo: userInfo)
            
            hideDeleteButton(false)
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
    
    private func deleteNote(_ noteIndex: Int) {
        var noteList = loadNoteList()
        noteList.remove(at: noteIndex)
        saveNoteList(noteList)
    }
    
    private func postNotification(name: String, userInfo: [AnyHashable: Any]) {
        let center = NotificationCenter.default
        center.post(name: Notification.Name(name), object: nil, userInfo: userInfo)
    }
    
    private func getDocumentDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return urls[0]
    }
    
    private func getTitleOfNote(_ text: String) -> String {
        let firstLine = text.components(separatedBy: "\n")[0]
        var title = firstLine
        if firstLine.count > maximumCharsOfNoteTitle {
            title = ""
            let substrings = firstLine.components(separatedBy: " ")

            var charsCounter = 0
            for eachSubstring in substrings {
                charsCounter += eachSubstring.count + 1
                if charsCounter > maximumCharsOfNoteTitle {
                    if title.count == 0 {
                        let indexAtMaximumCharsOfNoteTitle = firstLine.index(firstLine.startIndex, offsetBy: maximumCharsOfNoteTitle)
                        let substr = firstLine[...indexAtMaximumCharsOfNoteTitle]
                        title = String(substr)
                    }
                    
                    break
                } else {
                    if title.count > 0 {
                        title += " "
                    }
                    
                    title += eachSubstring
                }
            }
        }
        
        return title
        
    }
}
