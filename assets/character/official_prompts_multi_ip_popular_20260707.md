# 多 IP 热门角色与怪物像素立绘提示词

批次日期：2026-07-07

输出根目录：

```text
D:\游戏\earth-online\main\assets\character
```

本批次目标：绘制 10 个此前未绘制过的热门动漫或游戏 IP，每个 IP 4 个官方角色或怪物，共 40 张初始站立像素立绘。每个对象单独生成、单独扣图、单独落地到 `形态01_常态` 文件夹。

已绘制且本批次排除的 IP：七龙珠、火影忍者、尼尔机械纪元、艾尔登法环、只狼、黑神话悟空。

参考风格：

```text
D:\游戏\earth-online\main\assets\character\七龙珠\wukong\形态A\wukong.png
```

统一输出要求：

- 单对象、全身、初始站立或展示站姿。
- 正面或轻微 3/4 正面，脚底接近统一底部锚点。
- 最终输出 `256x256 RGBA`，透明背景。
- 粗像素块、深色外轮廓、低抗锯齿，整体参考悟空形态 A。
- 不要文字、水印、签名、数字、字母、符号、Logo 或服装上的可读印刷字。
- 不要场景背景、地面、投影、额外角色、召唤物、UI 边框。

## 通用提示词模板

将 `<subject>`、`<details>`、`<key>` 替换为各对象条目：

```text
Create ONE full-body 2D pixel-art game sprite of <subject>, official canonical appearance, matching the visible Wukong sprite reference style and stance: compact 256x256-ready standing portrait, front 3/4 facing viewer, feet near bottom anchor, crisp dark outline, hard-edged chunky pixel clusters, low anti-aliasing, readable iconic costume and silhouette, not a smooth high-resolution anime illustration.

Subject details: <details>.

Composition: centered full body, front torso visible, both shoulders visible, contained inside the frame with generous padding. Keep weapons, hair, tails, wings, capes, or large accessories close to the body. No extra characters, no text anywhere.

Background: perfectly flat solid <key> chroma-key background, one uniform color, no shadows, no gradients, no texture, no floor plane. Do not use <key> anywhere in the subject. No watermark, no signature, no kanji, no letters, no numbers, no symbols, no logo.
```

## 绘制清单与提示词要点

