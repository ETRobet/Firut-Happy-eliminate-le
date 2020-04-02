

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)



function MainScene:ctor()
	--    设置层
	local bg_layer=cc.LayerColor:create(cc.c4b(0, 0, 0, 0))  
						:addTo(self)
	local ui_layer=cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
						:addTo(self)
	--设置图片
    local sprite_frames=display.addSpriteFrames("image/image1.plist", "image/image1.pvr.ccz")
    local start_btn_images={normal="#start1.png",
    						pressed="#start2.png"}
	--设置背景
    local bg_sprite=display.newSprite("image/background1.png")
				    	:pos(display.cx, display.cy)  --两种设置方法初始化和通用
				    	-- :setPosition(cc.p(display.cx, display.cy))
				    	:addTo(bg_layer)
	--设置开始按钮
	local start_btn=cc.ui.UIPushButton.new(start_btn_images,{scale9=false})
						:onButtonClicked(function(evnet)
														--按键音效
														audio.playSound("music/hitbtn.wav")
														local PlayScene=import("app.scenes.PlayScene").new() 
														display.replaceScene(PlayScene,"turnOffTiles",0.5) 
														end)
						:align(display.CENTER,display.cx,display.cy)
						:addTo(ui_layer)

--测试节点共有的位置输出
--获取getPosition的X，Y值使用getPositionX()
-- local x,y=bg_sprite:getPosition()
--local a=bg_sprite:getPositionX()
-- 	print(x..y)
-- 	print(a)



end

function MainScene:onEnter()
	
end

function MainScene:onExit()
end

return MainScene
