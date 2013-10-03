class BezierOptionsMenu {  
  private Group bezierGroup;
  private Textfield name;
  private Button increaseResolution;
  private Button decreaseResolution;
  private Button increaseHorizontalForce;
  private Button decreaseHorizontalForce;
  private Button increaseVerticalForce;
  private Button decreaseVerticalForce;
  private Slider verticalForce;
  private DropdownList sourceList;
  PFont smallFont;
  
  BezierOptionsMenu() {
    // Initialize the font
    smallFont = createFont("Verdana",11,false);
    ControlFont font = new ControlFont(smallFont,11);
    
    // Quad options group
    bezierGroup = gui.addGroup("Bezier options")
                  .setPosition(20,40)
                  .setBackgroundHeight(300)
                  .setWidth(250)
                  .setBarHeight(20)
                  .setBackgroundColor(color(0,50));
    bezierGroup.captionLabel().style().marginTop = 6;
       
    // Name textfield
    name = gui.addTextfield("Bezier surface name")
              .setPosition(20,20)
              .setSize(200,25)
              .setFont(smallFont)
              .setId(10)
              .setGroup(bezierGroup);
    gui.getTooltip().register("Bezier surface name","Name of bezier surface");
       
    // Increase resolution button
    increaseResolution = gui.addButton("+ Increase ")
                            .setPosition(20,90)
                            .setSize(100,20)
                            .setId(11)
                            .setGroup(bezierGroup);
    increaseResolution.captionLabel().setFont(font).toUpperCase(false);
    gui.getTooltip().register("+ Increase ", "Increase resolution");
                            
    // Decrease resolution button
    decreaseResolution = gui.addButton("- Decrease ")
                            .setPosition(125,90)
                            .setSize(100,20)
                            .setId(12)
                            .setGroup(bezierGroup);
    decreaseResolution.captionLabel().setFont(font).toUpperCase(false);
    gui.getTooltip().register("- Decrease ", "Decrease resolution");
    
    // Increase horizontal force button
    increaseHorizontalForce = gui.addButton("+ Increase  ")
                            .setPosition(20,140)
                            .setSize(100,20)
                            .setId(13)
                            .setGroup(bezierGroup);
    increaseHorizontalForce.captionLabel().setFont(font).toUpperCase(false);
    gui.getTooltip().register("+ Increase  ", "Increase horizontal force");
    
    // Decrease horizontal force button
    decreaseHorizontalForce = gui.addButton("- Decrease  ")
                            .setPosition(125,140)
                            .setSize(100,20)
                            .setId(14)
                            .setGroup(bezierGroup);
    decreaseHorizontalForce.captionLabel().setFont(font).toUpperCase(false);
    gui.getTooltip().register("- Decrease  ", "Decrease horizontal force");
    
    // Increase vertical force button
    increaseVerticalForce = gui.addButton("+ Increase   ")
                            .setPosition(20,190)
                            .setSize(100,20)
                            .setId(15)
                            .setGroup(bezierGroup);
    increaseVerticalForce.captionLabel().setFont(font).toUpperCase(false);
    gui.getTooltip().register("+ Increase   ", "Increase vertical force");
                            
    // Decrease vertical force button
    decreaseVerticalForce = gui.addButton("- Decrease   ")
                            .setPosition(125,190)
                            .setSize(100,20)
                            .setId(16)
                            .setGroup(bezierGroup);
    decreaseVerticalForce.captionLabel().setFont(font).toUpperCase(false);    
    gui.getTooltip().register("- Decrease   ", "Decrease vertical force");

    // Source file dropdown
    sourceList = gui.addDropdownList("Texture source list ")
                    .setPosition(20,260)
                    .setSize(200,150)
                    .setBarHeight(20)
                    .setItemHeight(20)
                    .setId(17)
                    .setGroup(bezierGroup);
         
    compileSourceList();
       
    sourceList.captionLabel().set("Source file");
    sourceList.captionLabel().style().marginTop = 5;
  }
  
  void render() {
    if(bezierGroup.isOpen()) {
      text("Resolution", bezierGroup.getPosition().x + 20, bezierGroup.getPosition().y + 85);
      text("Horizontal force", bezierGroup.getPosition().x + 20, bezierGroup.getPosition().y + 135);
      text("Vertical force", bezierGroup.getPosition().x + 20, bezierGroup.getPosition().y + 185);
      text("Source file", bezierGroup.getPosition().x + 20, bezierGroup.getPosition().y + 235);
    }
  }
  
  void hide() {
    bezierGroup.hide();
  }
  
  void show() {
    bezierGroup.show();
  }
  
  void setSurfaceName(String name) {
    this.name.setValue(name);
  }
  
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
