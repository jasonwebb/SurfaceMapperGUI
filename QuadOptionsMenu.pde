class QuadOptionsMenu {  
  private Group quadGroup;
  private Textfield name;
  private Button increaseResolution;
  private Button decreaseResolution;
  private DropdownList sourceList;
  private PFont smallFont;
  
  QuadOptionsMenu() {
    smallFont = createFont("Verdana",11,false);
    ControlFont font = new ControlFont(smallFont,11);
    
    // Quad options group
    quadGroup = gui.addGroup("Quad options")
                  .setPosition(20,40)
                  .setBackgroundHeight(190)
                  .setWidth(250)
                  .setBarHeight(20)
                  .setBackgroundColor(color(0,50));
    quadGroup.captionLabel().style().marginTop = 6;
    
    // Name textfield
    name = gui.addTextfield("Quad surface name")
              .setPosition(20,20)
              .setSize(200,25)
              .setFont(smallFont)
              .setGroup(quadGroup);
    gui.getTooltip().register("Quad surface name","Name of quad");
     
    // Increase resolution button
    increaseResolution = gui.addButton("+ Increase")
                            .setPosition(20,90)
                            .setSize(100,20)
                            .setId(7)
                            .setGroup(quadGroup);
    increaseResolution.captionLabel().setFont(font).toUpperCase(false);
                            
    // Decrease resolution button
    decreaseResolution = gui.addButton("- Decrease")
                            .setPosition(125,90)
                            .setSize(100,20)
                            .setId(8)
                            .setGroup(quadGroup);
    decreaseResolution.captionLabel().setFont(font).toUpperCase(false);
    
    // Source file dropdown
    sourceList = gui.addDropdownList("sourcelist")
                    .setPosition(20,160)
                    .setSize(200,150)
                    .setBarHeight(20)
                    .setItemHeight(20)
                    .setId(9)
                    .setGroup(quadGroup);
         
    compileSourceList();
       
    sourceList.captionLabel().set("Source file");
    sourceList.captionLabel().style().marginTop = 5;
  }
  
  void render() {
    if(quadGroup.isOpen()) {
      text("Resolution", quadGroup.getPosition().x + 20, quadGroup.getPosition().y + 85);
      text("Source file", quadGroup.getPosition().x + 20, quadGroup.getPosition().y + 135);    
    }
  }
  
  void hide() {
    quadGroup.hide();
  }
  
  void show() {
    quadGroup.show();
  }
  
  void setSurfaceName(String name) {
    this.name.setValue(name);
  }
  
  /*************************************************
   Populate the source list with the filenames
   of all the textures found in data/texures
  **************************************************/
  void compileSourceList() {
    File file = new File(sketchPath + "/data/textures");
    
    if(file.isDirectory()) {
      File[] files = file.listFiles();
      
      for(int i=0; i<files.length; i++) {
        sourceList.addItem(files[i].getName(), i);
      }
    }
  }
}
