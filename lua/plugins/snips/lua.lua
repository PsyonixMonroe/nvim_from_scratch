local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local c = ls.choice_node
local sn = ls.snippet_node

return {

    -- import
    s("import", fmt("local {} = require('{}')", { i(1, "__default__"), rep(1) })),

    -- func
    s("func", fmt("{}", c(1, {
        fmt("local {} = function()\n    {}\nend", { i(1, "__func_name__"), i(2, "__body__") }),
        fmt("{}.{} = function()\n    {}\nend", { i(1, "__obj__"), i(2, "__func_name__"), i(3, "__body__") }),
    }))),

    -- for
    s("for",
        fmt("{}",
            { c(1,
                { sn(nil,
                    fmt("for {},{} in pairs({}) do\n    {}\nend",
                        { i(1, "__key__"), i(2, "__value__"), i(3, "__table__"), i(4, "__body__") })
                ),
                    sn(nil,
                        fmt("for {},{} in ipairs({}) do\n    {}\nend",
                            { i(1, "__index__"), i(2, "__value__"), i(3, "__table__"), i(4, "__body__") })
                    )
                }
            )
            })
    ),

    -- while
    s("while", fmt("while({}) do\n    {}\nend", { i(1, "__cond__"), i(2, "__body__") })),

    -- if
    s("if", fmt("{}", {
        c(1, {
            -- if
            sn(nil, fmt("if {} then\n    {}\nend", { i(1, "__cond__"), i(2, "__body__") })),
            -- if else
            sn(nil,
                fmt("if {} then\n    {}\nelse\n    {}\nend", { i(1, "__cond__"), i(2, "__body__"), i(3, "__body__") })),
            -- if elseif else
            sn(nil,
                fmt([[
                if {} then
                    {}
                elseif {} then
                    {}
                else
                    {}
                end]],
                    { i(1, "__cond__"), i(2, "__body__"), i(3, "__cond__"), i(4, "__body__"), i(5, "__body__") })),
        })
    })),

    -- log
    s("log",
        fmt("vim.notify(\"{}\"{})",
            { i(1, "__message__"), c(2, { t(""), t(', vim.log.levels.WARN'), t(', vim.log.levels.ERROR') }) })),

    -- struct/class
    s("struct", fmt("local {} = {{\n    {}\n}}", { i(1, "__name__"), i(2, "__body__") })),
    s("class", fmt("local {} = {{\n    {}\n}}", { i(1, "__name__"), i(2, "__body__") })),

    -- doc
    s("doc", fmt("{}", { c(1, {
        sn(nil, fmt([[
---@class
---@field __name__ __type__: __desc__
]], {})),
        sn(nil, fmt([[
---@param
]], {})),
    }) })),

    s("plugin", fmt([[
return {{
    {{
        "{}",
        dependencies = {{

        }},
        opts = {{
            {}
        }},
        config = function()
            {}
        end,
    }}
}}
    ]], { i(1, "__plugin__"), i(2, "__opts__"), i(3, "__config__") })),
}
