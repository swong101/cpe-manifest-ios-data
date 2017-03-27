//
//  ManifestUtils.swift
//  NextGenDataManagerExample
//
//  Created by Alec Ananian on 3/23/17.
//  Copyright © 2017 Warner Bros. All rights reserved.
//

import Foundation

extension Double {

    var formattedTimecode: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}
