//
//  QuizViewController.swift
//  iQuiz
//
//  Created by Munir Emam on 5/13/25.
//

import UIKit

class QuizViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var finalLabel: UILabel!
    
    @IBOutlet weak var answersTable: UITableView!
    
    @IBOutlet weak var questionStackView: UIStackView!
    
    @IBOutlet weak var answerStackView: UIStackView!
    
    @IBOutlet weak var finalStackView: UIStackView!
    
    var quiz: [[String: Any]] = []
    
    var question = [String: Any]()
    
    var answers: [String] = []
    
    var selectedAnswers: Int?
    
    var questionIndex: Int = 0
    
    var score: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionIndex = 0
        self.score = 0
        
        self.question = quiz[questionIndex]
        
        if let text = question["text"] as? String {
            questionLabel.text = text
        }
        
        if let options = question["answers"] as? [String] {
            answers = options
        }
        answersTable.delegate = self
        answersTable.dataSource = self
        answersTable.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.questionIndex = 0
        self.score = 0
        
        self.question = quiz[questionIndex]
        
        if let text = question["text"] as? String {
            questionLabel.text = text
        }
        
        if let options = question["answers"] as? [String] {
            answers = options
        }
        answersTable.delegate = self
        answersTable.dataSource = self
        answersTable.allowsMultipleSelection = false
    }
    
    
    @IBAction func submitQuestion(_ sender: Any) {
        if selectedAnswers == nil {
            let alert = UIAlertController(title: "answer", message: "you need to select an answer", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        } else {
            questionStackView.isHidden = true
            answerStackView.isHidden = false
            
            if let answer = question["answer"] as? String {
                let toInt = Int(answer)
                if toInt!-1 == selectedAnswers {
                    answerLabel.text = "Yay you got it correct. The answer is \(answers[toInt!-1])."
                    answerLabel.textColor = UIColor.systemGreen
                    score += 1
                } else {
                    answerLabel.text = "You got the question wrong. The answer is \(answers[toInt!])."
                    answerLabel.textColor = UIColor.systemRed
                }
            }
        }
    }
    
    @IBAction func goNext(_ sender: Any) {
        // go to next question and if not go to final screen
        questionIndex += 1
        
        if questionIndex < quiz.count {
            self.question = quiz[questionIndex]
            if let text = question["text"] as? String {
                questionLabel.text = text
            }
            
            if let options = question["answers"] as? [String] {
                answers = options
            }
            selectedAnswers = nil
            answersTable.reloadData()
            questionStackView.isHidden = false
            answerStackView.isHidden = true
        } else {
            questionStackView.isHidden = true
            answerStackView.isHidden = true
            finalStackView.isHidden = false
            
            questionLabel.isHidden = true
            
            let totalScore = Double(score) / Double(quiz.count)
            
            if totalScore == 1.0 {
                finalLabel.text = "Perfect! "
            } else if totalScore > 0.75 {
                finalLabel.text = "Almost there. "
            } else if totalScore > 0.50 {
                finalLabel.text = "Need more practice. "
            } else {
                finalLabel.text = "Terrible performance. "
            }
            
            finalLabel.text! += "You got a score of \(score) / \(quiz.count)"

        }
    }
    
    @IBAction func finalGoNext(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        cell.textLabel?.text = answers[indexPath.row]
        
        if indexPath.row == selectedAnswers {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAnswers = indexPath.row
        tableView.reloadData()
    }
    
}
