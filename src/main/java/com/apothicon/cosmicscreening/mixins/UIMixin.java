package com.apothicon.cosmicscreening.mixins;

import com.apothicon.cosmicscreening.CosmicScreening;
import com.badlogic.gdx.InputProcessor;
import finalforeach.cosmicreach.gamestates.GameState;
import finalforeach.cosmicreach.gamestates.InGame;
import finalforeach.cosmicreach.ui.UI;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(UI.class)
public abstract class UIMixin implements InputProcessor {

    @Shadow public static boolean renderUI;

    @Inject(at = @At("HEAD"), method = "render")
    public void render(CallbackInfo ci) {
        if (CosmicScreening.takeScreenshot > 0) {
            renderUI = false;
        }
    }
}
