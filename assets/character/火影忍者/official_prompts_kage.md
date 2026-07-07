# 火影忍者历代影官方形态绘制提示词

本文件用于生成 `main/assets/character/火影忍者/历代影/` 下的五大忍村历代影站立立绘。只采用官方主线中正式担任或官方列为代理担任的影级职务形态；不采用同人漫画、原创皮肤、动画原创秽土第三风影、六道仙人召唤的灵魂状态、或团藏这类未正式批准的候补影。

统一要求：

- 输出为单角色、全身、初始站立立绘。
- 风格参考 `main/assets/character/七龙珠/wukong/形态A/wukong.png`：小体量像素立绘、正面 3/4 站姿、黑/深紫外轮廓、粗颗粒像素块面、低抗锯齿、清晰块面高光。
- 原图使用纯 `#00ff00` 色键背景，后处理抠成透明 PNG。
- 不画文字、水印、签名、地面阴影、场景背景、其他角色。
- 武器、斗笠、斗篷、发尾和查克拉效果都必须贴近角色轮廓，不能占满画布。
- 秽土转生形态仅生成主线明确出现过的正式影：柱间、扉间、日斩、水门、罗砂、鬼灯幻月、矢仓、三代雷影艾、无。

通用英文模板：

```text
Create ONE full-body 2D pixel-art game sprite of [CHARACTER AND FORM], official Naruto/Boruto mainline form, using the Wukong sprite shown earlier as the visual style and stance reference: compact 256x256-ready pixel-art standing portrait, front 3/4 facing viewer, feet near bottom anchor, crisp dark outline, hard-edged chunky pixel clusters, low anti-aliasing, readable anime costume details, not smooth high-resolution illustration.

Subject details: [OFFICIAL IDENTITY MARKERS].
Composition: centered full body, front torso visible, both shoulders visible, contained inside the frame with generous padding. Keep all weapons, hats, capes, hair, and effects close to the body. No extra characters, no text anywhere.
Background: perfectly flat solid #00ff00 chroma-key background, one uniform color, no shadows, no gradients, no texture, no floor plane. Do not use #00ff00 anywhere in the character. No watermark, no signature.
```

## 木叶隐村 Hokage

### hashirama_senju / 形态01_初代火影

```text
Create ONE full-body 2D pixel-art game sprite of Hashirama Senju as the First Hokage, official Naruto mainline form, using the Wukong sprite shown earlier as the visual style and stance reference: compact 256x256-ready pixel-art standing portrait, front 3/4 facing viewer, feet near bottom anchor, crisp dark outline, hard-edged chunky pixel clusters, low anti-aliasing, readable anime costume details, not smooth high-resolution illustration.
Subject details: Hashirama Senju with long dark hair, calm powerful face, red layered shinobi armor over a dark under-suit, arm guards, shinobi sandals, no Hokage hat, no giant wood dragon, no sage face marks.
Composition: centered full body, front torso visible, both shoulders visible, contained inside the frame with generous padding. Background: perfectly flat solid #00ff00 chroma-key background. No text, no watermark, no signature.
```

### hashirama_senju / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Hashirama Senju in his official Edo Tensei / Impure World Reincarnation form, using the Wukong sprite shown earlier as style reference.
Subject details: same First Hokage red armor and long dark hair, pale gray reanimated skin, subtle cracked Edo Tensei fissures on face and exposed skin, darkened eyes, calm battle stance. No coffin, no paper talisman, no wood golem.
Composition and background: centered full body, front 3/4, compact 256x256 pixel sprite, flat #00ff00 chroma-key background, no text or watermark.
```

### tobirama_senju / 形态01_二代火影

```text
Create ONE full-body 2D pixel-art game sprite of Tobirama Senju as the Second Hokage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Tobirama with short spiky white hair, stern red eye markings, blue armor plates over dark shinobi clothes, white fur collar, forehead protector, shinobi sandals, authoritative tactical stance. Keep water effects absent.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### tobirama_senju / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Tobirama Senju in his official Edo Tensei form, using the Wukong sprite shown earlier as style reference.
Subject details: Second Hokage blue armor, white fur collar, spiky white hair, red eye markings, pale gray cracked reanimated skin, darkened Edo eyes, composed combat stance. No water dragon, no coffin, no paper talisman.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### hiruzen_sarutobi / 形态01_三代火影

