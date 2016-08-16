//
//  FeedAnyImagesCell.swift
//  Yep
//
//  Created by nixzhu on 15/9/30.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import UIKit
import YepKit
import AsyncDisplayKit

class FeedImageCellNode: ASCellNode {

    lazy var imageNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .ScaleAspectFill
        node.borderWidth = 1
        node.borderColor = UIColor.yepBorderColor().CGColor
        return node
    }()

    override init() {
        super.init()

        addSubnode(imageNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {

        return YepConfig.FeedNormalImagesCell.imageSize
    }

    override func layout() {
        super.layout()

        imageNode.frame = CGRect(origin: CGPointZero, size: YepConfig.FeedNormalImagesCell.imageSize)
    }

    func configureWithAttachment(attachment: DiscoveredAttachment, bigger: Bool) {

        if attachment.isTemporary {
            imageNode.image = attachment.image

        } else {
            let size = bigger ? YepConfig.FeedBiggerImageCell.imageSize : YepConfig.FeedNormalImagesCell.imageSize

            imageNode.yep_showActivityIndicatorWhenLoading = true
            imageNode.yep_setImageOfAttachment(attachment, withSize: size)
        }
    }
}

private let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width

typealias FeedTapMediaAction = (transitionView: UIView, image: UIImage?, attachments: [DiscoveredAttachment], index: Int) -> Void

typealias FeedTapImagesAction = (transitionViews: [UIView?], attachments: [DiscoveredAttachment], image: UIImage?, index: Int) -> Void

final class FeedAnyImagesCell: FeedBasicCell {

    override class func heightOfFeed(feed: DiscoveredFeed) -> CGFloat {

        let height = super.heightOfFeed(feed) + YepConfig.FeedNormalImagesCell.imageSize.height + 15
        return ceil(height)
    }

    lazy var mediaCollectionNode: ASCollectionNode = {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Horizontal
        layout.itemSize = YepConfig.FeedNormalImagesCell.imageSize

        let node = ASCollectionNode(collectionViewLayout: layout)

        node.view.scrollsToTop = false
        node.view.contentInset = UIEdgeInsets(top: 0, left: 15 + 40 + 10, bottom: 0, right: 15)
        node.view.showsHorizontalScrollIndicator = false
        node.view.backgroundColor = UIColor.clearColor()

        node.dataSource = self
        node.delegate = self

        return node
    }()

    /*
    lazy var mediaCollectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Horizontal

        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15 + 40 + 10, bottom: 0, right: 15)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()

        collectionView.registerNibOf(FeedMediaCell)

        collectionView.dataSource = self
        collectionView.delegate = self

        let backgroundView = TouchClosuresView(frame: collectionView.bounds)
        backgroundView.touchesBeganAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesBeganAction?(strongSelf)
            }
        }
        backgroundView.touchesEndedAction = { [weak self] in
            if let strongSelf = self {
                if strongSelf.editing {
                    return
                }
                strongSelf.touchesEndedAction?(strongSelf)
            }
        }
        backgroundView.touchesCancelledAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesCancelledAction?(strongSelf)
            }
        }
        collectionView.backgroundView = backgroundView

        return collectionView
    }()
     */

    var tapImagesAction: FeedTapImagesAction?

    var attachments = [DiscoveredAttachment]() {
        didSet {
            //mediaCollectionView.reloadData()
            mediaCollectionNode.reloadData()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //contentView.addSubview(mediaCollectionView)
        contentView.addSubview(mediaCollectionNode.view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        attachments = []
    }

    override func configureWithFeed(feed: DiscoveredFeed, layout: FeedCellLayout, needShowSkill: Bool) {

        super.configureWithFeed(feed, layout: layout, needShowSkill: needShowSkill)

        if let attachment = feed.attachment, case let .Images(attachments) = attachment {
            self.attachments = attachments
        }

        let anyImagesLayout = layout.anyImagesLayout!
        //mediaCollectionView.frame = anyImagesLayout.mediaCollectionViewFrame
        mediaCollectionNode.frame = anyImagesLayout.mediaCollectionViewFrame
    }
}

extension FeedAnyImagesCell: ASCollectionDataSource, ASCollectionDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {

        let node = FeedImageCellNode()
        if let attachment = attachments[safe: indexPath.item] {
            node.configureWithAttachment(attachment, bigger: (attachments.count == 1))
        }
        return node
    }

    func collectionView(collectionView: ASCollectionView, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> ASSizeRange {

        let size = YepConfig.FeedNormalImagesCell.imageSize
        return ASSizeRange(min: size, max: size)
    }
}

/*
extension FeedAnyImagesCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell: FeedMediaCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        if let attachment = attachments[safe: indexPath.item] {
            cell.configureWithAttachment(attachment, bigger: (attachments.count == 1))
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {

        return YepConfig.FeedNormalImagesCell.imageSize
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let firstAttachment = attachments.first where !firstAttachment.isTemporary else {
            return
        }

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FeedMediaCell

        let transitionViews: [UIView?] = (0..<attachments.count).map({
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: $0, inSection: indexPath.section)) as? FeedMediaCell
            return cell?.imageView
        })
        tapImagesAction?(transitionViews: transitionViews, attachments: attachments, image: cell.imageView.image, index: indexPath.item)
    }
}
*/
