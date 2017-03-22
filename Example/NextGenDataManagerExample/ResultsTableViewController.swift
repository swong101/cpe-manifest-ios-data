//
//  ResultsTableViewController.swift
//  NextGenDataManagerExample
//
//  Created by Alec Ananian on 3/21/17.
//  Copyright © 2017 Warner Bros. All rights reserved.
//

import UIKit
import RETableViewManager
import NextGenDataManager

enum ResultsTableType {
    case files
    case manifest
    case appData
    case cpeStyle
    case experiences

    var title: String {
        switch self {
        case .manifest:     return "Manifest"
        case .appData:      return "AppData"
        case .cpeStyle:     return "CPEStyle"
        case .experiences:  return "Experiences"
        default:            return "XML Suite"
        }
    }
}

class ResultsTableViewController: UITableViewController {

    var type = ResultsTableType.files
    var loadTimeInSeconds: Double = 0

    private var manager: RETableViewManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = type.title
        manager = RETableViewManager(tableView: self.tableView)

        switch type {
        case .manifest:
            showManifestTable()
            break

        case .experiences:
            showExperiencesTable()
            break

        default:
            showFilesTable()
            break
        }
    }

    private func pushResultsTableView(type: ResultsTableType) {
        let manifestResultsTableViewController = ResultsTableViewController(style: .grouped)
        manifestResultsTableViewController.type = type
        self.navigationController?.pushViewController(manifestResultsTableViewController, animated: true)
    }

    private func showFilesTable() {
        if let section = RETableViewSection(headerTitle: CPEXMLSuite.current?.manifest.mainExperience.title, footerTitle: "Total load time: \(String(format: "%.3f", loadTimeInSeconds))s") {
            manager.addSection(section)

            if let cpeXMLSuite = CPEXMLSuite.current {
                addItem(section: section, title: "Manifest", hasChildren: true, selectionHandler: { [weak self] in
                    self?.pushResultsTableView(type: .manifest)
                })

                addItem(section: section, title: "AppData", hasChildren: cpeXMLSuite.hasAppData, selectionHandler: {
                    if cpeXMLSuite.hasAppData {

                    }
                })

                addItem(section: section, title: "CPEStyle", hasChildren: cpeXMLSuite.hasCPEStyle, selectionHandler: {
                    if cpeXMLSuite.hasCPEStyle {

                    }
                })
            }
        }
    }

    private func showManifestTable() {
        let section = RETableViewSection()
        manager.addSection(section)

        if let manifest = CPEXMLSuite.current?.manifest {
            let numAudio = (manifest.audios?.count ?? 0)
            let numVideos = (manifest.videos?.count ?? 0)
            let numImages = (manifest.images?.count ?? 0)
            let numInteractives = (manifest.interactives?.count ?? 0)
            let numMetadatas = (manifest.metadatas?.count ?? 0)
            let numTextObjects = (manifest.textObjects?.count ?? 0)
            let numTextGroups = (manifest.textGroups?.count ?? 0)
            let numPresentations = manifest.presentations.count
            let numPlayableSequences = (manifest.playableSequences?.count ?? 0)
            let numPictures = (manifest.pictures?.count ?? 0)
            let numPictureGroups = (manifest.pictureGroups?.count ?? 0)
            let numGalleries = (manifest.galleries?.count ?? 0)
            let numAppGroups = (manifest.appGroups?.count ?? 0)
            let numExperienceApps = (manifest.experienceApps?.count ?? 0)
            let numExperiences = manifest.experiences.count
            let numTimedEventSequences = (manifest.timedEventSequences?.count ?? 0)

            addItem(section: section, title: "Audio", hasChildren: (numAudio > 0), numChildren: numAudio, selectionHandler: {

            })

            addItem(section: section, title: "Videos", hasChildren: (numVideos > 0), numChildren: numVideos, selectionHandler: {

            })

            addItem(section: section, title: "Images", hasChildren: (numImages > 0), numChildren: numImages, selectionHandler: {

            })

            addItem(section: section, title: "Interactives", hasChildren: (numInteractives > 0), numChildren: numInteractives, selectionHandler: {

            })

            addItem(section: section, title: "Metadata", hasChildren: (numMetadatas > 0), numChildren: numMetadatas, selectionHandler: {

            })

            addItem(section: section, title: "TextObjects", hasChildren: (numTextObjects > 0), numChildren: numTextObjects, selectionHandler: {

            })

            addItem(section: section, title: "TextGroups", hasChildren: (numTextGroups > 0), numChildren: numTextGroups, selectionHandler: {

            })

            addItem(section: section, title: "Presentations", hasChildren: (numPresentations > 0), numChildren: numPresentations, selectionHandler: {

            })

            addItem(section: section, title: "PlayableSequences", hasChildren: (numPlayableSequences > 0), numChildren: numPlayableSequences, selectionHandler: {

            })

            addItem(section: section, title: "Pictures", hasChildren: (numPictures > 0), numChildren: numPictures, selectionHandler: {

            })

            addItem(section: section, title: "PictureGroups", hasChildren: (numPictureGroups > 0), numChildren: numPictureGroups, selectionHandler: {

            })

            addItem(section: section, title: "Galleries", hasChildren: (numGalleries > 0), numChildren: numGalleries, selectionHandler: {

            })

            addItem(section: section, title: "AppGroups", hasChildren: (numAppGroups > 0), numChildren: numAppGroups, selectionHandler: {

            })

            addItem(section: section, title: "Experience Apps", hasChildren: (numExperienceApps > 0), numChildren: numExperienceApps, selectionHandler: {

            })

            addItem(section: section, title: "Experiences", hasChildren: (numExperiences > 0), numChildren: numExperiences, selectionHandler: { [weak self] in
                self?.pushResultsTableView(type: .experiences)
            })

            addItem(section: section, title: "TimedEventSequences", hasChildren: (numTimedEventSequences > 0), numChildren: numTimedEventSequences, selectionHandler: {

            })
        }
    }

    private func showExperiencesTable() {
        let section = RETableViewSection()
        manager.addSection(section)

        if let manifest = CPEXMLSuite.current?.manifest {
            addItem(section: section, title: "Main Experience", hasChildren: true)
            addItem(section: section, title: "In-Movie Experience", hasChildren: true, numChildren: manifest.inMovieExperience.numChildExperiences)
            addItem(section: section, title: "Out-of-Movie Experience", hasChildren: true, numChildren: manifest.outOfMovieExperience.numChildExperiences)
        }
    }

    private func addItem(section: RETableViewSection, title: String, hasChildren: Bool = false, numChildren: Int? = nil, detailText: String? = nil, selectionHandler: (() -> Void)? = nil) {
        let item = RETableViewItem(title: title, accessoryType: (hasChildren ? .disclosureIndicator : .none), selectionHandler: { (item) in
            item?.deselectRow(animated: true)
            selectionHandler?()
        })

        item!.style = .value1

        if !hasChildren {
            item!.selectionStyle = .none
        }

        if let detailText = detailText {
            item!.detailLabelText = detailText
        } else if let numChildren = numChildren {
            item!.detailLabelText = (numChildren > 0 ? String(numChildren) : "None")
        } else if !hasChildren {
            item!.detailLabelText = "None"
        }

        section.addItem(item)
    }

}