```text
Create ONE full-body 2D pixel-art game sprite of Hiruzen Sarutobi as the Third Hokage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: elderly Hiruzen with short gray hair, small beard, Konoha forehead protector, red-and-white Hokage battle robe or armor-like shinobi outfit, pipe optional but kept close, wise stern stance. No summoned Enma staff extension.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### hiruzen_sarutobi / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Hiruzen Sarutobi in his official Edo Tensei form, using the Wukong sprite shown earlier as style reference.
Subject details: elderly Third Hokage with gray hair, beard, Konoha forehead protector, Hokage battle outfit, pale gray cracked Edo Tensei skin, darkened eyes, staff kept close if included. No coffin, no paper talisman.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### minato_namikaze / 形态01_四代火影

```text
Create ONE full-body 2D pixel-art game sprite of Minato Namikaze as the Fourth Hokage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Minato with spiky blond hair, blue eyes, Konoha forehead protector, dark shinobi suit, white Hokage cloak with flame-red trim, calm heroic stance, tri-pronged kunai kept close if included. Do not write kanji on the cloak.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### minato_namikaze / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Minato Namikaze in his official Edo Tensei Fourth Hokage form, using the Wukong sprite shown earlier as style reference.
Subject details: spiky blond hair, Konoha forehead protector, dark shinobi suit, white Hokage cloak with flame-red trim, pale gray cracked Edo skin, darkened eyes, tri-pronged kunai held close. Do not write kanji or text on the cloak.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### tsunade / 形态01_五代火影

```text
Create ONE full-body 2D pixel-art game sprite of Tsunade as the Fifth Hokage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Tsunade with long blonde twin ponytails, diamond seal on forehead, green haori jacket over gray kimono-style top, dark pants, open-toed sandals, confident medical-ninja stance. Use muted forest green only, not neon #00ff00.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### kakashi_hatake / 形态01_六代火影

```text
Create ONE full-body 2D pixel-art game sprite of Kakashi Hatake as the Sixth Hokage, official Naruto/Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Kakashi with spiky silver hair, face mask, one visible calm eye, dark shinobi clothes, green flak vest or Hokage-era cloak elements, relaxed one-hand-in-pocket tactical stance. No Sharingan glow, no lightning blade.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### naruto_uzumaki / 形态01_七代火影

```text
Create ONE full-body 2D pixel-art game sprite of Naruto Uzumaki as the Seventh Hokage, official Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Naruto with short blond hair, whisker cheek marks, orange-and-black Hokage outfit, white cloak with orange flame trim if included, calm mature leader stance. Do not write kanji or text on the cloak.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### shikamaru_nara / 形态01_代理八代目火影

```text
Create ONE full-body 2D pixel-art game sprite of Shikamaru Nara as the provisional Eighth Hokage, official Boruto: Two Blue Vortex mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Shikamaru with tied-up dark hair, composed tired expression, dark shinobi outfit, Hokage-style white cloak or official leader coat kept plain without written kanji, hands relaxed, strategic calm stance. No shadow jutsu effect.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

## 砂隐村 Kazekage

### reto / 形态01_初代风影

```text
Create ONE full-body 2D pixel-art game sprite of Reto as the First Kazekage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: older Sunagakure founder leader, tan desert shinobi clothing, wrapped headgear or Kazekage-style cloth cap, layered robe, stern weathered face, dignified desert-leader stance. No sand storm effect, no text on clothing.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### shamon / 形态01_二代风影

```text
Create ONE full-body 2D pixel-art game sprite of Shamon as the Second Kazekage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Sunagakure elder shinobi with wrapped head covering, one eye covered or shaded, desert robe and shinobi armor elements, reserved puppet-master leader stance. No puppets, no sand effects, no text.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### third_kazekage / 形态01_三代风影

