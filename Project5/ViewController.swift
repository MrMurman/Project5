//
//  ViewController.swift
//  Project5
//
//  Created by Андрей Бородкин on 28.06.2021.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
 
    enum ErrorType {
        case notPossible, notOriginal, notReal
        
        var errorTitle: String {
            switch self {
            case .notReal:
                return "Word not recognized"
            case.notOriginal:
                return "Word already used"
            case.notPossible:
                return "Word not possible"
            }
        }
        var errorMessage: String {
            switch self {
            case .notReal:
                return "You can't just make them up, you know!"
            case.notOriginal:
                return "Be more original!"
            case.notPossible:
                return "You can't spell that word from PLACEHOLDER"
            }
        }
    
    }
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let starWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: starWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }


    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage(type: .notReal)
                }
            } else {
                showErrorMessage(type: .notOriginal)
            }
        } else {
            guard let title = title else {return}
            showErrorMessage(type: .notPossible)
//            errorTitle = "Word not possible"
//            errorMessage = "You can't spell that word from \(title.lowercased())"
        }
    }
    
    func isPossible(word: String) -> Bool {
        
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        guard word != title?.lowercased() else {return false}
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        guard word.count >= 3 else {return false}
        
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    
    func showErrorMessage(type: ErrorType) {
    
        
        let ac = UIAlertController(title: type.errorTitle, message: type.errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

