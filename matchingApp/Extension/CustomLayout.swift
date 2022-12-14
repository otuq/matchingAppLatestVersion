//
//  CustomLayout.swift
//  test
//
//  Created by USER on 2022/02/08.
//

import UIKit

protocol CustomDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, contentWidth: CGFloat) -> CGFloat
}
class CustomLayout: UICollectionViewLayout {
    // MARK: Properties
    weak var delegate: CustomDelegate!
    private var numberOfColumns = 2
    private var columPadding: CGFloat = 10
    private var attributeArray = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width
    }
    // MARK: - LifeCycle Methods
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    // cellの配置や大きさを計算して保持する
    override func prepare() {
        // 更新の際データが残っているとレイアウトとかに影響が出るから中身を空にする。
        attributeArray.removeAll()
        guard attributeArray.isEmpty, let collectionView = collectionView else { return }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        // cellのx座標
        var xOffset = [CGFloat]()
        // column分のoffsetを作る
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var colum = 0
        // cellのy座標
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let cellHeight = delegate.collectionView(collectionView, heightForItemAt: indexPath, contentWidth: columnWidth - columPadding * 2)
            // 上下のpaddingを計算にいれた高さ
            let height = columPadding * 2 + cellHeight
            let frame = CGRect(x: xOffset[colum], y: yOffset[colum], width: columnWidth, height: height)
            // cellにpaddingを設定
            let insetFrame = frame.insetBy(dx: columPadding, dy: columPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            attributeArray.append(attributes)
            contentHeight = frame.maxY
            // 次のcellのy座標
            yOffset[colum] = yOffset[colum] + height
            colum = colum < (numberOfColumns - 1) ? (colum + 1) : 0
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in attributeArray {
            attributes.frame.intersects(rect)
            visibleLayoutAttributes.append(attributes)
        }
        return visibleLayoutAttributes
    }
}
