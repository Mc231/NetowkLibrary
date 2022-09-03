//
//  Foundation_Bundle_Additions.swift
//
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

#if XCODE_BUILD
    extension Foundation.Bundle {
        /// Returns resource bundle as a `Bundle`.
        /// Requires Xcode copy phase to locate files into `ExecutableName.bundle`;
        /// or `ExecutableNameTests.bundle` for test resources
        static var module: Bundle = {
            var thisModuleName = "CLIQuickstartLib"
            var url = Bundle.main.bundleURL

            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                url = bundle.bundleURL.deletingLastPathComponent()
                thisModuleName = thisModuleName.appending("Tests")
            }

            url = url.appendingPathComponent("\(thisModuleName).bundle")

            guard let bundle = Bundle(url: url) else {
                fatalError("Foundation.Bundle.module could not load resource bundle: \(url.path)")
            }

            return bundle
        }()
    }
#endif
