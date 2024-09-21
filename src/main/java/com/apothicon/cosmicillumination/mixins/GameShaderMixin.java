package com.apothicon.cosmicillumination.mixins;

import com.badlogic.gdx.graphics.Camera;
import com.badlogic.gdx.math.Vector3;
import finalforeach.cosmicreach.blocks.BlockState;
import finalforeach.cosmicreach.entities.player.Player;
import finalforeach.cosmicreach.gamestates.InGame;
import finalforeach.cosmicreach.rendering.shaders.GameShader;
import finalforeach.cosmicreach.world.Chunk;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(GameShader.class)
public abstract class GameShaderMixin {

    @Shadow public abstract void bindOptionalInt(String uniformName, int value);

    @Inject(method = "bind", at = @At("HEAD"))
    public void bind(Camera worldCamera, CallbackInfo ci) {
        int isUnderwater = 0;
        if (InGame.world != null) {
            Player player = InGame.getLocalPlayer();
            if (player != null) {
                Chunk chunk = player.getChunk(InGame.world);
                if (chunk != null) {
                    BlockState state = player.getZone(InGame.world).getBlockState(new Vector3(player.getPosition().x, player.getPosition().y + 2f, player.getPosition().z));
                    if (state != null) {
                        isUnderwater = state.isFluid ? 1 : 0;
                    }
                }
            }
        }
        this.bindOptionalInt("isUnderwater", isUnderwater);
    }
}
