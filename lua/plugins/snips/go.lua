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
    -- while
    s("while", fmt([[
for {} {{
    {}
}}]], { i(1, "__COND__"), i(2, "__BODY__") })),

    -- for
    s("for", fmt("{}", c(1, {
        sn(nil, fmt([[
for {}, {} := range {} {{
    {}
}}]], { i(1, "__KEY__"), i(2, "__VALUE__"), i(3, "__ITERABLE__"), i(4, "__BODY__") })),
        sn(nil, fmt([[
for {} := range {} {{
    {}
}}]], { i(1, "__NDX__"), i(2, "__ITERABLE__"), i(3, "__BODY__") })),
    }))),

    -- if
    s("if", fmt("{}", c(1, {
        sn(nil, fmt([[
if {} {{
    {}
}}]], { i(1, "__COND__"), i(2, "__BODY__") })),
        sn(nil, fmt([[
if {} {{
    {}
}} else {{
    {}
}}]], { i(1, "__COND__"), i(2, "__BODY__"), i(3, "__BODY__") })),
        sn(nil, fmt([[
if {} {{
    {}
}} else if ({}) {{
    {}
}} else {{
    {}
}}]], { i(1, "__COND__"), i(2, "__BODY__"), i(3, "__COND__"), i(4, "__BODY__"), i(5, "__BODY__") })),
    }))),

    -- switch
    s("switch", fmt([[
switch {} {{
case {}:
    {}
default:
    {}
}}
    ]], { i(1, "__VAR__"), i(2, "__CASE__"), i(3, "__BODY__"), i(4, "__BODY__") })),

    -- iferr
    s("iferr", fmt("{}", { c(1, {
        sn(nil, fmt([[
if err != nil {{
    {}
}}]], { i(1, "__BODY__") })),
        sn(nil, fmt([[
if {} != nil {{
    {}
}}]], { i(1, "__ERR__"), i(2, "__BODY__") })),
        sn(nil, fmt([[
if err != nil {{
    wrapErr := shared.NewError("{}", err)
    shared.Logger.LogError("{}", wrapErr)
    badRequestError(wrapErr, c)
    return
}}]], { i(1, "__MSG__"), i(2, "__MSG__") })),
        sn(nil, fmt([[
if err != nil {{
    wrapErr := shared.NewError("{}", err)
    shared.Logger.LogError("{}", wrapErr)
    serverError(wrapErr, c)
    return
}}]], { i(1, "__MSG__"), i(2, "__MSG__") })),
    }) })),

    -- log and logf
    s("log", fmt("shared.Logger.Log{}(\"{}\")", { c(1, { t("Info"), t("Warn"), t("Error") }), i(2, "__MSG__") })),
    s("logf",
        fmt("shared.Logger.Log{}f(\"{}\", {})",
            { c(1, { t("Info"), t("Warn"), t("Error") }), i(2, "__MSG__"), i(3, "__ARGS__") })),

    -- func
    s("func", fmt("{}", { c(1, {
        sn(nil, fmt([[
func {}({}) {} {{
    {}
}}]], { i(1, "__FUNCNAME__"), i(2, "__ARGS__"), i(3, "__RETURN__"), i(4, "__BODY__") })),
        sn(nil, fmt([[
func ({}) {}({}) {} {{
    {}
}}]], { i(1, "__OBJ__"), i(2, "__FUNCNAME__"), i(3, "__ARGS__"), i(4, "__RETURN__"), i(5, "__BODY__") })),
    }) })),

    -- struct
    s("struct", fmt([[
type {} struct {{
    {}
}}]], { i(1, "__NAME__"), i(2, "__FIELDS__") })),

    -- class
    s("class", fmt([[
type {} struct {{
    {}
}}]], { i(1, "__NAME__"), i(2, "__FIELDS__") })),

    -- test
    s("test", fmt("{}", { c(1, {
        sn(nil, fmt([[
func Test_{}(t *testing.T) {{
    {}
}}]], { i(1, "__TESTNAME__"), i(2, "__BODY__") })),
        sn(nil, fmt([[
func Test_{}(t *testing.T) {{
    intTestEnabled(t)
    {}
}}]], { i(1, "__TESTNAME__"), i(2, "__BODY__") })),
    }) })),
}
