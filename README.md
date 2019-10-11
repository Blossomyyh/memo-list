# memo-list
MEST - Memo-list with AR Feature

-----

 yinyuhan

GITHUB：

[https://github.com/Blossomyyh/memo-list.git](https://github.com/Blossomyyh/memo-list.git)



### INTRODUCTION

------

> #### Abstract

- Implement a memory application which contains todo-list and AR effect to remind you of what you want to remember

> #### Platform

- Xcode 9+
- Swift 4
- Ios 11.0

> #### Requirements

- add, modify, delete your memo-list
- use camera to enter the AR environment and record your path of the way to find your secret things
- share with friends 
- innovative interaction



### IMPLEMENT

------

> ### Todo-list

- Tools

  - Interaction

    - Pull view

      - search bar

        ```swift
        lazy var searchController = ({ () -> UISearchController in
        let controller = UISearchController(searchResultsController: nil) controller.searchResultsUpdater = self
        controller.searchBar.tintColor = UIColor.white        controller.searchBar.setImage(UIImage(named: "clock_icon"), for: .search, state: .normal)      controller.searchBar.setImage(UIImage(named: "close"), for: .clear, state: .normal)       controller.hidesNavigationBarDuringPresentation = false        controller.dimsBackgroundDuringPresentation = false
        var fetchResultsController: NSFetchedResultsController<TodoList>                                    return controller
        })()
        ```

        when you begin scroll the table, the search bar is going to appear

      - jump view

        in this part, I also use `DispatchQueue.global` manages the execution of work items. Each work item submitted to a queue is processed on a pool of threads managed by the system.

        So the `contentOffset` of the scrollView can be detected in real time, which helps me to jump to another page when this `contentOffset` comes to a certain value

        ```swift
        override func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        print(scrollView.contentOffset)
        let sg = ( scrollView.contentOffset.y * -1 ) / 60.0
                self.refreshView.scrollViewDidScroll(scrollView)
                // use main queue to catch the distance
                DispatchQueue.global(qos:
                    DispatchQoS.QoSClass.userInitiated).async {
                        let distance = scrollView.contentOffset.y
                        DispatchQueue.main.async {
                            print(distance)
                            if (distance < -200){
                                
                            self.performSegue(withIdentifier: "from_todo_to_find", sender: nil)
                            }
                        }
                }
            }
        ```

        ​

    - Swipe button——SwipeTableViewCellDelegate

      A third part library support cell swiping styles like Mail cells, there are few functions to use:

      1. Left and Right swiping support with configurable transitions as the actions are exposed
      2. Draggable cells past a threshold triggering auto-expansion of the default action
      3. Flexible action button styling (text attributes, support images, etc.)

    - animationController

      to show different animation when a page is going to show

      ​

  - CoreData `NSFetchedResultsControllerDelegate`

    Use Core Data to manage the model layer objects in your application. It provides generalized and automated solutions to common tasks associated with object lifecycle and object graph management, including persistence.

    - Lazy loading of objects, partially materialized futures (faulting), and copy-on-write data sharing to reduce overhead.
    - Grouping, filtering, and organizing of data in memory and in the user interface.

    Using the Core Data framework, primarily through an object known as a managed object context (or just “context”). 

    The managed object context serves as your gateway to an underlying collection of framework objects—collectively known as the persistence stack—that mediate between the objects in your application and external data stores. At the bottom of the stack are persistent object stores, as illustrated in the following diagrams

    ​

- Functions

  - Tap the `+`button in the bottom right corner to add new task. 
  - To edit task just tap on it.
  - Right swipe allows to remove a task from a list. 
  - When you are done with ur task, just left swipe on it and it'll be mark as strikethrough text.


- Material Design 

  ​

> #### Memo-list

- Tools 

  - Augmented Reality with the Back Camera

    The most common kinds of AR experience display a view from an iOS device's back-facing camera, augmented by other visual content, giving the user a new way to see and interact with the world around them.

    [`ARWorldTrackingConfiguration`](https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration) provides this kind of experience: ARKit maps and tracks the real-world space the user inhabits, and matches it with a coordinate space for you to place virtual content. World tracking also offers features to make AR experiences more immersive, such as recognizing objects and images in the user's environment and responding to real-world lighting conditions.

  - dispatch queue

    Why are we dispatching this to the main queue?

  - AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView can only be manipulated on the main thread


- AVCaptureSession.startRunning() 

  is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked, which keeps the UI responsive.

- FileUtil

  - FileManager

    to save and record the file in users iphone environment

  - UIDocumentInteractionController

    for share

     when document previews are displayed and when a document is about to be opened by another application. You can also use this protocol to respond to commands (such as “copy” and “print”) from a document interaction controller’s options menu.

    UIDocumentInteractionController来打开

- SceneKit

  to build 3D object with AR

- Third part library

  - SVProgressHUD

    A popular library to show the status of indeterminate tasks 

  - Material

    A UI/UX framework for creating beautiful applications. Material's animation system has been completely reworked to take advantage of Motion, a library dedicated to animations and transitions.


- Function
  - locate at where you are by camera
  - show the path you want to record
  - name & save the path
  - search the path by FileUtil
  - share the path with friends

### USAGE PROCESS

------

> #### ScreenShot



### Statement

------

This project is only for communication and learning purposes only. If the project is infringing on copyright issues or is told to stop sharing and use, I will promptly delete this page and the entire project.

- https://github.com/Findme