| IP | 对象 | slug | 色键 | 英文 subject/details |
|---|---|---|---|---|
| 海贼王 | Monkey D. Luffy | `luffy` | `#00ff00` | `Monkey D. Luffy from One Piece, young pirate captain with black messy hair, open red vest, blue shorts, straw hat behind or on his back, sandals, confident relaxed stance, plain clothing with no text.` |
| 海贼王 | Roronoa Zoro | `zoro` | `#ff00ff` | `Roronoa Zoro from One Piece, muscular swordsman with short green hair, green haramaki waist sash, dark boots, three sheathed swords kept close to the body, stern stance, no text marks.` |
| 海贼王 | Nami | `nami` | `#00ff00` | `Nami from One Piece, orange-haired navigator, slim build, blue-and-white travel outfit, clima-tact staff held close, confident upright stance, no readable symbols.` |
| 海贼王 | Sanji | `sanji` | `#00ff00` | `Sanji from One Piece, blond hair covering one eye, elegant dark suit, tie, black shoes, hands relaxed, long legs, calm kickfighter posture, no cigarette smoke and no text.` |
| 死神 | Ichigo Kurosaki | `ichigo_kurosaki` | `#00ff00` | `Ichigo Kurosaki from Bleach, orange spiky hair, black shihakusho robe, large zanpakuto sword held close or resting by his side, determined stance, no written marks.` |
| 死神 | Rukia Kuchiki | `rukia_kuchiki` | `#00ff00` | `Rukia Kuchiki from Bleach, short black hair, black shihakusho robe, white scarf accent optional, slim swordswoman stance, short zanpakuto close to body, no text.` |
| 死神 | Byakuya Kuchiki | `byakuya_kuchiki` | `#00ff00` | `Byakuya Kuchiki from Bleach, long black hair with noble hairpieces simplified, black shihakusho and white captain haori, composed upright stance, sword close to body, no symbols.` |
| 死神 | Sosuke Aizen | `sosuke_aizen` | `#00ff00` | `Sosuke Aizen from Bleach, brown hair swept back, white Arrancar-style robe coat, calm villain posture, glasses omitted or simplified if needed, sword close to body, no text.` |
| 咒术回战 | Yuji Itadori | `yuji_itadori` | `#00ff00` | `Yuji Itadori from Jujutsu Kaisen, short pink hair, dark school uniform with red hood accent, athletic stance with fists ready, plain uniform with no letters or school marks.` |
| 咒术回战 | Megumi Fushiguro | `megumi_fushiguro` | `#00ff00` | `Megumi Fushiguro from Jujutsu Kaisen, spiky black hair, dark high-collar school uniform, calm sorcerer stance, hands near body, no shadow creatures, no text.` |
| 咒术回战 | Satoru Gojo | `satoru_gojo` | `#00ff00` | `Satoru Gojo from Jujutsu Kaisen, tall sorcerer with white hair, black blindfold or dark round glasses, dark high-collar outfit, relaxed confident pose, no text.` |
| 咒术回战 | Ryomen Sukuna | `ryomen_sukuna` | `#00ff00` | `Ryomen Sukuna from Jujutsu Kaisen, pink swept hair, dark markings simplified as non-text facial and body stripes, open dark robe or Yuji-body silhouette, menacing upright stance, no readable symbols.` |
| 鬼灭之刃 | Tanjiro Kamado | `tanjiro_kamado` | `#ff00ff` | `Tanjiro Kamado from Demon Slayer, maroon hair, forehead scar simplified, black Demon Slayer uniform, green-black checkered haori, katana close to body, hanafuda earrings simplified without printed symbols.` |
| 鬼灭之刃 | Nezuko Kamado | `nezuko_kamado` | `#ff00ff` | `Nezuko Kamado from Demon Slayer, long dark hair with orange tips, pink kimono, dark haori, bamboo muzzle simplified as a plain green cylinder, small demon stance, no pattern text.` |
| 鬼灭之刃 | Zenitsu Agatsuma | `zenitsu_agatsuma` | `#00ff00` | `Zenitsu Agatsuma from Demon Slayer, yellow-orange bowl-cut hair, orange-yellow haori with tiny triangle pattern simplified as abstract pixels, black uniform, sheathed katana close, nervous upright stance.` |
| 鬼灭之刃 | Inosuke Hashibira | `inosuke_hashibira` | `#00ff00` | `Inosuke Hashibira from Demon Slayer, boar mask head, bare muscular torso, fur pelt waist, two chipped swords held close, aggressive crouched standing pose, no text.` |
| 进击的巨人 | Eren Yeager | `eren_yeager` | `#ff00ff` | `Eren Yeager from Attack on Titan, young soldier with brown hair, Survey Corps style harness and short green cloak simplified, determined stance, swords or blades kept close, no readable emblems.` |
| 进击的巨人 | Mikasa Ackerman | `mikasa_ackerman` | `#ff00ff` | `Mikasa Ackerman from Attack on Titan, short dark hair, red scarf, Survey Corps style harness and short green cloak simplified, calm warrior stance, blades kept close, no readable emblems.` |
| 进击的巨人 | Levi Ackerman | `levi_ackerman` | `#ff00ff` | `Levi Ackerman from Attack on Titan, short black undercut hair, compact soldier build, Survey Corps style harness and short green cloak simplified, cool upright stance, blades kept close, no readable emblems.` |
| 进击的巨人 | Armored Titan | `armored_titan` | `#00ff00` | `Armored Titan from Attack on Titan, massive humanoid titan with pale hardened armor plates, brown-gold armored body silhouette, powerful front 3/4 stance scaled to fit sprite, no steam cloud or background.` |
| 原神 | Traveler Aether | `aether_traveler` | `#00ff00` | `Traveler Aether from Genshin Impact, blond medium hair, white and brown adventurer outfit with gold accents simplified, short cape kept close, sword omitted or close to body, no glowing letters.` |
| 原神 | Paimon | `paimon` | `#00ff00` | `Paimon from Genshin Impact, tiny floating companion, white hair, small halo-like crown kept close, white outfit with navy and gold accents simplified, hovering upright pose, no stars or text.` |
| 原神 | Zhongli | `zhongli` | `#00ff00` | `Zhongli from Genshin Impact, tall man with dark brown hair and amber tips, formal brown-black long coat with gold accents simplified, composed upright stance, no logos or text.` |
| 原神 | Raiden Shogun | `raiden_shogun` | `#00ff00` | `Raiden Shogun from Genshin Impact, long violet hair braid, purple kimono-style outfit with armor accents simplified, calm authority stance, polearm omitted or kept close, no symbols.` |
| 英雄联盟 | Jinx | `jinx` | `#00ff00` | `Jinx from League of Legends, very long blue twin braids kept inside frame, punk outfit simplified, oversized weapon reduced and kept close to body, manic confident stance, no graffiti or text.` |
| 英雄联盟 | Ahri | `ahri` | `#00ff00` | `Ahri from League of Legends, fox-like woman with long dark hair, white and red outfit simplified, multiple white fox tails fanned close behind body, elegant stance, no magic orb.` |
| 英雄联盟 | Yasuo | `yasuo` | `#00ff00` | `Yasuo from League of Legends, dark tied hair, blue-gray ronin outfit and scarf, katana close to body, wind swordsman stance, plain armor with no symbols.` |
| 英雄联盟 | Teemo | `teemo` | `#ff00ff` | `Teemo from League of Legends, small yordle scout, green cap with goggles, tan fur face, red scarf, blowgun close to body, cheerful standing pose, no badge text.` |
| 我的世界 | Creeper | `creeper` | `#ff00ff` | `Creeper from Minecraft, tall blocky green hostile creature, four short blocky legs, pixel face simplified, front 3/4 standing pose, no explosion effects, no text.` |
| 我的世界 | Zombie | `zombie` | `#ff00ff` | `Zombie from Minecraft, blocky undead humanoid, green skin, teal shirt, blue pants, square head and arms, simple front 3/4 standing pose, no blood, no text.` |
| 我的世界 | Skeleton | `skeleton` | `#00ff00` | `Skeleton from Minecraft, blocky pale skeleton archer, square skull and rib-like torso simplified, bow kept close to body, front 3/4 standing pose, no arrows flying, no text.` |
| 我的世界 | Enderman | `enderman` | `#00ff00` | `Enderman from Minecraft, tall thin black blocky creature, long limbs, purple eyes, slightly hunched standing pose, no teleport particles, no held block, no text.` |
| 最终幻想VII | Cloud Strife | `cloud_strife` | `#00ff00` | `Cloud Strife from Final Fantasy VII, spiky blond hair, dark sleeveless outfit, single shoulder guard simplified, huge buster sword held close behind or beside body, stoic stance, no text.` |
| 最终幻想VII | Tifa Lockhart | `tifa_lockhart` | `#00ff00` | `Tifa Lockhart from Final Fantasy VII, long dark hair, white crop top, black skirt or shorts, red gloves, martial artist stance, plain clothing with no letters.` |
| 最终幻想VII | Aerith Gainsborough | `aerith_gainsborough` | `#00ff00` | `Aerith Gainsborough from Final Fantasy VII, brown braided hair with ribbon, pink dress and red jacket, staff held close, gentle upright stance, no text.` |
| 最终幻想VII | Sephiroth | `sephiroth` | `#00ff00` | `Sephiroth from Final Fantasy VII, very long silver hair, black coat with shoulder armor, long katana kept close to body or vertical, cold villain stance, no text.` |
| 怪物猎人 | Rathalos | `rathalos` | `#00ff00` | `Rathalos from Monster Hunter, red wyvern monster, horned head, folded wings, taloned feet, long tail curled close, powerful front 3/4 standing pose, no rider or environment.` |
| 怪物猎人 | Rathian | `rathian` | `#ff00ff` | `Rathian from Monster Hunter, green wyvern monster, folded wings, spiked tail curled close, queen-like aggressive stance, clear wyvern silhouette, no rider or environment.` |
| 怪物猎人 | Zinogre | `zinogre` | `#00ff00` | `Zinogre from Monster Hunter, blue-green thunder wolf wyvern, bulky forelimbs, yellow horn and fur accents simplified, crouched powerful standing pose, no lightning effects.` |
| 怪物猎人 | Nargacuga | `nargacuga` | `#00ff00` | `Nargacuga from Monster Hunter, black panther-like flying wyvern, red eyes, bladed wing arms folded close, long tail curled inside frame, stealthy crouched stance, no motion trails.` |

