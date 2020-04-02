FruitItem=import("app.scenes.FruitItem")
local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)
--主程序创建框架层  框架层添加层监听器添加and精灵监听器实现功能→所有UI属性改变自动绘图and精灵移动应用动作函数同时改变监听器触发范围
function PlayScene:ctor()		--设置层
	bg_layer=cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
						:addTo(self)
	ui_layer=cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
						:addTo(self)
	--设置图片
  	sprite_frames=display.addSpriteFrames("image/image1.plist", "image/image1.pvr.ccz")

	--初始化UI变量
	self.highScore=cc.UserDefault:getInstance():getIntegerForKey("HighScore")
	self.stage=cc.UserDefault:getInstance():getIntegerForKey("Stage")
	if self.stage==0 then self.stage=1 end
	self.target=self.stage*200
	self.curScore=0
	--初始化界面ui
	self:initUI()
	--初始化分数变量
	self.scoreStart=5--水果基分
	self.scoreStep=10--加成分
	self.activeScore=0--当前高亮水果得分
	--初始化活动UI
	--静态UI放入initUI封装函数中 动态UI放入主函数
	self.activeScoreLabel=display.newTTFLabel({text="",size=30})
						:pos(display.width/2,120)
						:addTo(ui_layer)
	self.activeScoreLabel:setColor(display.COLOR_WHITE)
	self.curScoreLabel=display.newTTFLabel({text="",size=60})
						:pos(display.width/2,display.top-180)
						:addTo(ui_layer)
	self.curScoreLabel:setColor(display.COLOR_WHITE)
	audio.playMusic("music/playscenebg.wav",true)



    --设置背景
    local bg_sprite=display.newSprite("image/background2.png")
				    	:pos(display.cx, display.cy)
				    	:addTo(bg_layer)
	-- --测验场景载入
	-- print("进入PlayScene")
	--随机数种子
	math.newrandomseed()
	--设置水果矩阵
	self.xCount=8 --矩阵水平数
	self.yCount=8 --矩阵垂直数
	self.fruitgap=30 --水果间距
	--初始化1号水果坐标
	self.matrixLBX=(display.width-FruitItem.getWidth()*self.xCount-(self.yCount-1)*self.fruitgap)/2
	self.matrixLBY=(display.height-FruitItem.getWidth()*self.yCount-(self.xCount-1)*self.fruitgap)/2-30
-- print("转场结束")
	self:addNodeEventListener(cc.NODE_EVENT,function(event)

														if event.name=="enterTransitionFinish" then
															self:initMatrix()
															-- print("转场结束")--TOTEST
															end
														end)





end
--初始化水果矩阵
function PlayScene:initMatrix()
	--创建空矩阵
	self.matrix={}
	--高亮水果
	self.actives={}
	for y=1,self.yCount do
		for x=1,self.xCount do
			if 1==y and 2==x then
				--确保有可消除的水果
				self:createAndDropFruit(x,y,self.matrix[1].fruitIndex)
			else
				self:createAndDropFruit(x,y,nil)
			end
		end
	end
end
--清除已高亮水果
function PlayScene:inactive()
	for _,fruit in pairs(self.actives)do
		if(fruit) then fruit:setActive(false)--处理table中对应的值
		end
	end
	self.actives={}--重置table
end
function PlayScene:activeNeighbor(fruit)	--高亮fruit
	if false ==fruit.isActive then 
		fruit:setActive(true)
		table.insert(self.actives,fruit)
	end
	--检查左右两边水果

	if(fruit.x-1)>=1 then 
		local leftNeighbor=self.matrix[(fruit.y-1)*self.xCount+fruit.x-1]
		if(leftNeighbor.isActive==false) and(leftNeighbor.fruitIndex==fruit.fruitIndex)then
			leftNeighbor:setActive(true)
			table.insert(self.actives,leftNeighbor)
			self:activeNeighbor(leftNeighbor)
		end
	end


	
	if(fruit.x+1)<=self.xCount then 
		local rightNeighbor=self.matrix[(fruit.y-1)*self.xCount+fruit.x+1]
		if(rightNeighbor.isActive==false) and(rightNeighbor.fruitIndex==fruit.fruitIndex)then
			rightNeighbor:setActive(true)
			table.insert(self.actives,rightNeighbor)
			self:activeNeighbor(rightNeighbor)
		end
	end

--检查上下两边水果 
	if(fruit.y+1)<=self.yCount then 
		local upNeighbor=self.matrix[fruit.y*self.xCount+fruit.x]
		if(upNeighbor.isActive==false) and(upNeighbor.fruitIndex==fruit.fruitIndex)then
			upNeighbor:setActive(true)
			table.insert(self.actives,upNeighbor)
			self:activeNeighbor(upNeighbor)
		end
	end

	
	if(fruit.y-1)>=1 then 
		local downNeighbor=self.matrix[(fruit.y-2)*self.xCount+fruit.x]
		if(downNeighbor.isActive==false) and(downNeighbor.fruitIndex==fruit.fruitIndex)then
			downNeighbor:setActive(true)
			table.insert(self.actives,downNeighbor)
			self:activeNeighbor(downNeighbor)
		end
	end
