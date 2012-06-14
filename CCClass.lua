-- middleclass.lua - v2.0 (2011-09)
-- Copyright (c) 2011 Enrique García Cota
-- additional code Copyright (c) 2011 Aaron Pendley
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local _classes = setmetatable({}, {__mode = "k"})

local function _setClassDictionariesMetatables(klass)
  local dict = klass.__instanceDict
  dict.__index = dict

  local super = klass.super
  if super then
    local superStatic = super.static
    setmetatable(dict, super.__instanceDict)
    setmetatable(klass.static, { __index = function(_,k) return dict[k] or superStatic[k] end })
  else
    setmetatable(klass.static, { __index = function(_,k) return dict[k] end })
  end
end

local function _setClassMetatable(klass)
  setmetatable(klass, {
    --__tostring = function() return "class" .. class.name end,
    __index    = klass.static,
    __newindex = klass.__instanceDict,
    __call     = function(self, ...) return self:new(...) end
  })
end

local function _createClass(super)
  local klass = { super = super, static = {}, __mixins = {}, __instanceDict={} }
  klass.subclasses = setmetatable({}, {__mode = "k"})

  _setClassDictionariesMetatables(klass)
  _setClassMetatable(klass)
  _classes[klass] = true

  return klass
end

local function _createLookupMetamethod(klass, name)
  return function(...)
    local method = klass.super[name]
    ccAssert( type(method)=='function', tostring(klass) .. " doesn't implement metamethod '" .. name .. "'" )
    return method(...)
  end
end

local function _setClassMetamethods(klass)
  for _,m in ipairs(klass.__metamethods) do
    klass[m]= _createLookupMetamethod(klass, m)
  end
end

local function _setDefaultInitializeMethod(klass, super)
  klass.init = function(instance, ...)
    return super.init(instance, ...)
  end
end

local function _includeMixin(klass, mixin)
  ccAssert(type(mixin)=='table', "mixin must be a table")
  for name,method in pairs(mixin) do
    if name ~= "included" and name ~= "static" then klass[name] = method end
  end
  if mixin.static then
    for name,method in pairs(mixin.static) do
      klass.static[name] = method
    end
  end
  if type(mixin.included)=="function" then mixin:included(klass) end
  klass.__mixins[mixin] = true
end

local function _subclassOf(aClass, other)
  if not _classes[aClass] or not _classes[other] or aClass.super == nil then return false end
  return aClass.super == other or _subclassOf(aClass.super, other)
end

local function _instanceOf(obj, aClass)
  if not _classes[aClass] or type(obj) ~= 'table' or not _classes[obj.class] then return false end
  if obj.class == aClass then return true end
  return _subclassOf(obj.class, aClass)
end

local function _includes(aClass, mixin)
  if not _classes[aClass] then return false end
  if aClass.__mixins[mixin] then return true end
  return _includes(aClass.super, mixin)
end

Object = _createClass("Object", nil)

Object.static.__metamethods = { '__add', '__call', '__concat', '__div', '__le', '__lt', 
                                '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' }

function Object.static:allocate()
  ccAssert(_classes[self], "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
  return setmetatable({ class = self }, self.__instanceDict)
end

function Object.static:new(...)
  local instance = self:allocate()
  instance:init(...)
  return instance
end

function Object.static:subclass()
  ccAssert(_classes[self], "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")

  local subclass = _createClass(self)
  _setClassMetamethods(subclass)
  _setDefaultInitializeMethod(subclass, self)
  self.subclasses[subclass] = true
  self:subclassed(subclass)

  return subclass
end

function Object.static:subclassed(other) end

function Object.static:include( ... )
  ccAssert(_classes[self], "Make sure you that you are using 'Class:include' instead of 'Class.include'")
  for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
  return self
end

Object.static.subclassOf = _subclassOf
Object.static.includes = _includes
Object.static.synth = ccSynth
Object.static.synthColor = ccSynthColor
Object.static.synthColor4 = ccSynthColor4
Object.static.synthVec2 = ccSynthVec2

function Object:init() end

function Object:__tostring() return "instance of " .. tostring(self.class) end

Object.instanceOf = _instanceOf
Object.is_a = _instanceOf

--apendley: renamed from 'class' to 'Class' to avoid conflict with Codea's class function
function CCClass(super, ...)
  super = super or Object
  return super:subclass(...)
end