```text
Create ONE full-body 2D pixel-art game sprite of the Third Kazekage in his official living human form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Third Kazekage with dark hair, Sunagakure shinobi clothing, desert-toned cloak or flak armor, serious face, calm strongest-Kazekage stance. Do not make him a puppet body, do not include iron sand.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### rasa / 形态01_四代风影

```text
Create ONE full-body 2D pixel-art game sprite of Rasa as the Fourth Kazekage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Rasa with short auburn/brown hair, stern face, Kazekage robe and desert shinobi clothes, white or sand-colored cloak, compact gold dust gourd or sand accent kept close if included. No giant gold dust wave.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### rasa / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Rasa in his official Edo Tensei Fourth Kazekage form, using the Wukong sprite shown earlier as style reference.
Subject details: Fourth Kazekage robe, short auburn/brown hair, pale gray cracked Edo skin, darkened eyes, stern reanimated stance, small gold dust accent kept tight to the body. No giant sand wave, no coffin.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### gaara / 形态01_五代风影

```text
Create ONE full-body 2D pixel-art game sprite of Gaara as the Fifth Kazekage, official Naruto/Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Gaara with short red hair, pale face, dark-rimmed eyes, Kazekage robe or red-brown shinobi outfit, large sand gourd kept close on his back, calm protective stance. No giant sand arms or Shukaku form.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

## 雾隐村 Mizukage

### byakuren / 形态01_初代水影

```text
Create ONE full-body 2D pixel-art game sprite of Byakuren as the First Mizukage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: elderly Kirigakure founder with long white beard or moustache, one eye scarred or covered, layered mist-village robe, calm severe elder stance. No water dragon, no mist cloud.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### gengetsu_hozuki / 形态01_二代水影

```text
Create ONE full-body 2D pixel-art game sprite of Gengetsu Hozuki as the Second Mizukage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Gengetsu with light-colored hair, thin moustache, sharp grin, Kirigakure robe or striped high-collar outfit, confident mocking stance. No giant clam summon, no steam explosion effect.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### gengetsu_hozuki / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Gengetsu Hozuki in his official Edo Tensei Second Mizukage form, using the Wukong sprite shown earlier as style reference.
Subject details: same Second Mizukage outfit, pale gray cracked Edo skin, darkened eyes, light hair and moustache, playful dangerous stance. No clam summon, no coffin.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### third_mizukage / 形态01_三代水影

```text
Create ONE full-body 2D pixel-art game sprite of the Third Mizukage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Kirigakure leader with long dark hair, composed face, formal mist-village robe, high collar or layered kimono-like outfit, reserved summit-era stance. No water effect, no extra characters.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### yagura_karatachi / 形态01_四代水影

```text
Create ONE full-body 2D pixel-art game sprite of Yagura Karatachi as the Fourth Mizukage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: youthful Yagura with short gray-green hair, scar below one eye, blue or gray Mizukage outfit, small build, large hooked staff kept close, calm eerie jinchuriki stance. No Three-Tails transformation.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### yagura_karatachi / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Yagura Karatachi in his official Edo Tensei Fourth Mizukage form, using the Wukong sprite shown earlier as style reference.
Subject details: youthful Fourth Mizukage with short gray-green hair, scar below one eye, blue-gray outfit, hooked staff kept close, pale cracked Edo skin, darkened eyes, no tailed-beast cloak.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### mei_terumi / 形态01_五代水影

```text
Create ONE full-body 2D pixel-art game sprite of Mei Terumi as the Fifth Mizukage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Mei with long auburn hair covering one eye, teal-blue dress or Mizukage outfit, high heels or shinobi sandals, confident elegant stance. No lava, no steam, no text.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### chojuro / 形态01_六代水影

