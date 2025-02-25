{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dermetfan.services.xscreensaver;
in {
  options.profiles.dermetfan.services.xscreensaver.enable = lib.mkEnableOption "xscreensaver" // {
    default = config.services.xscreensaver.enable;
  };

  config = {
    home.packages = [ pkgs.rss-glx ];

    services.xscreensaver.settings = {
      timeout = "0:05:00";
      cycle = "0:03:00";
      lock = true;
      lockTimeout = "0:10:00";
      passwdTimeout = "0:00:02";
      visualID = "default";
      installColormap = true;
      verbose = false;
      timestamp = true;
      splash = true;
      splashDuration = "0:00:05";
      demoCommand = "xscreensaver-demo";
      prefsCommand = "xscreensaver-demo -prefs";
      nice = 10;
      memoryLimit = 0;
      fade = false;
      unfade = false;
      fadeSeconds = "0:00:03";
      fadeTicks = 20;
      captureStderr = true;
      ignoreUninstalledPrograms = false;
      font = "*-medium-r-*-140-*-m-*";
      dpmsEnabled = false;
      dpmsQuickOff = false;
      dpmsStandby = "2:00:00";
      dpmsSuspend = "2:00:00";
      dpmsOff = "4:00:00";
      grabDesktopImages = true;
      grabVideoFrames = true;
      chooseRandomImages = true;
      imageDirectory = "${config.xdg.userDirs.pictures}/wallpapers";
      mode = "blank";
      selected = -1;
      textMode = "program";
      textLiteral = "XScreenSaver";
      textProgram = "${config.home.homeDirectory}/.nix-profile/bin/fortune";
      textURL = https://en.wikipedia.org/w/index.php?title=Special:NewPages&feed=rss;
      pointerPollTime = "0:00:05";
      pointerHysteresis = 10;
      windowCreationTimeout = "0:00:30";
      initialDelay = "0:00:00";
      GetViewPortIsFullOfLies = false;
      procInterrupts = true;
      xinputExtensionDev = false;
      overlayStderr = true;
      authWarningSlack = 20;
      programs = ''
        maze -root \n\
        GL: superquadrics -root \n\
        attraction -root \n\
        blitspin -root \n\
        greynetic -root \n\
        helix -root \n\
        hopalong -root \n\
        imsmap -root \n\
        noseguy -root \n\
        pyro -root \n\
        qix -root \n\
        rocks -root \n\
        rorschach -root \n\
        decayscreen -root \n\
        flame -root \n\
        halo -root \n\
        slidescreen -root \n\
        pedal -root \n\
        bouboule -root \n\
        braid -root \n\
        coral -root \n\
        deco -root \n\
        drift -root \n\
        fadeplot -root \n\
        galaxy -root \n\
        goop -root \n\
        grav -root \n\
        ifs -root \n\
        GL: jigsaw -root \n\
        julia -root \n\
        kaleidescope -root \n\
        GL: moebius -root \n\
        moire -root \n\
        GL: morph3d -root \n\
        mountain -root \n\
        munch -root \n\
        penrose -root \n\
        GL: pipes -root \n\
        rd-bomb -root \n\
        GL: rubik -root \n\
        sierpinski -root \n\
        slip -root \n\
        GL: sproingies -root \n\
        starfish -root \n\
        strange -root \n\
        swirl -root \n\
        triangle -root \n\
        xjack -root \n\
        xlyap -root \n\
        GL: atlantis -root \n\
        bsod -root \n\
        GL: bubble3d -root \n\
        GL: cage -root \n\
        crystal -root \n\
        cynosure -root \n\
        discrete -root \n\
        distort -root \n\
        epicycle -root \n\
        flow -root \n\
        GL: glplanet -root \n\
        interference -root \n\
        kumppa -root \n\
        GL: lament -root \n\
        moire2 -root \n\
        GL: sonar -root \n\
        GL: stairs -root \n\
        truchet -root \n\
        - vidwhacker -root \n\
        blaster -root \n\
        bumps -root \n\
        ccurve -root \n\
        compass -root \n\
        deluxe -root \n\
        demon -root \n\
        GL: extrusion -root \n\
        loop -root \n\
        penetrate -root \n\
        petri -root \n\
        phosphor -root \n\
        GL: pulsar -root \n\
        ripples -root \n\
        shadebobs -root \n\
        GL: sierpinski3d -root \n\
        spotlight -root \n\
        squiral -root \n\
        wander -root \n\
        - webcollage -root \n\
        xflame -root \n\
        xmatrix -root \n\
        GL: gflux -root \n\
        nerverot -root \n\
        xrayswarm -root \n\
        xspirograph -root \n\
        GL: circuit -root \n\
        GL: dangerball -root \n\
        - GL: dnalogo -root \n\
        GL: engine -root \n\
        GL: flipscreen3d -root \n\
        GL: gltext -root \n\
        GL: menger -root \n\
        GL: molecule -root \n\
        rotzoomer -root \n\
        speedmine -root \n\
        GL: starwars -root \n\
        GL: stonerview -root \n\
        vermiculate -root \n\
        whirlwindwarp -root \n\
        zoom -root \n\
        anemone -root \n\
        apollonian -root \n\
        GL: boxed -root \n\
        GL: cubenetic -root \n\
        GL: endgame -root \n\
        euler2d -root \n\
        fluidballs -root \n\
        GL: flurry -root \n\
        GL: glblur -root \n\
        GL: glsnake -root \n\
        halftone -root \n\
        GL: juggler3d -root \n\
        GL: lavalite -root \n\
        polyominoes -root \n\
        GL: queens -root \n\
        GL: sballs -root \n\
        GL: spheremonics -root \n\
        thornbird -root \n\
        twang -root \n\
        GL: antspotlight -root \n\
        apple2 -root \n\
        GL: atunnel -root \n\
        barcode -root \n\
        GL: blinkbox -root \n\
        GL: blocktube -root \n\
        GL: bouncingcow -root \n\
        cloudlife -root \n\
        GL: cubestorm -root \n\
        eruption -root \n\
        GL: flipflop -root \n\
        GL: flyingtoasters -root \n\
        fontglide -root \n\
        GL: gleidescope -root \n\
        GL: glknots -root \n\
        GL: glmatrix -root \n\
        GL: glslideshow -root -delay 18584 \n\
        GL: hypertorus -root \n\
        GL: jigglypuff -root \n\
        metaballs -root \n\
        GL: mirrorblob -root \n\
        piecewise -root \n\
        GL: polytopes -root \n\
        pong -root \n\
        popsquares -root \n\
        GL: surfaces -root \n\
        xanalogtv -root \n\
        abstractile -root \n\
        anemotaxis -root \n\
        GL: antinspect -root \n\
        fireworkx -root \n\
        fuzzyflakes -root \n\
        interaggregate -root \n\
        intermomentary -root \n\
        memscroller -root \n\
        GL: noof -root \n\
        pacman -root \n\
        GL: pinion -root \n\
        GL: polyhedra -root \n\
        GL: providence -root \n\
        substrate -root \n\
        wormhole -root \n\
        GL: antmaze -root \n\
        GL: boing -root \n\
        boxfit -root \n\
        GL: carousel -root \n\
        celtic -root \n\
        GL: crackberg -root \n\
        GL: cube21 -root \n\
        fiberlamp -root \n\
        GL: fliptext -root \n\
        GL: glhanoi -root \n\
        GL: tangram -root \n\
        GL: timetunnel -root \n\
        GL: glschool -root \n\
        GL: topblock -root \n\
        GL: cubicgrid -root \n\
        cwaves -root \n\
        GL: gears -root \n\
        GL: glcells -root \n\
        GL: lockward -root \n\
        m6502 -root \n\
        GL: moebiusgears -root \n\
        GL: voronoi -root \n\
        GL: hypnowheel -root \n\
        GL: klein -root \n\
        lcdscrub -root \n\
        GL: photopile -root \n\
        GL: skytentacles -root \n\
        GL: rubikblocks -root \n\
        GL: companioncube -root \n\
        GL: hilbert -root \n\
        GL: tronbit -root \n\
        GL: geodesic -root \n\
        hexadrop -root \n\
        GL: kaleidocycle -root \n\
        GL: quasicrystal -root \n\
        GL: unknownpleasures -root \n\
        binaryring -root \n\
        GL: cityflow -root \n\
        GL: geodesicgears -root \n\
        GL: projectiveplane -root \n\
        GL: romanboy -root \n\
        tessellimage -root \n\
        GL: winduprobot -root \n\
        GL: splitflap -root \n\
        GL: dymaxionmap -root \n\
        GL: energystream -root \n\
        GL: hydrostat -root \n\
        GL: raverhoop -root \n\
        GL: unicrud -root \n\
        GL: cubestack -root \n\
        GL: cubetwist -root \n\
        GL: discoball -root \n\
        GL: hexstrut -root \n\
        GL: splodesic -root \n\
        GL: "Hufo's Tunnel"  hufo_tunnel --root \n\
        GL: "Flocks" flocks --root \n\
        GL: "Feedback" feedback --root \n\
        GL: "Lattice" lattice --root \n\
        GL: "Cyclone" cyclone --root \n\
        GL: "Skyrocket" skyrocket --root \n\
        GL: "Fieldlines" fieldlines --root \n\
        GL: "Lorenz" lorenz --root \n\
        GL: "BioF" biof --root \n\
        GL: "Solarwinds" solarwinds --root \n\
        GL: "Euphoria" euphoria --root \n\
        GL: "Flux" flux --root \n\
        GL: "Hufo's Smoke" hufo_smoke --root \n\
        GL: "Helios" helios --root \n\
        GL: "Colorfire" colorfire --root \n\
        GL: "MatrixView" matrixview --root \n\
        GL: "Plasma" plasma --root \n\
        GL: "Hyperspace" hyperspace --root \n\
        GL: "SpirographX" spirographx --root \n\
        GL: "Sundancer2" sundancer2 --root \n\
        GL: "BusySpheres" busyspheres --root \n\
        GL: "Drempels" drempels --root \n\
        GL: "Pixel City" pixelcity --root \n\
      '';
    };
  };
}
