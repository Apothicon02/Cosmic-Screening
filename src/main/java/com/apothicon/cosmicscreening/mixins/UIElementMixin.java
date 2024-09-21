package com.apothicon.cosmicscreening.mixins;

import com.apothicon.cosmicscreening.CosmicScreening;
import finalforeach.cosmicreach.lang.Lang;
import finalforeach.cosmicreach.ui.UIElement;
import finalforeach.cosmicreach.ui.UIObject;
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
        if (text.equals(Lang.get("Return_To_Game")) || text.equals(Lang.get("Return_to_Main_Menu"))) {
            CosmicScreening.takeScreenshot = 3;
        }
    }
}