```text
Create ONE full-body 2D pixel-art game sprite of Chojuro as the Sixth Mizukage, official Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Chojuro with blue hair, glasses, Kirigakure outfit, sword Hiramekarei carried close on back or at side, modest serious stance. Keep the sword compact inside the frame.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

## 云隐村 Raikage

### first_raikage_a / 形态01_初代雷影

```text
Create ONE full-body 2D pixel-art game sprite of A as the First Raikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Kumogakure founder leader with dark skin, strong muscular build, early cloud-village armor or robe, head covering or formal Raikage mantle, stern commanding stance. No lightning cloak.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### second_raikage_a / 形态01_二代雷影

```text
Create ONE full-body 2D pixel-art game sprite of A as the Second Raikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: dark-skinned Kumogakure leader with sturdy build, formal cloud-village robe or armor, beard or stern elder features if visible, calm diplomatic stance. No lightning cloak, no extra characters.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### third_raikage_a / 形态01_三代雷影

```text
Create ONE full-body 2D pixel-art game sprite of A as the Third Raikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: very muscular dark-skinned Third Raikage with white hair and moustache, Kumogakure armor or one-shoulder battle outfit, arm guards, bare powerful arms, stern indestructible stance. No lightning aura.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### third_raikage_a / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of A the Third Raikage in his official Edo Tensei form, using the Wukong sprite shown earlier as style reference.
Subject details: muscular Third Raikage with white hair and moustache, battle outfit, pale gray cracked Edo skin over dark complexion, darkened reanimated eyes, bare arms, powerful stance. No lightning aura, no coffin.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### fourth_raikage_a / 形态01_四代雷影

```text
Create ONE full-body 2D pixel-art game sprite of A as the Fourth Raikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: tall muscular dark-skinned Fourth Raikage with blond hair and moustache, white Raikage cloak or bare-chested battle outfit, massive arms, wrestling-champion stance. No lightning chakra mode aura.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### darui / 形态01_五代雷影

```text
Create ONE full-body 2D pixel-art game sprite of Darui as the Fifth Raikage, official Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Darui with dark skin, white hair over one eye, laid-back face, Kumogakure flak outfit or Raikage cloak, sword kept close on back if included, relaxed but powerful stance. No black lightning effect.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

## 岩隐村 Tsuchikage

### ishikawa / 形态01_初代土影

```text
Create ONE full-body 2D pixel-art game sprite of Ishikawa as the First Tsuchikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: elderly Iwagakure founder with heavy eyebrows or moustache, earth-toned shinobi robe, traditional stone-village clothing, compact elder stance. No giant rock effect, no extra characters.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### mu / 形态01_二代土影

```text
Create ONE full-body 2D pixel-art game sprite of Mu as the Second Tsuchikage, official Naruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: Mu with full-body white bandage wrappings, only eyes visible, Iwagakure shinobi cloak or simple robe, floating or lightly planted stance, mysterious particle-style leader presence. No particle beam effect.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### mu / 形态02_秽土转生

```text
Create ONE full-body 2D pixel-art game sprite of Mu in his official Edo Tensei Second Tsuchikage form, using the Wukong sprite shown earlier as style reference.
Subject details: bandaged Second Tsuchikage, pale gray cracked Edo skin visible only at small exposed areas, darkened eyes, Iwagakure cloak, floating or lightly planted stance. No particle beam, no coffin.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### onoki / 形态01_三代土影

```text
Create ONE full-body 2D pixel-art game sprite of Onoki as the Third Tsuchikage, official Naruto/Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: very short elderly Onoki with bald head, white moustache, red nose, green-and-yellow Iwagakure outfit or Tsuchikage robe, floating elder stance, hands behind back. No particle release cube.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```

### kurotsuchi / 形态01_四代土影

```text
Create ONE full-body 2D pixel-art game sprite of Kurotsuchi as the Fourth Tsuchikage, official Boruto mainline form, using the Wukong sprite shown earlier as style reference.
Subject details: adult Kurotsuchi with short dark hair, Iwagakure red or brown shinobi outfit, confident earth-style leader stance, gloves and boots, no lava or rock effect.
Composition and background: centered front 3/4 full body, compact 256x256 pixel sprite, flat #00ff00 background, no text or watermark.
```
