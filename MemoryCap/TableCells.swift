//
//  CategoryRow.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/12/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import Foundation
import UIKit

class CategoryRow : UITableViewCell {
    var imageKeyArray: [String] = []
    var name: String = ""
}

extension CategoryRow : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageKeyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "capsuleCell", for: indexPath as IndexPath)
        return cell
    }
}

extension CategoryRow : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow:CGFloat = 4
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

class CollectionRow : UICollectionView {
    
}
