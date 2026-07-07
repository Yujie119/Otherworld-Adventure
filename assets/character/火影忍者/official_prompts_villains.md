# 火影忍者反派官方形态绘制提示词

本文件用于生成 `main/assets/character/火影忍者/` 下的反派角色站立立绘。只采用官方漫画、动画、官方游戏或官方商品资料中可见的主线形态，不采用同人漫画、原创皮肤或活动换装。

统一要求：

- 输出为单角色、全身、初始站立立绘。
- 风格参考 `main/assets/character/七龙珠/wukong/形态A/wukong.png`：小体量像素立绘、正面 3/4 站姿、黑/深紫外轮廓、清晰块面高光。
- 原图使用纯 `#00ff00` 色键背景，后处理抠成透明 PNG。
- 不画文字、水印、签名、地面阴影、场景背景、其他角色。
- 能量、尾巴、翅膀、武器、求道玉都必须贴近角色轮廓，不能占满画布。
- 像素风格要接近悟空形态A：硬边缘、粗颗粒像素块面、低抗锯齿、清晰深色外轮廓，避免平滑赛璐璐插画感。
- 六道系黑色勾玉必须画成实心黑色逗号/水滴形 magatama，不得画成数字 `6`、`9`、`999`、文字、符号或印刷字符。

## 大蛇丸 Orochimaru

### 形态01_音隐常态

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Orochimaru in his classic Otogakure / rogue Sannin form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, sinister calm stance.
Subject details: pale-skinned Orochimaru with very long straight black hair, narrow golden snake-like eyes, purple eye markings, beige tunic top, dark pants, thick purple rope belt tied at the back, loose sleeves, shinobi sandals. No Akatsuki cloak, no giant snake body, no extra characters.
Composition/framing: centered full body, generous padding, no crop, no aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_晓袍时期

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Orochimaru during his Akatsuki period, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, predatory rogue-ninja stance.
Subject details: pale Orochimaru with long black hair, golden snake eyes, purple eye markings, black Akatsuki cloak with red cloud patterns and high collar, hands visible with long fingers, shinobi sandals. No snake body, no giant summons, no other characters.
Composition/framing: centered full body, generous padding, cloak contained inside canvas, no crop.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_八岐大蛇

```text
Use case: stylized-concept
Asset type: 2D game boss sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Orochimaru's Eight Branches Technique / Yamata no Orochi form, matching the Wukong reference sprite style and existing boss-villain sprite previews: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, centered idle boss stance.
Subject details: huge white eight-headed serpent form with multiple long snake necks rising close together, pale scales, yellow snake eyes, open fanged mouths on a few heads, coiled lower body kept compact, a sinister Orochimaru-like presence. This is a monster form, not a humanoid; keep it readable inside 256x256.
Composition/framing: centered full body, generous padding, all heads contained inside canvas, no crop, no background effects, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the subject.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same outline density and cel-shaded pixel language as the Wukong reference. No text, no watermark, no signature.
```

## 佩恩 Pain

### 形态01_天道佩恩

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Tendo Pain / Deva Path Pain, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, godlike cold stance.
Subject details: orange spiky-haired Pain with pale skin, Rinnegan eyes, multiple black facial piercings on nose and ears, black Akatsuki cloak with red cloud patterns and high collar, black nail polish, shinobi sandals. No other Six Paths bodies.
Composition/framing: centered full body, generous padding, cloak contained, no crop, no aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_修罗道佩恩

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Asura Path Pain, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, mechanical battle stance.
Subject details: bald or short-haired pale Pain body with Rinnegan eyes, black piercings, Akatsuki cloak partly open or torn to reveal mechanical armor and segmented cybernetic arms, compact missile/weapon details kept close to the torso. No other Pain bodies.
Composition/framing: centered full body, generous padding, mechanical parts contained, no crop, no explosions.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_畜生道佩恩

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Animal Path Pain, the female body version, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, summoner stance.
Subject details: female Pain body with orange hair tied up, pale skin, Rinnegan eyes, black facial piercings, black Akatsuki cloak with red clouds and high collar, black nail polish. No summoned animals, no other Pain bodies.
Composition/framing: centered full body, generous padding, cloak contained, no crop.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

## 宇智波带土 Uchiha Obito

