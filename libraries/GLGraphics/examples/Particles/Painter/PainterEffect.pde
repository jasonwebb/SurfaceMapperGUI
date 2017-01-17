// Class that encapsulates the painterly effect.
class PainterEffect
{
    PainterEffect(PApplet parent, int n, int w, int h)
    {
        this.parent = parent;
        numParticles = n;
        canvasWidth = w;
        canvasHeight = h;
          
        initParameters();
        createTextures();
        initTextures();    
        createFilters();          
    }
    
    void apply(GLTexture srcTex, GLTexture brushTex, GLTexture destTex, boolean clear, boolean change, float changeTime)
    {
        if (clear) destTex.clear(0, 0, 0, 255);
        updateBrushes(srcTex, change, changeTime);
        drawBrushes(brushTex, destTex);      
    }
    
    void updateBrushes(GLTexture srcTex, boolean change, float changeTime)
    {
        moveFilterSrcTex[0] = posTex.getReadTex();
        moveFilterSrcTex[1] = gradTex.getReadTex();
        moveFilterSrcTex[2] = texfpVel;
        moveFilterSrcTex[3] = texfpNoise;
    
        moveFilter.setParameterValue(0, new float[]{canvasWidth, canvasHeight});
        if (followGrad) moveFilter.setParameterValue(1, 1);
        else moveFilter.setParameterValue(1, 0); 
        moveFilter.setParameterValue(2, velMean);
        moveFilter.setParameterValue(3, noiseMag);         
        moveFilter.apply(moveFilterSrcTex, posTex.getWriteTex());
        posTex.swap();
        
        currentTime = float(millis()) / float(1000);
        
        if ((updateNoiseTime != 0) && (currentTime - lastNoiseUpdateTime >= updateNoiseTime))
        {
            noiseFilter.apply(posTex.getReadTex(), texfpNoise, canvasWidth, canvasHeight, currentTime);
         
            lastNoiseUpdateTime = currentTime;
        }
        
        if (updateColor) 
        {
            colorFilterSrcTex[0] = imageTex.getOldTex();
            colorFilterSrcTex[1] = imageTex.getNewTex();
            colorFilterSrcTex[2] = colorTex.getReadTex();
            colorFilterSrcTex[3] = colorAuxTex.getReadTex();
            colorFilterSrcTex[4] = posTex.getReadTex();
            colorFilterSrcTex[5] = colorCountTex.getReadTex();

            colorFilterDestTex[0] = colorTex.getWriteTex();
            colorFilterDestTex[1] = colorAuxTex.getWriteTex();
            colorFilterDestTex[2] = colorCountTex.getWriteTex();
        
            colorFilter.setParameterValue(0, brushMaxLength);
            colorFilter.setParameterValue(1, changeCoeff);
            colorFilter.setParameterValue(2, brushChangeFrac);            
            colorFilter.setParameterValue(3, brushChangePow);
            colorFilter.apply(colorFilterSrcTex, colorFilterDestTex);
            colorTex.swap();
            colorAuxTex.swap();
            colorCountTex.swap();        
        }   
         
        if (change)
        {
            println("Start changing image...");

            // Preprocessing filter is applied to the source image to generate the new image.
            imgFilter.apply(srcTex, imageTex.getNewTex());

            // The gradient of the new image is calculated and stored in first texture of newGradTex.
            newGradTex.setWriteTex(0);
            gradFilterSrcTex[0] = imageTex.getNewTex();
            gradFilterSrcTex[1] = texfpRand;
            gradFilter.apply(gradFilterSrcTex, newGradTex.getWriteTex());

            // Initializing variables to control transition between old and new image/gradient.
            changeCoeff = 0.0;       // Linear interpolation coefficient.
            swapedImageTex = false;

            // Used to control the averaging of the gradient of the new image during the transition
            // period.
            newGradTex.init();
        
            lastChangeTime = currentTime;
        }

        if ((0.0 <= changeCoeff) && (changeCoeff < 1.0))
        {
            // Updating linear interpolation coefficient.
            changeCoeff = (currentTime - lastChangeTime) / changeTime;
            if (1.0 < changeCoeff) changeCoeff = 1.0;
        }
        else if (!swapedImageTex)
        {
            // Transition period is finished.
            println("...done changing image.");
            imageTex.swap();
            swapedImageTex = true;
            changeCoeff = -1.0; // With this value, the shaders don't enter into the transition mode.
        }

        aveCount++;
        if (aveCount == aveInterval)
        {
            // Gradient average.
            aveCount = 0;
            for (int n = 0; n < numAveIter; n++)
            {
                aveGradFilterSrcTex[0] = gradTex.getReadTex();
                aveGradFilterSrcTex[1] = texfpRand; 
                aveGradFilterSrcTex[2] = newGradTex.getReadTex();
            
                aveGradFilter.setParameterValue(0, changeCoeff);
            
                if (changeCoeff == -1) 
                {
                    aveGradFilter.apply(aveGradFilterSrcTex, gradTex.getWriteTex());
                }
                else 
                {
                    aveGradFilterDestTex[0] = gradTex.getWriteTex();
                    aveGradFilterDestTex[1] = newGradTex.getWriteTex();
                    aveGradFilter.apply(aveGradFilterSrcTex, aveGradFilterDestTex);
                }
            
                gradTex.swap();
                newGradTex.swap();
            }
        }
    }
    
