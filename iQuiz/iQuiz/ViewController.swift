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


}

