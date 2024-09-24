package com.apothicon.cosmicscreening.mixins;

import com.apothicon.cosmicscreening.CosmicScreening;
import finalforeach.cosmicreach.TickRunner;
import finalforeach.cosmicreach.gamestates.GameState;
import finalforeach.cosmicreach.gamestates.PauseMenu;
import finalforeach.cosmicreach.gamestates.YouDiedMenu;
import finalforeach.cosmicreach.lang.Lang;
import finalforeach.cosmicreach.ui.UIElement;
import finalforeach.cosmicreach.ui.UIObject;
import java.util.Objects;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(UIElement.class)
public abstract class UIElementMixin implements UIObject {
    @Shadow private String text;

    @Inject(at = @At("HEAD"), method = "onClick")
    public void onClick(CallbackInfo ci) {
        if (Objects.equals(text, Lang.get("Return_to_Main_Menu")) && (GameState.currentGameState instanceof PauseMenu || GameState.currentGameState instanceof YouDiedMenu)) {
            TickRunner.INSTANCE.continueTickThread();
            GameState.switchToGameState(GameState.IN_GAME);
            CosmicScreening.takeScreenshot = 4;
        }
    }
}
