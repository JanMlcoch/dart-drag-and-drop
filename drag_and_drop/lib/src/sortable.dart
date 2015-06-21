part of drag_and_drop;

class Sortable{
  /// [DivElement] or [UlistElement] which elements will be sortable 
  Element sortingIn;
  /// [DivElement] or [UlistElement] which elements can be swapped across with sortingIn
  Element connectedWith;  
  // Sorting elements have to be draggable, there is method _makeDraggable for this
  Draggable _draggable;
  // Temporary variable for checing if any elements've been swapped
  int _pickedUpIndex;
  // StreamController for firing changes of any element's possition
  StreamController<SortableEvent> _onUpdate;
  
  /// Fired when the user starts dragging.
  /// Note: The [onDragStart] is fired not on touchStart or mouseDown but as
  /// soon as there is a drag movement. When a drag is started an [onDrag] event
  /// will also be fired.
  Stream<DraggableEvent> get onDragStart => _draggable.onDragStart;

  /// Fired periodically throughout the drag operation.
  Stream<DraggableEvent> get onDrag => _draggable.onDrag;

  /// Fired when the user ends the dragging.
  /// Is also fired when the user clicks the 'esc'-key or the window loses focus.
  Stream<DraggableEvent> get onDragEnd => _draggable.onDragEnd ;
  
  /// Fired when element is swapped. This fire events only if possition of swapped elements is different
  Stream<SortableEvent> get onUpdate{
    if (_onUpdate == null) {
      _onUpdate = new StreamController<SortableEvent>.broadcast(sync: true,
          onCancel: () => _onUpdate = null);
    }
    return _onUpdate.stream;
  }
  
  /// Creates new [Sortable] for elements in [sortingIn], connectedWith has type of [List<Element>] 
  Sortable(this.sortingIn, {this.connectedWith}){
    
    if(sortingIn is DivElement || sortingIn is UListElement){
      _makeDraggable(sortingIn);
    }
      
    _checkRelativePos();  
    
    if(connectedWith != null){
      _makeDraggable(connectedWith);
    }
    
  }
  
  /// Ensure creating [Dragzone] of elements what can be swapped (sorting element is insert before or after element of [Dragzone]
  /// If connected element is empty (with no children) this method can handle it
  void _checkRelativePos(){
    _createActiveDropzone(sortingIn.children);
    if(connectedWith != null){
      if(connectedWith.children.isNotEmpty){
        _createActiveDropzone(connectedWith.children);
      }else{
        _createEmptyDropzone(connectedWith);
      }
    }
  }
  
  /// Create [Dropzone] of empty element 
  /// It makes temporary [Element.li] when sorting element enter this empty element
  void _createEmptyDropzone(Element emptyElement){
    Dropzone dz = new Dropzone(emptyElement);
    dz.onDragEnter.listen((DropzoneEvent event){
      Element handleEl = new Element.li();
      event.dropzoneElement.append(handleEl);
      _swapElements(event.draggableElement, handleEl);
      handleEl.remove();
    });
  }
  
  /// Create regular [Dropzone] of all elements in [dropzoneList]
  void _createActiveDropzone(List<Element> dropzoneList){
    Dropzone dz = new Dropzone(dropzoneList);
    dz.onDragEnter.listen((DropzoneEvent event){
      _swapElements(event.draggableElement, event.dropzoneElement);
    });
  }
  
  /// Makes [Draggable] elements what should be able to sort
  /// This method handle [List<Element>] if input [draggableEls] isn't [Element]. Careful, this method cannot handle [ElementList]
  void _makeDraggable(var draggableEls){
    if(draggableEls is Element){
      _draggable = new Draggable(draggableEls.children, avatarHandler : new AvatarHandler.clone());
    }else{
      draggableEls.forEach((Element draggableEl){
        _draggable = new Draggable(draggableEl.children, avatarHandler : new AvatarHandler.clone());      
      });
    }
    _draggable.onDragStart.listen((DraggableEvent event){
      _pickedUpIndex = event.draggableElement.parent.children.indexOf(event.draggableElement);
    });
    _draggable.onDragEnd.listen((DraggableEvent event){
      // in case of removing draggable element is pickedDownIndex set on 0
      int pickedDownIndex = 0;
      if(event.draggableElement.parent != null){
        pickedDownIndex = event.draggableElement == null ? null : event.draggableElement.parent.children.indexOf(event.draggableElement);        
      }
      if(_pickedUpIndex != pickedDownIndex && _onUpdate != null){
        _onUpdate.add(new SortableEvent(_pickedUpIndex,pickedDownIndex));
      }
      //In case of last element we have to create empty dropzone
      _checkListsEmpty();
    });
  }
  
  /// Check [sortingIn] and [connectedWith] if they are empty, its called after every drag end
  void _checkListsEmpty(){
    if(sortingIn.children.isEmpty){
      _createEmptyDropzone(sortingIn);
    }
    if(connectedWith == null) return;
    if(connectedWith.children.isEmpty){
      _createEmptyDropzone(connectedWith);
    }
  }
  
  
  
  
  /// Simple function to swap two elements. Its insert elm1 on place of elm2
  void _swapElements(Element elm1, Element elm2) {
    var parent = elm2.parent;
    if(elm1.parent != elm2.parent){
      parent.insertBefore(elm1, elm2.nextElementSibling);
    }
    bool up = parent.children.indexOf(elm1) > parent.children.indexOf(elm2);
    if(up){
      parent.insertBefore(elm1, elm2);
    }else{
      parent.insertBefore(elm1, elm2.nextElementSibling);
    }

  }
}


class SortableEvent{
  int _originalIndex;
  int _newIndex;
  
  int get originalIndex => _originalIndex;
  int get newIndex => _newIndex;
  
  /// Event with information about sorting element, it save original and new index in list of children of target list
  SortableEvent(this._originalIndex,this._newIndex);
}