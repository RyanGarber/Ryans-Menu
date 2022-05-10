--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

Ryan.JSON = {
    -- General --
    Version = "0.1.2",

    EscapeMap = {
        ["\\"] = "\\",
        ["\""] = "\"",
        ["\b"] = "b",
        ["\f"] = "f",
        ["\n"] = "n",
        ["\r"] = "r",
        ["\t"] = "t",
    },

    EscapeMapReverse = { -- filled later
        ["/"] = "/"
    },

    Escape = function(c)
        return "\\" .. (Ryan.JSON.EscapeMap[c] or string.format("u%04x", c:byte()))
    end,

    LiteralMap = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil
    },

    TypeFunctions = { -- filled later
        ["boolean"] = tostring
    },

    CharacterFunctions = {}, -- filled later


    -- Encode --
    EncodeNil = function(val) return "null" end,

    EncodeTable = function(val, stack)
        local res = {}
        stack = stack or {}

        if stack[val] then error("circular reference") end
        stack[val] = true

        if rawget(val, 1) ~= nil or next(val) == nil then
            local n = 0
            for k in pairs(val) do
                if type(k) ~= "number" then
                    error("invalid table: mixed or invalid key types")
                end
                n = n + 1
            end
            if n ~= #val then
                error("invalid table: sparse array")
            end

            for i, v in ipairs(val) do
                table.insert(res, Ryan.JSON.EncodeValue(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        else
            for k, v in pairs(val) do
                if type(k) ~= "string" then
                    error("invalid table: mixed or invalid key types")
                end
                table.insert(res, Ryan.JSON.EncodeValue(k, stack) .. ":" .. Ryan.JSON.EncodeValue(v, stack))
            end
            stack[val] = nil
            return "{" .. table.concat(res, ",") .. "}"
        end
    end,

    EncodeString = function(val)
        return '"' .. val:gsub('[%z\1-\31\\"]', Ryan.JSON.Escape) .. '"'
    end,

    EncodeNumber = function(val)
        if val ~= val or val <= -math.huge or val >= math.huge then
            error("unexpected number value '" .. tostring(val) .. "'")
        end
        return string.format("%.14g", val)
    end,

    EncodeValue = function(val, stack)
        local t = type(val)
        local f = Ryan.JSON.TypeFunctions[t]
        if f then
            return f(val, stack)
        end
        error("unexpected type '" .. t .. "'")
    end,

    Encode = function(val)
        return Ryan.JSON.EncodeValue(val)
    end,


    -- Decode --
    CreateSet = function(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[select(i, ...)] = true
        end
        return res
    end,

    NextCharacter = function(str, idx, set, negate)
        for i = idx, #str do
            if set[str:sub(i, i)] ~= negate then
                return i
            end
        end
        return #str + 1
    end,

    DecodeError = function(str, idx, msg)
        local line_count = 1
        local col_count = 1
        for i = 1, idx - 1 do
            col_count = col_count + 1
            if str:sub(i, i) == "\n" then
                line_count = line_count + 1
                col_count = 1
            end
        end
        error(string.format("%s at line %d col %d", msg, line_count, col_count))
    end,

    CodePointToUTF8 = function(n)
        -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
        local f = math.floor
        if n <= 0x7f then
            return string.char(n)
        elseif n <= 0x7ff then
            return string.char(f(n / 64) + 192, n % 64 + 128)
        elseif n <= 0xffff then
            return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
        elseif n <= 0x10ffff then
            return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                            f(n % 4096 / 64) + 128, n % 64 + 128)
        end
        error(string.format("invalid unicode codepoint '%x'", n))
    end,

    ParseUnicodeEscape = function(s)
        local n1 = tonumber( s:sub(1, 4),  16 )
        local n2 = tonumber( s:sub(7, 10), 16 )

        -- Surrogate pair?
        if n2 then
            return Ryan.JSON.CodePointToUTF8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
        else
            return Ryan.JSON.CodePointToUTF8(n1)
        end
    end,

    ParseString = function(str, i)
        local res = ""
        local j = i + 1
        local k = j

        while j <= #str do
            local x = str:byte(j)

            if x < 32 then
                Ryan.JSON.DecodeError(str, j, "control character in string")
            elseif x == 92 then -- `\`: Escape
                res = res .. str:sub(k, j - 1)
                j = j + 1
                local c = str:sub(j, j)
                if c == "u" then
                    local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                            or str:match("^%x%x%x%x", j + 1)
                            or Ryan.JSON.DecodeError(str, j - 1, "invalid unicode escape in string")
                    res = res .. Ryan.JSON.ParseUnicodeEscape(hex)
                    j = j + #hex
                else
                    if not Ryan.JSON.EscapeCharacters[c] then
                        Ryan.JSON.DecodeError(str, j - 1, "invalid escape char '" .. c .. "' in string")
                    end
                    res = res .. Ryan.JSON.EscapeMapReverse[c]
                end
                k = j + 1
            elseif x == 34 then -- `"`: End of string
                res = res .. str:sub(k, j - 1)
                return res, j + 1
            end

            j = j + 1
        end

        Ryan.JSON.DecodeError(str, i, "expected closing quote for string")
    end,

    ParseNumber = function(str, i)
        local x = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.DelimiterCharacters)
        local s = str:sub(i, x - 1)
        local n = tonumber(s)
        if not n then
            Ryan.JSON.DecodeError(str, i, "invalid number '" .. s .. "'")
        end
        return n, x
    end,

    ParseLiteral = function(str, i)
        local x = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.DelimiterCharacters)
        local word = str:sub(i, x - 1)
        if not Ryan.JSON.Literals[word] then
            Ryan.JSON.DecodeError(str, i, "invalid literal '" .. word .. "'")
        end
        return Ryan.JSON.LiteralMap[word], x
    end,

    ParseArray = function(str, i)
        local res = {}
        local n = 1
        i = i + 1
        while 1 do
            local x
            i = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.SpaceCharacters, true)
    
            if str:sub(i, i) == "]" then
                i = i + 1
                break
            end
    
            x, i = Ryan.JSON.Parse(str, i)
            res[n] = x
            n = n + 1
    
            i = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.SpaceCharacters, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "]" then break end
            if chr ~= "," then Ryan.JSON.DecodeError(str, i, "expected ']' or ','") end
        end
        return res, i
    end,

    ParseObject = function(str, i)
        local res = {}
        i = i + 1
        while 1 do
            local key, val
            i = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.SpaceCharacters, true)

            if str:sub(i, i) == "}" then
                i = i + 1
                break
            end

            if str:sub(i, i) ~= '"' then
                Ryan.JSON.DecodeError(str, i, "expected string for key")
            end
            key, i = Ryan.JSON.Parse(str, i)

            i = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.SpaceCharacters, true)
            if str:sub(i, i) ~= ":" then
                Ryan.JSON.DecodeError(str, i, "expected ':' after key")
            end
            i = Ryan.JSON.NextCharacter(str, i + 1, Ryan.JSON.SpaceCharacters, true)
            
            val, i = Ryan.JSON.Parse(str, i)
            res[key] = val

            i = Ryan.JSON.NextCharacter(str, i, Ryan.JSON.SpaceCharacters, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "}" then break end
            if chr ~= "," then Ryan.JSON.DecodeError(str, i, "expected '}' or ','") end
        end
        return res, i
    end,

    Parse = function(str, idx)
        local chr = str:sub(idx, idx)
        local f = Ryan.JSON.CharacterFunctions[chr]
        if f then
            return f(str, idx)
        end
        Ryan.JSON.DecodeError(str, idx, "unexpected character '" .. chr .. "'")
    end,

    Decode = function(str)
        if type(str) ~= "string" then
              error("expected argument of type string, got " .. type(str))
        end
        local res, idx = Ryan.JSON.Parse(str, Ryan.JSON.NextCharacter(str, 1, Ryan.JSON.SpaceCharacters, true))
        idx = Ryan.JSON.NextCharacter(str, idx, Ryan.JSON.SpaceCharacters, true)
        if idx <= #str then
            Ryan.JSON.DecodeError(str, idx, "trailing garbage")
        end
        return res
    end
}

