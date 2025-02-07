local utility = require("__promethium-quality__.utility")

-- Base refining complexities
data.raw["item"]["ice"].refine_complexity = 1
data.raw["item"]["plastic-bar"].refine_complexity = 1 -- The two base recipes will conflict with each other
data.raw["item"]["holmium-plate"].refine_complexity = 1 -- Scrap recycling will be ignored. We need to set base complexity to holmium plate
data.raw["item"]["pentapod-egg"].refine_complexity = 600 -- This won't get picked up properly
data.raw["item"]["sulfur"].refine_complexity = 30 -- Artificially inflate
data.raw["item"]["uranium-238"].refine_complexity = 120
data.raw["item"]["lithium"].refine_complexity = 10 -- Artificially inflate
-- Science packs get predetermined refining times
data.raw["tool"]["automation-science-pack"].refine_complexity = utility.refine_time(0.5)
data.raw["tool"]["logistic-science-pack"].refine_complexity = utility.refine_time(1)
data.raw["tool"]["military-science-pack"].refine_complexity = utility.refine_time(2.5)
data.raw["tool"]["chemical-science-pack"].refine_complexity = utility.refine_time(4)
data.raw["tool"]["production-science-pack"].refine_complexity = utility.refine_time(8)
data.raw["tool"]["utility-science-pack"].refine_complexity = utility.refine_time(10)
data.raw["tool"]["space-science-pack"].refine_complexity = utility.refine_time(0.2)
data.raw["tool"]["metallurgic-science-pack"].refine_complexity = utility.refine_time(5)
data.raw["tool"]["agricultural-science-pack"].refine_complexity = utility.refine_time(5)
data.raw["tool"]["electromagnetic-science-pack"].refine_complexity = utility.refine_time(5)
data.raw["tool"]["cryogenic-science-pack"].refine_complexity = utility.refine_time(10)
data.raw["tool"]["promethium-science-pack"].refine_complexity = utility.refine_time(20)

-- Intentionally disabled refining
data.raw["item"]["scrap"].auto_refine = false
data.raw["item"]["uranium-ore"].auto_refine = false -- Force Kovarex enrichment process
data.raw["item"]["uranium-235"].auto_refine = false
data.raw["item"]["solid-fuel"].auto_refine = false
data.raw["item"]["rocket-fuel"].auto_refine = false -- By default rocket fuel should have no refining recipe but Gleba's biochemical one gets picked up
data.raw["item"]["iron-bacteria"].auto_refine = false -- Just refine ores bro
data.raw["item"]["copper-bacteria"].auto_refine = false

-- Useless on these items
data.raw["item"]["barrel"].auto_refine = false
data.raw["item"]["rocket-part"].auto_refine = false
data.raw["capsule"]["cliff-explosives"].auto_refine = false
data.raw["item"]["fast-transport-belt"].auto_refine = false
data.raw["item"]["underground-belt"].auto_refine = false
data.raw["item"]["splitter"].auto_refine = false

-- Useless on these tiles
data.raw["item"]["hazard-concrete"].auto_refine = false
data.raw["item"]["refined-hazard-concrete"].auto_refine = false
data.raw["item"]["space-platform-foundation"].auto_refine = false
data.raw["item"]["artificial-yumako-soil"].auto_refine = false
data.raw["item"]["artificial-jellynut-soil"].auto_refine = false
data.raw["item"]["overgrowth-yumako-soil"].auto_refine = false
data.raw["item"]["overgrowth-jellynut-soil"].auto_refine = false
data.raw["item"]["ice-platform"].auto_refine = false
data.raw["item"]["foundation"].auto_refine = false
