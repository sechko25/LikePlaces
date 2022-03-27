//
//  MainViewController.swift
//  MyPlaces
//
//  Created by secha on 15.11.21.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var places: Results<Place>!
    private var ascendinSorting = true
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filterPlaces: Results<Place>!  // колекция для найденных данных
    private var searchBarIsEmpty: Bool {  // проверка строки на пустоту
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {  // возвращает true если поисковая строка активна и не пуста
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        // Setuo the search controller
        searchController.searchResultsUpdater = self  // получатель инфы наш класс
        searchController.obscuresBackgroundDuringPresentation = false  // для взаимодеййствия с объектом
        searchController.searchBar.placeholder = "Search"  // названия для строки поиска
        navigationItem.searchController = searchController  // строка поиска в navigationBar
        definesPresentationContext = true  // отпускаем строку поиска при переходе на другой экран
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filterPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filterPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / CGFloat(2)
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: Table view delegete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    // MARK: - Navigation нажатие на ячейку
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering {
                place = filterPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    @IBAction func  unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func reversSorting(_ sender: Any) {
        
        ascendinSorting.toggle()
        
        if ascendinSorting {
            reversedSortingButton.image = UIImage(systemName: "arrow.down")
        } else {
            reversedSortingButton.image = UIImage(systemName: "arrow.up")
        }
        
        sorting()
    }
    
    private func sorting() {
        
        if isFiltering {
            if segmentedControl.selectedSegmentIndex == 0 {
                filterPlaces = filterPlaces.sorted(byKeyPath: "date", ascending: ascendinSorting)
            } else {
                filterPlaces = filterPlaces.sorted(byKeyPath: "name", ascending: ascendinSorting)
            }
        } else {
            if segmentedControl.selectedSegmentIndex == 0 {
                places = places.sorted(byKeyPath: "date", ascending: ascendinSorting)
            } else {
                places = places.sorted(byKeyPath: "name", ascending: ascendinSorting)
            }
        }
        
        tableView.reloadData()
    }
    
}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    // метод поиска по полю имя и локация в не зависимости от регистра
    private func filterContentForSearchText(_ searchText: String) {

        filterPlaces = places.filter("name CONTAINS[c] %@", searchText)

        tableView.reloadData()
    }
}
