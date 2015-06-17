// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library drag_and_drop.example;

import 'package:drag_and_drop/drag_and_drop.dart';
import 'dart:html' as html;

main() {
  html.Element sortingIn = html.querySelector('#example'); 
  html.Element exampleWith = html.querySelector('#exampleWith');
  html.Element exampleWith2 = html.querySelector('#exampleWith2');
  html.Element exampleEmpty = html.querySelector('#exampleEmpty');
  html.Element exampleDiv = html.querySelector('#exampleDiv');
  
//  Draggable draggable = new Draggable(html.querySelector('#div'), avatarHandler: new AvatarHandler.clone());
//  draggable.onDragStart.listen((onData){
//    print("startuju");
//  });
  Sortable sortable = new Sortable(sortingIn, connectedWith: exampleWith);
  
  Draggable dr = new Draggable(sortingIn, avatarHandler: new AvatarHandler.clone());
  
  // Install dropzone (trash).
  Dropzone dropzone = new Dropzone(html.querySelector('.trash'));
  
  // Remove the documents when dropped.
  dropzone.onDrop.listen((DropzoneEvent event) {
   event.draggableElement.remove();
   event.dropzoneElement.classes.add('full');
  });
  
//  Draggable dr = new Draggable(exampleDiv.children, avatarHandler: new AvatarHandler.clone());
  
//  dr.onDragStart.listen((onData){
//    print("sdfs");
//    
//  });
  
}

List<html.Element> getList(){
  html.UListElement list = html.querySelector('#example');
  List<html.Element> elList = [];
  for(int i=0;i<5;i++){
    elList.add(list.children[i]);    
  }
  return elList;
}
