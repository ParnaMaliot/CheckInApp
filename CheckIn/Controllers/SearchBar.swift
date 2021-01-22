//
//  SearchBar.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 18.1.21.
//

import UIKit

class SearchBar: UICollectionReusableView, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     
        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBar", for: indexPath)
        return searchView
    }
     
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        self.data.removeAll()
//             
//        for item in self.realData {
//            if (item.firstName.lowercased().contains(searchBar.text!.lowercased())) {
//                self.data.append(item)
//            }
//        }
//             
//        if (searchBar.text!.isEmpty) {
//            self.data = self.realData
//        }
//        self.collectionView.reloadData()
//    }
}
