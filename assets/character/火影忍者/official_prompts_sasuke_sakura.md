# 火影忍者角色官方形态绘制提示词：佐助与春野樱

本文件用于生成 `main/assets/character/火影忍者/` 下的角色站立立绘。只采用官方漫画、动画、官方游戏或官方商品资料中可见的主线形态，不采用同人漫画、原创皮肤或活动换装。

统一要求：

- 输出为单角色、全身、初始站立立绘。
- 风格参考 `main/assets/character/七龙珠/wukong/形态A/wukong.png`：小体量像素立绘、正面 3/4 站姿、黑/深紫外轮廓、清晰块面高光。
- 原图使用纯 `#00ff00` 色键背景，后处理抠成透明 PNG。
- 不画文字、水印、签名、地面阴影、场景背景、其他角色。
- 能量、翅膀、披风、武器都必须贴近角色轮廓，不能占满画布。

## 佐助 Uchiha Sasuke

### 形态01_少年常态

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha in his Part I / young ninja normal form, matching the visible Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, cool restrained stance.
Subject details: young Sasuke with short black spiky hair, dark eyes, serious expression, blue high-collar shirt with Uchiha fan crest on the back hinted by side angle, white shorts, blue arm warmers, shinobi sandals, forehead protector. No curse mark, no Sharingan glow, no sword, no cloak.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_疾风传常态

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha in his Shippuden normal form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, calm dangerous stance.
Subject details: teenage Sasuke with black spiky hair, pale skin, stern dark eyes, open white high-collar shirt exposing chest, dark pants, purple rope belt tied in a large knot, arm guards, shinobi sandals, sword sheath close at the waist/back. No curse mark wings, no Akatsuki cloak, no Susanoo.
Composition/framing: centered full body, generous padding, sword kept close to body, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_咒印状态一

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha with Cursed Seal Level One active, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, tense corrupted stance.
Subject details: teenage Sasuke in Shippuden white open shirt and purple rope belt, black curse mark patterns spreading over one side of his face, neck, chest and arm, one visible red Sharingan eye, darker expression, sword kept close. No wings, no full monster skin, no Akatsuki cloak.
Composition/framing: centered full body, generous padding, no crop, no aura cloud, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态04_咒印状态二

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha in Cursed Seal Level Two, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, monstrous but humanoid stance.
Subject details: transformed Sasuke with gray-brown skin, longer wild dark hair, black star-like curse mark features across the face, fierce Sharingan eyes, clawed hands, darkened Shippuden outfit remnants with purple rope belt, two large hand-shaped wing membranes folded close behind his back. Keep wings compact inside the canvas.
Composition/framing: centered full body, generous padding, folded wings kept close, no crop, no huge aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态05_晓袍鹰小队

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha in his Akatsuki cloak / Taka period appearance, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, cold rogue-ninja stance.
Subject details: teenage Sasuke with black spiky hair, serious face, red Sharingan eyes, black Akatsuki cloak with red cloud patterns, high collar, cloak partly open enough to show dark outfit and sword hilt close at the side. No curse mark wings, no Susanoo armor.
Composition/framing: centered full body, generous padding, cloak contained inside canvas, no crop, no other characters, no large aura.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态06_永恒万花筒写轮眼

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha with Eternal Mangekyo Sharingan in his Fourth Shinobi War outfit, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, elite swordsman stance.
Subject details: teenage Sasuke in open white high-collar shirt, dark pants, purple rope belt, sword held close or sheathed, both eyes red with Eternal Mangekyo Sharingan pattern hinted in pixels, stern expression. Add a subtle compact purple Susanoo ribcage or flame outline close behind the torso, not a giant avatar.
Composition/framing: centered full body, generous padding, Susanoo hint kept tight, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态07_六道轮回眼

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sasuke Uchiha in his Six Paths / Rinnegan final-battle form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, composed final-battle stance.
Subject details: teenage Sasuke with black hair partially covering one eye, right eye red Eternal Mangekyo Sharingan, left eye purple Rinnegan with tomoe rings, gray-blue open shirt, dark pants, purple rope belt, sword close at his side/back, subtle purple lightning or Susanoo energy close to the body. No adult cloak, no giant Susanoo.
Composition/framing: centered full body, generous padding, energy kept close, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

## 春野樱 Haruno Sakura

### 形态01_少女常态

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sakura Haruno in her Part I / young ninja normal form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, determined young stance.
Subject details: young Sakura with short pink hair, green eyes, red sleeveless qipao-style top with white trim and circular back mark hinted by side angle, dark shorts, blue ninja sandals, gloves, forehead protector worn as a headband. No Byakugo seal, no adult outfit, no medical coat.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态02_疾风传常态

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sakura Haruno in her Shippuden normal form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, confident medical ninja stance.
Subject details: teenage Sakura with short pink hair, green eyes, red sleeveless zip tunic, pale pink skirt/apron panels, black shorts, black gloves, elbow guards, knee-high boots or shinobi sandals, medical ninja pouch. No forehead diamond seal, no Byakugo markings, no adult outfit.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态03_忍界大战百豪印

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sakura Haruno in Fourth Shinobi War form with the Strength of a Hundred Seal visible, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, powerful healer-fighter stance.
Subject details: teenage Sakura in Shippuden red medical-ninja outfit, short pink hair, green eyes, black gloves, diamond-shaped purple Byakugo seal on the forehead, fists clenched, stronger battle-ready expression. No seal lines spreading across the body yet.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态04_百豪之术释放

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sakura Haruno using Strength of a Hundred Technique / Byakugo Release, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, overwhelming physical-power stance.
Subject details: teenage Sakura in Shippuden red outfit, short pink hair, green eyes, purple diamond seal opened on her forehead, dark purple seal markings spreading from the forehead across her face, neck, arms and legs, clenched gloved fists, intense expression. Add only a very subtle close pink chakra glow if needed, no large aura.
Composition/framing: centered full body, generous padding, markings readable, no crop, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态05_The Last

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of Sakura Haruno in her official The Last era outfit, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, mature kunoichi stance.
Subject details: young adult Sakura with slightly longer pink hair, green eyes, red sleeveless Chinese-style dress/tunic with white trim and side slits over dark leggings, black gloves, shinobi sandals/boots, medical pouch. No Byakugo release markings, no Boruto-era long coat.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```

### 形态06_成年医疗忍

Prompt:

```text
Use case: stylized-concept
Asset type: 2D game character sprite, single idle standing portrait
Primary request: Create ONE full-body pixel-art sprite of adult Sakura Uchiha / Haruno in Boruto-era official medical ninja form, matching the Wukong reference sprite style: compact anime pixel sprite, crisp black/dark-purple outline, clean cel-shaded pixel clusters, front 3/4 idle standing pose, feet planted, composed veteran medic stance.
Subject details: adult Sakura with short neat pink hair, green eyes, red sleeveless qipao-style tunic with Uchiha-style circular crest hinted by side/back angle, dark leggings, gloves, ninja sandals/boots, medical pouch, purple forehead diamond seal visible. No active Byakugo body markings, no fan-made outfit, no cloak.
Composition/framing: centered full body, generous padding, no crop, no aura, no other characters.
Background: perfectly flat solid #00ff00 chroma-key background only, no shadow, no gradient, no texture, no floor plane. Do not use #00ff00 anywhere in the character.
Style constraints: pixel art, 256x256 game sprite target, readable at small size, same scale/outline density/standing posture as the Wukong reference. No text, no watermark, no signature.
```
