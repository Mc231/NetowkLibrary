//
//  MimeTypeUtils.swift
//  NetworkLibrary
//
//  Created by Volodymyr Shyrochuk on 03.09.2022.
//

import Foundation

// https://stackoverflow.com/questions/26162616/upload-image-with-parameters-in-swift/26163136#26163136
public class MimeTypeUtils {
	
	public static let stramConstatns = "application/octet-stream"
	
	/** Determine mime type on the basis of extension of a file.
		This requires `import MobileCoreServices`
	  - parameter path: The path of the file for which we are going to determine the mime type.
	  - Returns: Returns the mime type if successful. Returns `application/octet-stream` if unable to determine mime type.
	*/
	public static func mimeType(for path: String) -> String {
		let url = URL(fileURLWithPath: path)
		let pathExtension = url.pathExtension
		
		if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
			if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
				return mimetype as String
			}
		}
		return MimeTypeUtils.stramConstatns
	}
}