## 官方性与来源备注

官方性审核已由子智能体在 2026-07-07 核对。宝可梦组、塞尔达组和巫师组在原图生成阶段被图像工具安全系统拦截，最终分别替换为《进击的巨人》和《我的世界》组，并由主线程补充核对官方入口。以下来源用于确认本批次对象属于官方或官方授权资料内可见的角色/怪物。

| IP | 纳入对象 | 来源 URL | 来源类型 | 备注 |
|---|---|---|---|---|
| 海贼王 | Luffy, Zoro, Nami, Sanji | https://one-piece.com/character/index.html | 官方角色页 | 草帽一味核心角色。 |
| 死神 | Ichigo, Rukia, Byakuya, Sosuke Aizen | https://bleach-anime.com/en/character/ | 官方动画角色页 | 主角、同伴、队长级角色、核心反派。 |
| 咒术回战 | Yuji, Megumi, Gojo, Sukuna | https://en.bandainamcoent.eu/jujutsu-kaisen/news/yuji-itadori-ryomen-sukuna-megumi-fushiguro-nobara-kugisaki-and-satoru-gojo | 官方授权游戏新闻 | 主角组、导师、核心反派。 |
| 鬼灭之刃 | Tanjiro, Nezuko, Zenitsu, Inosuke | https://asia.sega.com/kimetsu_hinokami/en/character/ | 官方授权游戏角色页 | 主角四人组。 |
| 进击的巨人 | Eren, Mikasa, Levi, Armored Titan | https://shingeki.tv/final/character/ | 官方动画角色页 | 主角、核心战士与代表性巨人。 |
| 原神 | Traveler Aether, Paimon, Zhongli, Raiden Shogun | https://genshin.hoyoverse.com/en/ | 官方站/HoYoWiki | Aether 为 Traveler 男主角口径；Paimon 为向导 NPC。 |
| 英雄联盟 | Jinx, Ahri, Yasuo, Teemo | https://www.leagueoflegends.com/en-us/champions/ | 官方英雄页 | Riot 官方英雄。 |
| 我的世界 | Creeper, Zombie, Skeleton, Enderman | https://www.minecraft.net/ | Mojang/Minecraft 官方站 | 官方游戏怪物，代表性强。 |
| 最终幻想VII | Cloud, Tifa, Aerith, Sephiroth | https://www.square-enix.com/ffvii/en-us/games/rebirth/characters/ | Square Enix 官方角色页 | 核心角色与代表反派。 |
| 怪物猎人 | Rathalos, Rathian, Zinogre, Nargacuga | https://www.monsterhunter.com/stories/en-us/monster | CAPCOM 官方怪物列表 | 官方怪物物种。 |
