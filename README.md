You realize that X-rays using promethium decay can be used to detect subtle imperfections in ingredients and machinery. The next obvious step is thinking of a way to automate fixing them...

This mod adds a new machine to the end-game, the **Refinery**. You unlock it after researching promethium science, alongside research productivity.

![Refinery preview](https://files.catbox.moe/7wyhip.png)

It has a base quality effect of +100%. Out of the box, it directly **upgrades an item to at least the next quality level**, **with no resource loss**.

- **Speed module effects break the upgrade guarantee**.
- Even though most items can be refined - even science packs - their refining time also depends on all the ingredients of the production chain.
- 1 promethium chunk satsifies 1 Refinery for 10 minutes of constant operation.

![Factoriopedia entries](https://files.catbox.moe/hol3wq.png)

# More technical details

- This mod has no control scripts; it's purely based off prototypes.
- Science packs have hard-coded refining times. You may use this to your advantage.
- Refining end products is faster than it should actually be. Speed module 3 with crafting speed 1 still takes an eternity though!
- Refining uranium-235 is not possible. You can't bang radiation with radiation. You're forced to setup quality Kovarex enrichment process instead. As such, any end products that need uranium-235 - Portable fission reactor, Spidertron and Biolab - are not directly refinable.
- Refining ammo and explosives in general is slow due to their, well, explosive nature, and so that you can't cheese your way out of military research for space platforms.
- Organic items can be refined, but living beings - eggs and fish - don't play well, they are way slower.
- Things that gain no perks from quality - tiles, transport belts and similar - can't be refined.

# Missing / experimental features

- Report incompatible mods! Because of how refining recipes are generated, some modded items might be impossible to refine.
- The Refinery can freeze on Aquilo but has no frozen cover.

# Credits

- Hurricane (Discord `@hurricane046`), for the gorgeous Refinery graphics & animation. Used with CC BY license
- Wube, for related icons, reference in autogenerating recipes, and this amazing game
- Many people active in `#mod-dev-help` over on the Factorio Discord
