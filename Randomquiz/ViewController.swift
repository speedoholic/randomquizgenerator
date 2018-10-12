//
//  ViewController.swift
//  Randomquiz
//
//  Created by Kushal Ashok on 12/19/17.
//  Copyright © 2017 Essex Lake Group. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet weak var countTextField: NSTextField!
    @IBOutlet var customTextView: NSTextView!
    @IBOutlet weak var numberOfQuestionsTextField: NSTextField!
    
    var questionsDictionary = Dictionary<String,[Int]>()
    var directoryPath = URL(string: "")
    var numberOfAttendees = 10
    var numberOfQuestions = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let newNumber = Int(self.countTextField.stringValue) {
            numberOfAttendees = newNumber
        }
        if let nQuestions = Int(self.numberOfQuestionsTextField.stringValue) {
            numberOfQuestions = nQuestions
        }
        setDirectoryPath()
        prepareFiles()
    }
    
    @IBAction func openFinderButtonPressed(_ sender: Any) {
        guard let filePath = directoryPath?.absoluteString else {return}
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: filePath)
    }
    
    
    func prepareFiles() {
        
        prepareQuestionsDictionary()
        prepareKeys()
        
        let contentsOfKeyFile = NSMutableAttributedString()

        for fileNumber in questionsDictionary.keys {
            if let array = questionsDictionary[fileNumber] {
                let contentsOfFile = NSMutableAttributedString()
                var questionsAndKeys = ""
                contentsOfFile.append(NSAttributedString(string: "TestPaper Number " + fileNumber + ":\n\n"))
                for qNumber in array {
                    contentsOfFile.append(getContentsOfFile(String(qNumber)))
                    contentsOfFile.append(NSAttributedString(string: "\n_______________________________________\n"))
                    guard let answer = keyDictionary[qNumber] else {continue}
                    questionsAndKeys += "Q" + String(qNumber) + ": " + answer + ", "
                }

                contentsOfKeyFile.append(NSAttributedString(string: "\n\nTestPaper Number " + fileNumber + ":\n"))
                contentsOfKeyFile.append(NSAttributedString(string: questionsAndKeys))
                contentsOfKeyFile.append(NSAttributedString(string: "\n\n"))
                saveFile(contentsOfFile, name: fileNumber)
            }
        }
        saveFile(contentsOfKeyFile, name: "Keys")
        
    }
    
    func prepareQuestionsDictionary() {
        clearFolder()
        questionsDictionary.removeAll()
        var arrayOfQuestionNumbers = [Int]()
        for i in 1...80 {
            arrayOfQuestionNumbers.append(i)
        }
        for j in 1...numberOfAttendees {
            var arrayOfSelectedNumbers = [Int]()
            for _ in 1...numberOfQuestions {
                let randomNumber = Int(arc4random_uniform(79) + 1)
                arrayOfSelectedNumbers.append(arrayOfQuestionNumbers[randomNumber])
            }
            questionsDictionary[String(j)] = arrayOfSelectedNumbers
        }
    }
    
    func getContentsOfFile(_ name: String) -> NSAttributedString {
        var attributedStringWithRtf = NSAttributedString()
        if let rtfPath = Bundle.main.url(forResource: name, withExtension: "rtf") {
            do {
                attributedStringWithRtf = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            } catch let error {
                print("Got an error \(error)")
            }
        }
        return attributedStringWithRtf
    }
    
    func saveFile(_ contents: NSMutableAttributedString, name: String) {
        let fileName = "\(name).rtf"
        
        guard let directoryPath = directoryPath else {return}
        let fileURL = directoryPath.appendingPathComponent(fileName)
        
        //writing
        do {
            if let rtfData = contents.rtf(from: NSMakeRange(0, contents.length), documentAttributes: [:]) {
                //TODO: Get correct path without hardcoding
                let filePathString = FileManager.default.currentDirectoryPath + "/Documents/" + fileName
                if FileManager.default.fileExists(atPath: filePathString) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try rtfData.write(to: fileURL)
            }
        }
        catch {
            print("Caught something while writing to \(fileURL.absoluteURL)")
        }
    }
    
    func setDirectoryPath() {
        // get the documents folder url
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            directoryPath = dir
            customTextView.textStorage?.append(NSAttributedString(string: dir.absoluteString))
        }
    }
    
    func clearFolder() {
        let fileManager = FileManager.default
        
        do {
            let dirPath = fileManager.currentDirectoryPath + "/Documents/"
            let filePaths = try fileManager.contentsOfDirectory(atPath: dirPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: dirPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    


}

