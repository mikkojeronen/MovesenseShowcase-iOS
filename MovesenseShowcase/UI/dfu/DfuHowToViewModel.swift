//
// DfuHowToViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation

class DfuHowToViewModel {

    let steps: [(text: String, image: String?)]

    init() {
        self.steps =
        [(text: NSLocalizedString("DFU_HOWTO_STEP_1", comment: ""), image: "image_dfu_howto_step_1"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_2", comment: ""), image: "image_dfu_howto_step_2"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_3", comment: ""), image: "image_dfu_howto_step_3"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_4", comment: ""), image: "image_dfu_howto_step_4"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_5", comment: ""), image: "image_dfu_howto_step_5"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_6", comment: ""), image: "image_dfu_howto_step_6"),
         (text: NSLocalizedString("DFU_HOWTO_STEP_7", comment: ""), image: nil)]
    }
}
