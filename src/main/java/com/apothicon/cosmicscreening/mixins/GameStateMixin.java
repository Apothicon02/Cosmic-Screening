package com.apothicon.cosmicscreening.mixins;

import com.apothicon.cosmicscreening.CosmicScreening;
import finalforeach.cosmicreach.gamestates.GameState;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(GameState.class)
public abstract class GameStateMixin{

    @Inject(at = @At("HEAD"), method = "switchToGameState", cancellable = true)
    private static void switchToGameState(CallbackInfo ci) {
        if (CosmicScreening.takeScreenshot > 1) {
            ci.cancel();
        }
    }
}