### 形态01_橙色面具阿飞

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of masked Obito Uchiha as Tobi with the orange spiral mask, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, mysterious Akatsuki stance.
Subject details: adult Obito wearing black Akatsuki cloak with red clouds, orange spiral mask with one eye hole, black gloves, cloak high collar, shinobi sandals. No white war mask, no Ten-Tails horns, no other characters.
Composition/framing: centered full body, generous padding, cloak contained, no crop.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_白面具战争

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Obito Uchiha in his white war mask form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, cold war-leader stance.
Subject details: Obito wearing white mask with black tomoe / Rinnegan-like pattern, one eye hole, dark high-collar cloak/robe, purple or dark gloves, war-era shinobi outfit hints, a gunbai fan or chain kept close if included. No Ten-Tails horns, no orange spiral mask.
Composition/framing: centered full body, generous padding, weapon kept close, no crop, no huge aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_战争无面具

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of unmasked war-era Obito Uchiha, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, wounded but dangerous stance.
Subject details: adult Obito with half-scarred face, short dark hair, one Sharingan eye and one Rinnegan eye, dark war-era shinobi robe with high collar, gloves, dark pants, shinobi sandals. No mask, no Ten-Tails horns, no giant aura.
Composition/framing: centered full body, generous padding, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态04_十尾人柱力

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Obito Uchiha as the Ten-Tails Jinchuriki, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, divine unstable stance.
Subject details: white Six Paths body, pale skin, short white hair or horn-like protrusions, clean white torso/robe with no chest markings, one Rinnegan and one Sharingan eye, black truth-seeking orbs floating very close behind him, short black staff kept close. Do not draw black magatama marks on the chest; do not draw any 6, 9, 999, digits, letters, words, printed characters, symbols, or text-like markings anywhere on the body or clothing. No mask, no giant Ten-Tails body.
Composition/framing: centered full body, generous padding, orbs and staff contained, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: hard-edged pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference, chunky pixel clusters instead of smooth anime illustration. No text, no watermark, no signature.
```

## 长门 Nagato

### 形态01_青年晓组织

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of young Nagato during the early Akatsuki era, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, tragic revolutionary stance.
Subject details: slim young Nagato with long straight red hair, pale skin, Rinnegan eyes, dark shinobi cloak/robe with simple Akatsuki-era styling, sandals, reserved expression. No Deva Path orange hair, no emaciated machine chair, no Edo cracks.
Composition/framing: centered full body, generous padding, no crop, no aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_外道枯瘦

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Nagato in his emaciated Gedo Statue controller state, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, centered full-body portrait, fragile but ominous stance.
Subject details: extremely thin Nagato with long red hair, Rinnegan eyes, gaunt pale face, black chakra receiver rods embedded in the back and arms, dark cloak hanging from a skeletal body, mechanical support frame or small chair elements kept close behind him. No Pain orange hair, no healthy young body.
Composition/framing: centered full body, generous padding, support frame contained, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same outline density and cel-shaded pixel language as the Wukong reference. No text, no watermark, no signature.
```

## 宇智波斑 Madara Uchiha

### 形态01_战国红甲

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Madara Uchiha in his Warring States red armor form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, legendary warrior stance.
Subject details: Madara with long wild black hair, stern face, red samurai-like Uchiha armor plates over dark bodysuit, arm guards, shinobi sandals, gunbai fan or large war fan kept close behind the body. No white Six Paths robe, no Edo cracks.
Composition/framing: centered full body, generous padding, fan kept close, no crop, no aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_秽土轮回眼

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Edo Tensei Madara with Rinnegan, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, immortal battlefield stance.
Subject details: Madara with long black hair, pale Edo Tensei cracked skin, Rinnegan eyes, red armor over dark bodysuit, gunbai fan or scythe-like weapon kept close, stern expression. No Six Paths white robe, no horns.
Composition/framing: centered full body, generous padding, weapon contained, no crop, no giant Susanoo.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_六道斑

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Madara Uchiha as the Ten-Tails Jinchuriki / Six Paths Madara, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, godlike final-boss stance.
Subject details: Madara with long white hair, pale skin, clean white Six Paths robe with no black chest markings, small horn-like forehead protrusions if visible, Rinnegan eyes, black truth-seeking orbs floating close behind him, black staff kept close to the body. Do not draw black magatama marks on the robe; do not draw any 6, 9, 999, digits, letters, words, printed characters, symbols, or text-like markings anywhere on the body or clothing. No red armor, no giant Ten-Tails.
Composition/framing: centered full body, generous padding, orbs and staff contained, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: hard-edged pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference, chunky pixel clusters instead of smooth anime illustration. No text, no watermark, no signature.
```

## 大筒木辉夜 Kaguya Otsutsuki

### 形态01_常态白眼

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Kaguya Otsutsuki in her standard white-robed form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet floating or lightly planted, serene terrifying stance.
Subject details: Kaguya with extremely long white hair flowing down, pale skin, Byakugan white eyes, small horn-like protrusions on the forehead, elegant clean white kimono-like robe, long sleeves, calm emotionless face. The robe must stay plain clean white with no black tomoe marks, no black numbers, no black symbols, no letters, no writing, and no printed characters. No rabbit monster body, no giant chakra arms.
Composition/framing: centered full body, generous padding, hair and sleeves contained, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: hard-edged pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference, chunky pixel clusters instead of smooth anime illustration. No text, no watermark, no signature.
```

### 形态02_轮回写轮眼

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Kaguya Otsutsuki with her Rinne Sharingan open, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet floating or lightly planted, dimension-ruling final-boss stance.
Subject details: Kaguya with very long white hair, forehead third eye open as red Rinne Sharingan with rings and tomoe, Byakugan white eyes, pale skin, clean white robe, sleeves slightly spread, subtle white-purple chakra edge kept close to the body. The robe must stay plain clean white with no black tomoe marks, no black numbers, no black symbols, no letters, no writing, and no printed characters. No rabbit monster transformation, no huge chakra arms.
Composition/framing: centered full body, generous padding, hair and sleeves contained, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: hard-edged pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference, chunky pixel clusters instead of smooth anime illustration. No text, no watermark, no signature.
```
