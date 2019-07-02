
import Foundation

let API_KEY = "76b366dd0d1cf17433f6ec86400dc707"

func flickrUrl(forApiKey ket: String, withAnnotation annotation: DroppablePin, addNumberOfPhotos number: Int) -> String {
    let url =  "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}
