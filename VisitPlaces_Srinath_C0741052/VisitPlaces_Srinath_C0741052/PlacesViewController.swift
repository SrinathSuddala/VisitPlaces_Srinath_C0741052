import UIKit

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var places = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Places"
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        addPlaces()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
    }
    
    func addPlaces() {
        guard let placeList =  UserDefaults.standard.value(forKey: "places") else {
            let staticPlaces = [["name": "Alberta" , "lat": 52.268112, "long": -113.0],
                          ["name": "Vancover" , "lat": 55.000000, "long": -115.000000],
                          ["name": "British Columbia" , "lat": 53.7267, "long": -127.6476],
                          ["name": "Montreal" , "lat": 45.5017, "long": -73.5673],
                          ["name": "Quebec" , "lat": 46.8139, "long": -71.2080]
            ]
            UserDefaults.standard.set(staticPlaces, forKey: "places")
            UserDefaults.standard.synchronize()
            self.places = staticPlaces
            tableView.reloadData()
            return
            
        }
        self.places = placeList as! [[String : Any]]
        tableView.reloadData()
    }
    
    @objc func addTapped() {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = places[indexPath.row]["name"] as? String
        cell.selectionStyle = .none
        return cell
    }

}

