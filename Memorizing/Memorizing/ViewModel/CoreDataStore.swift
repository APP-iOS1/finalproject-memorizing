//
//  CoreDataViewModel.swift
//  Memorizing
//
//  Created by 이종현 on 2023/01/31.
//

import Foundation
import CoreData
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
class CoreDataManager {
    
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { (_, error) in
            if let error {
                print("Error occured. \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error occured in saving. \(error.localizedDescription)")
        }
    }
}

class CoreDataStore: ObservableObject {
    let manager = CoreDataManager.instance
    let database = Firestore.firestore()
    @Published var notes: [NoteEntity] = []
    
    init() {
        getNotes()
    }
    
    func addNote(id: String,
                 noteName: String,
                 enrollmentUser: String,
                 noteCategory: String,
                 firstTestResult: Double,
                 lastTestResult: Double,
                 updateDate: Date) {
        let newNote = NoteEntity(context: manager.context)
        newNote.id = id
        newNote.noteName = noteName
        newNote.enrollmentUser = enrollmentUser
        newNote.noteCategory = noteCategory
        newNote.repeatCount = 0
        newNote.firstTestResult = firstTestResult
        newNote.lastTestResult = lastTestResult
        newNote.updateDate = updateDate
        
        save()
        getNotes()
    }
    
    func addWord(note: NoteEntity, id: String, wordLevel: Int64, wordMeaning: String, wordString: String) {
        let newWord = WordEntity(context: manager.context)
        newWord.id = id
        newWord.wordLevel = wordLevel
        newWord.wordMeaning = wordMeaning
        newWord.wordString = wordString
        
        note.addToWords(newWord)
        
        save()
        getNotes()
    }
    
    func addNoteAndWord<T: NoteProtocol>(note: T, words: [Word], _ repeatCount: Int? = nil) {
        let returnedNote = returnNote(
                   id: note.id,
                   noteName: note.noteName,
                   enrollmentUser: note.enrollmentUser,
                   noteCategory: note.noteCategory,
                   repeatCount: repeatCount ?? 0,
                   firstTestResult: 0,
                   lastTestResult: 0,
                   updateDate: note.updateDate
        )
        for word in words {
            let newWord = WordEntity(context: manager.context)
            newWord.id = word.id
            newWord.wordLevel = Int64(word.wordLevel)
            newWord.wordMeaning = word.wordMeaning
            newWord.wordString = word.wordString
            
            returnedNote.addToWords(newWord)
        }
        
        save()
    }
    
    func returnNote(id: String,
                    noteName: String,
                    enrollmentUser: String,
                    noteCategory: String,
                    repeatCount: Int,
                    firstTestResult: Double,
                    lastTestResult: Double,
                    updateDate: Date) -> NoteEntity {
        let newNote = NoteEntity(context: manager.context)
        newNote.id = id
        newNote.noteName = noteName
        newNote.enrollmentUser = enrollmentUser
        newNote.noteCategory = noteCategory
        newNote.repeatCount = Int64(repeatCount)
        newNote.firstTestResult = firstTestResult
        newNote.lastTestResult = lastTestResult
        newNote.updateDate = updateDate
        
        return newNote
    }
    
    func getNotes() {
        let repeatCountFilter = NSSortDescriptor(key: "repeatCount", ascending: true)
        // MARK: 두가지 정렬 해결해야함. (현재 방식으론 한개만 적용됨)
        let categoryFilter = NSSortDescriptor(key: "updateDate", ascending: false)
        
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        request.sortDescriptors = [repeatCountFilter, categoryFilter]
        DispatchQueue.main.async {
            do {
                self.notes = try self.manager.context.fetch(request)
            } catch {
                print("Error fetching. \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        manager.save()
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try manager.context.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        save()
        getNotes()
    }
    
    func syncronizeWithDB() async {
        guard let currentUser = Auth.auth().currentUser else { return print("return no current user")}
        // note fetch
        do {
            let snapshots = try await database.collection("users")
                .document(currentUser.uid)
                .collection("myWordNotes")
                .getDocuments()
            
            for document in snapshots.documents {
                let docData = document.data()
                let id: String = docData["id"] as? String ?? ""
                let noteName: String = docData["noteName"] as? String ?? ""
                let noteCategory: String = docData["noteCategory"] as? String ?? ""
                let enrollmentUser: String = docData["enrollmentUser"] as? String ?? ""
                let repeatCount: Int = docData["repeatCount"] as? Int ?? 0
                let createdAtTimeStamp: Timestamp = docData["updateDate"] as? Timestamp ?? Timestamp()
                let updateDate: Date = createdAtTimeStamp.dateValue()
                let note: MyWordNote = MyWordNote(id: id,
                                                  noteName: noteName,
                                                  noteCategory: noteCategory,
                                                  enrollmentUser: enrollmentUser,
                                                  repeatCount: repeatCount,
                                                  firstTestResult: 0,
                                                  lastTestResult: 0,
                                                  updateDate: updateDate)
                do {
                    let snapshot = try await self.database.collection("users").document(currentUser.uid)
                        .collection("myWordNotes")
                        .document(id)
                        .collection("words")
                        .getDocuments()
                    var words: [Word] = []
                    
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let wordString: String = docData["wordString"] as? String ?? ""
                        let wordMeaning: String = docData["wordMeaning"] as? String ?? ""
                        let wordLevel: Int = docData["wordLevel"] as? Int ?? 0
                        
                        let word = Word(id: id,
                                        wordString: wordString,
                                        wordMeaning: wordMeaning,
                                        wordLevel: wordLevel)
                        
                        words.append(word)
                    }
                    self.addNoteAndWord(note: note, words: words, note.repeatCount)
                } catch {
                    print("fetch words in syncronizeWithDB error occured")
                }
            }
            
        } catch {
                print("syncronizeWithDB error occured")
            }
        
    }
    func updateWordLevel(word: WordEntity, level: Int64) {
        word.wordLevel = level
        
        save()
    }
    
    func plusRepeatCount(note: NoteEntity) {
        note.repeatCount += 1
        
        save()
        getNotes()
    }
    
    func resetRepeatCount(note: NoteEntity) {
        note.repeatCount = 0
        
        save()
        getNotes()
    }
    
    func deleteWord(word: WordEntity) {
        
        manager.context.delete(word)
        
        save()
    }
    
    func returnColor(category: String) -> Color {
       
            switch category {
            case "영어":
                return Color.englishColor
            case "한국사":
                return Color.historyColor
            case "IT":
                return Color.iTColor
            case "경제":
                return Color.economyColor
            case "시사":
                return Color.knowledgeColor
            case "기타":
                return Color.etcColor
            default:
                return Color.mainDarkBlue
        }
    }
    
    func returnWidth(width: Int64) -> Double {
            switch width {
            case 0, 1:
                return 0.0
            case 2:
                return 97.0
            case 3:
                return 185.0
            default:
                return 260.0
            }
    }
    
}
