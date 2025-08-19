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
    s("import", fmt("local {} = require('{}')", { i(1, "default"), rep(1) })),
    s("func", fmt("local {} = function()\n    {}\nend", { i(1, "func_name"), i(2, "body") })),
    s("funcm", fmt("{}.{} = function()\n    {}\nend", { i(1, "obj"), i(2, "func_name"), i(3, "body") })),
    s("for", fmt("", {})),
    s("forarr", fmt("", {})),
    s("foreach", fmt("", {})),
    s("if", fmt("", {})),
    s("log",
        fmt("vim.notify(\"{}\"{})",
            { i(1, "message"), c(2, { t(""), t(', vim.log.levels.WARN'), t(', vim.log.levels.ERROR') }) })),
    s("struct", fmt("local {} = {{\n    {}\n}}", { i(1, "name"), i(2, "body") })),
    s("class", fmt("local {} = {{\n    {}\n}}", { i(1, "name"), i(2, "body") })),
    s("doc", fmt("---", {})),
    --s("test", fmt("", {})),
}
