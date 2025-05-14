//
//  ViewController.swift
//  iQuiz
//
//  Created by Munir Emam on 5/5/25.
//

import UIKit

class iQuizTableViewCell: UITableViewCell {
    @IBOutlet weak var quizImage: UIImageView!
    
    @IBOutlet weak var quizName: UILabel!
    
    @IBOutlet weak var quizDescription: UILabel!
    
}


class ViewController: UIViewController, UITableViewDelegate {
    
    @IBAction func settingsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    @IBOutlet weak var quizTable: UITableView!

    let quizTableData = iQuizTableDataModel([
        ["Mathematics", "math related questions", "math.png"],
        ["Science", "questions related to sciences", "science.png"],
        ["Marvel", "questions covering Marvel superheroes", "marvel.png"]
    ])
    
    let questionData: [String: [[String: Any]]] = [
        "Mathematics": [
            ["question": "What is 5 x 5?", "answers": ["20", "25", "15", "95"], "answer": 1],
            ["question": "What is 12 + 8?", "answers": ["18", "22", "20", "24"], "answer": 2],
            ["question": "What is 100 / 10?", "answers": ["1", "10", "100", "0"], "answer": 1]
        ],
        "Science": [
            ["question": "What is the chemical symbol for gold?", "answers": ["Ag", "Au", "He", "Go"], "answer": 1],
            ["question": "What is H2O commonly known as?", "answers": ["Salt", "Air", "Water", "Sugar"], "answer": 2],
            ["question": "Which planet is known as the Red Planet?", "answers": ["Earth", "Mars", "Jupiter", "Venus"], "answer": 1]
        ],
        "Marvel": [
            ["question": "What is Spiderman's real name?", "answers": ["Tony Stark", "Bruce Banner", "Peter Parker", "Steve Rogers"], "answer": 2],
            ["question": "What is Captain America's shield made of?", "answers": ["Adamantium", "Vibranium", "Promethium", "Steel"], "answer": 1],
            ["question": "Who is the God of Thunder?", "answers": ["Loki", "Odin", "Heimdall", "Thor"], "answer": 3]
        ]
    ]
    
    class iQuizTableDataModel : NSObject, UITableViewDataSource {
        
        let data: [[String]]
        init(_ items: [[String]]) {
            data = items
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "iQuizTableViewCell")! as! iQuizTableViewCell
            cell.quizName?.text = data[indexPath.row][0]
            cell.quizDescription?.text = data[indexPath.row][1]
            cell.quizImage?.image = UIImage(named: data[indexPath.row][2])
            
            return cell
        }
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        quizTable.dataSource = quizTableData
        quizTable.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quizName = quizTableData.data[indexPath.row][0]
        performSegue(withIdentifier: "quizSegue", sender: quizName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quizSegue" {
            if let destinationVC = segue.destination as? QuizViewController {
                if sender is String {
                    segue.destination.modalPresentationStyle = .fullScreen
                    
                    if let questionsCategory = questionData[sender as! String] {
                        destinationVC.quiz = questionsCategory
                    }
                }
            }
        }
    }
        
}

