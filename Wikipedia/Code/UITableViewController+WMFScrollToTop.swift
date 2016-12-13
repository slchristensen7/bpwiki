extension UITableViewController {
    fileprivate func scrollToFirstIndexPath() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
    }
}

extension UICollectionViewController {
    fileprivate func scrollToFirstIndexPath() {
        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
    }
}

extension WMFArticleListTableViewController {
    func scrollToTop(_ isScrollable: Bool) {
        guard isScrollable else { return }
        scrollToFirstIndexPath()
    }
}

extension WMFExploreViewController {
    func scrollToTop() {
        guard canScrollToTop else { return }
        scrollToFirstIndexPath()
    }
}
