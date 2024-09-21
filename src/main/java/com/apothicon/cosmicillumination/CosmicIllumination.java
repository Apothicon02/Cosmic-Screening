package com.apothicon.cosmicillumination;

import com.badlogic.gdx.Gdx;
import dev.crmodders.cosmicquilt.api.entrypoint.ModInitializer;
import finalforeach.cosmicreach.io.SaveLocation;
import org.quiltmc.loader.api.ModContainer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CosmicIllumination implements ModInitializer {
	public static final Logger LOGGER = LoggerFactory.getLogger("Cosmic Illumination");

	@Override
	public void onInitialize(ModContainer mod) {
		LOGGER.info("Cosmic Illumination Initialized!");

		Gdx.files.classpath("assets/base/shaders/chunk.frag.glsl").copyTo(Gdx.files.absolute(SaveLocation.getSaveFolderLocation() + "/mods/assets/base/shaders/chunk.frag.glsl"));
		Gdx.files.classpath("assets/base/shaders/chunk-water.frag.glsl").copyTo(Gdx.files.absolute(SaveLocation.getSaveFolderLocation() + "/mods/assets/base/shaders/chunk-water.frag.glsl"));
		Gdx.files.classpath("assets/base/shaders/sky.frag.glsl").copyTo(Gdx.files.absolute(SaveLocation.getSaveFolderLocation() + "/mods/assets/base/shaders/sky.frag.glsl"));
	}
}