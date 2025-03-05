import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()

    private init() {}

    // 获取 Documents 目录
    func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    // 列出存储的书籍
    func listBooks() -> [URL] {
        guard let booksDirectory = getDocumentsDirectory() else { return [] }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: booksDirectory, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "txt" || $0.pathExtension == "epub" }
        } catch {
            print("❌ 获取书籍列表失败: \(error.localizedDescription)")
            return []
        }
    }

    // 复制书籍文件到 Documents 目录
    func copyBookToDocuments(from sourceURL: URL) -> Bool {
        guard let documentsDirectory = getDocumentsDirectory() else { return false }
        
        let destinationURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                print("⚠️ 书籍已存在: \(destinationURL.lastPathComponent)")
                return false // 文件已存在，返回 false
            } else {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                print("✅ 书籍导入成功: \(destinationURL.lastPathComponent)")
                return true // 复制成功，返回 true
            }
        } catch {
            print("❌ 书籍导入失败: \(error.localizedDescription)")
            return false // 复制失败，返回 false
        }
    }
}
