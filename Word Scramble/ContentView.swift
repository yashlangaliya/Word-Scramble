//
//  ContentView.swift
//  Word Scramble
//
//  Created by stl-037 on 14/02/20.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord = ""
    @State private var usedWords = [String]()
    @State private var allWords = [String]()
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isShowingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Your Word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .disableAutocorrection(true)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                    
                }
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: loadGameData)
            .alert(isPresented: $isShowingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing: Button(action: startGame, label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Restart")
                }
            }))
        }
        
    }
    
    func addNewWord() {
        let word = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        if word.count > 0 {
            guard isOriginal() else {
                wordError(title: "Word used already", message: "Be more original")
                return
            }
            
            guard isPossible() else {
                wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
                return
            }
            
            guard isReal() else {
                wordError(title: "Word not possible", message: "That isn't a real word.")
                return
            }
            
            usedWords.insert(word.uppercased(), at: 0)
            newWord = ""
        }
    }
    
    func loadGameData() {
        guard let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt"),
            let contentOfFile = try? String(contentsOf: fileUrl) else {
            fatalError("Not able to read the file.")
        }
        allWords = contentOfFile.components(separatedBy: "\n")
        startGame()
    }
    
    func startGame() {
        rootWord = allWords.randomElement()?.uppercased() ?? "Snowfall".uppercased()
        newWord = ""
        usedWords.removeAll()
    }
    
    func isOriginal() -> Bool {
        return !usedWords.contains(newWord.uppercased())
    }
    
    func isPossible() -> Bool {
        var tempWord = rootWord
        for char in newWord.uppercased() {
            if let index = tempWord.firstIndex(of: char) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal() -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length:  newWord.utf16.count)
        return checker.rangeOfMisspelledWord(in: newWord, range: range, startingAt: 0, wrap: false, language: "en").location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isShowingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
