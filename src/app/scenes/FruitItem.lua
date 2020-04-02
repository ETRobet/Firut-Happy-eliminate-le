-- local FruitItem = class("FruitItem", function() return display.newScene("FruitItem") end)

--外部初始化益处：若失败则不再执行ctor
local FruitItem = class("FruitItem", function(x,y,fruitIndex) --既是类名亦是构造函数
	--获取或随机水果类型
	--如果fruitIndex为nil则随机数
	fruitIndex=fruitIndex or math.round(math.random()*1000)%8+1  --注意这里可以用相同参数名初始化
	local sprite=display.newSprite("#fruit"..fruitIndex..".png")
	sprite:setScale(1.8)
	--获取水果类型 位置 高亮状态
	sprite.fruitIndex=fruitIndex
	sprite.x=x
	sprite.y=y


	-- print(sprite:getPosition().x..sprite:getPosition().y)
	sprite.isActive=false
	return sprite
    -- return display.newScene("FruitItem")
end)

function FruitItem:setActive(active)
--active为传入的激活状态
self.isActive=active
--载入图像帧
local frame
if(active) then frame=display.newSpriteFrame("fruitlignt"..self.fruitIndex..".png")--材质文件名取错了 	
				else  frame=display.newSpriteFrame("fruit"..self.fruitIndex..".png") 	
end
self:setScale(1.8)
self:setSpriteFrame(frame)
--高亮图片切换
if(active) then 
	 self:stopAllActions() 
	 local scaleTo1=cc.ScaleTo:create(0.1, 1) 
	 local scaleTo2=cc.ScaleTo:create(0.05, 1.8)
     self:runAction(cc.Sequence:create(scaleTo1,scaleTo2))
end
end				 

function FruitItem.getWidth()
--获取图片宽度（美工已经统一大小 所以为类方法）
	g_fruitWidth=0
	if(0==g_fruitWidth) then 
		local sprite=display.newSprite("#fruit1.png")
		g_fruitWidth=sprite:getContentSize().width
	end
	return g_fruitWidth
end

-- function FruitItem:setPosition(x,y)
-- self.x=x
-- print(x)
-- self.y=y
-- print(y)
-- end
function FruitItem:ctor()
	return FruitItem
end

function FruitItem:onEnter()
end

function FruitItem:onExit()
end

return FruitItem