end


--水果矩阵绘图
function PlayScene:createAndDropFruit(x,y,fruitIndex)
	local newFruit=FruitItem.new(x,y,fruitIndex)
	local endPosition=self:positionOfFruit(x,y)
	local startPosition=cc.p(endPosition.x,endPosition.y+display.height/2)
	newFruit:setPosition(startPosition) 
	local speed =startPosition.y/(2*display.height)
	newFruit:runAction(cc.MoveTo:create(speed,endPosition))
	self.matrix[(y-1)*self.xCount+x]=newFruit--此数组非定位用，用以单数字标定水果
	newFruit:setTouchEnabled(true)
	newFruit:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
																if event.name=="ended" then
																if newFruit.isActive then
																	--不同消除音效切换
																	-- local musicIndex=#self.actives
																	-- if(musicIndex<2) then musicIndex=2 end
																	-- if(musicIndex>9)then musicIndex=9 end
																	-- local tmpStr=string.format("music/hitfruit.mp3", ···)
																	audio.playSound("music/hitfruit.mp3")
																	self:removeActivedFruits()
																	self:dropFruits()
																	self:checkNextStage()
																else
																	self:inactive()
																	--高亮音效
																	audio.playSound("music/light.wav")
																	self:activeNeighbor(newFruit)
																	self:showActivesScore()
																	-- print("x:"..newFruit.x.."y:"..newFruit.y)--TOTEST
																end
															end 
															if event.name=="began" then
																return true 
															end
														end)

	self:addChild(newFruit)
	

end
--单个水果元素绝对坐标
--改定位方法使用了两个锁定给水果 水果x，y坐标 与 绘图区域范围
function PlayScene:positionOfFruit(x,y)
	local px=self.matrixLBX+(FruitItem.getWidth()+self.fruitgap)*(x-1)+FruitItem	.getWidth()/2
	local py=self.matrixLBY+(FruitItem.getWidth()+self.fruitgap)*(y-1)+FruitItem	.getWidth()/2
	return cc.p(px,py)
end
--初始化UI界面
function PlayScene:initUI()
	--最高分面板
	display.newSprite("#highscore.png")
						:align(display.LEFT_CENTER, display.left+15, display.top-30)
						:addTo(ui_layer)
	display.newSprite("#highscore_part.png")
						:align(display.LEFT_CENTER, display.cx+10, display.top-26)
						:addTo(ui_layer)
	self.highScoreLabel=cc.ui.UILabel.new({UILabelType=1,text=tostring(self.highScore),font="font/number38.fnt"})
						:align(display.CENTER, display.cx+125, display.top-26)
						:addTo(ui_layer)
--目标面板
    display.newSprite("#target.png")
				    	:align(display.LEFT_CENTER,display.left+15,display.top-90)
				    	:addTo(ui_layer)
    display.newSprite("#target_part.png")
						:align(display.LEFT_CENTER,display.left+165,display.top-90)
				    	:addTo(ui_layer)
	self.tagetLabel=cc.ui.UILabel.new({UILabelType=1,text=tostring(self.target),font="font/number38.fnt"})
						:align(display.CENTER, display.left+220, display.top-90)
						:addTo(ui_layer)
--场景计数器
    display.newSprite("#stage.png")
				    	:align(display.LEFT_CENTER,display.left+320,display.top-90)
				    	:addTo(ui_layer)
    display.newSprite("#stage_part.png")
				    	:align(display.LEFT_CENTER,display.left+470,display.top-86)
				    	:addTo(ui_layer)		
	self.stageLabel=cc.ui.UILabel.new({UILabelType=1,text=tostring(self.stage),font="font/number38.fnt"})
						:align(display.CENTER, display.cx+205, display.top-88)
						:addTo(ui_layer)
--场景进度条
    local sliderImages={
    bar="image/The_time_axis_Tunnel.png",
    button="image/The_time_axis_Trolley.png",
}
    self.sliderBar=cc.ui.UISlider.new(display.LEFT_TO_RIGHT, sliderImages, {scale9=false})
    --设置滑动条大小；控件取值；位置对齐
    					:setSliderSize(display.width,125)
    					:setSliderValue(0)
    					:align(display.LEFT_BOTTOM,0,0)--区别Button与Bottom
    					:addTo(ui_layer)
    self.sliderBar:setTouchEnabled(false)



 end	
 function PlayScene:showActivesScore()if 1==#self.actives then
	self:inactive()
	self.activeScoreLabel:setString("")
	self.activeScore=0
	return
