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
    -- func
    s("func", fmt([[
/**
 * @param __type__ __name__ __desc__
 * @throws __ExceptionType__ __desc__
 * @return
 */
public function {}({}):{}
{{
    {}
}}]], { i(1, "__FunctionName__"), i(2, "__Params__"), i(3, "__ReturnType__"), i(4, "__Body__") })),

    -- for
    s("for", fmt([[
foreach({} as {})
{{
    {}
}}]], { i(1, "__array__"), i(2, "__value__"), i(3, "__body__") })),

    -- while
    s("while", fmt([[
while ({})
{{
    {}
}}]], { i(1, "__cond__"), i(2, "__body__") })),

    -- if
    s("if", fmt("{}", { c(1, {
        sn(nil, fmt([[
    if ({})
    {{
        {}
    }}]], { i(1, "__cond__"), i(2, "__body__") })),
        sn(nil, fmt([[
    if ({})
    {{
        {}
    }}
    else
    {{
        {}
    }}]], { i(1, "__cond__"), i(2, "__body__"), i(3, "__body__") })),
        sn(nil, fmt([[
    if ({})
    {{
        {}
    }}
    else if ({})
    {{
        {}
    }}
    else
    {{
        {}
    }}]], { i(1, "__cond__"), i(2, "__body__"), i(3, "__cond__"), i(4, "__body__"), i(5, "__body__") })),
    }) })),

    -- switch
    s("switch", fmt([[
switch ({})
{{
    case {}:
        {}
    default:
        {}
}}
    ]], { i(1, "__var__"), i(2, "__case__"), i(3, "__body__"), i(4, "__body__") })),

    -- log
    s("log",
        fmt([[SystemLogger::Log({}, "{}");]],
            { c(1, { t("LOG_INFO"), t("LOG_WARNING"), t("LOG_ERR"), t("LOG_DEBUG") }), i(2, "__message__") })),

    -- struct/class
    s("struct", fmt([[
<?php

class {}
{{
    {}
}}]], { i(1, "__ClassName__"), i(2, "__Body__") })),
    s("class", fmt([[
<?php

class {}
{{
    {}
}}]], { i(1, "__ClassName__"), i(2, "__Body__") })),

    -- test
    s("test", fmt([[
<?php

namespace PsyNet\Tests\{};

use PhpUnit\Frameword\TestCase;

class {}Test extends TestCase
{{
    public static function setUpBeforeClass(): void
    {{

    }}

    public static function tearDownAfterClass(): void
    {{

    }}

    /**
     * @test
     */
    public function Test{}()
    {{
        {}
    }}
}}]], { i(1, "__Package__"), i(2, "__ClassName__"), i(3, "__Name__"), i(4, "__TestBody__") })),

    -- service
    s("service", fmt([[
<?php

namespace PsyNet\Services\{};

use PsyNet\Services\Service;

class {}Service extends Service
{{
    public function Execute({}Request $Params): {}Response
    {{
        {}
    }}
}}]], { i(1, "__package__"), i(2, "__classname__"), i(3, "__Service__"), i(4, "__Service__"), i(5, "__body__") })),

    -- request
    s("request", fmt([[
<?php

namespace PsyNet\Services\{}\Models;

use PsyNet\Services\ServiceRequestModel;

class {}Request extends ServiceRequestModel
{{
    {}
}}]], { i(1, "__package__"), i(2, "__ClassName__"), i(3, "__body__") })),

    -- response
    s("response", fmt([[
<?php

namespace PsyNet\Services\{}\Models;

use PsyNet\Services\ServiceResponseModel;

class {}Response extends ServiceResponseModel
{{
    {}
}}]], { i(1, "__package__"), i(2, "__ClassName__"), i(3, "__body__") })),

    -- perms
    s("perms", fmt("{}", { c(1, {
        sn(nil, fmt([[
public function GetPermissions(): string
{{
    return UserPermissions::{};
}}]], { i(1, "__PERMS__") })),
        sn(nil, fmt([[
public function GetPermissionsInternal(): string
{{
    return UserPermissions::{};
}}]], { i(1, "__PERMS__") })),
        sn(nil, fmt([[
/**
  * @return string[]
  */
public function GetPermissions(): array
{{
    return [ UserPermissions::{} ];
}}]], { i(1, "__PERMS__") })),
        sn(nil, fmt([[
/**
  * @return string[]
  */
public function GetPermissionsInternal(): array
{{
    return [ UserPermissions::{} ];
}}]], { i(1, "__PERMS__") })),
    }) })),

    -- internal
    s("internal", fmt([[
public function IsInternal()
{{
    return true;
}}]], {})),

    -- validation
    s("validation", { t([[
protected function ValidationRules(): array
{{
    return [
        'required' => [ '__field__' ],
        'optional' => [ '__field__' ],
        'array' => [ '__field__' ],
        'integer' => [ '__field__' ],
        'numeric' => [ '__field_-' ],
        'positive_number' => [ '__field__' ],
        'string' => [ '__field__' ],
        'boolean' => [ '__field__' ],
        'uuid' => [ '__field__' ],
    ]
}}]]) }),
}
