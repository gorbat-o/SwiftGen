#if os(iOS)
  import UIKit

  public class CreateAccViewController: UIViewController {
  }
  public class XXPickerViewController: UIViewController {
  }
  public class CustomSegueClass: UIStoryboardSegue {
  }
  public class CustomSegueClass2: UIStoryboardSegue {
  }
#elseif os(OSX)
  import Cocoa

  public class CustomTabViewController: NSWindowController {
  }
#endif
