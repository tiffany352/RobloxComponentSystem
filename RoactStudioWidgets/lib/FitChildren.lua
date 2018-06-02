local Roact = require(script.Parent.Parent.Roact)

local function join(a, b)
	local t = {}
	for k,v in pairs(a) do
		t[k] = v
	end
	for k,v in pairs(b) do
		t[k] = v
	end
	return t
end

local function applySize(udim, value)
	if udim.Scale == 0 then
		return UDim.new(0, value)
	else
		return udim
	end
end

local function FitChildrenFactory(name)
	local FitChildren = Roact.Component:extend("FitChildren("..name..")")

	function FitChildren:_updateSize()
		local size = self.layout.AbsoluteContentSize
		if self.padding then
			local p = self.padding
			size = size + Vector2.new(
				p.PaddingLeft.Offset + p.PaddingRight.Offset,
				p.PaddingTop.Offset + p.PaddingBottom.Offset
			)
		end
		self.rbx.Size = UDim2.new(applySize(self.rbx.Size.X, size.X), applySize(self.rbx.Size.Y, size.Y))
		if self.rbx.ClassName == 'ScrollingFrame' then
			self.rbx.CanvasSize = UDim2.new(applySize(self.rbx.CanvasSize.X, size.X), applySize(self.rbx.CanvasSize.Y, size.Y))
		end
	end

	function FitChildren:_childAdded(inst)
		if inst:IsA("UILayout") then
			self.layout = inst
			self:_updateSize()
			self.sizeChangedConn = inst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				self:_updateSize()
			end)
		elseif inst.ClassName == 'UIPadding' then
			self.padding = inst
			self:_updateSize()
			self.paddingChangedConn = inst.Changed:Connect(function()
				self:_updateSize()
			end)
		end
	end

	function FitChildren:render()
		local props = self.props
		return Roact.createElement(name, join(props, {
			[Roact.Ref] = function(rbx)
				if rbx then
					self.rbx = rbx
					self.childAdded = rbx.ChildAdded:Connect(function(inst)
						self:_childAdded(inst)
					end)
					for _,child in pairs(rbx:GetChildren()) do
						self:_childAdded(child)
					end
				else
					self.rbx = nil
					self.childAdded:Disconnect()
					if self.sizeChangedConn then
						self.sizeChangedConn:Disconnect()
					end
					if self.paddingChangedConn then
						self.paddingChangedConn:Disconnect()
					end
				end
			end,
		}))
	end

	return FitChildren
end

local FitChildren = {}
FitChildren.Frame = FitChildrenFactory("Frame")
FitChildren.ScrollingFrame = FitChildrenFactory("ScrollingFrame")
return FitChildren
