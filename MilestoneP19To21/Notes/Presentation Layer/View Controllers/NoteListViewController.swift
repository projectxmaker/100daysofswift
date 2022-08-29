//
//  NoteListViewController.swift
//  Notes
//
//  Created by Pham Anh Tuan on 8/27/22.
//

import UIKit

class NoteListViewController: UITableViewController {
    var notes = [Note]()
    
    let dateFormatStyle = Date.FormatStyle()
        .day(.twoDigits)
        .month(.twoDigits)
        .year(.defaultDigits)
        .hour(.twoDigits(amPM: .wide))
        .minute(.twoDigits)
        .second(.twoDigits)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Note List"
        
        setupToolbars()
        
        registerNotificationObservers()
        
        reloadNoteList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)

        let note = notes[indexPath.row]

        setContentConfigurationForCell(cell, note: note)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openNoteDetailScreen(index: indexPath.row)
    }
    
    // MARK: - Extra Funcs
    private func setContentConfigurationForCell(_ cell: UITableViewCell, note: Note) {
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = note.title
        contentConfig.textProperties.font = UIFont.boldSystemFont(ofSize: 20)
        contentConfig.secondaryText = note.updatedAt.formatted(dateFormatStyle)
        cell.contentConfiguration = contentConfig
    }
    
    private func setupToolbars() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleCreateNewNoteButtonTapped))

        setToolbarItems([space, composeButton], animated: true)
        navigationController?.isToolbarHidden = false
    }

    @objc private func handleCreateNewNoteButtonTapped() {
        openNoteDetailScreen()
    }
    
    private func openNoteDetailScreen(index: Int? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let noteDetailViewController = storyboard.instantiateViewController(withIdentifier: "NoteDetail") as? NoteDetailViewController else { return }
        
        if index != nil {
            noteDetailViewController.noteIndex = index
        }

        navigationController?.pushViewController(noteDetailViewController, animated: true)
    }
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(handleUpdateNoteNotification), name: Notification.Name("com.projectxmaker.notes.updateNote"), object: nil)
        
        center.addObserver(self, selector: #selector(handleNewNoteNotification), name: Notification.Name("com.projectxmaker.notes.newNote"), object: nil)

        center.addObserver(self, selector: #selector(handleDeleteNoteNotification), name: Notification.Name("com.projectxmaker.com.notes.deleteNote"), object: nil)
        
        
    }
    
    @objc private func handleUpdateNoteNotification(_ notification: Notification) {
        guard
            let note = getNoteFromNotificationUserInfo(notification)
        else { return }
    
        reloadNoteList()
        updateCellWithNote(note)
    }
    
    @objc private func handleNewNoteNotification(_ notification: Notification) {
        guard let note = getNoteFromNotificationUserInfo(notification) else { return }
        
        reloadNoteList()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        updateCellWithNote(note)
    }
    
    @objc private func handleDeleteNoteNotification(_ notification: Notification) {
        guard let note = getNoteFromNotificationUserInfo(notification) else { return }

        deleteNote(note.index)
        
        tableView.deleteRows(at: [IndexPath(row: note.index, section: 0)], with: .automatic)
        
        reloadNoteList()
    }
    
    private func getNoteFromNotificationUserInfo(_ notification: Notification) -> Note? {
        guard
            let userInfo = notification.userInfo as? [String: Note],
            let note = userInfo["note"]
        else { return nil }
        
        return note
    }

    private func updateCellWithNote(_ note: Note) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: note.index, section: 0)) else { return }
        
        setContentConfigurationForCell(cell, note: note)
    }
    
    // MARK: - Notes
    private func reloadNoteList() {
        notes = loadNoteList()
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
    
    private func deleteNote(_ noteIndex: Int) {
        notes.remove(at: noteIndex)
        saveNoteList(notes)
    }
    
    private func saveNoteList(_ noteList: [Note]) {
        guard let encodedData = try? JSONEncoder().encode(noteList) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: "NoteList")
    }
}
