You realize the properties of the Promethium asteroid chunk can subtly improve the quality of your machines' components. The next logical step was to think of ways to industrialize its usage...

This mod adds a new machine to the end-game, the **Refinery**. You unlock it after researching promethium science, alongside research productivity.

![Refinery preview](https://files.catbox.moe/7wyhip.png)

It has a base quality effect of +100%. Out of the box, it directly **upgrades an item to the next quality level**, **with no resource loss**.

This technology however, also comes with **four major caveats**:

- **Promethium chunks spoil to an oxide chunk**, from the beginning - its special effects wither away after 2 hours.
- **Speed module effects break the upgrade guarantee** since they reduce quality chance on any and all machines.
- Even though most items can be refined - even science packs - their refining time also depends on all the ingredients of the production chain.
- 1 promethium chunk satsifies 1 Refinery for 10 minutes of constant operation. If you use them extensively, you're gonna have to design logistics for delivering promethium chunks, of all things, to your planets.

![Factoriopedia entries](https://files.catbox.moe/hol3wq.png)

# More technical details

- This mod has no control behaviors; it's purely based off prototypes.
- Science packs have hard-coded refining times to make ratio calculations ever so slightly easier, so you can at least expect some consistency when playing with quality and crazy SPM.
- Refining end products is faster than it should actually be. Tier 3 modules with crafting speed 1 still take 5 whole minutes though!
- Refining uranium-235 is not possible. You're forced to setup quality Kovarex enrichment process instead. As such, any end products that need uranium-235 - Portable fission reactor, Spidertron and Biolab - are not directly refinable.
- Refining ammo and explosives in general is slow due to their delicate nature, and so that you can't cheese your way out of military research for space platforms.
- Organic items can be refined, but eggs and fish don't play well - they are way slower.
- Some end products that gain no perks from quality - tiles, transport belts and similar - can't be refined.

# Missing / experimental features

- Report other incompatible mods! Because of how refining recipes are generated, some modded items might be impossible to refine, or the mod would outright crash the game.
- Refine time balancing was not exhaustively tested, for now it's merely eyeballed. Think of it as a proof-of-concept until it has its 1.0 release!
- Sound effects of the Refinery may change in the future if I find better samples to play with.
- The Refinery can freeze on Aquilo but has no frozen cover.

If you have any feedback feel free to DM me on Discord (`@lukitami`), or ping me in the Factorio Discord.

# Credits

- Hurricane (Discord `@hurricane046`), for the gorgeous Refinery graphics & animation. Used with CC BY license
- Wube, for related icons, reference in autogenerating recipes, and this amazing game
- Many people active in `#mod-dev-help` over on the Factorio Discord
