{ config, lib, pkgs, ... }:

let
  cfg = config.config.programs.minecraft;
in {
  options       .programs.minecraft.enable = lib.mkEnableOption "Minecraft";
  options.config.programs.minecraft.enable = with lib; mkOption {
    type = types.bool;
    default = config.programs.minecraft.enable;
    defaultText = "<option>config.programs.minecraft.enable</option>";
    description = "Whether to configure Minecraft.";
  };

  config.home.packages = lib.optional config.programs.minecraft.enable pkgs.minecraft;
  config.home.file = lib.mkIf cfg.enable {
    ".minecraft/options.txt".text = ''
      version:922
      invertYMouse:false
      mouseSensitivity:0.5
      fov:0.625
      gamma:1.0
      saturation:0.0
      renderDistance:25
      guiScale:3
      particles:0
      bobView:true
      anaglyph3d:false
      maxFps:120
      fboEnable:true
      difficulty:3
      fancyGraphics:true
      ao:2
      renderClouds:true
      resourcePacks:[]
      incompatibleResourcePacks:[]
      lastServer:server.dermetfan.net
      lang:de_de
      chatVisibility:0
      chatColors:true
      chatLinks:true
      chatLinksPrompt:true
      chatOpacity:1.0
      snooperEnabled:true
      fullscreen:false
      enableVsync:true
      useVbo:true
      hideServerAddress:false
      advancedItemTooltips:false
      pauseOnLostFocus:true
      touchscreen:false
      overrideWidth:0
      overrideHeight:0
      heldItemTooltips:true
      chatHeightFocused:1.0
      chatHeightUnfocused:0.44366196
      chatScale:1.0
      chatWidth:1.0
      showInventoryAchievementHint:true
      mipmapLevels:4
      forceUnicodeFont:false
      reducedDebugInfo:false
      useNativeTransport:true
      entityShadows:true
      mainHand:right
      attackIndicator:1
      showSubtitles:false
      realmsNotifications:true
      enableWeakAttacks:false
      autoJump:false
      key_key.attack:-100
      key_key.use:-99
      key_key.forward:17
      key_key.left:30
      key_key.back:31
      key_key.right:18
      key_key.jump:57
      key_key.sneak:42
      key_key.sprint:29
      key_key.drop:16
      key_key.inventory:32
      key_key.chat:37
      key_key.playerlist:15
      key_key.pickItem:-98
      key_key.command:53
      key_key.screenshot:60
      key_key.togglePerspective:63
      key_key.smoothCamera:0
      key_key.fullscreen:87
      key_key.spectatorOutlines:0
      key_key.swapHands:20
      key_key.hotbar.1:2
      key_key.hotbar.2:3
      key_key.hotbar.3:4
      key_key.hotbar.4:5
      key_key.hotbar.5:6
      key_key.hotbar.6:7
      key_key.hotbar.7:8
      key_key.hotbar.8:9
      key_key.hotbar.9:10
      soundCategory_master:1.0
      soundCategory_music:1.0
      soundCategory_record:1.0
      soundCategory_weather:1.0
      soundCategory_block:1.0
      soundCategory_hostile:1.0
      soundCategory_neutral:1.0
      soundCategory_player:1.0
      soundCategory_ambient:1.0
      soundCategory_voice:1.0
      modelPart_cape:true
      modelPart_jacket:true
      modelPart_left_sleeve:true
      modelPart_right_sleeve:true
      modelPart_left_pants_leg:true
      modelPart_right_pants_leg:true
      modelPart_hat:true
    '';
  };
}
