import Foundation

final class JKFileManager {
  static let standard = JKFileManager()
  private init() {}

  // MARK: - Variables
  enum StorageHelperError:Error {
    case error(_ message:String)
  }
  
  enum Directory {
    /** Only documents and other data that is user-generated, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud. */
    case documents
    
    /** Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. */
    case caches
  }
        
  // MARK: - Functions
  /** Store an encodable class to the specified directory on disk
   *  @param object the encodable class to store
   *  @param directory where to store the class
   *  @param fileName what to name the file where the class data will be stored
   */
  func save<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) throws {
    let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(object)
      if FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.removeItem(at: url)
      }
      FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }
    catch {
      throw(error)
    }
  }

  /** Retrieve and convert an Object from a file on disk
   *  @param fileName name of the file where class data is stored
   *  @param directory Directory where object data is stored
   *  @param type object type (i.e. Message.self)
   *  @return decoded object model(s) of data
   */
  func read<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) throws -> T {
    let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
    if !FileManager.default.fileExists(atPath: url.path) {
      throw StorageHelperError.error("No data at location: \(url.path)")
    }
    
    if let data = FileManager.default.contents(atPath: url.path) {
      let decoder = JSONDecoder()
      do {
        let model = try decoder.decode(type, from: data)
        return model
      } catch {
        throw(error)
      }
    }
    else {
      throw StorageHelperError.error("No data at location: \(url.path)")
    }
  }
      
  /** Remove all files at specified directory */
  func clear(_ directory: Directory) throws {
    let url = getURL(for: directory)
    do {
      let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
      for fileUrl in contents {
        try FileManager.default.removeItem(at: fileUrl)
      }
    }
    catch {
      throw(error)
    }
  }
    
  /** Remove specified file from specified directory */
  func remove(_ fileName: String, from directory: Directory) throws {
    let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
    if FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.removeItem(at: url)
      } catch {
        throw(error)
      }
    }
  }
    
  // MARK: - Helpers
  /** Returns BOOL indicating whether file exists at specified directory with specified file name */
  func fileExists(_ fileName: String, in directory: Directory) -> Bool {
    let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
    return FileManager.default.fileExists(atPath: url.path)
  }
    
  /** Returns URL constructed from specified directory */
  fileprivate func getURL(for directory: Directory) -> URL {
    var searchPathDirectory: FileManager.SearchPathDirectory
    switch directory {
      case .documents:
        searchPathDirectory = .documentDirectory
      
      case .caches:
        searchPathDirectory = .cachesDirectory
    }
    
    if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
      return url
    } else {
      fatalError("Could not create URL for specified directory!")
    }
  }
}

// MARK: - Examples for using the save & read functions
/*
 do {
   try JKFileManager.standard.save(responseData, to: .documents, as: "Jokes")
 } catch { }

 do {
   let value = try JKFileManager.standard.read("Jokes", from: .documents, as: Jokes.self)
 } catch { }
*/
