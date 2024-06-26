/*
* Copyright (c) 2024 Mike Chambers
* https://github.com/mikechambers/firefly-cl
*
* MIT License
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is furnished to do
* so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import ArgumentParser


//Represents an image query. Specifically structured to create JSON
//in the format required by the Firefly text to image API
//https://developer.adobe.com/firefly-services/docs/firefly-api/guides/api/image_generation/
struct GenerateImageQuery : Codable {
	let prompt:String
	let negativePrompt:String?
	let contentClass:ContentClass?
	let numVariations:Int?//number of variations
	let size:ImageSize?
	let seeds:[Int32]?
	let promptBiasingLocaleCode:String?
	let visualIntensity : Int?
	let style:GenerateImageStyle?
	let structure:GenerateImageStructure?
	let photoSettings:PhotoSettings?
	let tileable:Bool?
	
	init(prompt: String,
		 negativePrompt: String? = nil,
		 contentClass: ContentClass? = nil,
		 n: Int? = nil,
		 size: ImageSize? = nil,
		 seeds: [Int32]? = nil,
		 locale: String? = nil,
		 visualIntensity: Int? = nil,
		 style:GenerateImageStyle? = nil,
		 structure:GenerateImageStructure? = nil,
		 photoSettings:PhotoSettings? = nil,
		 tileable:Bool? = nil
	) {
		
		self.prompt = prompt
		self.negativePrompt = negativePrompt
		self.contentClass = contentClass
		self.numVariations = n
		self.size = size
		self.seeds = seeds
		self.promptBiasingLocaleCode = locale
		self.visualIntensity = visualIntensity
		self.style = style
		self.structure = structure
		self.photoSettings = photoSettings
		self.tileable = tileable
	}
}

struct GenerateImageStructure : Codable {
	let strength:Int?
	let imageReference:ReferenceImage?
	
}

struct GenerateImageStyle : Codable {
	let presets:[ImageStylePreset]?
	let strength:Int?
	let referenceImage:ReferenceImage?
}

struct ReferenceImage : Codable {
	let source:Source
}

struct Source : Codable {
	let uploadId:String
}

struct PhotoSettings : Codable {
	let aperture:Float?
	let shutterSpeed:Float?
	let fieldOfView:Int?
}

enum ContentClass: String, Codable, ExpressibleByArgument, CaseIterable {
	case photo = "photo"
	case art = "art"
	
	init?(argument:String) {
		self.init(rawValue: argument)
	}
}

//Supported image model styles
//https://developer.adobe.com/firefly-services/docs/firefly-api/guides/concepts/styles/
enum ImageStylePreset: String, Codable, ExpressibleByArgument, CaseIterable {
	case photo = "photo"
	case art = "art"
	case graphic = "graphic"
	case bw = "bw"
	case coolColors = "cool_colors"
	case golden = "golden"
	case monochromatic = "monochromatic"
	case mutedColor = "muted_color"
	case pastelColor = "pastel_color"
	case tonedImage = "toned_image"
	case vibrantColors = "vibrant_colors"
	case warmTone = "warm_tone"
	case closeup = "closeup"
	case knolling = "knolling"
	case landscapePhotography = "landscape_photography"
	case macrophotography = "macrophotography"
	case photographedThroughWindow = "photographed_through_window"
	case shallowDepthOfField = "shallow_depth_of_field"
	case shotFromAbove = "shot_from_above"
	case shotFromBelow = "shot_from_below"
	case surfaceDetail = "surface_detail"
	case wideAngle = "wide_angle"
	case beautiful = "beautiful"
	case bohemian = "bohemian"
	case chaotic = "chaotic"
	case dais = "dais"
	case divine = "divine"
	case eclectic = "eclectic"
	case futuristic = "futuristic"
	case kitschy = "kitschy"
	case nostalgic = "nostalgic"
	case simple = "simple"
	case antiquePhoto = "antique_photo"
	case bioluminescent = "bioluminescent"
	case bokeh = "bokeh"
	case colorExplosion = "color_explosion"
	case dark = "dark"
	case fadedImage = "faded_image"
	case fisheye = "fisheye"
	case gomoriPhotography = "gomori_photography"
	case grainyFilm = "grainy_film"
	case iridescent = "iridescent"
	case isometric = "isometric"
	case misty = "misty"
	case neon = "neon"
	case otherworldlyDepiction = "otherworldly_depiction"
	case ultraviolet = "ultraviolet"
	case underwater = "underwater"
	case backlighting = "backlighting"
	case dramaticLight = "dramatic_light"
	case goldenHour = "golden_hour"
	case harshLight = "harsh_light"
	case longTimeExposure = "long-time_exposure"
	case lowLighting = "low_lighting"
	case multiexposure = "multiexposure"
	case studioLight = "studio_light"
	case surrealLighting = "surreal_lighting"
	case _3dPatterns = "3d_patterns"
	case charcoal = "charcoal"
	case claymation = "claymation"
	case fabric = "fabric"
	case fur = "fur"
	case guillochePatterns = "guilloche_patterns"
	case layeredPaper = "layered_paper"
	case marble = "marble_sculpture"
	case madeOfMetal = "made_of_metal"
	case origami = "origami"
	case paperMache = "paper_mache"
	case polkaDotPattern = "polka-dot_pattern"
	case strangePatterns = "strange_patterns"
	case woodCarving = "wood_carving"
	case yarn = "yarn"
	case artDeco = "art_deco"
	case artNouveau = "art_nouveau"
	case baroque = "baroque"
	case bauhaus = "bauhaus"
	case constructivism = "constructivism"
	case cubism = "cubism"
	case cyberpunk = "cyberpunk"
	case fantasy = "fantasy"
	case fauvism = "fauvism"
	case filmNoir = "film_noir"
	case glitchArt = "glitch_art"
	case impressionism = "impressionism"
	case industrial = "industrialism"
	case maximalism = "maximalism"
	case minimalism = "minimalism"
	case modernArt = "modern_art"
	case modernism = "modernism"
	case neoExpressionism = "neo-expressionism"
	case pointillism = "pointillism"
	case psychedelic = "psychedelic"
	case scienceFiction = "science_fiction"
	case steampunk = "steampunk"
	case surrealism = "surrealism"
	case synthetism = "synthetism"
	case synthwave = "synthwave"
	case vaporwave = "vaporwave"
	case acrylicPaint = "acrylic_paint"
	case boldLines = "bold_lines"
	case chiaroscuro = "chiaroscuro"
	case colorShiftArt = "color_shift_art"
	case daguerreotype = "daguerreotype"
	case digitalFractal = "digital_fractal"
	case doodleDrawing = "doodle_drawing"
	case doubleExposurePortrait = "double_exposure_portrait"
	case fresco = "fresco"
	case geometricPen = "geometric_pen"
	case halftone = "halftone"
	case ink = "ink"
	case lightPainting = "light_painting"
	case lineDrawing = "line_drawing"
	case linocut = "linocut"
	case oilPaint = "oil_paint"
	case paintSpattering = "paint_spattering"
	case painting = "painting"
	case paletteKnife = "palette_knife"
	case photoManipulation = "photo_manipulation"
	case scribbleTexture = "scribble_texture"
	case sketch = "sketch"
	case splattering = "splattering"
	case stippling = "stippling_drawing"
	case watercolor = "watercolor"
	case _3d = "3d"
	case anime = "anime"
	case cartoon = "cartoon"
	case cinematic = "cinematic"
	case comicBook = "comic_book"
	case conceptArt = "concept_art"
	case cyberMatrix = "cyber_matrix"
	case digitalArt = "digital_art"
	case flatDesign = "flat_design"
	case geometric = "geometric"
	case glassmorphism = "glassmorphism"
	case glitchGraphic = "glitch_graphic"
	case graffiti = "graffiti"
	case hyperRealistic = "hyper_realistic"
	case interiorDesign = "interior_design"
	case lineGradient = "line_gradient"
	case lowPoly = "low_poly"
	case newspaperCollage = "newspaper_collage"
	case opticalIllusion = "optical_illusion"
	case patternPixel = "pattern_pixel"
	case pixelArt = "pixel_art"
	case popArt = "pop_art"
	case productPhoto = "product_photo"
	case psychedelicBackground = "psychedelic_background"
	case psychedelicWonderland = "psychedelic_wonderland"
	case scandinavian = "scandinavian"
	case splashImages = "splash_images"
	case stamp = "stamp"
	case trompeLoeil = "trompe_loeil"
	case vectorLook = "vector_look"
	case wireframe = "wireframe"

	// Custom initializer to create an enum from a string value
	init?(argument: String) {
		self.init(rawValue: argument)
	}
}
