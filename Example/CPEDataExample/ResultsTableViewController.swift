//
//  ResultsTableViewController.swift
//  CPEDataExample
//
//  Created by Alec Ananian on 3/21/17.
//  Copyright © 2017 Warner Bros. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SafariServices
import RETableViewManager
import CPEData

enum ResultsTableType {
    case files
    case manifest
    case appData
    case cpeStyle
    case experiences
    case experience
    case mainExperience
    case gallery
    case videos

    var title: String? {
        switch self {
        case .files:                return "XML Suite"
        case .manifest:             return "Manifest"
        case .appData:              return "AppData"
        case .cpeStyle:             return "CPEStyle"
        case .experiences:          return "Experiences"
        case .mainExperience:       return "Main Experience"
        case .videos:               return "Videos"
        default:                    return nil
        }
    }
}

class ResultsTableViewController: UITableViewController {

    var type = ResultsTableType.files
    var loadTimeInSeconds: Double = 0
    var experience: Experience?
    var gallery: Gallery?

    private var manager: RETableViewManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let title = type.title {
            self.title = title
        }

        manager = RETableViewManager(tableView: self.tableView)

        switch type {
        case .manifest:
            addTable(manifest: CPEXMLSuite.current!.manifest)
            break

        case .appData:
            addTable(appData: CPEXMLSuite.current!.appData!)
            break

        case .cpeStyle:
            addTable(cpeStyle: CPEXMLSuite.current!.cpeStyle!)
            break

        case .experiences:
            showExperiencesTable()
            break

        case .mainExperience:
            showMainExperienceTable()
            break

        case .experience:
            if let experience = experience {
                addTable(experience: experience)
            }
            break

        case .gallery:
            if let gallery = gallery {
                addTable(gallery: gallery)
            }
            break

        case .videos:
            if let videos = CPEXMLSuite.current!.manifest.videos {
                videos.forEach({ addSection(video: $1) })
            }
            break

        default:
            showFilesTable()
            break
        }
    }

    private func pushResultsTableView(type: ResultsTableType, experience: Experience? = nil, gallery: Gallery? = nil) {
        let manifestResultsTableViewController = ResultsTableViewController(style: .grouped)
        manifestResultsTableViewController.type = type
        manifestResultsTableViewController.experience = experience
        manifestResultsTableViewController.gallery = gallery
        manifestResultsTableViewController.title = (experience?.title ?? gallery?.title)
        self.navigationController?.pushViewController(manifestResultsTableViewController, animated: true)
    }

    private func presentAVAsset(url: URL, title: String? = nil) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.title = title
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    private func presentImage(url: URL) {
        if #available(iOS 9.0, *) {
            self.present(SFSafariViewController(url: url), animated: true)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    private func showFilesTable() {
        if let section = RETableViewSection(headerTitle: CPEXMLSuite.current?.manifest.mainExperience.title, footerTitle: "Total load time: \(String(format: "%.3f", loadTimeInSeconds))s") {
            manager.addSection(section)

            if let cpeXMLSuite = CPEXMLSuite.current {
                addItem(section: section, title: "Manifest", hasChildren: true) { [weak self] in
                    self?.pushResultsTableView(type: .manifest)
                }

                addItem(section: section, title: "AppData", hasChildren: cpeXMLSuite.hasAppData) { [weak self] in
                    if cpeXMLSuite.hasAppData {
                        self?.pushResultsTableView(type: .appData)
                    }
                }

                addItem(section: section, title: "CPEStyle", hasChildren: cpeXMLSuite.hasCPEStyle) { [weak self] in
                    if cpeXMLSuite.hasCPEStyle {
                        self?.pushResultsTableView(type: .cpeStyle)
                    }
                }
            }
        }
    }

    private func addTable(manifest: MediaManifest) {
        if let section = RETableViewSection(headerTitle: "Experiences") {
            manager.addSection(section)

            addItem(section: section, title: "Main Experience", hasChildren: true) { [weak self] in
                self?.pushResultsTableView(type: .mainExperience)
            }

            addItem(section: section, title: "In-Movie Experience", hasChildren: true, numChildren: manifest.inMovieExperience.numChildExperiences) { [weak self] in
                self?.pushResultsTableView(type: .experience, experience: manifest.inMovieExperience)
            }

            addItem(section: section, title: "Out-of-Movie Experience", hasChildren: true, numChildren: manifest.outOfMovieExperience.numChildExperiences) { [weak self] in
                self?.pushResultsTableView(type: .experience, experience: manifest.outOfMovieExperience)
            }
        }

        if let section = RETableViewSection(headerTitle: "Inventory") {
            manager.addSection(section)

            let numAudio = (manifest.audios?.count ?? 0)
            let numVideos = (manifest.videos?.count ?? 0)
            let numImages = (manifest.images?.count ?? 0)
            let numInteractives = (manifest.interactives?.count ?? 0)
            let numMetadatas = (manifest.metadatas?.count ?? 0)
            let numTextObjects = (manifest.textObjects?.count ?? 0)
            let numTextGroups = (manifest.textGroups?.count ?? 0)
            let numPresentations = manifest.presentations.count
            let numPlayableSequences = (manifest.playableSequences?.count ?? 0)
            let numPictureGroups = (manifest.pictureGroups?.count ?? 0)
            let numAppGroups = (manifest.appGroups?.count ?? 0)

            addItem(section: section, title: "Audio", hasChildren: (numAudio > 0), numChildren: numAudio) {

            }

            addItem(section: section, title: "Videos", hasChildren: (numVideos > 0), numChildren: numVideos) { [weak self] in
                self?.pushResultsTableView(type: .videos)
            }

            addItem(section: section, title: "Images", hasChildren: (numImages > 0), numChildren: numImages) {

            }

            addItem(section: section, title: "Interactives", hasChildren: (numInteractives > 0), numChildren: numInteractives) {

            }

            addItem(section: section, title: "Metadata", hasChildren: (numMetadatas > 0), numChildren: numMetadatas) {

            }

            addItem(section: section, title: "TextObjects", hasChildren: (numTextObjects > 0), numChildren: numTextObjects) {

            }

            addItem(section: section, title: "TextGroups", hasChildren: (numTextGroups > 0), numChildren: numTextGroups) {

            }

            addItem(section: section, title: "Presentations", hasChildren: (numPresentations > 0), numChildren: numPresentations) {

            }

            addItem(section: section, title: "PlayableSequences", hasChildren: (numPlayableSequences > 0), numChildren: numPlayableSequences) {

            }

            addItem(section: section, title: "PictureGroups", hasChildren: (numPictureGroups > 0), numChildren: numPictureGroups) {

            }

            addItem(section: section, title: "AppGroups", hasChildren: (numAppGroups > 0), numChildren: numAppGroups) {

            }
        }
    }

    private func showExperiencesTable() {
        let section = RETableViewSection()
        manager.addSection(section)

        if let manifest = CPEXMLSuite.current?.manifest {
            addItem(section: section, title: "Main Experience", hasChildren: true) { [weak self] in
                self?.pushResultsTableView(type: .mainExperience)
            }

            addItem(section: section, title: "In-Movie Experience", hasChildren: true, numChildren: manifest.inMovieExperience.numChildExperiences) { [weak self] in
                self?.pushResultsTableView(type: .experience, experience: manifest.inMovieExperience)
            }

            addItem(section: section, title: "Out-of-Movie Experience", hasChildren: true, numChildren: manifest.outOfMovieExperience.numChildExperiences) { [weak self] in
                self?.pushResultsTableView(type: .experience, experience: manifest.outOfMovieExperience)
            }
        }
    }

    private func showMainExperienceTable() {

    }

    private func addTable(experience: Experience) {
        addImageSection(imageURL: experience.thumbnailImageURL)

        if let timedEvents = experience.timedEventSequence?.timedEvents, let section = RETableViewSection(headerTitle: "Timed Events") {
            manager.addSection(section)

            addItem(section: section, title: "Total Timed Events", detailText: String(timedEvents.count))

            for timedEvent in timedEvents {
                addItem(section: section, title: "\(timedEvent.startTime.formattedTimecode) -> \(timedEvent.endTime.formattedTimecode)", hasChildren: true, detailText: timedEvent.description) { [weak self] in
                    if timedEvent.isType(.video), let videoURL = timedEvent.audioVisual?.presentation?.videoURL {
                        self?.presentAVAsset(url: videoURL, title: timedEvent.description)
                    } else if timedEvent.isType(.gallery) {
                        self?.pushResultsTableView(type: .gallery, gallery: timedEvent.gallery)
                    }
                }
            }
        } else if let section = RETableViewSection(headerTitle: "Child Experiences") {
            manager.addSection(section)

            if let childExperiences = experience.childExperiences {
                for childExperience in childExperiences {
                    addItem(section: section, title: childExperience.title, hasChildren: true) { [weak self] in
                        if childExperience.isType(.gallery) {
                            self?.pushResultsTableView(type: .gallery, gallery: childExperience.gallery)
                        } else {
                            self?.pushResultsTableView(type: .experience, experience: childExperience)
                        }
                    }
                }
            }
        }
    }

    private func addTable(gallery: Gallery) {
        addImageSection(imageURL: gallery.thumbnailImageURL)

        if let section = RETableViewSection(headerTitle: "Gallery Details") {
            manager.addSection(section)

            if let url = gallery.thumbnailImageURL {
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    if let data = data {
                        DispatchQueue.main.async {
                            (section.headerView as? UIImageView)?.image = UIImage(data: data)
                            section.reload(with: .none)
                        }
                    }
                }.resume()
            }

            addItem(section: section, title: "Name", detailText: gallery.title)
            addItem(section: section, title: "Total Images", detailText: String(gallery.numPictures))
            addItem(section: section, title: "Turntable?", detailText: (gallery.isTurntable ? "Yes" : "No"))
        }
    }

    private func addTable(appData: AppDataSet) {
        let section = RETableViewSection()
        manager.addSection(section)

        let numLocations = (appData.locations?.count ?? 0)
        let numProducts = (appData.products?.count ?? 0)
        let numPeople = (appData.people?.count ?? 0)

        addItem(section: section, title: "Locations", hasChildren: (numLocations > 0), numChildren: numLocations) {

        }

        addItem(section: section, title: "Products", hasChildren: (numProducts > 0), numChildren: numProducts) {

        }

        addItem(section: section, title: "People", hasChildren: (numPeople > 0), numChildren: numPeople) {

        }
    }

    private func addTable(cpeStyle: CPEStyleSet) {
        cpeStyle.nodeStyles.forEach({ addSection(nodeStyle: $1) })
    }

    private func addSection(video: Video) {
        if let section = RETableViewSection(headerTitle: "Video (\(video.id))") {
            manager.addSection(section)

            addItem(section: section, title: "Type", detailText: video.type.rawValue)
            if let codec = video.encoding?.codec {
                addItem(section: section, title: "Codec", detailText: codec.rawValue)
            }

            if let size = video.size {
                addItem(section: section, title: "Size", detailText: "\(size.width) x \(size.height)")
            }

            addItem(section: section, title: "Runtime", detailText: "\(String(video.runtimeInSeconds)) sec")

            if let url = video.url {
                addItem(section: section, title: "Watch", hasChildren: true) { [weak self] in
                    self?.presentAVAsset(url: url, title: video.id)
                }
            }
        }
    }

    private func addSection(nodeStyle: NodeStyle) {
        if let section = RETableViewSection(headerTitle: "Node Style (\(nodeStyle.id))") {
            manager.addSection(section)

            addItem(section: section, title: "Supports Landscape?", detailText: (nodeStyle.supportsLandscape ? "Yes" : "No"))
            addItem(section: section, title: "Supports Portrait?", detailText: (nodeStyle.supportsPortrait ? "Yes" : "No"))
            addItem(section: section, title: "Supports Tablet?", detailText: (nodeStyle.supportsTablet ? "Yes" : "No"))
            addItem(section: section, title: "Supports Phone?", detailText: (nodeStyle.supportsPhone ? "Yes" : "No"))

            let backgroundColorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            backgroundColorView.backgroundColor = nodeStyle.backgroundColor
            addItem(section: section, title: "Background Color", accessoryView: backgroundColorView)
            addItem(section: section, title: "Background Scale Method", detailText: nodeStyle.backgroundScaleMethod.rawValue)
            addItem(section: section, title: "Background Positioning Method", detailText: nodeStyle.backgroundPositioningMethod.rawValue)

            addItem(section: section, title: "Background Image", hasChildren: (nodeStyle.backgroundImage != nil)) { [weak self] in
                if let url = nodeStyle.backgroundImage?.url {
                    self?.presentImage(url: url)
                }
            }

            addItem(section: section, title: "Background Video", hasChildren: (nodeStyle.backgroundPresentation != nil)) { [weak self] in
                if let url = nodeStyle.backgroundPresentation?.videoURL {
                    self?.presentAVAsset(url: url)
                }
            }

            addItem(section: section, title: "Background Video Loops?", detailText: (nodeStyle.backgroundVideoLoops ? "Yes (\(nodeStyle.backgroundVideoLoopTimecode) sec)" : "No"))

            addItem(section: section, title: "Background Audio", hasChildren: (nodeStyle.backgroundAudio != nil)) { [weak self] in
                if let url = nodeStyle.backgroundAudio?.url {
                    self?.presentAVAsset(url: url)
                }
            }
        }
    }

    private func addImageSection(imageURL: URL?) {
        if let imageURL = imageURL {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
            imageView.backgroundColor = UIColor.black
            imageView.contentMode = .scaleAspectFit

            if let section = RETableViewSection(headerView: imageView) {
                manager.addSection(section)

                URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
                    if let data = data {
                        DispatchQueue.main.async {
                            (section.headerView as? UIImageView)?.image = UIImage(data: data)
                            section.reload(with: .none)
                        }
                    }
                }.resume()
            }
        }
    }

    private func addItem(section: RETableViewSection, title: String, hasChildren: Bool = false, numChildren: Int? = nil, accessoryView: UIView? = nil, detailText: String? = nil, selectionHandler: (() -> Void)? = nil) {
        let item = RETableViewItem(title: title, accessoryType: (hasChildren ? .disclosureIndicator : .none), selectionHandler: { (item) in
            item?.deselectRow(animated: true)
            selectionHandler?()
        })

        item!.style = .value1

        if !hasChildren {
            item!.selectionStyle = .none
        }

        if let accessoryView = accessoryView {
            item!.accessoryView = accessoryView
        } else if let detailText = detailText {
            item!.detailLabelText = detailText
        } else if let numChildren = numChildren {
            item!.detailLabelText = (numChildren > 0 ? String(numChildren) : "None")
        } else if !hasChildren {
            item!.detailLabelText = "None"
        }

        section.addItem(item)
    }

}