    void drawBrushes(GLTexture brushTex, GLTexture destTex)
    {
        brushesFilterSrcTex[0] = gradTex.getReadTex();
        brushesFilterSrcTex[1] = brushTex;
        brushesFilterSrcTex[2] = colorTex.getReadTex();
        brushesFilterSrcTex[3] = posTex.getReadTex();
        
        if (blendBrushes) brushesFilter.setBlendMode(blendMode);
        else brushesFilter.noBlend();
        brushesFilter.setParameterValue(0, brushSize);
        brushesFilter.apply(brushesFilterSrcTex, destTex);    
    }

    void initParameters()
    {
        setDefParameters();
 
        aveCount = 0;
        lastChangeTime = -1;
        changeCoeff = -1.0;
        lastNoiseUpdateTime = -1;

        startClock = millis();    
    }
    
    void createTextures()
    {
        GLTextureParameters floatTexParams = new GLTextureParameters();
        floatTexParams.minFilter = GLTexture.NEAREST_SAMPLING;
        floatTexParams.magFilter = GLTexture.NEAREST_SAMPLING;        
        floatTexParams.format = GLTexture.FLOAT;
    
        imageTex = new GLTexturePingPong(new GLTexture(parent, canvasWidth, canvasHeight), 
                                         new GLTexture(parent, canvasWidth, canvasHeight));    
    
        posTex = new GLTexturePingPong(new GLTexture(parent, numParticles, floatTexParams), 
                                       new GLTexture(parent, numParticles, floatTexParams));        
    
        gradTex = new GLTexturePingPong(new GLTexture(parent, canvasWidth, canvasHeight, floatTexParams), 
                                        new GLTexture(parent, canvasWidth, canvasHeight, floatTexParams));         
    
        newGradTex = new GLTexturePingPong(new GLTexture(parent, canvasWidth, canvasHeight, floatTexParams), 
                                           new GLTexture(parent, canvasWidth, canvasHeight, floatTexParams));     
    
        colorTex = new GLTexturePingPong(new GLTexture(parent, numParticles, floatTexParams), 
                                         new GLTexture(parent, numParticles, floatTexParams));

        colorAuxTex = new GLTexturePingPong(new GLTexture(parent, numParticles, floatTexParams), 
                                            new GLTexture(parent, numParticles, floatTexParams));
    
        colorCountTex = new GLTexturePingPong(new GLTexture(parent, numParticles, floatTexParams), 
                                              new GLTexture(parent, numParticles, floatTexParams));

        int w = posTex.getReadTex().width;
        int h = posTex.getReadTex().height;

        texfpVel = new GLTexture(parent, w, h, floatTexParams);
        texfpRand = new GLTexture(parent, canvasWidth, canvasHeight, floatTexParams);
        texfpNoise = new GLTexture(parent, w, h, floatTexParams);
    
        moveFilterSrcTex = new GLTexture[4];
        colorFilterSrcTex = new GLTexture[6];
        colorFilterDestTex = new GLTexture[3];
        gradFilterSrcTex = new GLTexture[2];
        aveGradFilterSrcTex = new GLTexture[3];
        aveGradFilterDestTex = new GLTexture[2];
        brushesFilterSrcTex = new GLTexture[4];
    
        println("Size of particles box: " + w + "x" + h);
        println("Number of particles: " + w * h);    
    }

