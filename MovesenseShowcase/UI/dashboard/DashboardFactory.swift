//
// DashboardFactory.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardFactory {

    static func createOperationViewModel(name: String,
                                         device: MovesenseDevice,
                                         resource: MovesenseResource) -> DashboardContainerViewModel? {
        switch resource {
        case is MovesenseResourceAcc:
            return DashboardContainerViewModelAcc(name: name, device: device, resource: resource)
        case is MovesenseResourceEcg:
            return DashboardContainerViewModelEcg(name: name, device: device, resource: resource)
        case is MovesenseResourceGyro:
            return DashboardContainerViewModelGyro(name: name, device: device, resource: resource)
        case is MovesenseResourceHeartRate:
            return DashboardContainerViewModelHr(name: name, device: device, resource: resource)
        default:
            #if DEBUG
            return DashboardContainerViewModelDebug(name: name, device: device, resource: resource)
            #else
            return nil
            #endif
        }
    }

    static func createOperationViewController(viewModel: DashboardContainerViewModel) -> UIViewController? {
        switch viewModel.resource {
        case .acc:
            guard let viewModel = viewModel as? DashboardContainerViewModelAcc else { return nil }
            return DashboardOperationViewControllerAcc(viewModel: viewModel)
        case .ecg: return DashboardOperationViewControllerEcg(viewModel: viewModel)
        case .gyro: return DashboardOperationViewControllerGyro(viewModel: viewModel)
        case .heartRate: return DashboardOperationViewControllerHr(viewModel: viewModel)
        default:
            return DashboardOperationViewControllerDebug(viewModel: viewModel)
        }
    }
}
