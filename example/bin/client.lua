package.path =  "../../depends/proto4z/?.lua;" .. package.path
--require
require("proto4z")
require("TestProto")
logw = summer.logw
logi = summer.logi
loge = summer.loge


function rateUpdate(props, rate)
    local r = props[rate] or 0.0
    r = r / 1000.0
    props[rate] = r
end

function test(props)
    local rate = props.hp or 0.0
    props.hp = rate
end

function update(props)
    local attrs = {"hp", "atk", "curHP", "def",  "anti"}
    for k,v in pairs(attrs) do
        props[v]  = math.random()
        rateUpdate(props, v)
    end
    test(props)
end


_props = {}
for i=1, 10000 do
    local props = {}
    update(props)
    _props = props
end










--echo pack

local echo = {  _iarray = {{_char=1,_uchar=2,_short=3,_ushort=4,_int=5,_uint=6,_i64=12345678,_ui64=12345678.2},{_char=1,_uchar=2,_short=3,_ushort=4,_int=5,_uint=6,_i64="1234567812213123.2",_ui64="123"}},
                _farray = {{_float=2.235,_double=235.111},{_float=2.235,_double=235.111},},
                _sarray = {{_string="abcdefg"},{_string="abcdefg"},{_string="abcdefg"}},
                _imap = {{k="123", v={_char=1,_uchar=2,_short=3,_ushort=4,_int=5,_uint=6,_i64="12345678",_ui64="12345678"}}, {k="223", v={_char=1,_uchar=2,_short=3,_ushort=4,_int=5,_uint=6,_i64="12345678",_ui64="12345678"}}},
                _fmap = {{k="523", v={_float=2.235,_double=235.111}},{k="623", v={_float=2.235,_double=235.111}}},
                _smap = {{k="723", v={_string="abcdefg"}},{k="823", v={_string="abcdefg"}}},
                }

-- 连接成功事件
local function whenLinked(sID, remoteIP, remotePort)
    print("session is on connected. sID=" .. sID .. ", remoteIP=" .. remoteIP .. ", remotePort=" .. remotePort)
    local data = Proto4z.encode(echo, "EchoPack")
    Proto4z.dump(echo)
    Proto4z.putbin(data)
    summer.sendContent(sID, Proto4z.EchoPack.__getID, data)
end
summer.whenLinked(whenLinked)

-- 收到消息
local function whenMessage(sID, pID, content)
    --print("whenMessage. sID=" .. sID .. ", pID=" .. pID )
    --Proto4z.putbin(content)
    local name = Proto4z.getName(pID)
    if name == nil then
        logw("unknown message id recv. pID=" .. pID)
    else
            local echo = Proto4z.decode(content, name)
            --Proto4z.dump(echo)
            local data = Proto4z.encode(echo, "EchoPack")
            summer.sendContent(sID, Proto4z.EchoPack.__getID, data)
            --local data = Proto4z.pack(echo, "EchoPack")
            --summer.sendData(sID, data)
            
    end

end
summer.whenMessage(whenMessage)

-- 连接断开事件
local function whenClosed(sID, remoteIP, remotePort)
    print("session is on disconnect. sID=" .. sID .. ", remoteIP=" .. remoteIP .. ", remotePort=" .. remotePort)
end
summer.whenClosed(whenClosed)

-- 脉冲
local function whenPulse(sID)
    print("session is on pulse. sID=" .. sID )
end
summer.whenPulse(whenPulse)

--启动网络
summer.start()

--连接服务器
local id = summer.addConnect("127.0.0.1", 8081, nil, 5)
if id == nil then
    summer.logw("id == nil when addConnect")
end
print("new connect id=" .. id)

--进入循环
--summer.run()
--如果嵌入其他程序 例如cocos2dx, 可以吧runOnce设置true然后放入update中.
--while summer.runOnce(true) do
while summer.runOnce() do
end


