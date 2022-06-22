import UIKit

class NewPlaceViewController: UITableViewController {

    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet var ratingControl: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame:  CGRect(x: 0,
                                                          y: 0,
                                                          width: tableView.frame.size.width,
                                                          height: 1))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.choseImagePicker(source: .camera)
            }
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.choseImagePicker(source: .photoLibrary)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(named: "Office")
        }
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
                                   location: placeLocation.text,
                                   type: placeType.text,
                                   imageData: imageData,
                                   rating: ratingControl.rating)
        
        // проверка режима(добавление/редактирование)
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        }else {
                StorageManager.saveObject(newPlace)
        }
    }
    
    // передача значений в ячейки при редактировании
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFit
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = currentPlace.rating
        }
    }
    
    // замена тайтла и кнопки кенсел при редактировании
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: Text Field Delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрывает клавиатуру по нажатию на Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func choseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true  // изменение выбранного фото
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage  // присваеваем отредактированое фото
        placeImage.contentMode = .scaleAspectFit  // маштабирует фото по UIImage
        placeImage.clipsToBounds = true  // обрезка по границам
        
        imageIsChanged = true
        
        dismiss(animated: true)  // закрываем видеоконтроллер
    }
}