for from, to in pairs(Ryan.JSON.EscapeMap) do
    Ryan.JSON.EscapeMapReverse[to] = from
end

Ryan.JSON.TypeFunctions["nil"] = Ryan.JSON.EncodeNil
Ryan.JSON.TypeFunctions["table"] = Ryan.JSON.EncodeTable
Ryan.JSON.TypeFunctions["string"] = Ryan.JSON.EncodeString
Ryan.JSON.TypeFunctions["number"] = Ryan.JSON.EncodeNumber

Ryan.JSON.CharacterFunctions['"'] = Ryan.JSON.ParseString
Ryan.JSON.CharacterFunctions["0"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["1"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["2"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["3"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["4"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["5"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["6"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["7"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["8"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["9"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["-"] = Ryan.JSON.ParseNumber
Ryan.JSON.CharacterFunctions["t"] = Ryan.JSON.ParseLiteral
Ryan.JSON.CharacterFunctions["f"] = Ryan.JSON.ParseLiteral
Ryan.JSON.CharacterFunctions["n"] = Ryan.JSON.ParseLiteral
Ryan.JSON.CharacterFunctions["["] = Ryan.JSON.ParseArray
Ryan.JSON.CharacterFunctions["{"] = Ryan.JSON.ParseObject

Ryan.JSON.SpaceCharacters = Ryan.JSON.CreateSet(" ", "\t", "\r", "\n")
Ryan.JSON.DelimiterCharacters = Ryan.JSON.CreateSet(" ", "\t", "\r", "\n", "]", "}", ",")
Ryan.JSON.EscapeCharacters = Ryan.JSON.CreateSet("\\", "/", '"', "b", "f", "n", "r", "t", "u")
Ryan.JSON.Literals = Ryan.JSON.CreateSet("true", "false", "null")