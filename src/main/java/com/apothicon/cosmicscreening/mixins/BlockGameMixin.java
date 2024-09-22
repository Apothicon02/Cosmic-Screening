package com.apothicon.cosmicscreening.mixins;

import com.apothicon.cosmicscreening.CosmicScreening;
import com.badlogic.gdx.Gdx;
import finalforeach.cosmicreach.BlockGame;
import finalforeach.cosmicreach.gamestates.GameState;
import finalforeach.cosmicreach.gamestates.InGame;
import finalforeach.cosmicreach.gamestates.MainMenu;
import finalforeach.cosmicreach.io.ChunkSaver;
import finalforeach.cosmicreach.io.SaveLocation;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(BlockGame.class)
public class BlockGameMixin {
    @Inject(at = @At("HEAD"), method = "render")
    public void render(CallbackInfo ci) {
        if (CosmicScreening.takeScreenshot > 0) {
            CosmicScreening.takeScreenshot--;
        }
        if (CosmicScreening.takeScreenshot == 1) {
            String screenshot = GameState.currentGameState.takeScreenshot();
            Gdx.files.absolute(screenshot).copyTo(Gdx.files.absolute(SaveLocation.getAllWorldsSaveFolderLocation().substring(8) + "cosmic-screening/last-world-exit.png"));
            ChunkSaver.saveWorld(InGame.world);
            GameState.switchToGameState(new MainMenu());
            Gdx.input.setCursorCatched(false);
        }
    }
}
