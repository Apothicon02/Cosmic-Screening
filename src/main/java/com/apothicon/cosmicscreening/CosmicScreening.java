package com.apothicon.cosmicscreening;

import dev.crmodders.cosmicquilt.api.entrypoint.ModInitializer;
import org.quiltmc.loader.api.ModContainer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CosmicScreening implements ModInitializer {
	public static final Logger LOGGER = LoggerFactory.getLogger("Cosmic Screening");
	public static int takeScreenshot = 0;

	@Override
	public void onInitialize(ModContainer mod) {
		LOGGER.info("Cosmic Screening Initialized!");
	}
}