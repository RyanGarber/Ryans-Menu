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

JSON = {}

-- -- General
JSON.Version = "0.1.2"

JSON.EscapeMap = {
    ["\\"] = "\\",
    ["\""] = "\"",
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
}

JSON.EscapeMapReverse = {
    ["/"] = "/"
}

JSON.Escape = function(c)
    return "\\" .. (JSON.EscapeMap[c] or string.format("u%04x", c:byte()))
end

JSON.LiteralMap = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil
}

JSON.TypeFunctions = {
    ["boolean"] = tostring
}

JSON.CharacterFunctions = {}


-- -- Encode
JSON.EncodeNil = function(val)
    return "null"
end

JSON.EncodeTable = function(val, stack)
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
            table.insert(res, JSON.EncodeValue(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"
    else
        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, JSON.EncodeValue(k, stack) .. ":" .. JSON.EncodeValue(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
    end
end

JSON.EncodeString = function(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', JSON.Escape) .. '"'
end

JSON.EncodeNumber = function(val)
    if val ~= val or val <= -math.huge or val >= math.huge then
        error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
end

JSON.EncodeValue = function(val, stack)
    local t = type(val)
    local f = JSON.TypeFunctions[t]
    if f then
        return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
end

JSON.Encode = function(val)
    return JSON.EncodeValue(val)
end


-- -- Decode
JSON.CreateSet = function(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end

JSON.NextCharacter = function(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end

JSON.DecodeError = function(str, idx, msg)
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
end

JSON.CodePointToUTF8 = function(n)
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
end

JSON.ParseUnicodeEscape = function(s)
    local n1 = tonumber(s:sub(1, 4),  16)
    local n2 = tonumber(s:sub(7, 10), 16)

    if n2 then
        return JSON.CodePointToUTF8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return JSON.CodePointToUTF8(n1)
    end
end

JSON.ParseString = function(str, i)
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
        local x = str:byte(j)

        if x < 32 then
            JSON.DecodeError(str, j, "control character in string")
        elseif x == 92 then -- `\`: Escape
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                        or str:match("^%x%x%x%x", j + 1)
                        or JSON.DecodeError(str, j - 1, "invalid unicode escape in string")
                res = res .. JSON.ParseUnicodeEscape(hex)
                j = j + #hex
            else
                if not JSON.EscapeCharacters[c] then
                    JSON.DecodeError(str, j - 1, "invalid escape char '" .. c .. "' in string")
                end
                res = res .. JSON.EscapeMapReverse[c]
            end
            k = j + 1
        elseif x == 34 then -- `"`: End of string
            res = res .. str:sub(k, j - 1)
            return res, j + 1
        end

        j = j + 1
    end

    JSON.DecodeError(str, i, "expected closing quote for string")
end

JSON.ParseNumber = function(str, i)
    local x = JSON.NextCharacter(str, i, JSON.DelimiterCharacters)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        JSON.DecodeError(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
end

JSON.ParseLiteral = function(str, i)
    local x = JSON.NextCharacter(str, i, JSON.DelimiterCharacters)
    local word = str:sub(i, x - 1)
    if not JSON.Literals[word] then
        JSON.DecodeError(str, i, "invalid literal '" .. word .. "'")
    end
    return JSON.LiteralMap[word], x
end

JSON.ParseArray = function(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = JSON.NextCharacter(str, i, JSON.SpaceCharacters, true)

        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end

        x, i = JSON.Parse(str, i)
        res[n] = x
        n = n + 1

        i = JSON.NextCharacter(str, i, JSON.SpaceCharacters, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then break end
        if chr ~= "," then JSON.DecodeError(str, i, "expected ']' or ','") end
    end
    return res, i
end

JSON.ParseObject = function(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = JSON.NextCharacter(str, i, JSON.SpaceCharacters, true)

        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end

        if str:sub(i, i) ~= '"' then
            JSON.DecodeError(str, i, "expected string for key")
        end
        key, i = JSON.Parse(str, i)

        i = JSON.NextCharacter(str, i, JSON.SpaceCharacters, true)
        if str:sub(i, i) ~= ":" then
            JSON.DecodeError(str, i, "expected ':' after key")
        end
        i = JSON.NextCharacter(str, i + 1, JSON.SpaceCharacters, true)
        
        val, i = JSON.Parse(str, i)
        res[key] = val

        i = JSON.NextCharacter(str, i, JSON.SpaceCharacters, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then break end
        if chr ~= "," then JSON.DecodeError(str, i, "expected '}' or ','") end
    end
    return res, i
end

JSON.Parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = JSON.CharacterFunctions[chr]
    if f then
        return f(str, idx)
    end
    JSON.DecodeError(str, idx, "unexpected character '" .. chr .. "'")
end

JSON.Decode = function(str)
    if type(str) ~= "string" then
            error("expected argument of type string, got " .. type(str))
    end
    local res, idx = JSON.Parse(str, JSON.NextCharacter(str, 1, JSON.SpaceCharacters, true))
    idx = JSON.NextCharacter(str, idx, JSON.SpaceCharacters, true)
    if idx <= #str then
        JSON.DecodeError(str, idx, "trailing garbage")
    end
    return res
end

for from, to in pairs(JSON.EscapeMap) do
    JSON.EscapeMapReverse[to] = from
end

JSON.TypeFunctions["nil"] = JSON.EncodeNil
JSON.TypeFunctions["table"] = JSON.EncodeTable
JSON.TypeFunctions["string"] = JSON.EncodeString
JSON.TypeFunctions["number"] = JSON.EncodeNumber

JSON.CharacterFunctions['"'] = JSON.ParseString
JSON.CharacterFunctions["0"] = JSON.ParseNumber
JSON.CharacterFunctions["1"] = JSON.ParseNumber
JSON.CharacterFunctions["2"] = JSON.ParseNumber
JSON.CharacterFunctions["3"] = JSON.ParseNumber
JSON.CharacterFunctions["4"] = JSON.ParseNumber
JSON.CharacterFunctions["5"] = JSON.ParseNumber
JSON.CharacterFunctions["6"] = JSON.ParseNumber
JSON.CharacterFunctions["7"] = JSON.ParseNumber
JSON.CharacterFunctions["8"] = JSON.ParseNumber
JSON.CharacterFunctions["9"] = JSON.ParseNumber
JSON.CharacterFunctions["-"] = JSON.ParseNumber
JSON.CharacterFunctions["t"] = JSON.ParseLiteral
JSON.CharacterFunctions["f"] = JSON.ParseLiteral
JSON.CharacterFunctions["n"] = JSON.ParseLiteral
JSON.CharacterFunctions["["] = JSON.ParseArray
JSON.CharacterFunctions["{"] = JSON.ParseObject

JSON.SpaceCharacters = JSON.CreateSet(" ", "\t", "\r", "\n")
JSON.DelimiterCharacters = JSON.CreateSet(" ", "\t", "\r", "\n", "]", "}", ",")
JSON.EscapeCharacters = JSON.CreateSet("\\", "/", '"', "b", "f", "n", "r", "t", "u")
JSON.Literals = JSON.CreateSet("true", "false", "null")