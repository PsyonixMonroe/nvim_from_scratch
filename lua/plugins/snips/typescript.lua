local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

return {
    s("ts", { t(
        "-- ts snippet"
    ) })
}