    void initTextures()
    {
        int pix[] = new int[canvasWidth * canvasHeight];
        for (int k = 0; k < canvasWidth * canvasHeight; k++) pix[k] = 0xff000000;

        imageTex.getOldTex().putBuffer(pix);
        imageTex.getNewTex().putBuffer(pix);
    
        posTex.getReadTex().setRandom(0, canvasWidth, 0, canvasHeight, 0, 0, 0, 0);
        posTex.getWriteTex().setRandom(0, canvasWidth, 0, canvasHeight, 0, 0, 0, 0);  
    
        texfpVel.setRandom(velCoeffMin, velCoeffMax, 0, 0, 0, 0, 0, 0);
    
        texfpRand.setRandomDir2D(1.0, 1.0, 0.0, TWO_PI);
    
        texfpNoise.setRandomDir2D(0.0, 1.0, 0.0, TWO_PI);

        colorTex.getReadTex().setZero();
        colorTex.getWriteTex().setZero();
    
        colorAuxTex.getReadTex().setZero();
        colorAuxTex.getWriteTex().setZero();
    
        colorCountTex.getReadTex().setRandom(0, 0, brushMinLengthCoeff, brushMaxLengthCoeff, 0, 0, 0, 0);
        colorCountTex.getWriteTex().setRandom(0, 0, brushMinLengthCoeff, brushMaxLengthCoeff, 0, 0, 0, 0); 
    
        gradTex.getReadTex().setZero();
        gradTex.getWriteTex().setZero();
        newGradTex.getReadTex().setZero();
        newGradTex.getWriteTex().setZero();
    }

    void createFilters()
    {
        moveFilter = new GLTextureFilter(parent, "MovePart.xml");      // Compatible with NVidia GeForce 8x00 and newer.
        //moveFilter = new GLTextureFilter(parent, "MovePart-preGF8.xml"); // Compatible with NVidia video cards previous to GeForce 8x00.
    
        colorFilter = new GLTextureFilter(parent, "ColorPart.xml");      // Compatible with NVidia GeForce 8x00 and newer.
        //colorFilter = new GLTextureFilter(parent, "ColorPart-preGF8.xml"); // Compatible with NVidia video cards previous to GeForce 8x00.
    
        imgFilter = new GLTextureFilter(parent, "Blur.xml");
    
        gradFilter = new GLTextureFilter(parent, "RenderGrad2fp.xml");
    
        aveGradFilter = new GLTextureFilter(parent, "RenderAveGrad.xml");

        noiseFilter = new SimplexNoiseFilter(parent, "SimplexNoise.xml");

        brushesFilter = new GLTextureFilter(parent, "RenderBrushes.xml");
    }
        
    void setDefParameters()
    {
        brushSize = 5.0;
        
        brushMaxLength = 10;
        brushMinLengthCoeff = 0.8;
        brushMaxLengthCoeff = 1.2;
        brushChangeFrac = 3.0;
        brushChangePow = 1.0;
        
        velMean = 1.0;
        velCoeffMin = 0.8;
        velCoeffMax = 1.2;
        updateNoiseTime = 0.1;
        numAveIter = 1;
        aveInterval = 2;
        followGrad = true;
        updateColor = true;
        noiseMag = 1.0;
        blendBrushes = true;
        blendMode = BLEND;  
    }    
    
    PApplet parent;
    int numParticles;
    int canvasWidth, canvasHeight;
    float brushSize;
    int brushMaxLength;
    float brushMinLengthCoeff;
    float brushMaxLengthCoeff;
    float brushChangeFrac;
    float brushChangePow;
    float velMean;
    float velCoeffMin;
    float velCoeffMax;
    float updateNoiseTime;
    int numAveIter;
    int aveInterval;
    boolean followGrad;
    boolean updateColor;
    float noiseMag;
    boolean blendBrushes;
    int blendMode;
    
    float currentTime, lastChangeTime, changeCoeff, lastNoiseUpdateTime;
    boolean swapedImageTex;
    int aveCount;
    int startClock;
    
    GLTexturePingPong imageTex, posTex, gradTex, newGradTex, colorTex, colorAuxTex, colorCountTex;
    GLTexture texfpVel, texfpRand, texfpNoise; 

    GLTexture[] moveFilterSrcTex;
    GLTexture[] colorFilterSrcTex;
    GLTexture[] colorFilterDestTex;
    GLTexture[] gradFilterSrcTex;
    GLTexture[] aveGradFilterSrcTex;
    GLTexture[] aveGradFilterDestTex;
    GLTexture[] brushesFilterSrcTex;

    GLTextureFilter moveFilter, colorFilter, imgFilter, gradFilter, aveGradFilter, brushesFilter;
    SimplexNoiseFilter noiseFilter;    
}

