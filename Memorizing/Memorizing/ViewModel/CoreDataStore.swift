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
    @Published var myWordNotes : [MyWordNote] = []
    
    init() {
        getNotes()
    }
    
    func addNote(id: String,
                 noteName: String,
                 enrollmentUser: String,
                 noteCategory: String,
                 firstTestResult: Double,
                 lastTestResult: Double,
                 updateDate: Date,
                 nextStudyDate: Date) {
        let newNote = NoteEntity(context: manager.context)
        newNote.id = id
        newNote.noteName = noteName
        newNote.enrollmentUser = enrollmentUser
        newNote.noteCategory = noteCategory
        newNote.repeatCount = 0
        newNote.firstTestResult = firstTestResult
        newNote.lastTestResult = lastTestResult
        newNote.updateDate = updateDate
        newNote.nextStudyDate = nextStudyDate
        
        save()
        getNotes()
    }
    
    func addWord(note: NoteEntity,
                 id: String,
                 wordLevel: Int64,
                 wordMeaning: String,
                 wordString: String) {
        let newWord = WordEntity(context: manager.context)
        newWord.id = id
        newWord.wordLevel = wordLevel
        newWord.wordMeaning = wordMeaning
        newWord.wordString = wordString
        
        note.addToWords(newWord)
        
        save()
        getNotes()
    }
    
    func addNoteAndWord<T: NoteProtocol>(note: T,
                                         words: [Word],
                                         _ repeatCount: Int? = nil,
                                         firstTestResult: Double? = nil,
                                         lastTestResult: Double? = nil,
                                         nextStudyDate: Date? = nil
    )
    {
        let returnedNote = returnNote(
                   id: note.id,
                   noteName: note.noteName,
                   enrollmentUser: note.enrollmentUser,
                   noteCategory: note.noteCategory,
                   repeatCount: repeatCount ?? 0,
                   firstTestResult: firstTestResult ?? 0,
                   lastTestResult: lastTestResult ?? 0,
                   updateDate: note.updateDate,
                   nextStudyDate: nextStudyDate ?? Date()
                   
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
                    updateDate: Date,
                    nextStudyDate: Date) -> NoteEntity {
        let newNote = NoteEntity(context: manager.context)
        newNote.id = id
        newNote.noteName = noteName
        newNote.enrollmentUser = enrollmentUser
        newNote.noteCategory = noteCategory
        newNote.repeatCount = Int64(repeatCount)
        newNote.firstTestResult = firstTestResult
        newNote.lastTestResult = lastTestResult
        newNote.updateDate = updateDate
        newNote.nextStudyDate = nextStudyDate
        save()
        return newNote
    }
    
    func getNotes() {
        let repeatCountFilter = NSSortDescriptor(key: "repeatCount", ascending: true)
        // MARK: 두가지 정렬 해결해야함. (현재 방식으론 한개만 적용됨)
        let categoryFilter = NSSortDescriptor(key: "updateDate", ascending: false)
        let request = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        
        request.sortDescriptors = [repeatCountFilter, categoryFilter]
        
        DispatchQueue.main.async {
            
            self.notes.removeAll()
            
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
    
    func syncronizeNotes() async {
        guard let currentUser = Auth.auth().currentUser else { return print("return no current user")}
        // note fetch
        do {
            await MainActor.run {
                self.myWordNotes.removeAll()
            }
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
                let firstTestResult: Double = docData["firstTestResult"] as? Double ?? 0.0
                let lastTestResult: Double = docData["lastTestResult"] as? Double ?? 0.0
                let createdAtTimeStamp: Timestamp = docData["updateDate"] as? Timestamp ?? Timestamp()
                let updateDate: Date = createdAtTimeStamp.dateValue()
                let nextStudyTimeStamp: Timestamp = docData["nextStudyDate"] as? Timestamp ?? Timestamp()
                let nextStudyDate: Date = nextStudyTimeStamp.dateValue()
                if id == "" {
                    continue
                }
                let note: MyWordNote = MyWordNote(id: id,
                                                  noteName: noteName,
                                                  noteCategory: noteCategory,
                                                  enrollmentUser: enrollmentUser,
                                                  repeatCount: repeatCount,
                                                  firstTestResult: firstTestResult,
                                                  lastTestResult: lastTestResult,
                                                  updateDate: updateDate,
                                                  nextStudyDate: nextStudyDate)
                await MainActor.run {
                    self.myWordNotes.append(note)
                }
                
            }
        } catch {
                print("syncronizeWithDB error occured")
            }
    }
    
    func syncronizeWords(id: String) async -> [Word] {
        guard let currentUser = Auth.auth().currentUser else { return [] }
       
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
                return words
                
            } catch {
                print("fetch words in syncronizeWithDB error occured")
                return []
            }
        
    }
    
    func saveNotesInCoreData() async {
        
        for note in myWordNotes {
            let words = await self.syncronizeWords(id: note.id)
            addNoteAndWord(note: note, words: words, note.repeatCount, firstTestResult: note.firstTestResult, lastTestResult: note.lastTestResult, nextStudyDate: note.nextStudyDate)
        }
    }
    
    func updateWordLevel(word: WordEntity, level: Int64) {
        word.wordLevel = level
        
        save()
    }
    
    func plusRepeatCount(note: NoteEntity,
                         firstTestResult: Double?,
                         lastTestResult: Double?) {
        if let firstTestResult {
            note.firstTestResult = firstTestResult
        }
        
        if let lastTestResult {
            note.lastTestResult = lastTestResult
        }
        
        note.repeatCount += 1
        note.updateDate = Date()
        save()
        getNotes()
    }
    
    func resetRepeatCount(note: NoteEntity) {
        note.repeatCount = 0
        note.firstTestResult = 0.0
        note.lastTestResult = 0.0
        note.updateDate = Date()
        save()
        getNotes()
    }
    
    func deleteWord(word: WordEntity) {
        
        manager.context.delete(word)
        save()
    }
    
    // MARK: - 코어데이터 상에서도 note 자체를 지워줘야 하는데.. 왜 업데이트가 안되는거지?
    func deleteNote(note: NoteEntity) {
        manager.context.delete(note)
        save()
        getNotes()
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
    
    func returnWidth(width: CGFloat) -> Double {
            switch width {
            case 0, 1:
                return UIScreen.main.bounds.width * 0.72 * 0.0
            case 2:
                return UIScreen.main.bounds.width * 0.72 * 0.3333
            case 3:
                return UIScreen.main.bounds.width * 0.72 * 0.6666
            default:
                return UIScreen.main.bounds.width * 0.72
            }
    }
    
}
