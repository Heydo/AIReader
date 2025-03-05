import SwiftUI

@main
struct AIReaderApp: App {
    init() {
        if let booksFolder = FileManagerHelper.shared.getDocumentsDirectory() {
            print("✅ AIReaderBooks 文件夹路径: \(booksFolder.path)")
        } else {
            print("❌ AIReaderBooks 文件夹创建失败")
        }
    }

    var body: some Scene {
        WindowGroup {
            BookshelfView()
        }
    }
}