end
self.activeScore=(self.scoreStart*2+self.scoreStep*(#self.actives-1)*#self.actives/2)
self.activeScoreLabel:setString(string.format("%d连消,得分%d",#self.actives,self.activeScore))
 end	

 function PlayScene:removeActivedFruits()


 	local fruitScore=self.scoreStart
 	for _,fruit in pairs(self.actives)do
 		if(fruit)then 
 			self.matrix[(fruit.y-1)*self.xCount+fruit.x]=nil
 			-- self:scorePopupEffect(fruitScore,fruit:getPosition())
 			--TODO粒子特效
 			fruitScore=fruitScore+self.scoreStep
 			local time=0.2
 	--爆炸圈
 			local circleSprite=display.newSprite("image/circle.png")
 					:pos(fruit:getPosition())
 					:addTo(self)
 			circleSprite:setScale(0)
 			circleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(time, 1.0),
 													cc.CallFunc:create(function()
 														circleSprite:removeFromParent()
 														end)
 														)
 													)
 	--爆炸碎片
 			local emitter=cc.ParticleSystemQuad:create("image/stars.plist")
 			emitter:setPosition(fruit:getPosition())
 			local batch=cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
 			batch:addChild(emitter)
 			self:addChild(batch)
 			fruit:removeFromParent()
 		end
 	end
 	self.actives={}
 	self.curScore=self.curScore+self.activeScore
 	self.curScoreLabel:setString(tostring(self.curScore))
 	self.activeScoreLabel:setString("")
 	self.activeScore=0
 	--更新进度条
 	local Value=self.curScore/self.target*100
 	
    if Value>100 then
    	Value=100
    end
    -- print(Value)--TOTEST
    self.sliderBar:setSliderValue(Value)

 end		

 function PlayScene:dropFruits() 	local emptyInfo={}
 	--掉落水果 按列处理
 	for x=1,self.xCount do
 		local removeFruits=0
 		local newY=0
 		for y=1,self.yCount do
 			local temp=self.matrix[(y-1)*self.xCount+x]--当通过任意的var变量赋值精灵永远是引用 除非新建一个精灵变量复制
 			if temp==nil then
 				--水果已被移除
 				removeFruits=removeFruits+1
 			else
 				--从下到上检测是否移除
 				if removeFruits>0 then
 					newY=y-removeFruits
 					self.matrix[(newY-1)*self.xCount+x]=temp--上一个空缺处
 					temp.y=newY--精灵的变量为自定义不会改变通过动作函数改变
 					self.matrix[(y-1)*self.xCount+x]=nil--当前位置置空
 					local endPosition=self:positionOfFruit(x,newY)
 					local speed=(temp:getPositionY()-endPosition.y)/display.height

 					temp:stopAllActions()
 					temp:runAction(cc.MoveTo:create(speed,endPosition))--直接用动作方法实现精灵运动
 				end
 			end
 		end
 		emptyInfo[x]=removeFruits
 		
 	
 	end
 	for x=1,self.xCount do
 		for y=self.yCount-emptyInfo[x]+1,self.yCount do
 			self:createAndDropFruit(x, y)--调用函数实现新精灵创建
 		end
 	end
 end

function PlayScene:checkNextStage()
	--检测通关情况
	if self.curScore<self.target then return end
	--通关音乐
	audio.playSound("music/completed.wav")
	--通关层与触摸监听吞噬
	local resultLayer=display.newColorLayer(cc.c4b(0,0,0,150))

				resultLayer:addTo(self)
				resultLayer:setTouchEnabled(true)
				resultLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
					                                        if event.name=="began" then return true end
					                                        end)

	--数据更新
	if self.curScore>=self.highScore then self.highScore=self.curScore end
	self.stage=self.stage+1
	-- self.target=self.stage*200
	--存档
	cc.UserDefault:getInstance():setIntegerForKey("HighScore",self.highScore)
	cc.UserDefault:getInstance():setIntegerForKey("Stage", self.stage)
	--通关界面
	display.newTTFLabel({text=string.format("恭喜过关！\n最高得分%d", self.highScore),size=60})
				:pos(display.cx,display.cy+140)
				:addTo(resultLayer)
	--开始按钮
	local startBtnImages={
											normal="#start1.png",
    						  				pressed="#start2.png"
    						  				}
   local backBtn=cc.ui.UIPushButton.new(startBtnImages,{scale9=false})
				:onButtonClicked(function(evnet)
												--停止背景音乐
												audio.stopMusic()
												local mainScene=import("app.scenes.MainScene"):new() 
												display.replaceScene(mainScene,"flipx",0.5)
												end)
				:align(display.CENTER,display.cx,display.cy-80)
				:addTo(resultLayer)--[string "framework/shortcodes.lua"]:69: in function 'addTo'  报错原因是传入nil layer



end

function PlayScene:onEnter()
end

function PlayScene:onExit()
end

return PlayScene
