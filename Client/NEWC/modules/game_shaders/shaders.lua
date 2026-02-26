
function init()
  -- add manually your shaders from /data/shaders

  -- map shaders
  g_shaders.createShader("map_default", "/shaders/map_default_vertex", "/shaders/map_default_fragment")  

  g_shaders.createShader("map_rainbow", "/shaders/map_rainbow_vertex", "/shaders/map_rainbow_fragment")
  g_shaders.addTexture("map_rainbow", "/images/shaders/rainbow.png")

  -- use modules.game_interface.gameMapPanel:setShader("map_rainbow") to set shader

  -- outfit shaders
  g_shaders.createOutfitShader("outfit_default", "/shaders/outfit_default_vertex", "/shaders/outfit_default_fragment")
  --g_shaders.createOutfitShader("outfit_default", "/shaders/outfit_rainbow_vertex", "/shaders/outfit_rainbow_fragment")
  -- you can use creature:setOutfitShader("outfit_rainbow") to set shader


  g_shaders.createOutfitShader("Colorizing Dots", "/shaders/done/outfit_colorizingWave_vertex", "/shaders/done/outfit_colorizingWave_fragment")

  g_shaders.createOutfitShader("Holographic", "/shaders/done/outfit_rainbowRGB_vertex", "/shaders/done/outfit_rainbowRGB_fragment")

  g_shaders.createOutfitShader("Rainbow Wave", "/shaders/done/outfit_rainbowWave_vertex", "/shaders/done/outfit_rainbowWave_fragment")

  g_shaders.createOutfitShader("Shine", "/shaders/done/outfit_shine_vertex", "/shaders/done/outfit_shine_fragment")
  
  g_shaders.createOutfitShader("Darken Starslink", "/shaders/done/outfit_starsLinkDarken_vertex", "/shaders/done/outfit_starsLinkDarken_fragment")
  
  g_shaders.createOutfitShader("Matrix Fall", "/shaders/done/outfit_matrixFall_vertex", "/shaders/done/outfit_matrixFall_fragment")
  
  g_shaders.createOutfitShader("Rainbow Nebula", "/shaders/done/outfit_starsRainbowNebula_vertex", "/shaders/done/outfit_starsRainbowNebula_fragment")
 
  g_shaders.createOutfitShader("Redglow", "/shaders/done/outfit_redGlow_vertex", "/shaders/done/outfit_redGlow_fragment")

 g_shaders.createOutfitShader("outlinerainbow", "/shaders/outline/outline_rainbow_vertex", "/shaders/outline/outline_rainbow_fragment")

 g_shaders.createOutfitShader("outlinegreen", "/shaders/outline/outfit_outlinegreen_vertex", "/shaders/outline/outfit_outlinegreen_fragment")

  -- monster variant tints
  g_shaders.createOutfitShader("variant_blue", "/shaders/outfit_default_vertex", "/shaders/outfit_variant_blue_fragment")
  g_shaders.createOutfitShader("variant_red", "/shaders/outfit_default_vertex", "/shaders/outfit_variant_red_fragment")
  g_shaders.createOutfitShader("variant_green", "/shaders/outfit_default_vertex", "/shaders/outfit_variant_green_fragment")


    
end


function terminate()
end
