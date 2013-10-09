class ProgramOptionsMenu {
  private Group programGroup;
  private Button newQuad;
  private Button newBezier;
  private Button loadLayout;
  private Button saveLayout;
  private Button switchRender;
  private PFont smallFont;
  
  ProgramOptionsMenu() {    
    smallFont = createFont("Verdana",11,false);    
    
    // Program options menu
    programGroup = gui.addGroup("Program options")
                           .setPosition(width - 300,40)
                           .setBackgroundHeight(300)
                           .setWidth(280)
                           .setBarHeight(20)
                           .setBackgroundColor(color(0,50));
    programGroup.captionLabel().style().marginTop = 6;
    
    // Create new quad button
    newQuad = gui.addButton("newQuad")
                        .setPosition(10,20)
                        .setImages(loadImage("buttons/new-quad-off.png"),loadImage("buttons/new-quad-hover.png"),loadImage("buttons/new-quad-click.png"))
                        .updateSize()
                        .setId(1)
                        .setGroup(programGroup);
                        
    // Create new bezier button
    newBezier = gui.addButton("newBezier")
                        .setPosition(10,65)
                        .setImages(loadImage("buttons/new-bezier-off.png"),loadImage("buttons/new-bezier-hover.png"),loadImage("buttons/new-bezier-click.png"))
                        .updateSize()
                        .setId(2)
                        .setGroup(programGroup);
                        
    // Load layout button
    loadLayout = gui.addButton("loadLayout")
                        .setPosition(10,130)
                        .setImages(loadImage("buttons/load-layout-off.png"),loadImage("buttons/load-layout-hover.png"),loadImage("buttons/load-layout-click.png"))
                        .updateSize()
                        .setId(3)
                        .setGroup(programGroup);
                        
    // Load layout button
    saveLayout = gui.addButton("saveLayout")
                        .setPosition(130,130)
                        .setImages(loadImage("buttons/save-layout-off.png"),loadImage("buttons/save-layout-hover.png"),loadImage("buttons/save-layout-click.png"))
                        .updateSize()
                        .setId(4)
                        .setGroup(programGroup);
                        
    // Save layout button
    switchRender = gui.addButton("switchRender")
                        .setPosition(10,195)
                        .setImages(loadImage("buttons/switch-render-off.png"),loadImage("buttons/switch-render-hover.png"),loadImage("buttons/switch-render-click.png"))
                        .updateSize()
                        .setId(5)
                        .setGroup(programGroup);
  }
  
  void render() {
    if(programGroup.isOpen()) {
      stroke(255,150);
      line(programGroup.getPosition().x, programGroup.getPosition().y + 115, programGroup.getPosition().x + programGroup.getWidth(), programGroup.getPosition().y + 115);
      
      stroke(255,150);
      line(programGroup.getPosition().x, programGroup.getPosition().y + 177, programGroup.getPosition().x + programGroup.getWidth(), programGroup.getPosition().y + 177);
      
      textFont(smallFont);
      fill(255);
      text("Double click to return", programGroup.getPosition().x + 20, programGroup.getPosition().y + 245);
      
      text("Hit Escape to close program", programGroup.getPosition().x + 20, programGroup.getPosition().y + 280);      
    }
  }
  
  void hide() {
    programGroup.hide();
  }
  
  void show() {
    programGroup.show();
  }
}
