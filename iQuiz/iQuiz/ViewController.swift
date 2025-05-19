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
//            if let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewControllerID") {
//                present(settingVC, animated: true, completion: nil)
//            }
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        @IBOutlet weak var quizTable: UITableView!

        var quizTableData: iQuizTableDataModel! = iQuizTableDataModel([])
        
        var questionData: [String: [[String: Any]]] = [:]
        
//        let questionData: [String: [[String: Any]]] = [
//            "Mathematics": [
//                ["question": "What is 5 x 5?", "answers": ["20", "25", "15", "95"], "answer": 1],
//                ["question": "What is 12 + 8?", "answers": ["18", "22", "20", "24"], "answer": 2],
//                ["question": "What is 100 / 10?", "answers": ["1", "10", "100", "0"], "answer": 1]
//            ],
//            "Science": [
//                ["question": "What is the chemical symbol for gold?", "answers": ["Ag", "Au", "He", "Go"], "answer": 1],
//                ["question": "What is H2O commonly known as?", "answers": ["Salt", "Air", "Water", "Sugar"], "answer": 2],
//                ["question": "Which planet is known as the Red Planet?", "answers": ["Earth", "Mars", "Jupiter", "Venus"], "answer": 1]
//            ],
//            "Marvel": [
//                ["question": "What is Spiderman's real name?", "answers": ["Tony Stark", "Bruce Banner", "Peter Parker", "Steve Rogers"], "answer": 2],
//                ["question": "What is Captain America's shield made of?", "answers": ["Adamantium", "Vibranium", "Promethium", "Steel"], "answer": 1],
//                ["question": "Who is the God of Thunder?", "answers": ["Loki", "Odin", "Heimdall", "Thor"], "answer": 3]
//            ]
      //  ]
        
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
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadDataIn()
            getData(urlString: UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json")
            
            quizTable.reloadData()
            print("below is the quizTableData")
            print(quizTableData)
            print(questionData)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            quizTable.dataSource = quizTableData
            quizTable.delegate = self
            loadDataIn()
            getData(urlString: UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json")

            quizTable.reloadData()
            print("below is the quizTableData")
            print(quizTableData)
            print(questionData)
        }
        
        func loadDataIn() {
            if let categories = UserDefaults.standard.data(forKey: "categories") {
                if let decodedCategories = try? PropertyListDecoder().decode([[String]].self, from: categories) {
                    self.quizTableData = iQuizTableDataModel(decodedCategories)
                    self.quizTable.dataSource = self.quizTableData
                    
                    print(decodedCategories)
                }
            }
            
            if let questionsData = UserDefaults.standard.data(forKey: "questions") { // Use matching key
                if let questionsPlist = try? PropertyListSerialization.propertyList(from: questionsData, options: [], format: nil),
                   let decodedQuestions = questionsPlist as? [String: [[String: Any]]] {
                    
                    self.questionData = decodedQuestions
                }
            }
        }
        
        func getData(urlString: String) {
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url) {data, response, error in
                
                if let error = error {
                    print("Network request error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                            self.quizTable.reloadData()
                            print("network error")
                        }
                    }
                    let alertController = UIAlertController(title: "Network Error", message: "Check Network Connection", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    if Thread.isMainThread {
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    print("HTTP Error: Invalid response or status code \(statusCode)")
                    return
                }
                
                guard let validData = data else {
                    print("No data received from server.")
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        let quizObject = try JSONSerialization.jsonObject(with: validData, options: .allowFragments)
                        
                        let categoriesArray = self.quizObjectToData(transformData: quizObject as! [[String : Any]])
                        
                        self.quizTableData = iQuizTableDataModel(categoriesArray)
                        
                        self.quizTable.dataSource = self.quizTableData
                        self.quizTable.reloadData()
                        
                        let categoriesData = try PropertyListEncoder().encode(categoriesArray)
                        
                        UserDefaults.standard.set(categoriesData, forKey: "categories")
                        
                        self.questionData = self.quizObjectToTest(transformData: quizObject as! [[String : Any]])
                        
                        print(self.questionData)
                        
                        let questionsData = try PropertyListSerialization.data(
                            fromPropertyList: self.questionData,
                            format: .binary,
                            options: 0
                        )
                        print("should print something")
                        print(questionsData)
                        
                        UserDefaults.standard.set(questionsData, forKey: "questions")
                        
                        print("fetched data")
                    } catch {
                        print("JSON parsing error: \(error)")
                        
                    }
                }
            }.resume()
        }
        
        func quizObjectToData(transformData: [[String: Any]]) -> [[String]] {
            var output: [[String]] = []
            for topicDict in transformData {
                if let title = topicDict["title"] as? String,
                   let desc = topicDict["desc"] as? String {
                    output.append([title, desc, "default_icon.png"])
                }
            }
            return output
        }
        
        func quizObjectToTest(transformData: [[String: Any]]) -> [String: [[String: Any]]] {
            var output: [String: [[String: Any]]] = [:]
            for topic in transformData {
                if let title = topic["title"] as? String,
                   let rest = topic["questions"] as? [[String: Any]] {
                    output[title] = rest
                }
            }
            return output
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

